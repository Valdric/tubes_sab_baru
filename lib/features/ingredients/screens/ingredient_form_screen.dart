import 'package:gosir/main.dart';
import 'package:flutter/material.dart';
import 'package:gosir/core/services/api_service.dart';

class IngredientFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const IngredientFormScreen({super.key, this.item});

  @override
  State<IngredientFormScreen> createState() => _IngredientFormScreenState();
}

class _IngredientFormScreenState extends State<IngredientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _stockController;
  late TextEditingController _thresholdController;
  String _selectedUnit = 'GRAM';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?['name']?.toString() ?? '');
    _stockController = TextEditingController(text: widget.item?['stock']?.toString() ?? '0');
    _thresholdController = TextEditingController(text: widget.item?['threshold']?.toString() ?? '0');
    _selectedUnit = widget.item?['unit']?.toString() ?? 'GRAM';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final data = {
      'name': _nameController.text.trim(),
      'stock': double.parse(_stockController.text),
      'threshold': double.parse(_thresholdController.text),
      'unit': _selectedUnit,
    };
    try {
      if (widget.item == null) {
        await _api.post('/ingredients', data);
      } else {
        await _api.put('/ingredients/${widget.item!['id']}', data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(title: Text(widget.item == null ? 'Tambah Bahan' : 'Edit Bahan'), actions: [const ThemeToggle()],),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Nama Bahan Baku'),
              TextFormField(controller: _nameController, decoration: InputDecoration(hintText: 'misal: Gula')),
              SizedBox(height: 20),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Stok'), TextFormField(controller: _stockController, keyboardType: TextInputType.number)])),
                SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Satuan'), DropdownButtonFormField<String>(initialValue: _selectedUnit, items: ['GRAM', 'ML', 'PCS'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _selectedUnit = v!))])),
              ]),
              SizedBox(height: 20),
              _buildLabel('Batas Stok Menipis'),
              TextFormField(controller: _thresholdController, keyboardType: TextInputType.number),
              SizedBox(height: 40),
              ElevatedButton(onPressed: _isLoading ? null : _save, child: _isLoading ? const CircularProgressIndicator() : Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String t) => Padding(padding: EdgeInsets.only(bottom: 8), child: Text(t, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)));
}
