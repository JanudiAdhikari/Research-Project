import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class IotBleService {
  static const String deviceName = "Ceylon-Pepper-Sensor";
  static const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  BluetoothDevice? _targetDevice;
  BluetoothCharacteristic? _targetCharacteristic;
  StreamSubscription<List<int>>? _valueSubscription;
  
  final _moistureController = StreamController<double>.broadcast();
  Stream<double> get moistureStream => _moistureController.stream;

  final _connectionStatusController = StreamController<String>.broadcast();
  Stream<String> get connectionStatusStream => _connectionStatusController.stream;

  bool _isConnecting = false;

  Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
      
      return statuses[Permission.bluetoothScan]!.isGranted &&
             statuses[Permission.bluetoothConnect]!.isGranted &&
             statuses[Permission.location]!.isGranted;
    }
    return true; // iOS handles this differently or permissions are granted at different levels
  }

  Future<void> startConnecting() async {
    if (_isConnecting) return;
    _isConnecting = true;
    _targetDevice = null;
    
    _connectionStatusController.add("Checking permissions...");
    bool permissionsGranted = await _checkPermissions();
    if (!permissionsGranted) {
      _connectionStatusController.add("Permissions denied");
      _isConnecting = false;
      return;
    }

    // Check if Bluetooth is on
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      _connectionStatusController.add("Bluetooth is OFF");
      _isConnecting = false;
      return;
    }

    _connectionStatusController.add("Scanning...");

    // 1. Start scanning for specific Service UUID
    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid(serviceUuid)],
        timeout: const Duration(seconds: 15),
      );
    } catch (e) {
      print("Scan Error: $e");
      _connectionStatusController.add("Scan failed");
      _isConnecting = false;
      return;
    }

    // 2. Listen to scan results
    var subscription = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        // Find by name or if it has our service
        if (r.device.platformName == deviceName || r.advertisementData.serviceUuids.contains(Guid(serviceUuid))) {
          _targetDevice = r.device;
          await FlutterBluePlus.stopScan();
          _connectToDevice();
          break;
        }
      }
    });

    // Clean up scan subscription after timeout
    Future.delayed(const Duration(seconds: 15), () {
      subscription.cancel();
      if (_targetDevice == null && _isConnecting) {
        _isConnecting = false;
        _connectionStatusController.add("Device not found");
      }
    });
  }

  Future<void> _connectToDevice() async {
    if (_targetDevice == null) return;

    try {
      _connectionStatusController.add("Connecting...");
      await _targetDevice!.connect(timeout: const Duration(seconds: 10));
      
      _connectionStatusController.add("Discovering Services...");
      List<BluetoothService> services = await _targetDevice!.discoverServices();
      
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == characteristicUuid.toLowerCase()) {
              _targetCharacteristic = characteristic;
              _subscribeToChanges();
              _connectionStatusController.add("Connected");
              _isConnecting = false;
              break;
            }
          }
        }
      }
      
      if (_targetCharacteristic == null) {
        _connectionStatusController.add("Service not found");
        _isConnecting = false;
      }
    } catch (e) {
      print("BLE Connection Error: $e");
      _connectionStatusController.add("Connection failed");
      _isConnecting = false;
    }
  }

  void _subscribeToChanges() async {
    if (_targetCharacteristic == null) return;

    try {
      await _targetCharacteristic!.setNotifyValue(true);
      _valueSubscription = _targetCharacteristic!.lastValueStream.listen((value) {
        if (value.isNotEmpty) {
          String stringValue = String.fromCharCodes(value);
          double? moisture = double.tryParse(stringValue);
          if (moisture != null) {
            _moistureController.add(moisture);
          }
        }
      });
    } catch (e) {
      print("Subscription Error: $e");
    }
  }

  Future<void> disconnect() async {
    await _valueSubscription?.cancel();
    await _targetDevice?.disconnect();
    _targetDevice = null;
    _targetCharacteristic = null;
    _isConnecting = false;
    _connectionStatusController.add("Disconnected");
  }

  void dispose() {
    _moistureController.close();
    _connectionStatusController.close();
    disconnect();
  }
}
