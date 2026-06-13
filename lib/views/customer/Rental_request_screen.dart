import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:tenant_management_app/mock/room_mock_data.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/models/rental_request.dart';

// ─── RentalRequestScreen — Yêu cầu thuê ──────────────────────────────────────
// HUY.4.1 · Sprint 4
// Form gửi yêu cầu thuê cho 1 phòng cụ thể: ngày dự kiến nhận phòng + số người ở.
// Nhận `room` từ RoomDetailScreen (nút "Gửi yêu cầu thuê").
class RentalRequestScreen extends StatefulWidget {
  final RoomData room;

  const RentalRequestScreen({super.key, required this.room});

  @override
  State<RentalRequestScreen> createState() => _RentalRequestScreenState();
}

class _RentalRequestScreenState extends State<RentalRequestScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  final TextEditingController _hometownController = TextEditingController();
  final TextEditingController _occupantsController = TextEditingController(text: '1');
  DateTime? _selectedDate;
  int _occupants = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      final user = appState.currentUser;
      if (user != null) {
        setState(() {
          _nameController.text = user.fullName;
          _phoneController.text = user.phone ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cccdController.dispose();
    _hometownController.dispose();
    _occupantsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimary,
              onPrimary: kOnPrimary,
              surface: kSurface,
              onSurface: kOnSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String get _formattedDate {
    if (_selectedDate == null) return 'Chọn ngày';
    return '${_selectedDate!.day.toString().padLeft(2, '0')}/'
        '${_selectedDate!.month.toString().padLeft(2, '0')}/'
        '${_selectedDate!.year}';
  }

  void _decrementOccupants() {
    if (_occupants > 1) {
      setState(() {
        _occupants--;
        _occupantsController.text = _occupants.toString();
      });
    }
  }

  void _incrementOccupants() {
    if (_occupants < 10) {
      setState(() {
        _occupants++;
        _occupantsController.text = _occupants.toString();
      });
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final cccd = _cccdController.text.trim();
    final hometown = _hometownController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập họ tên')),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
      );
      return;
    }
    if (cccd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số CCCD/CMND')),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày dự kiến thuê')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;
    if (user == null) return;

    final request = RentalRequestModel(
      roomId: widget.room.id,
      roomNumber: widget.room.roomNumber,
      userUid: user.uid,
      fullName: name,
      phone: phone,
      cccd: cccd,
      hometown: hometown.isNotEmpty ? hometown : null,
      startDate: _selectedDate!.toIso8601String().substring(0, 10),
      occupants: _occupants,
      status: 'pending',
      createdAt: DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19),
    );

    appState.sendRentalRequest(request).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi yêu cầu thuê phòng ${widget.room.roomNumber} thành công!'),
            backgroundColor: kPrimary,
          ),
        );
        Navigator.maybePop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gửi yêu cầu thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: Stack(
        children: [
          // ── Background blobs (giống 2 div blur trang trí trong HTML) ──
          Positioned(
            top: -80,
            left: -80,
            child: _BlobDecoration(
              size: 320,
              color: kPrimaryFixed.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _BlobDecoration(
              size: 280,
              color: kSecondaryContainer.withValues(alpha: 0.3),
            ),
          ),

          // ── Bottom Sheet Panel ──────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: _GlassPanel(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag handle (chỉ hiển thị trên mobile — luôn show trong app)
                      Center(
                        child: Container(
                          width: 48,
                          height: 6,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: kSurfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gửi yêu cầu thuê',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: kOnSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          _CloseButton(onTap: () => Navigator.maybePop(context)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phòng ${widget.room.roomNumber} · ${widget.room.facility}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kOnSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Họ tên Field
                      _FieldLabel(label: 'Họ và tên khách thuê'),
                      const SizedBox(height: 8),
                      _NeumorphicField(
                        icon: Icons.person_outline,
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Nhập họ tên đầy đủ',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 15, color: kOnSurface),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Số điện thoại Field
                      _FieldLabel(label: 'Số điện thoại liên hệ'),
                      const SizedBox(height: 8),
                      _NeumorphicField(
                        icon: Icons.phone_outlined,
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Nhập số điện thoại',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 15, color: kOnSurface),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Số CCCD Field
                      _FieldLabel(label: 'Số CCCD / CMND'),
                      const SizedBox(height: 8),
                      _NeumorphicField(
                        icon: Icons.badge_outlined,
                        child: TextField(
                          controller: _cccdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Nhập 12 số CCCD',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 15, color: kOnSurface),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Quê quán Field
                      _FieldLabel(label: 'Quê quán (Tỉnh / Thành phố)'),
                      const SizedBox(height: 8),
                      _NeumorphicField(
                        icon: Icons.home_work_outlined,
                        child: TextField(
                          controller: _hometownController,
                          decoration: const InputDecoration(
                            hintText: 'Nhập tỉnh/thành quê quán',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 15, color: kOnSurface),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Date Field
                      _FieldLabel(label: 'Ngày dự kiến bắt đầu thuê'),
                      const SizedBox(height: 8),
                      _NeumorphicField(
                        onTap: _pickDate,
                        icon: Icons.calendar_month_outlined,
                        child: Text(
                          _formattedDate,
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedDate == null
                                ? kOnSurfaceVariant
                                : kOnSurface,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Occupants Field
                      _FieldLabel(label: 'Số người ở cùng'),
                      const SizedBox(height: 8),
                      _OccupantsField(
                        value: _occupants,
                        onDecrement: _decrementOccupants,
                        onIncrement: _incrementOccupants,
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed >= 1 && parsed <= 10) {
                            setState(() => _occupants = parsed);
                          }
                        },
                        controller: _occupantsController,
                      ),

                      const SizedBox(height: 28),

                      // Submit Button
                      _GradientButton(
                        label: 'Gửi yêu cầu',
                        onPressed: _submit,
                      ),

                      // Safe area bottom padding
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Blob trang trí nền ────────────────────────────────────────────────────
class _BlobDecoration extends StatelessWidget {
  final double size;
  final Color color;

  const _BlobDecoration({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: const SizedBox(),
      ),
    );
  }
}

// ─── Glass panel (glassmorphism container) ──────────────────────────────────
// Dùng ClipRRect + BackdropFilter để tạo hiệu ứng blur nền giống CSS
// backdrop-filter: blur(20px) trong HTML gốc
class _GlassPanel extends StatelessWidget {
  final Widget child;

  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: kOutlineVariant.withValues(alpha: 0.15),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D596064),
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
              BoxShadow(
                color: Colors.white,
                blurRadius: 20,
                offset: Offset(-4, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: child,
        ),
      ),
    );
  }
}

// ─── Close button ───────────────────────────────────────────────────────────
class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: const Icon(
          Icons.close,
          color: kOnSurfaceVariant,
          size: 22,
        ),
      ),
    );
  }
}

// ─── Field label ────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: kOnSurfaceVariant,
      ),
    );
  }
}

