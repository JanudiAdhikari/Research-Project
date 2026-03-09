import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/farm_diary.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/farm_diary_provider.dart';
import '../../../utils/responsive.dart';
import 'farm_diary_form_screen.dart';

Color colorWithOpacity(Color c, double opacity) {
  final alpha = (opacity * 255).round().clamp(0, 255);
  return c.withAlpha(alpha);
}

class FarmDiaryDetailScreen extends StatefulWidget {
  final String entryId;

  const FarmDiaryDetailScreen({super.key, required this.entryId});

  @override
  State<FarmDiaryDetailScreen> createState() => _FarmDiaryDetailScreenState();
}

class _FarmDiaryDetailScreenState extends State<FarmDiaryDetailScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF2E7D32);
  late FarmDiaryProvider _provider;
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _provider = AppProviders.farmDiary;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEntry());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadEntry() {
    _provider.loadDiaryEntry(widget.entryId).then((_) {
      if (mounted) {
        setState(() => _isLoading = false);
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<FarmDiaryProvider>(
        builder: (context, provider, child) {
          if (_isLoading || provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: _primary));
          }
          final entry = provider.selectedEntry;
          if (entry == null) {
            return _buildErrorState(r);
          }
          return CustomScrollView(
            slivers: [
              _buildSliverHeader(entry, r),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: r.padding(
                        mobile: const EdgeInsets.symmetric(vertical: 20),
                        tablet: const EdgeInsets.symmetric(vertical: 28),
                        desktop: const EdgeInsets.symmetric(vertical: 32),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuickInfoRow(entry, r),
                          if (entry.description.isNotEmpty)
                            _buildSection(r, 'Description', Icons.description_outlined, [
                              Text(
                                entry.description,
                                style: TextStyle(
                                  fontSize: r.fontSize(mobile: 15, tablet: 16),
                                  color: Colors.grey[800],
                                  height: 1.5,
                                ),
                              ),
                            ]),
                          _buildWeatherSection(entry, r),
                          _buildObservationsSection(entry, r),
                          _buildInputsSection(entry, r),
                          if (entry.notes.isNotEmpty)
                            _buildSection(r, 'Additional Notes', Icons.note_alt_outlined, [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.blueGrey.shade100),
                                ),
                                child: Text(
                                  entry.notes,
                                  style: TextStyle(
                                    fontSize: r.fontSize(mobile: 14, tablet: 15),
                                    color: Colors.blueGrey[800],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ]),
                          _buildMetaInfo(entry, r),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverHeader(FarmDiary entry, Responsive r) {
    return SliverAppBar(
      expandedHeight: r.value(mobile: 220, tablet: 260, desktop: 300),
      pinned: true,
      elevation: 0,
      backgroundColor: _primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () => context.navigateToFarmDiaryForm(entry: entry),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          onPressed: () => _showDeleteDialog(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, colorWithOpacity(_primary, 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Decorative Icon
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                _getActivityIcon(entry.activityType),
                size: 200,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            // Header Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      entry.activityType.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: r.fontSize(mobile: 26, tablet: 32, desktop: 36),
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMMM dd, yyyy • HH:mm').format(entry.diaryDate),
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoRow(FarmDiary entry, Responsive r) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.value(mobile: 16, tablet: 28)),
      child: Row(
        children: [
          _buildQuickStat(r, Icons.sync, entry.syncStatus.toUpperCase(), 
            entry.syncStatus == 'synced' ? Colors.green : Colors.orange),
          const SizedBox(width: 12),
          _buildQuickStat(r, Icons.health_and_safety_outlined, entry.observations.plantHealth.toUpperCase(), 
            _getHealthColor(entry.observations.plantHealth)),
        ],
      ),
    );
  }

  Widget _buildQuickStat(Responsive r, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(Responsive r, String title, IconData icon, List<Widget> children) {
    return Padding(
      padding: EdgeInsets.fromLTRB(r.value(mobile: 16, tablet: 28), 24, r.value(mobile: 16, tablet: 28), 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: _primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: r.fontSize(mobile: 17, tablet: 19),
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildWeatherSection(FarmDiary entry, Responsive r) {
    final hasWeather = entry.weather.temperature != null || (entry.weather.condition != 'unknown' && entry.weather.condition.isNotEmpty);
    if (!hasWeather) return const SizedBox.shrink();

    return _buildSection(r, 'Weather Context', Icons.wb_sunny_outlined, [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWeatherStat(r, Icons.thermostat_rounded, '${entry.weather.temperature ?? '--'}°C', 'Temperature', Colors.orange),
                _buildWeatherStat(r, Icons.water_drop_outlined, '${entry.weather.humidity ?? '--'}%', 'Humidity', Colors.blue),
                _buildWeatherStat(r, Icons.cloudy_snowing, '${entry.weather.rainfall ?? '--'}mm', 'Rainfall', Colors.indigo),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Icon(Icons.filter_drama_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Condition: ${entry.weather.condition.toUpperCase()}',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildWeatherStat(Responsive r, IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildObservationsSection(FarmDiary entry, Responsive r) {
    return _buildSection(r, 'Observations', Icons.visibility_outlined, [
      _buildInfoCard(
        r,
        title: 'Health Status',
        content: entry.observations.plantHealth.toUpperCase(),
        icon: Icons.monitor_heart_outlined,
        color: _getHealthColor(entry.observations.plantHealth),
      ),
      if (entry.observations.diseaseSymptoms != null)
        const SizedBox(height: 12),
      if (entry.observations.diseaseSymptoms != null)
        _buildInfoCard(
          r,
          title: 'Disease Symptoms',
          content: entry.observations.diseaseSymptoms!,
          icon: Icons.coronavirus_outlined,
          color: Colors.redAccent,
        ),
      if (entry.observations.pestPresence != null)
        const SizedBox(height: 12),
      if (entry.observations.pestPresence != null)
        _buildInfoCard(
          r,
          title: 'Pest Presence',
          content: entry.observations.pestPresence!,
          icon: Icons.bug_report_outlined,
          color: Colors.brown,
        ),
    ]);
  }

  Widget _buildInputsSection(FarmDiary entry, Responsive r) {
    final hasInputs = entry.inputs.fertilizer != null || entry.inputs.pesticide != null || entry.inputs.waterQuantity != null;
    if (!hasInputs) return const SizedBox.shrink();

    return _buildSection(r, 'Inputs Applied', Icons.inventory_2_outlined, [
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          if (entry.inputs.fertilizer != null)
            _buildInputBadge(r, 'Fertilizer', entry.inputs.fertilizer!, Icons.science_outlined, Colors.purple),
          if (entry.inputs.pesticide != null)
            _buildInputBadge(r, 'Pesticide', entry.inputs.pesticide!, Icons.biotech_outlined, Colors.red),
          if (entry.inputs.waterQuantity != null)
            _buildInputBadge(r, 'Water', '${entry.inputs.waterQuantity} Liters', Icons.opacity, Colors.blue),
        ],
      ),
    ]);
  }

  Widget _buildInputBadge(Responsive r, String label, String value, IconData icon, Color color) {
    return Container(
      width: r.value(mobile: (r.width - 44) / 2, tablet: (r.width - 100) / 3),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Responsive r, {required String title, required String content, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorWithOpacity(color, 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(FarmDiary entry, Responsive r) {
    return _buildSection(r, 'Meta Info', Icons.info_outline, [
      Column(
        children: [
          _buildMetaRow('Created At', entry.createdAt != null ? DateFormat('MMM dd, HH:mm').format(entry.createdAt!) : '--'),
          const Divider(),
          _buildMetaRow('Last Updated', entry.updatedAt != null ? DateFormat('MMM dd, HH:mm').format(entry.updatedAt!) : '--'),
        ],
      ),
    ]);
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildErrorState(Responsive r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text('Entry not found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this diary entry forever?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey[600]))),
          ElevatedButton(
            onPressed: () {
              _provider.deleteDiaryEntry(widget.entryId).then((success) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry deleted')));
                  Navigator.pop(context);
                }
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case 'watering': return Colors.blue;
      case 'fertilizing': return Colors.brown;
      case 'pest_control': return Colors.red;
      case 'harvesting': return Colors.green;
      case 'pruning': return Colors.purple;
      case 'weeding': return Colors.orange;
      case 'inspection': return Colors.teal;
      case 'disease_treatment': return Colors.pink;
      default: return Colors.grey;
    }
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'watering': return Icons.water_drop;
      case 'fertilizing': return Icons.healing;
      case 'pest_control': return Icons.bug_report;
      case 'harvesting': return Icons.agriculture;
      case 'pruning': return Icons.cut;
      case 'weeding': return Icons.remove;
      case 'inspection': return Icons.checklist;
      case 'disease_treatment': return Icons.medical_services;
      default: return Icons.note;
    }
  }

  Color _getHealthColor(String health) {
    switch (health.toLowerCase()) {
      case 'excellent': return Colors.green;
      case 'good': return Colors.lightGreen;
      case 'fair': return Colors.orange;
      case 'poor': return Colors.red;
      default: return Colors.grey;
    }
  }
}
