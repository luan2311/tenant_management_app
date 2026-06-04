import 'package:flutter/material.dart';
import '../model/user.dart';
import '../model/facility.dart';
import '../model/room.dart';
import '../model/tenant.dart';
import '../model/contract.dart';
import '../model/invoice.dart';
import '../model/notification.dart';
import 'database_helper.dart';

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
  List<Map<String, dynamic>> debtorList = [];

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

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // --- Auth ---
  Future<bool> login(String username, String password) async {
    setLoading(true);
    final user = await _db.login(username, password);
    if (user != null) {
      _currentUser = user;
      await refreshAllData();
      setLoading(false);
      return true;
    }
    setLoading(false);
    return false;
  }

  Future<void> logout() async {
    if (_currentUser != null) {
      await _db.logout(_currentUser!.id!);
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> checkAutoLogin() async {
    setLoading(true);
    final user = await _db.getLoggedInUser();
    if (user != null) {
      _currentUser = user;
      await refreshAllData();
    }
    setLoading(false);
  }

  // --- Data Loading & Synchronization ---
  Future<void> refreshAllData() async {
    if (_currentUser == null) return;
    
    // Run background scans for notifications/contracts
    await _db.runBackgroundScans(_currentUser!.id!);

    _facilities = await _db.getAllFacilities();
    _rooms = await _db.getAllRooms();
    _tenants = await _db.getAllTenants();
    _contracts = await _db.getAllContracts();
    _invoices = await _db.getAllInvoices();
    _notifications = await _db.getNotificationsForUser(_currentUser!.id!);

    // Load stats
    roomStats = await _db.getRoomStatistics();
    unpaidInvoicesCount = await _db.getUnpaidInvoicesCount();
    monthlyRevenue = await _db.getRevenueByMonth();
    debtorList = await _db.getDebtorList();

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
      _notifications = await _db.getNotificationsForUser(_currentUser!.id!);
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
}
