import 'package:flutter/material.dart';

class ExporterCertificationsScreen extends StatefulWidget {
  const ExporterCertificationsScreen({super.key});

  @override
  State<ExporterCertificationsScreen> createState() => _ExporterCertificationsScreenState();
}

class _ExporterCertificationsScreenState extends State<ExporterCertificationsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Farmer-side certifications (as we discussed)
  bool _gap = false;
  bool _organic = false;
  bool _fairTrade = false;

  final _gapIdCtrl = TextEditingController();
  final _organicIdCtrl = TextEditingController();
  final _fairTradeIdCtrl = TextEditingController();

  @override
  void dispose() {
    _gapIdCtrl.dispose();
    _organicIdCtrl.dispose();
    _fairTradeIdCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;

    final payload = {
      "ssdfrdh": {"enabled": _gap, "id": _gapIdCtrl.text.trim()},
      "fgfg": {"enabled": _organic, "id": _organicIdCtrl.text.trim()},
      "try": {"enabled": _fairTrade, "id": _fairTradeIdCtrl.text.trim()},
    };

    // TODO: Save to Firestore (later)
    // For now just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Saved: ${payload.toString()}"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Certifications"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _certCard(
                title: "dfhfh",
                subtitle: "Enter certificate number to verify later",
                value: _gap,
                onChanged: (v) => setState(() => _gap = v),
                controller: _gapIdCtrl,
                hint: "Example: SLGAP-XXXX",
                validator: (v) {
                  if (!_gap) return null;
                  if (v == null || v.trim().isEmpty) return "Certificate ID required";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              _certCard(
                title: "df",
                subtitle: "Enter certificate number (issuer specific)",
                value: _organic,
                onChanged: (v) => setState(() => _organic = v),
                controller: _organicIdCtrl,
                hint: "Certificate number",
                validator: (v) {
                  if (!_organic) return null;
                  if (v == null || v.trim().isEmpty) return "Certificate ID required";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              _certCard(
                title: "tuy",
                subtitle: "Usually for farmer groups or cooperatives",
                value: _fairTrade,
                onChanged: (v) => setState(() => _fairTrade = v),
                controller: _fairTradeIdCtrl,
                hint: "Certificate number",
                validator: (v) {
                  if (!_fairTrade) return null;
                  if (v == null || v.trim().isEmpty) return "Certificate ID required";
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Verification can be automated for SLGAP, others can be manual or portal-based.",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _certCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: Colors.green,
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: value
                ? Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: "Certificate ID",
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                ),
                validator: validator,
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
