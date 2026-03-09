import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../services/blockchain_service.dart';
import '../widgets/blockchain_widgets.dart';

class ViewBlockchainScreen extends StatefulWidget {
  final Map<String, dynamic> record;

  const ViewBlockchainScreen({super.key, required this.record});

  @override
  State<ViewBlockchainScreen> createState() => _ViewBlockchainScreenState();
}

class _ViewBlockchainScreenState extends State<ViewBlockchainScreen> {
  bool _loadingQc = true;
  bool _downloadingPdf = false;
  String? _qcError;
  Map<String, dynamic>? _qc;

  String _safe(dynamic v, [String fallback = '-']) {
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  String _normalizeStatus(dynamic s) {
    if (s == null) return '';
    return s
        .toString()
        .trim()
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .toUpperCase();
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;

    if (v is Map && v[r'$date'] != null) {
      return DateTime.tryParse(v[r'$date'].toString());
    }

    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  String _formatDateOnly(dynamic v) {
    final dt = _parseDate(v);
    if (dt == null) return _safe(v);

    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }

  double? _safeDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  String _formatNumber(dynamic v) {
    final n = _safeDouble(v);
    if (n == null) return _safe(v);
    final isInt = (n - n.roundToDouble()).abs() < 0.000001;
    return isInt ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
  }

  String _prettyStatus(String raw) {
    switch (raw.toUpperCase()) {
      case 'BATCH_CREATED':
        return 'Batch Created';
      case 'MARKETPLACE_LISTED':
        return 'Listed in Marketplace';
      case 'VERIFIED':
        return 'Verified by Admin';
      case 'QR_GENERATED':
        return 'QR Generated';
      case 'RECEIVED':
        return 'Received by Exporter';
      default:
        return raw.isEmpty ? 'Unknown' : raw;
    }
  }

  IconData _statusIcon(String raw) {
    switch (raw.toUpperCase()) {
      case 'BATCH_CREATED':
        return Icons.add_box_rounded;
      case 'MARKETPLACE_LISTED':
        return Icons.storefront_rounded;
      case 'VERIFIED':
        return Icons.verified_rounded;
      case 'QR_GENERATED':
        return Icons.qr_code_2_rounded;
      case 'RECEIVED':
        return Icons.local_shipping_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _statusColor(String raw) {
    switch (raw.toUpperCase()) {
      case 'BATCH_CREATED':
        return Colors.blue;
      case 'MARKETPLACE_LISTED':
        return Colors.deepPurple;
      case 'VERIFIED':
        return Colors.green;
      case 'QR_GENERATED':
        return const Color(0xFF2E7D32);
      case 'RECEIVED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _prettyRole(dynamic role) {
    final r = _safe(role, 'UNKNOWN').toUpperCase();
    switch (r) {
      case 'FARMER':
        return 'Farmer';
      case 'ADMIN':
        return 'Admin';
      case 'EXPORTER':
        return 'Exporter';
      default:
        final lower = r.toLowerCase();
        return lower.isEmpty
            ? 'Unknown'
            : '${lower[0].toUpperCase()}${lower.substring(1)}';
    }
  }

  String _prettyFactorKey(String key) {
    final s = key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    return s
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Color _factorColor(String key) {
    final k = key.toLowerCase();
    if (k.contains('density')) return Colors.green;
    if (k.contains('adulter')) return Colors.teal;
    if (k.contains('mold')) return Colors.purple;
    if (k.contains('extraneous')) return Colors.orange;
    if (k.contains('broken')) return Colors.indigo;
    if (k.contains('variety') || k.contains('piperine')) return Colors.blue;
    if (k.contains('healthy')) return Colors.lightBlue;
    if (k.contains('cert')) return Colors.green.shade700;
    return Colors.blueGrey;
  }

  List<Map<String, dynamic>> _sortedHistory(dynamic historyRaw) {
    final history = (historyRaw is List)
        ? historyRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList()
        : <Map<String, dynamic>>[];

    history.sort((a, b) {
      final ia = (a['index'] is num) ? (a['index'] as num).toInt() : 0;
      final ib = (b['index'] is num) ? (b['index'] as num).toInt() : 0;
      return ia.compareTo(ib);
    });

    return history;
  }

  void _showQrPopup({
    required String qrToken,
    required String batchId,
    required String qrGeneratedOn,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Batch QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Batch ID: $batchId',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: QrImageView(data: qrToken, size: 240),
              ),
              const SizedBox(height: 14),
              Text(
                'Generated on: $qrGeneratedOn',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Close'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPdf() async {
    setState(() => _downloadingPdf = true);

    try {
      final record = widget.record;

      final batchId = _safe(record['batchId'], _safe(record['_id']));
      final pepperType = _safe(record['pepperType']);
      final district = _safe(record['district']);
      final price = _formatNumber(record['pricePerKg']);
      final qty = _formatNumber(record['quantity']);
      final notes = _safe(record['notes'], 'No notes');

      final statusRaw = _normalizeStatus(record['currentStatus']);
      final statusPretty = _prettyStatus(statusRaw);

      final qrToken = _safe(record['qrToken'], '');
      final qrGeneratedOn = _formatDateOnly(record['qrGeneratedAt']);

      final history = _sortedHistory(record['statusHistory']);

      final harvestDate = _qc?['batch']?['harvestDate'];
      final harvestedOn = harvestDate != null
          ? _formatDateOnly(harvestDate)
          : '-';

      final qcStatus = _safe(_qc?['status'], '-');
      final qcGrade = _safe(_qc?['results']?['grade'], '-');
      final qcScore = _formatNumber(_qc?['results']?['overallScore']);
      final dryingMethod = _safe(_qc?['batch']?['dryingMethod'], '-');
      final pepperVariety = _safe(_qc?['batch']?['pepperVariety'], '-');
      final densityValue = _formatNumber(_qc?['density']?['value']);
      final densitySource = _safe(_qc?['density']?['source'], '-');
      final densityMeasuredOn = _formatDateOnly(_qc?['density']?['measuredAt']);

      final certCount = (_qc?['certificatesSnapshot']?['count'] is num)
          ? (_qc?['certificatesSnapshot']?['count'] as num).toInt()
          : 0;

      final factorScoresRaw = _qc?['results']?['factorScores'];
      final Map<String, dynamic> factorScores = (factorScoresRaw is Map)
          ? Map<String, dynamic>.from(factorScoresRaw)
          : {};

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColors.green100,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Pepper Batch Report',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Batch ID: $batchId'),
                        pw.Text('Current Status: $statusPretty'),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green700,
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(
                      statusPretty,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            _pdfSectionTitle('Batch Details'),
            _pdfInfoTable([
              ['Pepper Type', pepperType],
              ['District', district],
              ['Price / kg', price],
              ['Quantity', '$qty kg'],
              ['Additional Notes', notes],
            ]),
            pw.SizedBox(height: 16),
            _pdfSectionTitle('Quality Details'),
            _pdfInfoTable([
              ['Harvest Date', harvestedOn],
              ['QC Status', qcStatus],
              ['Grade', qcGrade],
              ['Overall Score', qcScore],
              ['Pepper Variety', pepperVariety],
              ['Drying Method', dryingMethod],
              ['Density', '$densityValue g/L'],
              ['Density Source', densitySource],
              ['Measured On', densityMeasuredOn],
              ['Certificates', certCount.toString()],
            ]),
            if (factorScores.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              _pdfSectionTitle('Factor Scores'),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _pdfTableCell('Factor', isHeader: true),
                      _pdfTableCell('Score', isHeader: true),
                    ],
                  ),
                  ...factorScores.entries.map((e) {
                    final score = (_safeDouble(e.value) ?? 0)
                        .clamp(0, 100)
                        .toDouble();
                    return pw.TableRow(
                      children: [
                        _pdfTableCell(_prettyFactorKey(e.key)),
                        _pdfTableCell(
                          score % 1 == 0
                              ? score.toInt().toString()
                              : score.toStringAsFixed(1),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
            pw.SizedBox(height: 16),
            _pdfSectionTitle('QR Details'),
            _pdfInfoTable([
              ['QR Token', qrToken.isEmpty ? 'Not available' : qrToken],
              ['Generated On', qrGeneratedOn],
            ]),
            pw.SizedBox(height: 16),
            _pdfSectionTitle('Blockchain History'),
            if (history.isEmpty && harvestedOn == '-')
              pw.Text('No history found.')
            else
              pw.Column(
                children: [
                  if (harvestedOn != '-')
                    _pdfHistoryRow('Harvested', harvestedOn, 'Farmer'),
                  ...history.map((block) {
                    final stRaw = _normalizeStatus(block['status']);
                    final title = _prettyStatus(stRaw);
                    final date = _formatDateOnly(block['timestamp']);
                    final role = _prettyRole(block['actorRole']);
                    return _pdfHistoryRow(title, date, role);
                  }),
                ],
              ),
          ],
        ),
      );

      final Uint8List bytes = await pdf.save();

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(
            pdfBytes: bytes,
            fileName: 'batch_report_$batchId.pdf',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('PDF Error'),
            ],
          ),
          content: Text(
            'Failed to generate the PDF.\n\n$e',
            style: const TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _downloadingPdf = false);
      }
    }
  }

  pw.Widget _pdfSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.green800,
        ),
      ),
    );
  }

  pw.Widget _pdfInfoTable(List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.2),
        1: const pw.FlexColumnWidth(3.8),
      },
      children: rows
          .map(
            (row) => pw.TableRow(
              children: [
                _pdfTableCell(row[0], isHeader: true),
                _pdfTableCell(row[1]),
              ],
            ),
          )
          .toList(),
    );
  }

  pw.Widget _pdfTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _pdfHistoryRow(String title, String date, String role) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text('On: $date'),
          pw.Text('By: $role'),
        ],
      ),
    );
  }

  Widget _factorList(Map<String, dynamic> factorScores) {
    final entries = factorScores.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      children: entries.map((e) {
        final label = _prettyFactorKey(e.key);
        final score = (_safeDouble(e.value) ?? 0).clamp(0, 100).toDouble();
        final color = _factorColor(e.key);

        return factorScoreItemWidget(label: label, score: score, color: color);
      }).toList(),
    );
  }

  Widget _historySection(
    List<Map<String, dynamic>> history,
    String? harvestedOn,
  ) {
    if (history.isEmpty && harvestedOn == null) {
      return Text(
        'No history found.',
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Column(
      children: [
        if (harvestedOn != null)
          timelineItemWidget(
            isLast: history.isEmpty,
            title: 'Harvested',
            date: harvestedOn,
            role: 'By: ${_prettyRole('FARMER')}',
            icon: Icons.agriculture_rounded,
            iconColor: const Color(0xFF2E7D32),
          ),
        ...List.generate(history.length, (i) {
          final block = history[i];
          final stRaw = _normalizeStatus(block['status']);
          final title = _prettyStatus(stRaw);
          final date = _formatDateOnly(block['timestamp']);
          final role = 'By: ${_prettyRole(block['actorRole'])}';
          final icon = _statusIcon(stRaw);
          final iconColor = _statusColor(stRaw);

          final total = history.length + (harvestedOn != null ? 1 : 0);
          final currentIndex = i + (harvestedOn != null ? 1 : 0);
          final isLast = currentIndex == total - 1;

          return timelineItemWidget(
            isLast: isLast,
            title: title,
            date: date,
            role: role,
            icon: icon,
            iconColor: iconColor,
          );
        }),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchQuality();
  }

  Future<void> _fetchQuality() async {
    setState(() {
      _loadingQc = true;
      _qcError = null;
      _qc = null;
    });

    try {
      final batchId = widget.record['batchId']?.toString();
      if (batchId == null || batchId.trim().isEmpty) {
        setState(() => _loadingQc = false);
        return;
      }

      final list = await BlockchainService.getQualityChecksByBatch(batchId);
      if (list.isEmpty) {
        setState(() => _loadingQc = false);
        return;
      }

      list.sort((a, b) {
        DateTime? da =
            _parseDate(a['results']?['processedAt']) ??
            _parseDate(a['updatedAt']) ??
            _parseDate(a['createdAt']);
        DateTime? db =
            _parseDate(b['results']?['processedAt']) ??
            _parseDate(b['updatedAt']) ??
            _parseDate(b['createdAt']);
        return (db ?? DateTime(1970)).compareTo(da ?? DateTime(1970));
      });

      setState(() {
        _qc = list.first;
        _loadingQc = false;
      });
    } catch (e) {
      setState(() {
        _qcError = e.toString();
        _loadingQc = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;

    final batchId = _safe(record['batchId'], _safe(record['_id']));
    final pepperType = _safe(record['pepperType']);
    final district = _safe(record['district']);
    final price = _formatNumber(record['pricePerKg']);
    final qty = _formatNumber(record['quantity']);
    final notes = _safe(record['notes'], 'No notes');

    final statusRaw = _normalizeStatus(record['currentStatus']);
    final statusPretty = _prettyStatus(statusRaw);
    final statusColor = _statusColor(statusRaw);

    final qrToken = _safe(record['qrToken'], '');
    final qrGeneratedOn = _formatDateOnly(record['qrGeneratedAt']);

    final history = _sortedHistory(record['statusHistory']);

    final isMarketplaceListed = history.any(
      (b) => _normalizeStatus(b['status']) == 'MARKETPLACE_LISTED',
    );

    final harvestDate = _qc?['batch']?['harvestDate'];
    final harvestedOn = harvestDate != null
        ? _formatDateOnly(harvestDate)
        : null;

    final qcStatus = _safe(_qc?['status'], '-');
    final qcGrade = _safe(_qc?['results']?['grade'], '-');
    final qcScore = _formatNumber(_qc?['results']?['overallScore']);
    final dryingMethod = _safe(_qc?['batch']?['dryingMethod'], '-');
    final pepperVariety = _safe(_qc?['batch']?['pepperVariety'], '-');

    final densityValue = _formatNumber(_qc?['density']?['value']);
    final densitySource = _safe(_qc?['density']?['source'], '-');
    final densityMeasuredOn = _formatDateOnly(_qc?['density']?['measuredAt']);

    final certCount = (_qc?['certificatesSnapshot']?['count'] is num)
        ? (_qc?['certificatesSnapshot']?['count'] as num).toInt()
        : 0;

    final factorScoresRaw = _qc?['results']?['factorScores'];
    final Map<String, dynamic> factorScores = (factorScoresRaw is Map)
        ? Map<String, dynamic>.from(factorScoresRaw)
        : {};

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Batch Details'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchQuality,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              appCard(
                child: batchStatusHeaderWidget(
                  batchId: batchId,
                  statusPretty: statusPretty,
                  statusColor: statusColor,
                  statusIcon: _statusIcon(statusRaw),
                  isMarketplaceListed: isMarketplaceListed,
                ),
              ),
              const SizedBox(height: 14),

              appCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionHeaderWidget('Batch Details'),
                    infoRowWidget(
                      icon: Icons.spa_rounded,
                      label: 'Pepper Type',
                      value: pepperType,
                    ),
                    infoRowWidget(
                      icon: Icons.location_on_rounded,
                      label: 'District',
                      value: district,
                    ),
                    infoRowWidget(
                      icon: Icons.attach_money_rounded,
                      label: 'Price / kg',
                      value: price,
                    ),
                    infoRowWidget(
                      icon: Icons.inventory_2_rounded,
                      label: 'Quantity',
                      value: '$qty kg',
                    ),
                    infoRowWidget(
                      icon: Icons.sticky_note_2_rounded,
                      label: 'Additional Notes',
                      value: notes,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              appCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionHeaderWidget(
                      'Quality Details',
                      trailing: _loadingQc
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (_qcError != null)
                      Text(
                        'Failed to load quality details: $_qcError',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else if (!_loadingQc && _qc == null)
                      Text(
                        'No quality check record found for this batch.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      )
                    else if (_qc != null) ...[
                      qualityGradeBannerWidget(
                        qcGrade: qcGrade,
                        qcScore: qcScore,
                      ),
                      infoRowWidget(
                        icon: Icons.fact_check_rounded,
                        label: 'QC Status',
                        value: qcStatus,
                      ),
                      infoRowWidget(
                        icon: Icons.eco_rounded,
                        label: 'Pepper Variety',
                        value: pepperVariety,
                      ),
                      infoRowWidget(
                        icon: Icons.wb_sunny_rounded,
                        label: 'Drying Method',
                        value: dryingMethod,
                      ),
                      infoRowWidget(
                        icon: Icons.scale_rounded,
                        label: 'Density',
                        value: '$densityValue g/L',
                      ),
                      infoRowWidget(
                        icon: Icons.sensors_rounded,
                        label: 'Density Source',
                        value: densitySource,
                      ),
                      infoRowWidget(
                        icon: Icons.event_available_rounded,
                        label: 'Measured On',
                        value: densityMeasuredOn,
                      ),
                      infoRowWidget(
                        icon: Icons.badge_rounded,
                        label: 'Certificates',
                        value: certCount.toString(),
                      ),
                      if (factorScores.isNotEmpty) ...[
                        sectionHeaderWidget(
                          'Factor Scores',
                          icon: Icons.tune_rounded,
                        ),
                        _factorList(factorScores),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              appCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionHeaderWidget('QR Code'),
                    if (qrToken.isEmpty)
                      Text(
                        'QR not available for this record.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          infoRowWidget(
                            icon: Icons.event_rounded,
                            label: 'Generated On',
                            value: qrGeneratedOn,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showQrPopup(
                                qrToken: qrToken,
                                batchId: batchId,
                                qrGeneratedOn: qrGeneratedOn,
                              ),
                              icon: const Icon(Icons.qr_code_2_rounded),
                              label: const Text('View QR Code'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2E7D32),
                                side: const BorderSide(
                                  color: Color(0xFF2E7D32),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              appCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionHeaderWidget('Blockchain History'),
                    _historySection(history, harvestedOn),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _downloadingPdf ? null : _downloadPdf,
                    icon: _downloadingPdf
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download_rounded),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        _downloadingPdf
                            ? 'Preparing PDF...'
                            : 'Download PDF Report',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PdfPreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const PdfPreviewScreen({
    super.key,
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('PDF Preview'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          pdfSuccessBannerWidget(),
          Expanded(
            child: PdfPreview(
              build: (format) async => pdfBytes,
              allowPrinting: false,
              allowSharing: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              pdfFileName: fileName,
            ),
          ),
        ],
      ),
    );
  }
}
