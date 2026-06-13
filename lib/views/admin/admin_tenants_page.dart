import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/theme/styles.dart';

class AdminTenantsPage extends StatefulWidget {
  const AdminTenantsPage({super.key});

  @override
  State<AdminTenantsPage> createState() => _AdminTenantsPageState();
}

class _AdminTenantsPageState extends State<AdminTenantsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tenants = appState.filteredTenants;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
      children: [
        SanctuaryHeader(
          title: 'Khách thuê',
          subtitle: 'Tra cứu hồ sơ cư dân theo họ tên hoặc số điện thoại.',
          trailing: GlassmorphicContainer(
            width: 78,
            height: 44,
            borderRadius: 18,
            opacity: 0.74,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_alt_outlined, size: 17, color: AppColors.sanctuaryDark),
                const SizedBox(width: 6),
                Text('${tenants.length}', style: AppStyles.body(context, color: AppColors.sanctuaryDark, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _searchController,
          onChanged: (query) {
            setState(() {});
            appState.searchTenants(query);
          },
          decoration: InputDecoration(
            hintText: 'Tìm kiếm theo họ tên hoặc SĐT...',
            hintStyle: AppStyles.body(context, color: AppColors.textMuted, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.sanctuaryDark),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.sanctuaryDark),
                    onPressed: () {
                      _searchController.clear();
                      appState.searchTenants('');
                      setState(() {});
                    },
                  ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.62),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.70)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.sanctuaryDark, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (tenants.isEmpty)
          GlassmorphicContainer(
            height: 240,
            borderRadius: 22,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search_outlined, size: 54, color: AppColors.textSecondary.withOpacity(0.72)),
                const SizedBox(height: 14),
                Text('Không tìm thấy khách thuê.', style: AppStyles.body(context, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
              ],
            ),
          )
        else
          ...tenants.map((tenant) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GlassmorphicContainer(
                padding: const EdgeInsets.all(18),
                borderRadius: 22,
                opacity: 0.74,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.sanctuaryBlue.withOpacity(0.62),
                          child: Text(
                            tenant.fullName.trim().isEmpty ? '?' : tenant.fullName.trim()[0].toUpperCase(),
                            style: AppStyles.body(context, color: AppColors.sanctuaryDark, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tenant.fullName, style: AppStyles.title(context, color: AppColors.sanctuaryInk, fontSize: 17, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              Text(tenant.phone, style: AppStyles.caption(context, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        SoftIconButton(
                          icon: Icons.phone_in_talk_outlined,
                          color: AppColors.badgeRentedText,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đang kết nối cuộc gọi đến ${tenant.phone}')));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(icon: Icons.badge_outlined, label: 'CCCD / CMND', value: tenant.cccd),
                    const SizedBox(height: 10),
                    _InfoRow(icon: Icons.location_on_outlined, label: 'Quê quán', value: tenant.hometown ?? 'Không rõ'),
                    const SizedBox(height: 10),
                    _InfoRow(icon: Icons.calendar_today_outlined, label: 'Ngày bắt đầu', value: tenant.startDate ?? 'Chưa xác định'),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.sanctuaryDark.withOpacity(0.66)),
        const SizedBox(width: 10),
        SizedBox(
          width: 96,
          child: Text(label, style: AppStyles.caption(context, fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppStyles.body(context, color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
