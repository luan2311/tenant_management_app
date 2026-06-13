import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/models/contract.dart';
import 'package:tenant_management_app/models/invoice.dart';
import 'package:tenant_management_app/models/room.dart';
import 'package:tenant_management_app/models/tenant.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/theme/styles.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _billingMonthController = TextEditingController();
  final _newElectricityController = TextEditingController();
  final _newWaterController = TextEditingController();
  final _electricityPriceController = TextEditingController(text: '3500');
  final _waterPriceController = TextEditingController(text: '15000');
  final _servicePriceController = TextEditingController(text: '0');
  final _otherPriceController = TextEditingController(text: '0');

  ContractModel? _selectedContract;

  @override
  void initState() {
    super.initState();
    _billingMonthController.text = _formatBillingMonth(DateTime.now());
  }

  @override
  void dispose() {
    _billingMonthController.dispose();
    _newElectricityController.dispose();
    _newWaterController.dispose();
    _electricityPriceController.dispose();
    _waterPriceController.dispose();
    _servicePriceController.dispose();
    _otherPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final activeContracts =
        appState.contracts
            .where((contract) => contract.status == 'active')
            .toList()
          ..sort((a, b) => a.roomId.compareTo(b.roomId));

    if (_selectedContract == null && activeContracts.isNotEmpty) {
      _selectedContract = activeContracts.first;
    }

    final room = _selectedContract == null
        ? null
        : _firstWhereOrNull<RoomModel>(
            appState.rooms,
            (item) => item.id == _selectedContract!.roomId,
          );
    final tenant = _selectedContract == null
        ? null
        : _firstWhereOrNull<TenantModel>(
            appState.tenants,
            (item) => item.id == _selectedContract!.tenantId,
          );
    final baseReadings = _baseReadings(appState, _selectedContract);
    final preview = _invoicePreview(room, baseReadings);
    final hasDuplicate =
        _selectedContract != null &&
        appState.invoices.any(
          (invoice) =>
              invoice.contractId == _selectedContract!.id &&
              invoice.billingMonth == _billingMonthController.text.trim(),
        );

    return Scaffold(
      body: EtherealBackground(
        child: SafeArea(
          bottom: false,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
              children: [
                SanctuaryHeader(
                  title: 'Tạo hóa đơn',
                  subtitle:
                      'Nhập chỉ số hiện tại, hệ thống tự tính điện nước và cộng tiền phòng.',
                  trailing: SoftIconButton(
                    icon: Icons.close_rounded,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
                const SizedBox(height: 22),
                if (activeContracts.isEmpty)
                  GlassmorphicContainer(
                    height: 240,
                    borderRadius: 22,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 54,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.72,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Chưa có hợp đồng đang hiệu lực để tạo hóa đơn.',
                          textAlign: TextAlign.center,
                          style: AppStyles.body(
                            context,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _SectionCard(
                    title: 'Phòng cần lập hóa đơn',
                    icon: Icons.meeting_room_outlined,
                    children: [
                      DropdownButtonFormField<ContractModel>(
                        initialValue: _selectedContract,
                        isExpanded: true,
                        decoration: _inputDecoration(context, 'Chọn phòng'),
                        items: activeContracts.map((contract) {
                          final itemRoom = _firstWhereOrNull<RoomModel>(
                            appState.rooms,
                            (room) => room.id == contract.roomId,
                          );
                          final itemTenant = _firstWhereOrNull<TenantModel>(
                            appState.tenants,
                            (tenant) => tenant.id == contract.tenantId,
                          );
                          return DropdownMenuItem(
                            value: contract,
                            child: Text(
                              'Phòng ${itemRoom?.roomNumber ?? contract.roomId} - ${itemTenant?.fullName ?? 'Khách thuê'}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedContract = value;
                            _newElectricityController.clear();
                            _newWaterController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _InfoLine(
                        label: 'Khách thuê',
                        value: tenant?.fullName ?? 'Chưa xác định',
                      ),
                      const SizedBox(height: 8),
                      _InfoLine(
                        label: 'Tiền phòng',
                        value: room == null ? '-' : _formatMoney(room.price),
                      ),
                      const SizedBox(height: 8),
                      _InfoLine(
                        label: 'Tháng hóa đơn',
                        value: _billingMonthController.text,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Chỉ số hiện tại',
                    icon: Icons.speed_outlined,
                    children: [
                      TextFormField(
                        controller: _billingMonthController,
                        keyboardType: TextInputType.datetime,
                        decoration: _inputDecoration(
                          context,
                          'Tháng hóa đơn (YYYY-MM)',
                        ),
                        validator: _validateBillingMonth,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      _ReadingsHint(baseReadings: baseReadings),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _newElectricityController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                context,
                                'Số điện hiện tại',
                              ),
                              validator: (value) => _validateCurrentReading(
                                value,
                                baseReadings.electricity,
                                'Số điện',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _newWaterController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                context,
                                'Số nước hiện tại',
                              ),
                              validator: (value) => _validateCurrentReading(
                                value,
                                baseReadings.water,
                                'Số nước',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Đơn giá',
                    icon: Icons.price_change_outlined,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _electricityPriceController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                context,
                                'Giá điện / kWh',
                              ),
                              validator: (value) =>
                                  _validatePositiveNumber(value, 'Giá điện'),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _waterPriceController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                context,
                                'Giá nước / m³',
                              ),
                              validator: (value) =>
                                  _validatePositiveNumber(value, 'Giá nước'),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _servicePriceController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                context,
                                'Phí dịch vụ',
                              ),
                              validator: (value) => _validateNonNegativeNumber(
                                value,
                                'Phí dịch vụ',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _otherPriceController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(context, 'Phí khác'),
                              validator: (value) =>
                                  _validateNonNegativeNumber(value, 'Phí khác'),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InvoicePreviewCard(preview: preview),
                  if (hasDuplicate) ...[
                    const SizedBox(height: 12),
                    _WarningBox(
                      message:
                          'Phòng này đã có hóa đơn cho tháng ${_billingMonthController.text}.',
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: hasDuplicate
                        ? null
                        : () => _saveInvoice(
                            context,
                            appState,
                            room,
                            baseReadings,
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sanctuaryDark,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.textMuted.withValues(
                        alpha: 0.28,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: Text(
                      'Tạo hóa đơn',
                      style: AppStyles.body(
                        context,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _BaseReadings _baseReadings(AppState appState, ContractModel? contract) {
    if (contract == null) return const _BaseReadings(0, 0, 'Chỉ số ban đầu');

    final billingMonth = _billingMonthController.text.trim();
    final previousMonth = _previousBillingMonth(billingMonth);
    final previousInvoice = previousMonth == null
        ? null
        : _firstWhereOrNull<InvoiceModel>(
            appState.invoices,
            (invoice) =>
                invoice.contractId == contract.id &&
                invoice.billingMonth == previousMonth,
          );

    if (previousInvoice != null) {
      return _BaseReadings(
        previousInvoice.newElectricity,
        previousInvoice.newWater,
        'Lấy từ hóa đơn tháng $previousMonth',
      );
    }

    return _BaseReadings(
      contract.initialElectricity,
      contract.initialWater,
      'Lấy từ chỉ số ban đầu của hợp đồng',
    );
  }

  _InvoicePreview _invoicePreview(RoomModel? room, _BaseReadings baseReadings) {
    final newElectricity = _parseNumber(_newElectricityController.text);
    final newWater = _parseNumber(_newWaterController.text);
    final electricityPrice = _parseNumber(_electricityPriceController.text);
    final waterPrice = _parseNumber(_waterPriceController.text);
    final servicePrice = _parseNumber(_servicePriceController.text);
    final otherPrice = _parseNumber(_otherPriceController.text);
    final electricityUsage = (newElectricity - baseReadings.electricity)
        .clamp(0, double.infinity)
        .toDouble();
    final waterUsage = (newWater - baseReadings.water)
        .clamp(0, double.infinity)
        .toDouble();
    final electricityTotal = electricityUsage * electricityPrice;
    final waterTotal = waterUsage * waterPrice;
    final roomPrice = room?.price ?? 0.0;

    return _InvoicePreview(
      roomPrice: roomPrice,
      electricityUsage: electricityUsage,
      waterUsage: waterUsage,
      electricityTotal: electricityTotal,
      waterTotal: waterTotal,
      servicePrice: servicePrice,
      otherPrice: otherPrice,
      total:
          roomPrice + electricityTotal + waterTotal + servicePrice + otherPrice,
    );
  }

  Future<void> _saveInvoice(
    BuildContext context,
    AppState appState,
    RoomModel? room,
    _BaseReadings baseReadings,
  ) async {
    if (_selectedContract == null || room == null) return;
    if (_formKey.currentState?.validate() != true) return;

    final preview = _invoicePreview(room, baseReadings);
    final invoice = InvoiceModel(
      roomId: room.id!,
      contractId: _selectedContract!.id!,
      billingMonth: _billingMonthController.text.trim(),
      oldElectricity: baseReadings.electricity,
      newElectricity: _parseNumber(_newElectricityController.text),
      oldWater: baseReadings.water,
      newWater: _parseNumber(_newWaterController.text),
      electricityPrice: _parseNumber(_electricityPriceController.text),
      waterPrice: _parseNumber(_waterPriceController.text),
      servicePrice: _parseNumber(_servicePriceController.text),
      otherPrice: _parseNumber(_otherPriceController.text),
      totalPrice: preview.total,
    );

    final success = await appState.saveInvoice(invoice);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Đã tạo hóa đơn.' : 'Tạo hóa đơn thất bại.'),
      ),
    );
    if (success) Navigator.of(context).pop();
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppStyles.caption(context, color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.68),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.78)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.sanctuaryDark,
          width: 1.4,
        ),
      ),
      errorMaxLines: 2,
    );
  }

  String? _validateBillingMonth(String? value) {
    final text = value?.trim() ?? '';
    if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(text)) {
      return 'Nhập theo định dạng YYYY-MM';
    }
    final month = int.tryParse(text.substring(5));
    if (month == null || month < 1 || month > 12) {
      return 'Tháng không hợp lệ';
    }
    return null;
  }

  String? _validateCurrentReading(
    String? value,
    double baseValue,
    String label,
  ) {
    final number = double.tryParse((value ?? '').trim());
    if (number == null) return '$label không hợp lệ';
    if (number < baseValue) {
      return '$label hiện tại phải lớn hơn hoặc bằng chỉ số cũ';
    }
    return null;
  }

  String? _validatePositiveNumber(String? value, String label) {
    final number = double.tryParse((value ?? '').trim());
    if (number == null || number <= 0) return '$label phải lớn hơn 0';
    return null;
  }

  String? _validateNonNegativeNumber(String? value, String label) {
    final number = double.tryParse((value ?? '').trim());
    if (number == null || number < 0) return '$label không được âm';
    return null;
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      opacity: 0.74,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.sanctuaryBlue.withValues(
                  alpha: 0.62,
                ),
                child: Icon(icon, size: 18, color: AppColors.sanctuaryDark),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppStyles.body(
                  context,
                  color: AppColors.sanctuaryInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _ReadingsHint extends StatelessWidget {
  final _BaseReadings baseReadings;

  const _ReadingsHint({required this.baseReadings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sanctuaryBlue.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _InfoLine(
            label: 'Chỉ số điện cũ',
            value: _formatNumber(baseReadings.electricity),
          ),
          const SizedBox(height: 8),
          _InfoLine(
            label: 'Chỉ số nước cũ',
            value: _formatNumber(baseReadings.water),
          ),
          const SizedBox(height: 8),
          _InfoLine(label: 'Nguồn dữ liệu', value: baseReadings.source),
        ],
      ),
    );
  }
}

class _InvoicePreviewCard extends StatelessWidget {
  final _InvoicePreview preview;

  const _InvoicePreviewCard({required this.preview});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      opacity: 0.82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tạm tính hóa đơn',
            style: AppStyles.body(
              context,
              color: AppColors.sanctuaryInk,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _InfoLine(
            label: 'Tiền phòng',
            value: _formatMoney(preview.roomPrice),
          ),
          const SizedBox(height: 8),
          _InfoLine(
            label: 'Điện (${_formatNumber(preview.electricityUsage)} kWh)',
            value: _formatMoney(preview.electricityTotal),
          ),
          const SizedBox(height: 8),
          _InfoLine(
            label: 'Nước (${_formatNumber(preview.waterUsage)} m³)',
            value: _formatMoney(preview.waterTotal),
          ),
          const SizedBox(height: 8),
          _InfoLine(
            label: 'Dịch vụ',
            value: _formatMoney(preview.servicePrice),
          ),
          const SizedBox(height: 8),
          _InfoLine(label: 'Phí khác', value: _formatMoney(preview.otherPrice)),
          const Divider(height: 26, color: Colors.white70),
          Row(
            children: [
              Text(
                'Tổng cộng',
                style: AppStyles.title(
                  context,
                  color: AppColors.sanctuaryInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                _formatMoney(preview.total),
                style: AppStyles.title(
                  context,
                  color: AppColors.sanctuaryInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppStyles.caption(context, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppStyles.body(
              context,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _WarningBox extends StatelessWidget {
  final String message;

  const _WarningBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.badgeMaintenanceBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.badgeMaintenanceText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppStyles.caption(
                context,
                color: AppColors.badgeMaintenanceText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BaseReadings {
  final double electricity;
  final double water;
  final String source;

  const _BaseReadings(this.electricity, this.water, this.source);
}

class _InvoicePreview {
  final double roomPrice;
  final double electricityUsage;
  final double waterUsage;
  final double electricityTotal;
  final double waterTotal;
  final double servicePrice;
  final double otherPrice;
  final double total;

  const _InvoicePreview({
    required this.roomPrice,
    required this.electricityUsage,
    required this.waterUsage,
    required this.electricityTotal,
    required this.waterTotal,
    required this.servicePrice,
    required this.otherPrice,
    required this.total,
  });
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}

double _parseNumber(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0.0;
}

String _formatBillingMonth(DateTime value) {
  return '${value.year}-${value.month.toString().padLeft(2, '0')}';
}

String? _previousBillingMonth(String billingMonth) {
  if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(billingMonth)) return null;
  final year = int.tryParse(billingMonth.substring(0, 4));
  final month = int.tryParse(billingMonth.substring(5));
  if (year == null || month == null || month < 1 || month > 12) return null;
  final previous = month == 1
      ? DateTime(year - 1, 12)
      : DateTime(year, month - 1);
  return _formatBillingMonth(previous);
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}

String _formatMoney(double amount) {
  final value = amount.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    final positionFromEnd = value.length - i;
    buffer.write(value[i]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }
  return '$bufferđ';
}
