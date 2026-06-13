# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Lumiere Stay** — ứng dụng quản lý phòng trọ, Flutter/Dart, offline-first với SQLite.  
Nhóm 3 thành viên: Phùng Tuấn Huy (Auth + Tenant UI), Phạm Gia Khánh (Contracts + Invoices + Tenant screens), Phạm Nguyễn Minh Luân (Admin UI + DatabaseHelper).  
Roadmap: 6 Sprint × 2 ngày.

## Commands

```bash
# Cài dependencies
flutter pub get

# Chạy trên Chrome (web, dùng trong quá trình dev)
flutter run -d chrome --web-renderer canvaskit

# Chạy trên Android emulator
flutter run -d emulator-5554

# Kiểm tra lỗi tĩnh
flutter analyze

# Chạy tests
flutter test

# Build APK
flutter build apk --release
```

## Architecture

### Startup Flow — hai luồng xác thực song song

**Tenant flow** (`main.dart`):  
`_SessionGate` (FutureBuilder → `AuthService.isLoggedIn()`) → `TenantShell` hoặc `LoginScreen`  
`AuthService` dùng SharedPreferences để lưu session.

**Admin flow** (vào từ `LoginScreen` → chọn "Admin"):  
`AdminLoginScreen` → `AppState.login()` → SQLite `is_logged_in` flag → `AdminMainLayout`  
`AppState` check `DatabaseHelper.getLoggedInUser()` khi khởi động để auto-login admin.

### State Management
`AppState extends ChangeNotifier` (Provider) — singleton wrapping `DatabaseHelper.instance`.  
Tất cả UI admin đọc state qua `context.watch<AppState>()` hoặc `context.read<AppState>()`.  
`AppState.refreshAllData()` load lại toàn bộ dữ liệu sau mỗi write operation.  
`Provider<AppState>` phải được inject ở root widget trước `AdminMainLayout`.

### Navigation
- **Tenant tabs:** `TenantShell` dùng `IndexedStack` — giữ nguyên state mỗi tab (4 tabs)
- **Admin tabs:** `AdminMainLayout` dùng `IndexedStack` — 5 tabs (Home, Rooms, Tenants, Statistics, Profile)
- **Push detail:** `Navigator.push(MaterialPageRoute(...))` — nổi trên shell
- **Sau admin login:** `Navigator.pushReplacement` → `AdminMainLayout`
- **Sau tenant login:** `Navigator.pushReplacementNamed(context, '/home')` → `TenantShell`
- **Route `/home`** khai báo trong `MaterialApp.routes` → `TenantShell`

### Cấu trúc `lib/`
```
lib/
├── main.dart                        # Entry point, SessionGate (tenant only), route '/home'
├── theme/
│   ├── app_theme.dart               # kPrimary, kSurface... + buildAppTheme() — dùng cho tenant UI
│   └── styles.dart                  # AppColors, AppStyles, GlassmorphicContainer, EtherealBackground — dùng cho admin UI
├── services/
│   ├── auth_service.dart            # SharedPreferences session (tenant flow)
│   ├── database_helper.dart         # SQLite singleton — tất cả CRUD + query thống kê
│   ├── app_state.dart               # ChangeNotifier wrapping DatabaseHelper — admin state
│   └── mock_service.dart            # Legacy mock data cho tenant contract/invoice (chưa dọn)
├── models/                          # Data models (SQLite-mapped)
│   ├── user.dart, facility.dart, room.dart, tenant.dart
│   ├── contract.dart, invoice.dart, notification.dart
│   └── mock/                        # Legacy mock models (contract_model.dart, invoice_model.dart, notification_model.dart)
├── mock/room_mock_data.dart          # RoomData + kMockRooms — dùng cho tenant Explore screen
├── widgets/
│   ├── glass_card.dart              # GlassCard (Glassmorphism) + NeuCard (Neumorphism)
│   ├── bottom_nav_bar.dart          # LumiereBottomNavBar.tenant() / .admin()
│   ├── primary_button.dart, lumiere_text_field.dart, loading_spinner.dart
└── views/
    ├── auth/                        # Tất cả màn hình xác thực
    │   ├── login_screen.dart        # Tenant login (SharedPreferences)
    │   ├── admin_login_screen.dart  # Admin login (SQLite via AppState)
    │   ├── register_screen.dart, forgot_password_screen.dart, onboarding_screen.dart
    ├── tenant_shell.dart            # IndexedStack 4 tabs cho Khách thuê
    ├── customer/                    # Màn hình phía Khách thuê (Huy)
    │   ├── home_page_screen.dart, explore_screen.dart (mock RoomData)
    │   ├── room_detail_screen.dart, rental_request_screen.dart, notification_screen.dart
    ├── tenant/                      # Màn hình Khách thuê (Khánh)
    │   ├── my_room_screen.dart, contract_detail_screen.dart, my_invoice_screen.dart
    └── admin/                       # Admin UI (Luân)
        ├── admin_main_layout.dart   # Root shell + AdminProfilePage (đổi mật khẩu, đăng xuất)
        ├── admin_home_page.dart     # Dashboard: room stats, unpaid invoices, debtor list
        ├── admin_rooms_page.dart    # Filter theo facility/status, thêm/xóa phòng
        ├── admin_tenants_page.dart  # Tìm kiếm (diacritics-aware), xem chi tiết khách
        ├── admin_statistics_page.dart  # Biểu đồ doanh thu (fl_chart), revenue summary
        ├── admin_add_room_page.dart, add_contract_screen.dart, invoice_admin_screen.dart
```

