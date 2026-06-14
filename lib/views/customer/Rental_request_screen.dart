import 'dart:convert' show jsonEncode;
import 'dart:math' show sin, pi;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:tenant_management_app/mock/room_mock_data.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/models/rental_request.dart';

// Danh sách 63 tỉnh/thành phố Việt Nam
const List<String> kProvinces = [
  'An Giang', 'Bà Rịa - Vũng Tàu', 'Bạc Liêu', 'Bắc Giang', 'Bắc Kạn', 'Bắc Ninh',
  'Bến Tre', 'Bình Dương', 'Bình Định', 'Bình Phước', 'Bình Thuận', 'Cà Mau',
  'Cao Bằng', 'Cần Thơ', 'Đà Nẵng', 'Đắk Lắk', 'Đắk Nông', 'Điện Biên',
  'Đồng Nai', 'Đồng Tháp', 'Gia Lai', 'Hà Giang', 'Hà Nam', 'Hà Nội',
  'Hà Tĩnh', 'Hải Dương', 'Hải Phòng', 'Hậu Giang', 'Hòa Bình', 'Hưng Yên',
  'Khánh Hòa', 'Kiên Giang', 'Kon Tum', 'Lai Châu', 'Lạng Sơn', 'Lào Cai',
  'Lâm Đồng', 'Long An', 'Nam Định', 'Nghệ An', 'Ninh Bình', 'Ninh Thuận',
  'Phú Thọ', 'Phú Yên', 'Quảng Bình', 'Quảng Nam', 'Quảng Ngãi', 'Quảng Ninh',
  'Quảng Trị', 'Sóc Trăng', 'Sơn La', 'Tây Ninh', 'Thái Bình', 'Thái Nguyên',
  'Thanh Hóa', 'Thừa Thiên Huế', 'Tiền Giang', 'TP Hồ Chí Minh', 'Trà Vinh',
  'Tuyên Quang', 'Vĩnh Long', 'Vĩnh Phúc', 'Yên Bái'
];