// ─── Neumorphic input field (inset shadow) ──────────────────────────────────
// Map từ class .inset-neumorphism trong HTML:
// box-shadow: inset 4px 4px 8px rgba(89,96,100,0.1), inset -4px -4px 8px rgba(255,255,255,0.7)
class _NeumorphicField extends StatelessWidget {
  final Widget child;
  final IconData icon;
  final VoidCallback? onTap;

  const _NeumorphicField({
    required this.child,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kSurfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            // inset dark shadow (top-left)
            BoxShadow(
              color: Color(0x1A596064),
              blurRadius: 8,
              offset: Offset(4, 4),
              spreadRadius: 0,
            ),
            // inset light shadow (bottom-right)
            BoxShadow(
              color: Color(0xB3FFFFFF),
              blurRadius: 8,
              offset: Offset(-4, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: child),
            Icon(icon, color: kOnSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Occupants field (number input với stepper) ──────────────────────────────
class _OccupantsField extends StatelessWidget {
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const _OccupantsField({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: kSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A596064),
            blurRadius: 8,
            offset: Offset(4, 4),
          ),
          BoxShadow(
            color: Color(0xB3FFFFFF),
            blurRadius: 8,
            offset: Offset(-4, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nút giảm
          _StepperButton(
            icon: Icons.remove,
            onTap: onDecrement,
            enabled: value > 1,
          ),
          // Giá trị ở giữa
          Expanded(
            child: Center(
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kOnSurface,
                ),
              ),
            ),
          ),
          // Nút tăng
          _StepperButton(
            icon: Icons.add,
            onTap: onIncrement,
            enabled: value < 10,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.group_outlined,
              color: kOnSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? kPrimaryFixed.withValues(alpha: 0.4)
              : kSurfaceContainerHigh,
        ),
        child: Icon(
          icon,
          size: 18,
          color:
              enabled ? kPrimary : kOnSurfaceVariant,
        ),
      ),
    );
  }
}

// ─── Gradient submit button ──────────────────────────────────────────────────
// Map từ class .signature-gradient trong HTML:
// background: linear-gradient(135deg, #a5d8ff, #2e6486)
class _GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _GradientButton({required this.label, required this.onPressed});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFA5D8FF), // primary-fixed
                Color(0xFF2E6486), // primary
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(4, 8),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 16,
                offset: Offset(-4, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: kOnPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.send_rounded,
                color: kOnPrimary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}