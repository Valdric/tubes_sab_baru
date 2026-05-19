import 'package:gosir/main.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gosir/core/services/api_service.dart';

class MenuFormScreen extends StatefulWidget {
  final Map<String, dynamic>? menu;

  const MenuFormScreen({super.key, this.menu});

  @override
  State<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends State<MenuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _hppController;
  String _selectedDivision = 'BAR';
  String? _selectedCategoryId;
  bool _isActive = true;

  List<dynamic> _categories = [];
  List<dynamic> _ingredients = [];
  List<Map<String, dynamic>> _recipeRows = [];

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu?['name']?.toString() ?? '');
    _priceController = TextEditingController(text: widget.menu?['price']?.toString() ?? '');
    _hppController = TextEditingController(text: widget.menu?['hpp']?.toString() ?? '');
    _selectedDivision = widget.menu?['division']?.toString() ?? 'BAR';
    _selectedCategoryId = widget.menu?['category_id']?.toString() ?? widget.menu?['category']?['id']?.toString();
    _isActive = widget.menu?['is_active'] ?? true;
    
    if (widget.menu?['recipes'] != null) {
      _recipeRows = List<Map<String, dynamic>>.from(
        (widget.menu!['recipes'] as List).map((r) => {
          'ingredient_id': r['ingredient_id']?.toString(),
          'quantity': r['quantity']?.toString(),
        })
      );
    }
    _fetchOptions();
  }

  Future<void> _fetchOptions() async {
    try {
      final catRes = await _api.get('/categories');
      final ingRes = await _api.get('/ingredients');
      if (mounted) {
        setState(() {
          final cData = catRes['data'];
          _categories = cData is Map ? (cData['items'] ?? []) : (cData is List ? cData : []);
          
          final iData = ingRes['data'];
          _ingredients = iData is Map ? (iData['items'] ?? []) : (iData is List ? iData : []);
        });
      }
    } catch (e) {
      // Handle error or ignore
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final fields = {
      'name': _nameController.text.trim(),
      'price': _priceController.text.trim(),
      'hpp': _hppController.text.trim(),
      'category_id': _selectedCategoryId ?? '',
      'division': _selectedDivision,
      'is_active': _isActive.toString(),
    };

    final List<Map<String, dynamic>> recipesList = [];
    for (var row in _recipeRows) {
      if (row['ingredient_id'] != null) {
        recipesList.add({
          'ingredient_id': row['ingredient_id'],
          'quantity': double.tryParse(row['quantity']?.toString() ?? '') ?? 0.0,
        });
      }
    }
    if (recipesList.isNotEmpty) {
      fields['recipes'] = jsonEncode(recipesList);
    }

    List<int>? fileBytes;
    String? fileName;
    if (_pickedImage != null) {
      fileBytes = await _pickedImage!.readAsBytes();
      fileName = _pickedImage!.name;
    }

    try {
      if (widget.menu == null) {
        await _api.multipart('/menus', fields, fileBytes: fileBytes, fileName: fileName);
      } else {
        await _api.multipart('/menus/${widget.menu!['id']}', fields, fileBytes: fileBytes, fileName: fileName, method: 'PUT');
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
      appBar: AppBar(title: Text(widget.menu == null ? 'Tambah Menu' : 'Edit Menu'), actions: [const ThemeToggle()],),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              SizedBox(height: 24),
              _buildLabel('Nama Menu'),
              TextFormField(controller: _nameController, decoration: InputDecoration(hintText: 'Nama')),
              SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Harga'), TextFormField(controller: _priceController, keyboardType: TextInputType.number)])),
                SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('HPP'), TextFormField(controller: _hppController, keyboardType: TextInputType.number)])),
              ]),
              SizedBox(height: 16),
              _buildLabel('Kategori'),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                items: _categories.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name']))).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
              SizedBox(height: 16),
              _buildLabel('Divisi'),
              DropdownButtonFormField<String>(
                initialValue: _selectedDivision,
                items: ['BAR', 'KITCHEN'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedDivision = v!),
              ),
              SizedBox(height: 16),
              SwitchListTile(title: Text('Status Aktif'), value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
              Divider(height: 40),
              _buildRecipes(),
              SizedBox(height: 40),
              ElevatedButton(onPressed: _isLoading ? null : _save, child: _isLoading ? const CircularProgressIndicator() : Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: InkWell(
        onTap: () async {
          final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
          if (img != null) setState(() => _pickedImage = img);
        },
        child: Container(
          width: double.infinity, height: 160,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
          child: _pickedImage != null 
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12), 
                child: kIsWeb 
                    ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                    : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
              )
            : (widget.menu?['image_url'] != null ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(widget.menu!['image_url'], fit: BoxFit.cover)) : Icon(Icons.add_a_photo_outlined, size: 40)),
        ),
      ),
    );
  }

  Widget _buildRecipes() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Resep / Komposisi', style: TextStyle(fontWeight: FontWeight.bold)),
      ...List.generate(_recipeRows.length, (i) => Row(children: [
        Expanded(child: DropdownButtonFormField<String>(initialValue: _recipeRows[i]['ingredient_id'], items: _ingredients.map((ing) => DropdownMenuItem(value: ing['id'].toString(), child: Text(ing['name']))).toList(), onChanged: (v) => setState(() => _recipeRows[i]['ingredient_id'] = v))),
        SizedBox(width: 8),
        Expanded(child: TextFormField(initialValue: _recipeRows[i]['quantity'], onChanged: (v) => _recipeRows[i]['quantity'] = v, keyboardType: TextInputType.number)),
        IconButton(icon: Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setState(() => _recipeRows.removeAt(i))),
      ])),
      TextButton.icon(onPressed: () => setState(() => _recipeRows.add({'ingredient_id': null, 'quantity': '0'})), icon: Icon(Icons.add), label: Text('Tambah Bahan')),
    ]);
  }

  Widget _buildLabel(String t) => Padding(padding: EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)));
}
