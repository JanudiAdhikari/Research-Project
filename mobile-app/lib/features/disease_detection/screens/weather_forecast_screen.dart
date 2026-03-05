import 'package:flutter/material.dart';
import '../../../services/weather_service.dart';
import '../../../utils/localization.dart';
import '../../../utils/language_prefs.dart';
import 'package:geolocator/geolocator.dart';

Color _withOpacity(Color c, double opacity) {
  final alpha = (opacity * 255).round().clamp(0, 255);
  return c.withAlpha(alpha);
}

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _currentLanguage = 'en';
  Future<WeatherData>? _weatherFuture;
  double _latitude = 6.9271; // Default: Colombo, Sri Lanka
  double _longitude = 80.7789;
  String _currentLocation = 'Fetching location...';
  bool _isLoadingLocation = false;

  static const Color primary = Color(0xFF2E7D32);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFE74C3C);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    LanguagePrefs.getLanguage().then((lang) {
      if (mounted) setState(() => _currentLanguage = lang);
    });

    // Initialize weather data immediately with default location
    _weatherFuture = WeatherService.fetchWeatherData(
      latitude: _latitude,
      longitude: _longitude,
    );

    _getCurrentLocation();
    _animationController.forward();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoadingLocation = true);

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _currentLocation = 'Lat: ${position.latitude.toStringAsFixed(2)}, '
              'Lon: ${position.longitude.toStringAsFixed(2)}';
          _isLoadingLocation = false;
        });

        _loadWeatherData();
      } else {
        setState(() {
          _isLoadingLocation = false;
          _currentLocation = 'Location permission denied';
          // Set default location (Colombo, Sri Lanka)
          _latitude = 6.9271;
          _longitude = 80.7789;
        });
        // Load default location if permission denied
        _loadWeatherData();
      }
    } catch (e) {
      print('Location error: $e');
      setState(() {
        _isLoadingLocation = false;
        _currentLocation = 'Unable to get location';
        // Set default location (Colombo, Sri Lanka)
        _latitude = 6.9271;
        _longitude = 80.7789;
      });
      _loadWeatherData();
    }
  }

  void _loadWeatherData() {
    setState(() {
      _weatherFuture = WeatherService.fetchWeatherData(
        latitude: _latitude,
        longitude: _longitude,
      );
    });
  }

  Future<void> _searchLocation(String cityName) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Searching location...'),
          duration: Duration(seconds: 1),
        ),
      );

      final coords = await WeatherService.searchLocation(cityName);
      setState(() {
        _latitude = coords['latitude']!;
        _longitude = coords['longitude']!;
        _currentLocation = cityName;
      });

      _loadWeatherData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded weather for $cityName'),
            backgroundColor: successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: errorColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showLocationDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_translate('search_location')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: _translate('enter_city_name'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _searchLocation(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(_translate('search')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return errorColor;
      case 'normal':
        return successColor;
      case 'low':
        return warningColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(IconType iconType) {
    switch (iconType) {
      case IconType.humidity:
        return Icons.opacity_rounded;
      case IconType.temperature:
        return Icons.device_thermostat_rounded;
      case IconType.rainfall:
        return Icons.cloud_queue_rounded;
      case IconType.warning:
        return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _translate('weather_forecast_title'),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            Text(
              _currentLocation,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: _showLocationDialog,
            tooltip: _translate('search_location'),
          ),
          IconButton(
            icon: const Icon(Icons.gps_fixed_rounded, color: Colors.white),
            onPressed: _isLoadingLocation ? null : _getCurrentLocation,
            tooltip: _translate('use_current_location'),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _weatherFuture = WeatherService.fetchWeatherData(
                latitude: _latitude,
                longitude: _longitude,
              );
            });
          },
          child: FutureBuilder<WeatherData>(
            future: _weatherFuture,
            builder: (context, snapshot) {
              if (_weatherFuture == null || snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _translate('loading_weather'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _translate('weather_error'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _translate('loading_weather'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final weather = snapshot.data!;
              final notifications = WeatherService.getNotifications(
                humidity: weather.humidity,
                temperature: weather.temperature,
                rainfall: weather.rainfall,
                consecutiveRainyDays: weather.consecutiveRainyDays,
              );

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Current weather conditions
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildCurrentWeatherCard(weather),
                      ),

                      const SizedBox(height: 24),

                      // Section title - Alerts & Notifications
                      _buildSectionTitle(
                        _translate('weather_alerts'),
                        Icons.notifications_active_rounded,
                      ),

                      const SizedBox(height: 14),

                      // Notifications list
                      if (notifications.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _withOpacity(Colors.black, 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 48,
                                color: successColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _translate('all_conditions_normal'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...notifications
                            .map((n) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildNotificationCard(n),
                                ))
                            .toList(),

                      const SizedBox(height: 24),

                      // Section title - Past 7 days
                      _buildSectionTitle(
                        _translate('past_7_days'),
                        Icons.calendar_today_rounded,
                      ),

                      const SizedBox(height: 14),

                      // Past 7 days data
                      _buildPast7DaysChart(weather.past7Days),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(WeatherData weather) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FAF8), Color(0xFFEFF2EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _withOpacity(Colors.black, 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location and description
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.location,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.description.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Main temperature display
              Column(
                children: [
                  Text(
                    '${weather.temperature.toStringAsFixed(0)}°',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Feels like ${weather.feelsLike.toStringAsFixed(1)}°',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weather metrics in a grid
          Row(
            children: [
              Expanded(
                child: _buildWeatherMetric(
                  icon: Icons.opacity_rounded,
                  label: _translate('humidity'),
                  value: '${weather.humidity.toStringAsFixed(1)}%',
                  bgColor: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWeatherMetric(
                  icon: Icons.device_thermostat_rounded,
                  label: _translate('temperature'),
                  value: '${weather.temperature.toStringAsFixed(1)}°C',
                  bgColor: const Color(0xFFFFE0B2),
                  iconColor: const Color(0xFFE65100),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWeatherMetric(
                  icon: Icons.cloud_queue_rounded,
                  label: _translate('rainfall'),
                  value: '${weather.rainfall.toStringAsFixed(1)}mm',
                  bgColor: const Color(0xFFC8E6C9),
                  iconColor: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Additional details
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  icon: Icons.speed_rounded,
                  label: 'Wind',
                  value: '${weather.windSpeed} m/s',
                ),
                _buildDetailItem(
                  icon: Icons.compress_rounded,
                  label: 'Pressure',
                  value: '${weather.pressure} hPa',
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Last updated
          Text(
            _translate('last_updated') +
                ': ${weather.timestamp.hour.toString().padLeft(2, '0')}:${weather.timestamp.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(WeatherNotification notification) {
    final severityColor = _getSeverityColor(notification.severity);
    final icon = _getNotificationIcon(notification.iconType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _withOpacity(severityColor, 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _withOpacity(Colors.black, 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _withOpacity(severityColor, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: severityColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: severityColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPast7DaysChart(List<WeatherEntry> entries) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _withOpacity(Colors.black, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs for different metrics
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: entries.map((entry) {
                final dayName = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    [entry.date.weekday % 7];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildDayColumn(entry, dayName),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(WeatherEntry entry, String dayName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildMiniMetric(
            icon: Icons.opacity_rounded,
            value: '${entry.humidity.toStringAsFixed(0)}%',
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(height: 6),
          _buildMiniMetric(
            icon: Icons.device_thermostat_rounded,
            value: '${entry.temperature.toStringAsFixed(0)}°',
            color: const Color(0xFFE65100),
          ),
          const SizedBox(height: 6),
          _buildMiniMetric(
            icon: Icons.cloud_queue_rounded,
            value: '${entry.rainfall.toStringAsFixed(1)}mm',
            color: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        Icon(icon, color: primary, size: 22),
      ],
    );
  }

  String _translate(String key) =>
      AppLocalizations.translate(_currentLanguage, key);
}

