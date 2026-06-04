import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/room.dart';
import '../../service/app_state.dart';
import '../../theme/styles.dart';

class AdminAddRoomPage extends StatefulWidget {
  final RoomModel? room;

  const AdminAddRoomPage({super.key, this.room});

  @override
  State<AdminAddRoomPage> createState() => _AdminAddRoomPageState();
}

class _AdminAddRoomPageState extends State<AdminAddRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  final _maxTenantsController = TextEditingController(text: '2');
  int? _selectedFacilityId;
  String _selectedStatus = 'empty';

  @override
  void initState() {
    super.initState();
    final editingRoom = widget.room;

    if (editingRoom != null) {
      _roomNumberController.text = editingRoom.roomNumber;
      _priceController.text = editingRoom.price.toStringAsFixed(0);
      _depositController.text = editingRoom.deposit.toStringAsFixed(0);
      _maxTenantsController.text = editingRoom.maxTenants.toString();
      _selectedFacilityId = editingRoom.facilityId;
      _selectedStatus = editingRoom.status;
    } else {
      final facilities = context.read<AppState>().facilities;
      if (facilities.isNotEmpty) {
        _selectedFacilityId = facilities.first.id;
      }
    }
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _maxTenantsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedFacilityId == null) return;

    final room = RoomModel(
      id: widget.room?.id,
      facilityId: _selectedFacilityId,
      roomNumber: _roomNumberController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      deposit: double.parse(_depositController.text.trim()),
      maxTenants: int.parse(_maxTenantsController.text.trim()),
      status: _selectedStatus,
    );

    final success = widget.room == null
        ? await context.read<AppState>().addNewRoom(room)
        : await context.read<AppState>().updateRoom(room);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (widget.room == null ? 'Thêm phòng mới thành công!' : 'Cập nhật thông tin phòng thành công!')
              : (widget.room == null ? 'Thêm phòng mới thất bại. Vui lòng kiểm tra lại.' : 'Cập nhật phòng thất bại. Vui lòng kiểm tra lại.'),
        ),
      ),
    );

    if (success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final facilities = appState.facilities;
    final isEditing = widget.room != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SoftIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: EtherealBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              const SizedBox(height: 24),
              SanctuaryHeader(
                title: isEditing ? 'Cập nhật phòng' : 'Thêm phòng mới',
                subtitle: isEditing
                    ? 'Điều chỉnh thông tin phòng, giá thuê, cọc và trạng thái.'
                    : 'Điền thông tin phòng để cập nhật kho phòng Lumiere Stay.',
              ),
              const SizedBox(height: 28),
              GlassmorphicContainer(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                opacity: 0.76,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionTitle(icon: Icons.home_work_outlined, title: 'Thông tin phòng'),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<int>(
                        value: _selectedFacilityId,
                        decoration: _inputDecoration('Cơ sở nhà trọ', Icons.business_outlined),
                        items: facilities.map((fac) => DropdownMenuItem<int>(value: fac.id, child: Text(fac.name))).toList(),
                        onChanged: (value) => setState(() => _selectedFacilityId = value),
                        validator: (value) => value == null ? 'Vui lòng chọn cơ sở' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _roomNumberController,
                        decoration: _inputDecoration('Số phòng / Tên phòng', Icons.meeting_room_outlined),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập số phòng' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Giá thuê (đ/tháng)', Icons.payments_outlined),
                        validator: _positiveMoneyValidator,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _depositController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Tiền đặt cọc (đ)', Icons.savings_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Vui lòng nhập tiền đặt cọc';
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed < 0) return 'Tiền cọc không được là số âm';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _maxTenantsController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Số người ở tối đa', Icons.people_alt_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Vui lòng nhập số người ở tối đa';
                          final parsed = int.tryParse(value);
                          if (parsed == null || parsed <= 0) return 'Số người ở tối đa phải lớn hơn 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: _inputDecoration('Trạng thái phòng', Icons.tune_outlined),
                        items: const [
                          DropdownMenuItem(value: 'empty', child: Text('Trống')),
                          DropdownMenuItem(value: 'rented', child: Text('Đang thuê')),
                          DropdownMenuItem(value: 'maintenance', child: Text('Bảo trì')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _selectedStatus = value);
                        },
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
                        onPressed: appState.isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sanctuaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        icon: appState.isLoading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Icon(isEditing ? Icons.save_outlined : Icons.add_home_outlined),
                        label: Text(
                          isEditing ? 'Lưu thay đổi' : 'Thêm phòng',
                          style: AppStyles.body(context, color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _positiveMoneyValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập giá thuê';
    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) return 'Giá thuê phải là số dương';
    return null;
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.sanctuaryDark, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.58),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.72)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.sanctuaryDark, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.badgeMaintenanceText, width: 1.2),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.sanctuaryBlue.withOpacity(0.62),
          child: Icon(icon, color: AppColors.sanctuaryDark, size: 19),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppStyles.title(context, color: AppColors.sanctuaryInk, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
