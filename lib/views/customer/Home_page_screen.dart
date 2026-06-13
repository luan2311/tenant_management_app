import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

// ─── HomeScreen — Trang chủ khách thuê ───────────────────────────────────────
// HUY.3.1 · Sprint 3
class HomeScreen extends StatelessWidget {
  final VoidCallback? onViewAll;
  const HomeScreen({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: Stack(
        children: [
          const _AmbientBackground(),
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _GreetingSection(onViewAll: onViewAll),
                    const SizedBox(height: 24),
                    const _RoomCard(),
                    const SizedBox(height: 16),
                    const _UnpaidBillCard(),
                    const SizedBox(height: 16),
                    const _QuickShortcuts(),
                    const SizedBox(height: 24),
                    const _NotificationsSection(),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: kOnSurfaceVariant.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.bubble_chart_rounded, color: kPrimary, size: 26),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPrimaryFixed, kPrimary],
            ).createShader(bounds),
            child: const Text(
              'Lumiere Stay',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.4,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 26),
        ],
      ),
    );
  }
}

// ─── Ambient Background ───────────────────────────────────────────────────────
class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -80, left: -80,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimaryFixed.withValues(alpha: 0.3),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.33,
              right: -80,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kTertiaryContainer.withValues(alpha: 0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Greeting Section ─────────────────────────────────────────────────────────
class _GreetingSection extends StatelessWidget {
  final VoidCallback? onViewAll;
  const _GreetingSection({this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AuthService.getUserName(),
      builder: (context, snapshot) {
        final raw = snapshot.data ?? '';
        final name = raw.contains('@') ? raw.split('@').first : raw;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chào buổi sáng,',
                  style: TextStyle(
                    color: kOnSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name.isEmpty ? 'Khách thuê' : name,
                  style: const TextStyle(
                    color: kOnSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'Khám phá →',
                  style: TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Room Card (Glassmorphism) ────────────────────────────────────────────────
class _RoomCard extends StatelessWidget {
  const _RoomCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: kOutlineVariant.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                blurRadius: 16,
                offset: const Offset(-4, -4),
              ),
              BoxShadow(
                color: kOnSurfaceVariant.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(8, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20, top: -20,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kPrimaryFixed.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PHÒNG ĐANG THUÊ',
                            style: TextStyle(
                              color: kOnSurfaceVariant,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'P.101',
                            style: TextStyle(
                              color: kOnSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kPrimaryFixed,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Lumiere Stay',
                          style: TextStyle(
                            color: kOnPrimaryFixed,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _infoRow(Icons.calendar_month_outlined,
                      'Hợp đồng: 12/05/2024 – 12/05/2025'),
                  const SizedBox(height: 12),
                  _infoRow(Icons.group_outlined, '2 người ở'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: kPrimary, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: kOnSurface,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Unpaid Bill Card ─────────────────────────────────────────────────────────
const _kErrorContainer    = Color(0xFFFA746F);
const _kOnErrorContainer  = Color(0xFF6E0A12);
const _kErrorDim          = Color(0xFF67040D);

class _UnpaidBillCard extends StatelessWidget {
  const _UnpaidBillCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kErrorContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 16,
              offset: const Offset(-4, -4),
            ),
            BoxShadow(
              color: kOnSurfaceVariant.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: _kOnErrorContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hóa đơn tháng 10',
                      style: TextStyle(
                        color: _kOnErrorContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hạn chót: Hôm nay',
                      style: TextStyle(
                        color: _kErrorDim,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '3.450.000đ',
                  style: TextStyle(
                    color: _kOnErrorContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'CHƯA THANH TOÁN',
                  style: TextStyle(
                    color: _kErrorDim,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Shortcuts ──────────────────────────────────────────────────────────
class _QuickShortcuts extends StatelessWidget {
  const _QuickShortcuts();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ShortcutButton(
            icon: Icons.description_outlined,
            label: 'Xem hợp đồng',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ShortcutButton(
            icon: Icons.history_rounded,
            label: 'Lịch sử hóa đơn',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ShortcutButton extends StatefulWidget {
  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData     icon;
  final String       label;
  final VoidCallback onTap;

  @override
  State<_ShortcutButton> createState() => _ShortcutButtonState();
}

class _ShortcutButtonState extends State<_ShortcutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: _pressed ? kSurfaceContainerHigh : kSurfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.9),
              blurRadius: 10,
              offset: const Offset(-2, -2),
            ),
            BoxShadow(
              color: kOnSurfaceVariant.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.9),
                    blurRadius: 8,
                    offset: const Offset(-2, -2),
                  ),
                  BoxShadow(
                    color: kOnSurfaceVariant.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: kPrimary, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kOnSurface,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Notifications Section ────────────────────────────────────────────────────
class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông báo mới',
          style: TextStyle(
            color: kOnSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        const _NotificationItem(
          icon: Icons.campaign_rounded,
          iconColor: kPrimary,
          title: 'Lịch vệ sinh hành lang',
          body:
              'Ban quản lý sẽ tiến hành tổng vệ sinh hành lang vào sáng Chủ nhật (15/10). Vui lòng dọn dẹp giày dép.',
          time: '2 giờ trước',
        ),
        const SizedBox(height: 12),
        const _NotificationItem(
          icon: Icons.water_drop_rounded,
          iconColor: Color(0xFF585C85),
          title: 'Thông báo cúp nước tạm thời',
          body:
              'Khu vực sẽ tạm ngưng cấp nước từ 22:00 đến 04:00 sáng mai để bảo trì đường ống.',
          time: 'Hôm qua',
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
  });

  final IconData icon;
  final Color    iconColor;
  final String   title;
  final String   body;
  final String   time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 10,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: kOnSurfaceVariant.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kOnSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: kOnSurfaceVariant,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    color: kOutline,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
