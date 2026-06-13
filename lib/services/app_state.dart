import 'package:flutter/material.dart';
import 'package:tenant_management_app/models/user.dart';
import 'package:tenant_management_app/models/facility.dart';
import 'package:tenant_management_app/models/room.dart';
import 'package:tenant_management_app/models/tenant.dart';
import 'package:tenant_management_app/models/contract.dart';
import 'package:tenant_management_app/models/invoice.dart';
import 'package:tenant_management_app/models/notification.dart';
import 'database_helper.dart';
import 'package:tenant_management_app/services/auth_service.dart';

class AppState extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  UserModel? _currentUser;
  List<FacilityModel> _facilities = [];
  List<RoomModel> _rooms = [];
  List<TenantModel> _tenants = [];
  List<ContractModel> _contracts = [];
  List<InvoiceModel> _invoices = [];
  List<NotificationModel> _notifications = [];

  // Filtered lists for Admin UI
  List<RoomModel> _filteredRooms = [];
  List<TenantModel> _filteredTenants = [];

  // Current selections for filtering (Sprint 3)
  int? selectedFacilityId;
  String selectedRoomStatus = 'all'; // 'all', 'empty', 'rented', 'maintenance'
  String tenantSearchQuery = '';

  // Stats
  Map<String, int> roomStats = {'total': 0, 'empty': 0, 'rented': 0, 'maintenance': 0};
  int unpaidInvoicesCount = 0;
  Map<String, double> monthlyRevenue = {};
  Map<String, double> revenueSummary = {'paid': 0, 'unpaid': 0};
  List<Map<String, dynamic>> debtorList = [];
  Map<String, dynamic>? offlineHealthCheck;

  bool _isLoading = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<FacilityModel> get facilities => _facilities;
  List<RoomModel> get rooms => _rooms;
  List<RoomModel> get filteredRooms => _filteredRooms;
  List<TenantModel> get tenants => _tenants;
  List<TenantModel> get filteredTenants => _filteredTenants;
  List<ContractModel> get contracts => _contracts;
  List<InvoiceModel> get invoices => _invoices;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get currentBillingMonth => _formatBillingMonth(DateTime.now());

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // --- Auth ---
  Future<bool> login(String email, String password) async {
    setLoading(true);
    try {
      final userModel = await AuthService.signInWithEmail(email, password);
      if (userModel != null) {
        _currentUser = userModel;
        await refreshAllData();
        setLoading(false);
        return true;
      }
    } catch (_) {
      // Lỗi xác thực sẽ được xử lý ở UI layer
    }
    setLoading(false);
    return false;
  }

  Future<void> logout() async {
    await AuthService.clearSession();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> checkAutoLogin() async {
    setLoading(true);
    final user = await AuthService.getCurrentUserModel();
    if (user != null) {
      _currentUser = user;
      await refreshAllData();
    }
    setLoading(false);
  }

  /// Đặt user đã đăng nhập từ Firebase (dùng cho AdminLoginScreen).
  Future<void> loginWithFirebaseUser(UserModel user) async {
    _currentUser = user;
    await refreshAllData();
    notifyListeners();
  }

  // --- Data Loading & Synchronization ---
  Future<void> refreshAllData() async {
    if (_currentUser == null) return;
    
    // Run background scans for notifications/contracts
    // Background scans dùng int id — tạm dùng hashCode từ UID
    await _db.runBackgroundScans(_currentUser!.uid.hashCode);

    _facilities = await _db.getAllFacilities();
    _rooms = await _db.getAllRooms();
    _tenants = await _db.getAllTenants();
    _contracts = await _db.getAllContracts();
    _invoices = await _db.getAllInvoices();
    _notifications = await _db.getNotificationsForUser(_currentUser!.uid.hashCode);

    // Load stats
    roomStats = await _db.getRoomStatistics();
    unpaidInvoicesCount = await _db.getUnpaidInvoicesCount();
    monthlyRevenue = await _db.getRevenueByMonth();
    revenueSummary = await _db.getRevenueSummary(billingMonth: currentBillingMonth);
    debtorList = await _db.getDebtorList(billingMonth: currentBillingMonth);

    applyFilters();
  }

  // --- Room Operations ---
  Future<bool> addNewRoom(RoomModel room) async {
    setLoading(true);
    final id = await _db.insertRoom(room);
    if (id > 0) {
      await refreshAllData();
      setLoading(false);
      return true;
    }
    setLoading(false);
    return false;
  }

  Future<bool> updateRoom(RoomModel room) async {
    setLoading(true);
    final affectedRows = await _db.updateRoom(room);
    if (affectedRows > 0) {
      await refreshAllData();
      setLoading(false);
      return true;
    }
    setLoading(false);
    return false;
  }

  Future<bool> deleteRoom(int roomId) async {
    setLoading(true);
    final affectedRows = await _db.deleteRoom(roomId);
    if (affectedRows > 0) {
      await refreshAllData();
      setLoading(false);
      return true;
    }
    setLoading(false);
    return false;
  }

  Future<bool> changeCurrentUserPassword(String currentPassword, String newPassword) async {
    try {
      await AuthService.changePassword(currentPassword, newPassword);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> runOfflineHealthCheck() async {
    offlineHealthCheck = await _db.runOfflineHealthCheck();
    notifyListeners();
  }

  Future<bool> saveContract(ContractModel contract) async {
    setLoading(true);
    final affectedRows = contract.id == null
        ? await _db.createContractWithRoomSync(contract)
        : await _db.updateContract(contract);
    if (affectedRows > 0) {
      await refreshAllData();
      setLoading(false);
      return true;
    }
    setLoading(false);
    return false;
  }

  Future<bool> terminateContract(int contractId, int roomId) async {
    setLoading(true);
    final affectedRows = await _db.terminateContractWithRoomSync(contractId, roomId);
    if (affectedRows > 0) {
      await refreshAllData();
      setLoading(false);
      return true;
    }
    setLoading(false);
    return false;
  }

  Future<bool> saveInvoice(InvoiceModel invoice) async {
    setLoading(true);
    final affectedRows = invoice.id == null ? await _db.insertInvoice(invoice) : await _db.updateInvoice(invoice);
    if (affectedRows > 0) {
      await refreshAllData();
      setLoading(false);
      return true;
    }
    setLoading(false);
    return false;
  }

  Future<bool> markInvoicePaid(int invoiceId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final affectedRows = await _db.updateInvoiceStatus(invoiceId, 'paid', today);
    if (affectedRows > 0) {
      await refreshAllData();
      return true;
    }
    return false;
  }

  // Task LUAN.3.3: Viết logic lọc phòng nhanh theo trạng thái và theo từng Cơ sở trọ trực quan
  void filterRoomsByFacility(int? facilityId) {
    selectedFacilityId = facilityId;
    applyFilters();
  }

  void filterRoomsByStatus(String status) {
    selectedRoomStatus = status;
    applyFilters();
  }

  void applyFilters() {
    // Rooms filter
    _filteredRooms = _rooms.where((room) {
      final matchesFacility = selectedFacilityId == null || room.facilityId == selectedFacilityId;
      final matchesStatus = selectedRoomStatus == 'all' || room.status == selectedRoomStatus;
      return matchesFacility && matchesStatus;
    }).toList();

    // Tenants filter / search
    if (tenantSearchQuery.trim().isEmpty) {
      _filteredTenants = List.from(_tenants);
    } else {
      String queryLower = _removeDiacritics(tenantSearchQuery.toLowerCase());
      _filteredTenants = _tenants.where((tenant) {
        String nameNormalized = _removeDiacritics(tenant.fullName.toLowerCase());
        String phoneNormalized = tenant.phone.trim();
        return nameNormalized.contains(queryLower) || phoneNormalized.contains(queryLower);
      }).toList();
    }

    notifyListeners();
  }

  // Task LUAN.3.2: Tìm kiếm khách thuê (trigger filtering in memory immediately for fast response)
  void searchTenants(String query) {
    tenantSearchQuery = query;
    applyFilters();
  }

  // --- Notifications Operations ---
  Future<void> readNotification(int notifId) async {
    await _db.markNotificationAsRead(notifId);
    if (_currentUser != null) {
      _notifications = await _db.getNotificationsForUser(_currentUser!.uid.hashCode);
      notifyListeners();
    }
  }

  // Helper for Vietnamese diacritics removal
  String _removeDiacritics(String str) {
    const vietnamese = 'aAeEoOuUiIdDyY';
    const vietnameseRegex = [
      'aàáảãạăằắẳẵặâầấẩẫậ',
      'AÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬ',
      'eèéẻẽẹêềếểễệ',
      'EÈÉẺẼẸÊỀẾỂỄỆ',
      'oòóỏõọôồốổỗộơờớởỡợ',
      'OÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢ',
      'uùúủũụưừứửữự',
      'UÙÚỦŨỤƯỪỨỬỮỰ',
      'iìíỉĩị',
      'IÌÍỈĨỊ',
      'dđ',
      'DĐ',
      'yỳýỷỹỵ',
      'YỲÝỶỸỴ'
    ];

    String result = str;
    for (int i = 0; i < vietnameseRegex.length; i++) {
      final regex = RegExp('[' + vietnameseRegex[i] + ']');
      result = result.replaceAll(regex, vietnamese[i]);
    }
    return result;
  }

  String _formatBillingMonth(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    return '${value.year}-$month';
  }
}
