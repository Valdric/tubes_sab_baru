import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/core/services/api_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('/categories');
      if (mounted) {
        setState(() {
          if (response is List) {
            _categories = response;
          } else if (response is Map && response['data'] != null) {
            // Check for items list or directly in data
            _categories = response['data'] is List ? response['data'] : (response['data']['items'] ?? []);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load categories: $e')));
      }
    }
  }

  Future<void> _deleteCategory(String id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _api.delete('/categories/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted!')));
        _fetchCategories();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  void _showForm([Map<String, dynamic>? category]) {
    final nameController = TextEditingController(text: category?['name'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Category Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(context);
              
              setState(() => _isLoading = true);
              try {
                final data = {'name': nameController.text.trim()};
                if (category == null) {
                  await _api.post('/categories', data);
                } else {
                  await _api.put('/categories/${category['id']}', data);
                }
                _fetchCategories();
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Operation failed: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 6)) : null,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Categories', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )),
      ),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 6),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _categories.isEmpty 
                ? const Center(child: Text('No categories found.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 4 : 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return _categoryCard(cat);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _categoryCard(Map<String, dynamic> cat) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category, size: 40, color: AppColors.primary),
                const SizedBox(height: 12),
                Text(cat['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') _showForm(cat);
                if (val == 'delete') _deleteCategory(cat['id'].toString());
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