// ─── RentalRequestScreen — Yêu cầu thuê ──────────────────────────────────────
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
  DateTime? _selectedDate;
  
  // Quản lý thông tin người ở cùng
  int _roommatesCount = 0;
  final List<TextEditingController> _roommateNameControllers = [];
  final List<TextEditingController> _roommateCccdControllers = [];

  // Các GlobalKey để gọi hiệu ứng rung lắc (Shake)
  final GlobalKey<ShakeWidgetState> _nameShakeKey = GlobalKey<ShakeWidgetState>();
  final GlobalKey<ShakeWidgetState> _phoneShakeKey = GlobalKey<ShakeWidgetState>();
  final GlobalKey<ShakeWidgetState> _cccdShakeKey = GlobalKey<ShakeWidgetState>();
  final GlobalKey<ShakeWidgetState> _hometownShakeKey = GlobalKey<ShakeWidgetState>();
  final GlobalKey<ShakeWidgetState> _dateShakeKey = GlobalKey<ShakeWidgetState>();
  final List<GlobalKey<ShakeWidgetState>> _roommateNameShakeKeys = [];
  final List<GlobalKey<ShakeWidgetState>> _roommateCccdShakeKeys = [];

  // Biến lưu thông báo lỗi cho từng trường
  String? _nameError;
  String? _phoneError;
  String? _cccdError;
  String? _hometownError;
  String? _dateError;
  List<String?> _roommateNameErrors = [];
  List<String?> _roommateCccdErrors = [];

  bool _autovalidate = false;
  String? _selectedProvince;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _cccdController.addListener(_onFieldChanged);
    
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
    _nameController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _cccdController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _cccdController.dispose();
    
    for (final ctrl in _roommateNameControllers) {
      ctrl.removeListener(_onFieldChanged);
      ctrl.dispose();
    }
    for (final ctrl in _roommateCccdControllers) {
      ctrl.removeListener(_onFieldChanged);
      ctrl.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged() {
    if (_autovalidate) {
      setState(() {
        _validateForm();
      });
    }
  }

  void _updateRoommatesCount(int newCount) {
    final maxAllowedRoommates = widget.room.maxTenants > 0 ? widget.room.maxTenants - 1 : 0;
    if (newCount < 0 || newCount > maxAllowedRoommates) return;
    setState(() {
      _roommatesCount = newCount;
      while (_roommateNameControllers.length < _roommatesCount) {
        final nameCtrl = TextEditingController();
        final cccdCtrl = TextEditingController();
        nameCtrl.addListener(_onFieldChanged);
        cccdCtrl.addListener(_onFieldChanged);
        
        _roommateNameControllers.add(nameCtrl);
        _roommateCccdControllers.add(cccdCtrl);
        _roommateNameShakeKeys.add(GlobalKey<ShakeWidgetState>());
        _roommateCccdShakeKeys.add(GlobalKey<ShakeWidgetState>());
      }
      while (_roommateNameControllers.length > _roommatesCount) {
        _roommateNameControllers.last.removeListener(_onFieldChanged);
        _roommateCccdControllers.last.removeListener(_onFieldChanged);
        _roommateNameControllers.last.dispose();
        _roommateCccdControllers.last.dispose();
        
        _roommateNameControllers.removeLast();
        _roommateCccdControllers.removeLast();
        _roommateNameShakeKeys.removeLast();
        _roommateCccdShakeKeys.removeLast();
      }
      
      _roommateNameErrors = List.filled(_roommatesCount, null);
      _roommateCccdErrors = List.filled(_roommatesCount, null);
      
      if (_autovalidate) {
        _validateForm();
      }
    });
  }

  bool _validateForm() {
    bool isValid = true;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final cccd = _cccdController.text.trim();

    // 1. Validate Họ tên
    if (name.isEmpty) {
      _nameError = 'Vui lòng nhập họ và tên';
      isValid = false;
    } else if (name.length < 2) {
      _nameError = 'Họ và tên phải có ít nhất 2 ký tự';
      isValid = false;
    } else if (RegExp(r'[0-9]').hasMatch(name)) {
      _nameError = 'Họ và tên không được chứa chữ số';
      isValid = false;
    } else {
      _nameError = null;
    }

    // 2. Validate Điện thoại
    if (phone.isEmpty) {
      _phoneError = 'Vui lòng nhập số điện thoại';
      isValid = false;
    } else if (!RegExp(r'^0[35789][0-9]{8}$').hasMatch(phone)) {
      _phoneError = 'Số điện thoại không hợp lệ (10 chữ số bắt đầu bằng 03/05/07/08/09)';
      isValid = false;
    } else {
      _phoneError = null;
    }

    // 3. Validate CCCD (Chỉ nhận đúng 12 ký tự số)
    if (cccd.isEmpty) {
      _cccdError = 'Vui lòng nhập số CCCD';
      isValid = false;
    } else if (cccd.length != 12) {
      _cccdError = 'CCCD không hợp lệ (phải gồm đúng 12 chữ số)';
      isValid = false;
    } else if (!RegExp(r'^[0-9]+$').hasMatch(cccd)) {
      _cccdError = 'CCCD chỉ được chứa các chữ số';
      isValid = false;
    } else {
      _cccdError = null;
    }

    // 4. Validate Quê quán
    if (_selectedProvince == null) {
      _hometownError = 'Vui lòng chọn quê quán';
      isValid = false;
    } else {
      _hometownError = null;
    }

    // 5. Validate Ngày thuê (không được ở quá khứ)
    if (_selectedDate == null) {
      _dateError = 'Vui lòng chọn ngày dự kiến bắt đầu thuê';
      isValid = false;
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      if (selectedDay.isBefore(today)) {
        _dateError = 'Ngày bắt đầu thuê không được ở trong quá khứ';
        isValid = false;
      } else {
        _dateError = null;
      }
    }

    // 6. Validate Người ở cùng
    _roommateNameErrors = List.filled(_roommatesCount, null);
    _roommateCccdErrors = List.filled(_roommatesCount, null);
    for (int i = 0; i < _roommatesCount; i++) {
      final rName = _roommateNameControllers[i].text.trim();
      if (rName.isEmpty) {
        _roommateNameErrors[i] = 'Vui lòng nhập họ tên người ở cùng';
        isValid = false;
      } else if (rName.length < 2) {
        _roommateNameErrors[i] = 'Họ tên phải có ít nhất 2 ký tự';
        isValid = false;
      } else if (RegExp(r'[0-9]').hasMatch(rName)) {
        _roommateNameErrors[i] = 'Họ tên không được chứa chữ số';
        isValid = false;
      }

      final rCccd = _roommateCccdControllers[i].text.trim();
      if (rCccd.isEmpty) {
        _roommateCccdErrors[i] = 'Vui lòng nhập số CCCD người ở cùng';
        isValid = false;
      } else if (rCccd.length != 12) {
        _roommateCccdErrors[i] = 'CCCD không hợp lệ (phải gồm đúng 12 chữ số)';
        isValid = false;
      } else if (!RegExp(r'^[0-9]+$').hasMatch(rCccd)) {
        _roommateCccdErrors[i] = 'CCCD chỉ được chứa các chữ số';
        isValid = false;
      }
    }

    // 7. Validate số người ở cùng không vượt quá giới hạn tối đa của phòng
    final maxAllowedRoommates = widget.room.maxTenants > 0 ? widget.room.maxTenants - 1 : 0;
    if (_roommatesCount > maxAllowedRoommates) {
      isValid = false;
    }

    return isValid;
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
      setState(() {
        _selectedDate = picked;
        if (_autovalidate) {
          _validateForm();
        }
      });
    }
  }

  void _pickProvince() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProvincePickerBottomSheet(
          provinces: kProvinces,
          onSelected: (province) {
            setState(() {
              _selectedProvince = province;
              if (_autovalidate) {
                _validateForm();
              }
            });
          },
        );
      },
    );
  }

  String get _formattedDate {
    if (_selectedDate == null) return 'Chọn ngày';
    return '${_selectedDate!.day.toString().padLeft(2, '0')}/'
        '${_selectedDate!.month.toString().padLeft(2, '0')}/'
        '${_selectedDate!.year}';
  }

  void _decrementOccupants() {
    if (_roommatesCount > 0) {
      _updateRoommatesCount(_roommatesCount - 1);
    }
  }

  void _incrementOccupants() {
    final maxAllowedRoommates = widget.room.maxTenants > 0 ? widget.room.maxTenants - 1 : 0;
    if (_roommatesCount < maxAllowedRoommates) {
      _updateRoommatesCount(_roommatesCount + 1);
    }
  }

  void _submit() {
    setState(() {
      _autovalidate = true;
    });

    final isValid = _validateForm();
    if (!isValid) {
      // Kích hoạt hiệu ứng rung lắc cho các trường bị lỗi
      if (_nameError != null) _nameShakeKey.currentState?.shake();
      if (_phoneError != null) _phoneShakeKey.currentState?.shake();
      if (_cccdError != null) _cccdShakeKey.currentState?.shake();
      if (_hometownError != null) _hometownShakeKey.currentState?.shake();
      if (_dateError != null) _dateShakeKey.currentState?.shake();
      for (int i = 0; i < _roommatesCount; i++) {
        if (_roommateNameErrors[i] != null) {
          _roommateNameShakeKeys[i].currentState?.shake();
        }
        if (_roommateCccdErrors[i] != null) {
          _roommateCccdShakeKeys[i].currentState?.shake();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại thông tin nhập liệu'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final cccd = _cccdController.text.trim();

    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;
    if (user == null) return;

    // Chuỗi hóa thông tin người ở cùng sang định dạng JSON
    final roommatesJson = _roommatesCount > 0
        ? jsonEncode(List.generate(_roommatesCount, (index) => {
            'full_name': _roommateNameControllers[index].text.trim(),
            'cccd': _roommateCccdControllers[index].text.trim(),
          }))
        : null;

    final request = RentalRequestModel(
      roomId: widget.room.id,
      roomNumber: widget.room.roomNumber,
      userUid: user.uid,
      fullName: name,
      phone: phone,
      cccd: cccd,
      hometown: _selectedProvince,
      startDate: _selectedDate!.toIso8601String().substring(0, 10),
      occupants: _roommatesCount + 1, // Tổng số người ở = Khách thuê + số người ở cùng
      status: 'pending',
      createdAt: DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19),
      roommates: roommatesJson,
    );

    appState.sendRentalRequest(request).then((success) {
      if (!mounted) return;
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
          // ── Background blobs ──
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
                      // Drag handle
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
                      const _FieldLabel(label: 'Họ và tên khách thuê'),
                      const SizedBox(height: 8),
                      ShakeWidget(
                        key: _nameShakeKey,
                        child: _NeumorphicField(
                          icon: Icons.person_outline,
                          errorText: _nameError,
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
                      ),

                      const SizedBox(height: 16),

                      // Số điện thoại Field
                      const _FieldLabel(label: 'Số điện thoại liên hệ'),
                      const SizedBox(height: 8),
                      ShakeWidget(
                        key: _phoneShakeKey,
                        child: _NeumorphicField(
                          icon: Icons.phone_outlined,
                          errorText: _phoneError,
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
                      ),

                      const SizedBox(height: 16),

                      // Số CCCD Field
                      const _FieldLabel(label: 'Số CCCD (12 số)'),
                      const SizedBox(height: 8),
                      ShakeWidget(
                        key: _cccdShakeKey,
                        child: _NeumorphicField(
                          icon: Icons.badge_outlined,
                          errorText: _cccdError,
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
                      ),

                      const SizedBox(height: 16),

                      // Quê quán Field (chọn từ danh sách tỉnh thành)
                      const _FieldLabel(label: 'Quê quán (Tỉnh / Thành phố)'),
                      const SizedBox(height: 8),
                      ShakeWidget(
                        key: _hometownShakeKey,
                        child: _NeumorphicField(
                          onTap: _pickProvince,
                          icon: Icons.home_work_outlined,
                          errorText: _hometownError,
                          child: Text(
                            _selectedProvince ?? 'Chọn quê quán (Tỉnh / Thành)',
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedProvince == null
                                  ? kOnSurfaceVariant
                                  : kOnSurface,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Date Field
                      const _FieldLabel(label: 'Ngày dự kiến bắt đầu thuê'),
                      const SizedBox(height: 8),
                      ShakeWidget(
                        key: _dateShakeKey,
                        child: _NeumorphicField(
                          onTap: _pickDate,
                          icon: Icons.calendar_month_outlined,
                          errorText: _dateError,
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
                      ),

                      const SizedBox(height: 16),

                      // Occupants Field (Stepping roommates count >= 0)
                      const _FieldLabel(label: 'Số người ở cùng (bạn bè / người thân)'),
                      const SizedBox(height: 8),
                      _OccupantsField(
                        value: _roommatesCount,
                        onDecrement: _decrementOccupants,
                        onIncrement: _incrementOccupants,
                        maxValue: widget.room.maxTenants > 0 ? widget.room.maxTenants - 1 : 0,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phòng tối đa ${widget.room.maxTenants} người ở (chỉ được thêm tối đa ${widget.room.maxTenants > 0 ? widget.room.maxTenants - 1 : 0} người ở cùng)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: kOnSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      // Kê khai thông tin người ở cùng
                      if (_roommatesCount > 0) ...[
                        const SizedBox(height: 24),
                        const Row(
                          children: [
                            Icon(Icons.people_outline, color: kPrimary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Kê khai thông tin người ở cùng',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kOnSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_roommatesCount, (index) {
                          return Container(
                            key: ValueKey('roommate_$index'),
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: kSurfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: kOutlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Người ở cùng thứ ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Tên người ở cùng
                                const _FieldLabel(label: 'Họ và tên'),
                                const SizedBox(height: 6),
                                ShakeWidget(
                                  key: _roommateNameShakeKeys[index],
                                  child: _NeumorphicField(
                                    icon: Icons.person_outline,
                                    errorText: _roommateNameErrors[index],
                                    child: TextField(
                                      controller: _roommateNameControllers[index],
                                      decoration: const InputDecoration(
                                        hintText: 'Nhập họ tên đầy đủ',
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: const TextStyle(fontSize: 15, color: kOnSurface),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // CCCD người ở cùng
                                const _FieldLabel(label: 'Số CCCD (12 số)'),
                                const SizedBox(height: 6),
                                ShakeWidget(
                                  key: _roommateCccdShakeKeys[index],
                                  child: _NeumorphicField(
                                    icon: Icons.badge_outlined,
                                    errorText: _roommateCccdErrors[index],
                                    child: TextField(
                                      controller: _roommateCccdControllers[index],
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
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

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
        decoration: const BoxDecoration(
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
class _NeumorphicField extends StatelessWidget {
  final Widget child;
  final IconData icon;
  final VoidCallback? onTap;
  final String? errorText;

  const _NeumorphicField({
    required this.child,
    required this.icon,
    this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kSurfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasError
                    ? Colors.redAccent.withValues(alpha: 0.6)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                if (hasError) ...[
                  // Red glow shadow
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(2, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.90),
                    blurRadius: 8,
                    offset: const Offset(-2, -2),
                  ),
                ] else ...const [
                  // Normal inset dark shadow (top-left)
                  BoxShadow(
                    color: Color(0x1A596064),
                    blurRadius: 8,
                    offset: Offset(4, 4),
                    spreadRadius: 0,
                  ),
                  // Normal inset light shadow (bottom-right)
                  BoxShadow(
                    color: Color(0xB3FFFFFF),
                    blurRadius: 8,
                    offset: Offset(-4, -4),
                    spreadRadius: 0,
                  ),
                ]
              ],
            ),
            child: Row(
              children: [
                Expanded(child: child),
                Icon(
                  icon,
                  color: hasError ? Colors.redAccent.shade700 : kOnSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: errorText == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(left: 8, top: 6),
                  child: Text(
                    errorText!,
                    style: TextStyle(
                      color: Colors.redAccent.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Occupants field (stepper roommates >= 0) ──────────────────────────────
class _OccupantsField extends StatelessWidget {
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final int maxValue;

  const _OccupantsField({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.maxValue,
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
            enabled: value > 0,
          ),
          // Giá trị ở giữa
          Expanded(
            child: Center(
              child: Text(
                value == 0 ? 'Không có (ở một mình)' : '$value người',
                style: const TextStyle(
                  fontSize: 15,
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
            enabled: value < maxValue,
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

// ─── Province Picker Bottom Sheet ───────────────────────────────────────────
class _ProvincePickerBottomSheet extends StatefulWidget {
  final List<String> provinces;
  final ValueChanged<String> onSelected;

  const _ProvincePickerBottomSheet({
    required this.provinces,
    required this.onSelected,
  });

  @override
  State<_ProvincePickerBottomSheet> createState() => _ProvincePickerBottomSheetState();
}

class _ProvincePickerBottomSheetState extends State<_ProvincePickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredProvinces = [];

  @override
  void initState() {
    super.initState();
    _filteredProvinces = widget.provinces;
    _searchController.addListener(_filterProvinces);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProvinces() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProvinces = widget.provinces;
      } else {
        _filteredProvinces = widget.provinces
            .where((p) => p.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: kOutlineVariant.withValues(alpha: 0.2),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: kOutlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Chọn quê quán',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kOnSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: kSurfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm tỉnh/thành...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: kOnSurfaceVariant),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredProvinces.isEmpty
                    ? const Center(
                        child: Text(
                          'Không tìm thấy tỉnh/thành nào',
                          style: TextStyle(color: kOnSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredProvinces.length,
                        itemBuilder: (context, index) {
                          final province = _filteredProvinces[index];
                          return ListTile(
                            title: Text(
                              province,
                              style: const TextStyle(color: kOnSurface),
                            ),
                            onTap: () {
                              widget.onSelected(province);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shake Widget for Validation Vibrations ─────────────────────────────────
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double shakeOffset;

  const ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.shakeOffset = 8.0,
  });

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shake() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        if (_controller.value == 0.0 || _controller.value == 1.0) {
          return child!;
        }
        final double progress = _controller.value;
        final double offset = sin(progress * 4 * pi) * widget.shakeOffset * (1.0 - progress);
        return Transform.translate(
          offset: Offset(offset, 0.0),
          child: child,
        );
      },
    );
  }
}

// ─── Gradient submit button ──────────────────────────────────────────────────
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