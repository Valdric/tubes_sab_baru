import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/core/services/api_service.dart';

class InventoryFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item; // null for Create, not null for Update

  const InventoryFormScreen({super.key, this.item});

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _stockController;
  late TextEditingController _thresholdController;
  String _selectedUnit = 'GRAM';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?['name'] ?? '');
    _stockController = TextEditingController(text: widget.item?['stock']?.toString() ?? '');
    _thresholdController = TextEditingController(text: widget.item?['threshold']?.toString() ?? '0');
    _selectedUnit = widget.item?['unit'] ?? 'GRAM';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Sync with API requirements: name, stock, unit, threshold
    final data = {
      'name': _nameController.text.trim(),
      'stock': int.tryParse(_stockController.text.trim()) ?? 0,
      'unit': _selectedUnit,
      'threshold': int.tryParse(_thresholdController.text.trim()) ?? 0,
    };

    try {
      if (widget.item == null) {
        // CREATE -> /ingredients
        await _api.post('/ingredients', data);
      } else {
        // UPDATE -> /ingredients/:id
        await _api.put('/ingredients/${widget.item!['id']}', data);
      }

      if (mounted) {
        Navigator.pop(context, true); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.item == null ? 'Ingredient added!' : 'Ingredient updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          widget.item == null ? 'Add Ingredient' : 'Edit Ingredient',
          style: GoogleFonts.hankenGrotesk(
              color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Ingredient Name', textColor),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: textColor),
                decoration: _buildInputDecoration('e.g. Biji Kopi Arabica'),
                validator: (val) => val!.isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Stock', textColor),
                        TextFormField(
                          controller: _stockController,
                          style: TextStyle(color: textColor),
                          decoration: _buildInputDecoration('e.g. 1000'),
                          keyboardType: TextInputType.number,
                          validator: (val) => val!.isEmpty ? 'Stock required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Unit', textColor),
                        DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          style: TextStyle(color: textColor),
                          decoration: _buildInputDecoration(''),
                          items: ['GRAM', 'ML', 'PCS']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedUnit = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildLabel('Alert Threshold (Low Stock)', textColor),
              TextFormField(
                controller: _thresholdController,
                style: TextStyle(color: textColor),
                decoration: _buildInputDecoration('e.g. 500'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Threshold required' : null,
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.item == null ? 'Create Ingredient' : 'Save Changes',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.1))),
    );
  }
}
