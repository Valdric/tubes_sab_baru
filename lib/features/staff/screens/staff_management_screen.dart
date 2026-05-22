import 'package:flutter/material.dart';
import 'package:gosir/shared/widgets/profile_button.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/shared/widgets/animated_entry.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _staff = [];
  bool _isLoading = true;
  String _myRole = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/users', params: _searchQuery.isNotEmpty ? {'search': _searchQuery} : null);
      final me = await _api.get('/auth/me');
      if (mounted) {
        setState(() {
          _staff = res['data']['items'] ?? [];
          _myRole = me['data']['role'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteStaff(int id) async {
    try {
      await _api.delete('/users/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff berhasil dihapus'), backgroundColor: Colors.green),
        );
        _fetchData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showFormModal({Map<String, dynamic>? item}) {
    final nameController = TextEditingController(text: item?['name'] ?? '');
    final usernameController = TextEditingController(text: item?['username'] ?? '');
    final passwordController = TextEditingController();
    String selectedRole = item?['role'] ?? 'CASHIER';
    final bool isEdit = item != null;
    String? nameErrorText;
    String? usernameErrorText;
    String? passwordErrorText;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'StaffForm',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return Transform.scale(
          scale: curve.value,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEdit ? 'Ubah Data Staff' : 'Tambah Staff Baru', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration('Misal: Andi Wijaya', errorText: nameErrorText),
                  onChanged: (v) {
                    if (nameErrorText != null) setModalState(() => nameErrorText = null);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Username', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: usernameController,
                  decoration: _inputDecoration('andi_wijaya', errorText: usernameErrorText),
                  enabled: !isEdit,
                  onChanged: (v) {
                    if (usernameErrorText != null) setModalState(() => usernameErrorText = null);
                  },
                ),
                if (!isEdit) ...[
                  const SizedBox(height: 16),
                  const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    decoration: _inputDecoration('Min. 6 Karakter', errorText: passwordErrorText),
                    obscureText: true,
                    onChanged: (v) {
                      if (passwordErrorText != null) setModalState(() => passwordErrorText = null);
                    },
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Role', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  items: ['SUPERADMIN', 'ADMIN', 'CASHIER', 'KITCHEN']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedRole = val!),
                  decoration: _inputDecoration(''),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
            ScaleOnTap(
              onTap: () async {
                bool hasError = false;
                final nameTrimmed = nameController.text.trim();
                final usernameTrimmed = usernameController.text.trim();

                if (nameTrimmed.isEmpty) {
                  setModalState(() => nameErrorText = 'Nama lengkap wajib diisi');
                  hasError = true;
                }
                if (usernameTrimmed.isEmpty) {
                  setModalState(() => usernameErrorText = 'Username wajib diisi');
                  hasError = true;
                }
                if (!isEdit && passwordController.text.length < 6) {
                  setModalState(() => passwordErrorText = 'Password minimal 6 karakter');
                  hasError = true;
                }
                if (hasError) return;

                try {
                  final data = {
                    'name': nameTrimmed,
                    'username': usernameTrimmed,
                    'role': selectedRole,
                  };
                  if (!isEdit) data['password'] = passwordController.text;

                  if (isEdit) {
                    await _api.put('/users/${item['id']}', data);
                  } else {
                    await _api.post('/users', data);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    _fetchData();
                  }
                } catch (e) {
                  setModalState(() => nameErrorText = e.toString());
                }
              },
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2)),
    );
  }

  Widget _buildFilterSection(bool isDesktop, bool isAdmin) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBgColor = isDark ? const Color(0xFF131A16) : const Color(0xFFFFFFFF);
    final Color borderColor = isDark ? const Color(0xFF223029) : const Color(0xFFE2E8F0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 16.0, vertical: 12.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cari Pegawai',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        onChanged: (v) {
                          setState(() => _searchQuery = v);
                          _fetchData();
                        },
                        style: TextStyle(
                          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Cari nama atau username...',
                          prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0A0D0B) : const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: 16),
                  ScaleOnTap(
                    onTap: () => _showFormModal(),
                    child: ElevatedButton.icon(
                      onPressed: null, // Handled by ScaleOnTap
                      icon: const Icon(Icons.person_add_alt_1, size: 20),
                      label: const Text('Tambah Pegawai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary,
                        foregroundColor: isDark ? const Color(0xFF0A0D0B) : const Color(0xFFFFFFFF),
                        minimumSize: const Size(200, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cari Pegawai',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  onChanged: (v) {
                    setState(() => _searchQuery = v);
                    _fetchData();
                  },
                  style: TextStyle(
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau username...',
                    prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0A0D0B) : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    final bool isAdmin = _myRole.toUpperCase() == 'ADMIN' || _myRole.toUpperCase() == 'SUPERADMIN';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 6)) : null,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).cardColor,
              title: Text('Manajemen Staff', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
              actions: [const ProfileButton()],
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) const Sidebar(currentIndex: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 32.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Staff & Pegawai',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola hak akses dan informasi pegawai toko Anda.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                _buildFilterSection(isDesktop, isAdmin),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 8),
                          itemCount: _staff.length,
                          itemBuilder: (context, index) {
                            final item = _staff[index];
                            return AnimateEntry(
                              delay: Duration(milliseconds: (index % 12) * 50),
                              child: _staffTile(item, isAdmin),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: (!isDesktop && isAdmin)
          ? ScaleOnTap(
              onTap: () => _showFormModal(),
              child: FloatingActionButton(
                onPressed: null, // Handled by ScaleOnTap
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF10B981)
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0A0D0B)
                    : const Color(0xFFFFFFFF),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.add, size: 28),
              ),
            )
          : null,
      bottomNavigationBar: null,
    );
  }

  Widget _staffTile(Map<String, dynamic> item, bool isAdmin) {
    return ScaleOnTap(
      onTap: isAdmin ? () => _showFormModal(item: item) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Text(item['name']?[0].toUpperCase() ?? '?', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          title: Text(item['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('@${item['username']}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(item['role'] ?? '-', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          trailing: isAdmin
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showFormModal(item: item)),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _showDeleteConfirm(item)),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  void _showDeleteConfirm(Map<String, dynamic> item) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DeleteStaffConfirm',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return Transform.scale(
          scale: curve.value,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        title: const Text('Hapus Pegawai'),
        content: Text('Apakah Anda yakin ingin menghapus "${item['name']}"? User ini tidak akan bisa login lagi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ScaleOnTap(
            onTap: () {
              Navigator.pop(context);
              _deleteStaff(item['id']);
            },
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Theme.of(context).cardColor),
              child: const Text('Hapus'),
            ),
          ),
        ],
      ),
    );
  }
}
