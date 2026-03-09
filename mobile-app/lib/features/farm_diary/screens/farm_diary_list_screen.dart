import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/farm_diary.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/farm_diary_provider.dart';
import '../../../utils/responsive.dart';
import 'farm_diary_detail_screen.dart';
import 'farm_diary_form_screen.dart';

Color colorWithOpacity(Color c, double opacity) {
  final alpha = (opacity * 255).round().clamp(0, 255);
  return c.withAlpha(alpha);
}

class FarmDiaryListScreen extends StatefulWidget {
  final String? farmPlotId;

  const FarmDiaryListScreen({super.key, this.farmPlotId});

  @override
  State<FarmDiaryListScreen> createState() => _FarmDiaryListScreenState();
}

class _FarmDiaryListScreenState extends State<FarmDiaryListScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF2E7D32);
  late FarmDiaryProvider _provider;
  String _selectedActivityFilter = 'all';
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> activityTypes = [
    'all',
    'watering',
    'fertilizing',
    'pest_control',
    'harvesting',
    'pruning',
    'weeding',
    'inspection',
    'disease_treatment',
    'other',
  ];

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
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEntries());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadEntries() async {
    await _provider.loadDiaryEntries(
      farmPlotId: widget.farmPlotId,
      startDate: _startDate,
      endDate: _endDate,
      activityType:
          _selectedActivityFilter == 'all' ? null : _selectedActivityFilter,
    );
    if (mounted) {
      _animationController.forward(from: 0);
    }
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Diary Entries',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Activity Type:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: activityTypes.map((activity) {
                    final isSelected = _selectedActivityFilter == activity;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(activity.replaceAll('_', ' ')),
                        selected: isSelected,
                        selectedColor: colorWithOpacity(_primary, 0.15),
                        checkmarkColor: _primary,
                        labelStyle: TextStyle(
                          color: isSelected ? _primary : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedActivityFilter = activity;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Date Range:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _startDate != null
                            ? DateFormat('MMM dd').format(_startDate!)
                            : 'Start Date',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                      icon: const Icon(Icons.event, size: 16),
                      label: Text(
                        _endDate != null
                            ? DateFormat('MMM dd').format(_endDate!)
                            : 'End Date',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedActivityFilter = 'all';
                          _startDate = null;
                          _endDate = null;
                        });
                        _loadEntries();
                        Navigator.pop(context);
                      },
                      child:
                          Text('Clear All', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _loadEntries();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(r),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _loadEntries(),
                color: _primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildSearchBar(r),
                      _buildListContent(r),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'farm_diary_fab',
        onPressed: () => context.navigateToFarmDiaryForm(
          farmPlotId: widget.farmPlotId,
        ),
        icon: const Icon(Icons.add_task),
        label: const Text(
          'New Entry',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeader(Responsive r) {
    return Container(
      padding: r.padding(
        mobile: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        tablet: const EdgeInsets.fromLTRB(32, 24, 32, 36),
        desktop: const EdgeInsets.fromLTRB(40, 28, 40, 42),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, colorWithOpacity(_primary, 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(r.value(mobile: 28, tablet: 36, desktop: 40)),
          bottomRight: Radius.circular(r.value(mobile: 28, tablet: 36, desktop: 40)),
        ),
        boxShadow: [
          BoxShadow(
            color: colorWithOpacity(_primary, 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm Diary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: r.fontSize(mobile: 22, tablet: 26, desktop: 30),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.farmPlotId != null
                      ? 'Logs for this plot'
                      : 'History of activities',
                  style: TextStyle(
                    color: colorWithOpacity(Colors.white, 0.8),
                    fontSize: r.fontSize(mobile: 12, tablet: 14, desktop: 15),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.book_rounded, color: Colors.white30, size: 40),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Responsive r) {
    return Padding(
      padding: r.padding(
        mobile: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        tablet: const EdgeInsets.fromLTRB(24, 32, 24, 20),
        desktop: const EdgeInsets.fromLTRB(32, 40, 32, 24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (query) => setState(() => _searchQuery = query),
                decoration: InputDecoration(
                  hintText: 'Search entries...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: _openFilterBottomSheet,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: colorWithOpacity(_primary, 0.1)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.tune, color: _primary, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(Responsive r) {
    return Consumer<FarmDiaryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator(color: _primary)),
          );
        }

        final filtered = provider.diaryEntries.where((e) {
          if (_searchQuery.isEmpty) return true;
          return e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.activityType.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState(r, provider.error);
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: r.value(mobile: 16, tablet: 24, desktop: 32),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) =>
                    _buildDiaryCard(filtered[index], r),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiaryCard(FarmDiary entry, Responsive r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorWithOpacity(_primary, 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.navigateToFarmDiaryDetail(entryId: entry.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildActivityIcon(entry.activityType, r),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy • HH:mm').format(entry.diaryDate),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      if (entry.syncStatus != 'synced') ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: entry.syncStatus == 'pending'
                                ? Colors.orange[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entry.syncStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: entry.syncStatus == 'pending'
                                  ? Colors.orange[900]
                                  : Colors.red[900],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityIcon(String type, Responsive r) {
    final color = _getActivityColor(type);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, colorWithOpacity(color, 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(_getActivityIcon(type), color: Colors.white, size: 24),
    );
  }

  Widget _buildEmptyState(Responsive r, String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              error != null ? Icons.error_outline : Icons.book_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              error ?? 'No entries found',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            if (error != null)
              TextButton(onPressed: _loadEntries, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case 'watering':
        return Colors.blue;
      case 'fertilizing':
        return Colors.brown;
      case 'pest_control':
        return Colors.red;
      case 'harvesting':
        return Colors.green;
      case 'pruning':
        return Colors.purple;
      case 'weeding':
        return Colors.orange;
      case 'inspection':
        return Colors.teal;
      case 'disease_treatment':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'watering':
        return Icons.water_drop;
      case 'fertilizing':
        return Icons.healing;
      case 'pest_control':
        return Icons.bug_report;
      case 'harvesting':
        return Icons.agriculture;
      case 'pruning':
        return Icons.cut;
      case 'weeding':
        return Icons.remove;
      case 'inspection':
        return Icons.checklist;
      case 'disease_treatment':
        return Icons.medical_services;
      default:
        return Icons.note;
    }
  }
}