## Data Layer — SQLite (Live)

`DatabaseHelper` singleton (`DatabaseHelper.instance`) — file `lumiere_stay.db`.  
DB tự seed data khi `onCreate` (2 facilities, 4 rooms, 2 tenants, 2 contracts, 3 invoices, 2 notifications).

**7 bảng:** `users`, `facilities`, `rooms`, `tenants`, `contracts`, `invoices`, `notifications`

**Seed credentials (mật khẩu lưu plain-text — demo only):**
- Admin: `admin` / `admin123`
- Tenant 1: `huytenant` / `tenant123`
- Tenant 2: `khanhtenant` / `tenant123`

**Quy tắc đồng bộ trạng thái:**
- Khi tạo contract → room status tự động → `'rented'` (dùng transaction)
- Khi terminate/expire contract → room status tự động → `'empty'`
- `runBackgroundScans()` chạy mỗi lần `refreshAllData()`: quét contract sắp hết hạn (< 30 ngày) và nhắc hóa đơn unpaid (ngày 1–5 đầu tháng)

**Tenant-side** vẫn dùng `lib/mock/room_mock_data.dart` cho Explore screen và `MockService` cho contract/invoice — chưa kết nối SQLite.

## Design System "The Ethereal Sanctuary"

Hai file theme song song — không trộn lẫn:

**`app_theme.dart`** — dùng cho tenant UI:
| Constant | Hex | Dùng cho |
|----------|-----|----------|
| `kSurface` | `#F7F9FB` | Background màn hình |
| `kPrimary` | `#2E6486` | Màu chủ đạo |
| `kPrimaryFixed` | `#A5D8FF` | Accent nhạt |
| `kOnSurface` | `#2C3437` | Text chính |
| `kOnSurfaceVariant` | `#596064` | Text phụ |
| `kSurfaceContainerLow` | `#F0F4F7` | Card background |
| `kSurfaceContainerHigh` | `#E3E9ED` | Pressed state |

**`styles.dart`** — dùng cho admin UI:
- `AppColors.sanctuaryDark`, `AppColors.accent`, `AppColors.textSecondary`, ...
- `AppStyles.headline(context)`, `.title()`, `.body()`, `.caption()` — text styles với Be Vietnam Pro
- `GlassmorphicContainer` — glassmorphism widget tái dùng trong admin
- `EtherealBackground` — gradient background wrapper

**Widget dùng chung (tenant):**
- **`GlassCard`** — `BackdropFilter` blur + white opacity. Dùng cho info card, search bar.
- **`NeuCard`** — double shadow (dark bottom-right + white top-left). Dùng cho mini card.
- **`LumiereBottomNavBar.tenant()`** / **`.admin()`** — Glass nav bar, animated icon/text khi chọn.

**Quy tắc code UI:**
- Dùng `.withValues(alpha: x)` thay cho `.withOpacity(x)` (deprecated)
- Font: Be Vietnam Pro qua `google_fonts` — cấu hình trong `buildAppTheme()`
- `useMaterial3: true`
- Unused callback params: dùng tên có nghĩa `(ctx, err, trace)` thay vì `(_, __, ___)`

## Git

Mỗi thành viên làm việc trên nhánh riêng:
- `feature/huy-auth` — Phùng Tuấn Huy
- `feature/khanh-logic` — Phạm Gia Khánh  
- `feature/luan-admin` — Phạm Nguyễn Minh Luân

Merge vào `main` (qua `project_main`) do Minh Luân thực hiện cuối mỗi Sprint.
