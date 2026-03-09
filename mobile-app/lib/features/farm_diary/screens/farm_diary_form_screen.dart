import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/farm_diary.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/farm_diary_provider.dart';
import '../../../services/farmer_service.dart';
import '../../../models/farm_plot.dart';
import '../../../utils/responsive.dart';

class FarmDiaryFormScreen extends StatefulWidget {
  final String? farmPlotId;
  final FarmDiary? entry;

  const FarmDiaryFormScreen({super.key, this.farmPlotId, this.entry});

  @override
  State<FarmDiaryFormScreen> createState() => _FarmDiaryFormScreenState();
}

class _FarmDiaryFormScreenState extends State<FarmDiaryFormScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF2E7D32);
  late FarmDiaryProvider _provider;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late TextEditingController _fertiliserController;
  late TextEditingController _pesticideController;
  late TextEditingController _waterQuantityController;
  late TextEditingController _diseaseSymptomController;
  late TextEditingController _pestPresenceController;

  String _selectedActivityType = 'other';
  DateTime _selectedDate = DateTime.now();
  String _plantHealth = 'good';
  List<String> _tags = [];
  bool _isLoading = false;

  // Plot selection
  final FarmerService _farmerService = FarmerService();
  List<FarmPlot> _availablePlots = [];
  String? _selectedFarmPlotId;
  bool _isLoadingPlots = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> activityTypes = [
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

  final List<String> plantHealthOptions = ['excellent', 'good', 'fair', 'poor'];

  @override
  void initState() {
    super.initState();
    _provider = AppProviders.farmDiary;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _initializeFields();

    _selectedFarmPlotId = widget.farmPlotId ?? widget.entry?.farmPlotId;
    if (_selectedFarmPlotId == null) {
      _loadAvailablePlots();
    } else {
      _animationController.forward();
    }
  }

  void _initializeFields() {
    if (widget.entry != null) {
      _titleController = TextEditingController(text: widget.entry!.title);
      _descriptionController = TextEditingController(text: widget.entry!.description);
      _notesController = TextEditingController(text: widget.entry!.notes);
      _fertiliserController = TextEditingController(text: widget.entry!.inputs.fertilizer ?? '');
      _pesticideController = TextEditingController(text: widget.entry!.inputs.pesticide ?? '');
      _waterQuantityController =
          TextEditingController(text: widget.entry!.inputs.waterQuantity?.toString() ?? '');
      _diseaseSymptomController =
          TextEditingController(text: widget.entry!.observations.diseaseSymptoms ?? '');
      _pestPresenceController =
          TextEditingController(text: widget.entry!.observations.pestPresence ?? '');
      _selectedActivityType = widget.entry!.activityType;
      _selectedDate = widget.entry!.diaryDate;
      _plantHealth = widget.entry!.observations.plantHealth;
      _tags = List.from(widget.entry!.tags);
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _notesController = TextEditingController();
      _fertiliserController = TextEditingController();
      _pesticideController = TextEditingController();
      _waterQuantityController = TextEditingController();
      _diseaseSymptomController = TextEditingController();
      _pestPresenceController = TextEditingController();
    }
  }

  Future<void> _loadAvailablePlots() async {
    setState(() => _isLoadingPlots = true);
    try {
      final plots = await _farmerService.fetchPlots();
      setState(() {
        _availablePlots = plots;
      });
      _animationController.forward();
    } catch (e) {
      debugPrint('Error loading plots: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPlots = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _fertiliserController.dispose();
    _pesticideController.dispose();
    _waterQuantityController.dispose();
    _diseaseSymptomController.dispose();
    _pestPresenceController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _saveDiaryEntry() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFarmPlotId == null) {
      _showSnackBar('Please select a farm plot');
      return;
    }

    setState(() => _isLoading = true);

    final entry = FarmDiary(
      id: widget.entry?.id ?? '',
      title: _titleController.text,
      description: _descriptionController.text,
      activityType: _selectedActivityType,
      diaryDate: _selectedDate,
      farmPlotId: _selectedFarmPlotId!,
      weather: const Weather(
        condition: 'unknown',
        temperature: null,
        humidity: null,
        rainfall: null,
      ),
      observations: Observations(
        plantHealth: _plantHealth,
        diseaseSymptoms: _diseaseSymptomController.text.isEmpty ? null : _diseaseSymptomController.text,
        pestPresence: _pestPresenceController.text.isEmpty ? null : _pestPresenceController.text,
      ),
      inputs: Inputs(
        fertilizer: _fertiliserController.text.isEmpty ? null : _fertiliserController.text,
        pesticide: _pesticideController.text.isEmpty ? null : _pesticideController.text,
        waterQuantity: _waterQuantityController.text.isEmpty
            ? null
            : double.tryParse(_waterQuantityController.text),
      ),
      notes: _notesController.text,
      tags: _tags,
    );

    try {
      final success = widget.entry != null
          ? await _provider.updateDiaryEntry(widget.entry!.id, entry) != null
          : await _provider.createDiaryEntry(entry) != null;

      if (success) {
        if (!mounted) return;
        _showSnackBar(widget.entry != null ? 'Entry updated successfully' : 'Entry created successfully');
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        _showSnackBar(_provider.error ?? 'Failed to save entry');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoadingPlots
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : Form(
              key: _formKey,
              child: CustomScrollView(
                slivers: [
                  _buildSliverHeader(r),
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: r.value(mobile: 16, tablet: 40, desktop: 100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection(
                                r,
                                'General Information',
                                Icons.info_outline,
                                [
                                  if (widget.farmPlotId == null && widget.entry == null)
                                    _buildPlotDropdown(r),
                                  _buildFieldName('Activity Title'),
                                  _buildTextField(
                                    _titleController,
                                    hint: 'e.g., Early Morning Watering',
                                    icon: Icons.title,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildActivityDropdown(r),
                                  const SizedBox(height: 16),
                                  _buildDateTimeField(r),
                                ],
                              ),
                              _buildSection(
                                r,
                                'Observation & Health',
                                Icons.visibility_outlined,
                                [
                                  _buildHealthDropdown(r),
                                  const SizedBox(height: 16),
                                  _buildFieldName('Disease Symptoms'),
                                  _buildTextField(
                                    _diseaseSymptomController,
                                    hint: 'Describe any symptoms...',
                                    icon: Icons.coronavirus_outlined,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFieldName('Pest Presence'),
                                  _buildTextField(
                                    _pestPresenceController,
                                    hint: 'Describe any pests found...',
                                    icon: Icons.bug_report_outlined,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                              _buildSection(
                                r,
                                'Usage & Inputs',
                                Icons.inventory_2_outlined,
                                [
                                  _buildFieldName('Fertilizer Used'),
                                  _buildTextField(
                                    _fertiliserController,
                                    hint: 'Type and amount of fertilizer',
                                    icon: Icons.science_outlined,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFieldName('Pesticide Used'),
                                  _buildTextField(
                                    _pesticideController,
                                    hint: 'Type and amount of pesticide',
                                    icon: Icons.biotech_outlined,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFieldName('Water Quantity (L)'),
                                  _buildTextField(
                                    _waterQuantityController,
                                    hint: 'Amount of water in liters',
                                    icon: Icons.water_drop_outlined,
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return null;
                                      final n = double.tryParse(v);
                                      if (n == null || n <= 0) return 'Enter a positive number';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              _buildSection(
                                r,
                                'Notes & Description',
                                Icons.description_outlined,
                                [
                                  _buildFieldName('Main Description'),
                                  _buildTextField(
                                    _descriptionController,
                                    hint: 'What did you do today?',
                                    maxLines: 4,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFieldName('Additional Notes'),
                                  _buildTextField(
                                    _notesController,
                                    hint: 'Extra info or future plans...',
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              _buildSaveButton(r),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSliverHeader(Responsive r) {
    return SliverAppBar(
      expandedHeight: r.value(mobile: 120, tablet: 150),
      pinned: true,
      elevation: 0,
      backgroundColor: _primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          widget.entry != null ? 'Edit Entry' : 'New Diary Entry',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Icon(
                  Icons.edit_note,
                  size: 150,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSection(Responsive r, String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primary, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldName(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, color: _primary.withOpacity(0.5), size: 20) : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPlotDropdown(Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldName('Select Farm Plot'),
        DropdownButtonFormField<String>(
          value: _selectedFarmPlotId,
          hint: const Text('Choose a plot...'),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          decoration: _dropdownDecoration(Icons.landscape_outlined),
          items: _availablePlots
              .map((plot) => DropdownMenuItem(
                    value: plot.id,
                    child: Text('${plot.name} (${plot.crop})'),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedFarmPlotId = value),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActivityDropdown(Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldName('Activity Type'),
        DropdownButtonFormField<String>(
          value: _selectedActivityType,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          decoration: _dropdownDecoration(Icons.category_outlined),
          items: activityTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.replaceAll('_', ' ').toUpperCase()),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedActivityType = value);
          },
        ),
      ],
    );
  }

  Widget _buildHealthDropdown(Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldName('Plant Health Status'),
        DropdownButtonFormField<String>(
          value: _plantHealth,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          decoration: _dropdownDecoration(Icons.monitor_heart_outlined),
          items: plantHealthOptions
              .map((health) => DropdownMenuItem(
                    value: health,
                    child: Text(health.toUpperCase()),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _plantHealth = value);
          },
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: _primary.withOpacity(0.5), size: 20),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildDateTimeField(Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldName('Date & Time'),
        Row(
          children: [
            Expanded(
              child: _buildPickerButton(
                icon: Icons.calendar_today,
                label: DateFormat('MMM dd, yyyy').format(_selectedDate),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPickerButton(
                icon: Icons.access_time,
                label: DateFormat('HH:mm').format(_selectedDate),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDate),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPickerButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(Responsive r) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveDiaryEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: _primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_outlined),
                  const SizedBox(width: 10),
                  Text(
                    widget.entry != null ? 'UPDATE DIARY' : 'SAVE TO DIARY',
                    style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.1),
                  ),
                ],
              ),
      ),
    );
  }
}
