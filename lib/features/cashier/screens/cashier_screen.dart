import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';
import 'package:tubes_ppm_sab/shared/widgets/mobile_bottom_nav.dart';
import 'package:tubes_ppm_sab/features/profile/screens/profile_screen.dart';
import 'package:tubes_ppm_sab/features/cashier/screens/cart_screen.dart'; // PASTIKAN IMPORT INI ADA

class CashierScreen extends StatelessWidget {
  const CashierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.surface,
      // 1. Sidebar untuk Mobile
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 1)) : null,

      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: Text(
          'Cashier',
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        // 2. Tombol Menu dengan Builder
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_open, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen())
              ),
              borderRadius: BorderRadius.circular(20),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceContainerHigh,
                backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAebimc9BJtwloOpY4j3Hwdhm0j-EIy2iiW2CJ0maPC0ynBmA_zCVpSSjaDMuEHEOJcCN51Od4Hadfzzk_XFBW5sZ9g3S6NSfet_46wnnjChcC_agRNK38d5OIyXw7k-GcYERvIB3mG99bNXGtl7w6fbQO4vm6E41_3PyzbPBgY7hddAPSGq1TA8abykcXUvJDQrYjGHz6DpcACh4LwxiV7gMHlhVa1sTbnC9Po_RDVQ5amXn3dbVomw4pyhxCHJpaBLG3U9HmKvdqk'),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) const Sidebar(currentIndex: 1),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kiri: Menu Grid
                Expanded(
                  flex: 7,
                  child: Container(
                    color: AppColors.surfaceBright,
                    child: Column(
                      children: [
                        _buildSearchAndFilters(context),
                        Expanded(
                          child: GridView.count(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Tambah padding bawah biar gak ketutup FAB
                            crossAxisCount: isDesktop ? 3 : 2,
                            childAspectRatio: 0.75, // Disesuaikan biar lebih mobile-app style
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: [
                              _buildMenuCard(context, title: 'Artisan Latte', price: '\$4.50', desc: '12oz • Hot', icon: Icons.coffee),
                              _buildMenuCard(context, title: 'Smashed Avo', price: '\$9.00', desc: 'Sourdough', icon: Icons.breakfast_dining),
                              _buildMenuCard(context, title: 'Butter Croissant', price: '\$3.75', desc: 'Fresh Baked', icon: Icons.bakery_dining),
                              _buildMenuCard(context, title: 'Nitro Cold Brew', price: '\$5.50', desc: '16oz • Iced', icon: Icons.coffee_maker),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Kanan: Cart (Desktop Only)
                if (isDesktop)
                  Container(
                    width: 380,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(left: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)))
                    ),
                    child: _buildCartSection(context),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 1),

      // 3. Floating Action Button: View Cart Mobile
      floatingActionButton: !isDesktop
          ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () {
              // PINDAH KE HALAMAN ISI KERANJANG
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            label: SizedBox(
              width: MediaQuery.of(context).size.width - 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_basket, color: Colors.white),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('3 Items', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('View Cart', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Text('\$24.84', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)))
      ),
      child: TextField(
          decoration: InputDecoration(
            hintText: 'Cari menu...',
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))
            ),
          )
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required String price, required String desc, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16))
                    ),
                    child: Icon(icon, size: 40, color: AppColors.primary)
                )
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(desc, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                    const SizedBox(height: 8),
                    Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary))
                  ]
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCartSection(BuildContext context) {
    return Column(
      children: [
        const Padding(
            padding: EdgeInsets.all(24),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Current Order', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                ]
            )
        ),
        const Expanded(child: Center(child: Text('Keranjang Belanja (Desktop)'))),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))]
          ),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total'), Text('\$24.84', style: GoogleFonts.hankenGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary))]),
              const SizedBox(height: 16),
              SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      onPressed: () {},
                      child: const Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                  )
              ),
            ],
          ),
        )
      ],
    );
  }
}