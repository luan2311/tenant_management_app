# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Lumiere Stay** — ứng dụng quản lý phòng trọ, Flutter/Dart, offline-first với SQLite.  
Nhóm 3 thành viên: Phùng Tuấn Huy (Auth + Tenant UI), Phạm Gia Khánh (Contracts + Invoices), Phạm Nguyễn Minh Luân (Admin UI + DatabaseHelper).  
Roadmap: 6 Sprint × 2 ngày. Sprint hiện tại: **Sprint 3**. Chi tiết phân công: `doc/project_implementation_plan.md`.

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

# Build APK (Sprint 6)
flutter build apk --release
```

## Architecture

### Startup Flow
`main.dart` → `_SessionGate` (FutureBuilder kiểm tra `AuthService.isLoggedIn()`)  
→ nếu đã đăng nhập: `TenantShell` | nếu chưa: `LoginScreen`

### Navigation
- **Tab ↔ Tab:** `TenantShell` dùng `IndexedStack` + `_switchTab()` — giữ nguyên state mỗi tab
- **Push detail:** `Navigator.push(MaterialPageRoute(...))` cho `RoomDetailScreen` — nổi trên shell
- **Sau login:** `Navigator.pushReplacementNamed(context, '/home')`
- **Route `/home`** được khai báo trong `MaterialApp.routes` → `TenantShell`

### Cấu trúc `lib/`
```
lib/
├── main.dart                    # Entry point, SessionGate, route '/home'
├── theme/app_theme.dart         # Toàn bộ màu (kPrimary, kSurface...) + buildAppTheme()
├── services/auth_service.dart   # SharedPreferences session (saveSession, isLoggedIn, clearSession)
├── mock/room_mock_data.dart      # RoomData model + kMockRooms (5 phòng) — tạm thời đến Sprint 5
├── widgets/
│   ├── glass_card.dart          # GlassCard (Glassmorphism) và NeuCard (Neumorphism)
│   ├── bottom_nav_bar.dart      # LumiereBottomNavBar.tenant() / .admin()
│   ├── primary_button.dart
│   ├── lumiere_text_field.dart
│   └── loading_spinner.dart
└── views/
    ├── Login_screen.dart        # HUY Sprint 2
    ├── Register_screen.dart     # HUY Sprint 1
    ├── Forgot_password_screen.dart
    ├── tenant_shell.dart        # IndexedStack 4 tabs cho phân hệ Khách thuê
    ├── customer/                # Tất cả màn hình phía Khách thuê
    │   ├── Home_page_screen.dart    # HUY.3.1
    │   ├── Explore_screen.dart      # HUY.3.2
    │   └── Rome_detail_screen.dart  # HUY.3.3 (filename typo, class = RoomDetailScreen)
    └── admin/                   # Sprint 2+ Minh Luân (chưa tạo)
```

> **Quy ước folder:** Auth screens → `views/` root. Tenant screens → `views/customer/`. Admin screens → `views/admin/`.

## Design System "The Ethereal Sanctuary"

### Màu sắc — dùng constants từ `app_theme.dart`, **không** hardcode Color hex
| Constant | Hex | Dùng cho |
|----------|-----|----------|
| `kSurface` | `#F7F9FB` | Background màn hình |
| `kPrimary` | `#2E6486` | Màu chủ đạo |
| `kPrimaryFixed` | `#A5D8FF` | Accent nhạt, badge, gradient start |
| `kPrimaryFixedDim` | `#97CAF0` | Gradient button |
| `kOnSurface` | `#2C3437` | Text chính |
| `kOnSurfaceVariant` | `#596064` | Text phụ |
| `kSurfaceContainerLow` | `#F0F4F7` | Card background |
| `kSurfaceContainerHigh` | `#E3E9ED` | Pressed state |

### Widget dùng chung
- **`GlassCard`** — Glassmorphism: `BackdropFilter` blur + white opacity. Dùng cho info card, search bar, bottom action bar.
- **`NeuCard`** — Neumorphism: double shadow (dark bottom-right + white top-left). Dùng cho button shortcut, filter chip, mini card.
- **`LumiereBottomNavBar.tenant()`** / **`.admin()`** — Glass nav bar, animated icon/text khi chọn.

### Quy tắc code UI
- Dùng `.withValues(alpha: x)` thay cho `.withOpacity(x)` (deprecated)
- Font: Be Vietnam Pro qua `google_fonts` — đã cấu hình trong `buildAppTheme()`
- `useMaterial3: true` — không dùng Material 2 API
- Unused callback params: dùng tên có nghĩa `(ctx, err, trace)` thay vì `(_, __, ___)`

## Data Layer

### Hiện tại (Sprint 1–4): Mock Data
`lib/mock/room_mock_data.dart` chứa `RoomData` model và `kMockRooms` (5 phòng hardcode).  
`RoomData` có các field: `id, roomNumber, facility, price, deposit, maxTenants, status, amenities, description, imageUrl?`

### Sprint 5: SQLite
`DatabaseHelper` (do Minh Luân viết) sẽ thay thế mock. Schema 7 bảng:  
`users`, `facilities`, `rooms`, `tenants`, `contracts`, `invoices`, `notifications`  
Khi thay thế: tìm comment `// Sprint 5: Thay bằng DatabaseHelper...` trong code.

### AuthService (SharedPreferences)
```dart
AuthService.saveSession(userId: id, role: 'tenant', name: email)
AuthService.isLoggedIn()     // → bool
AuthService.getUserName()    // → String (email hoặc tên)
AuthService.getUserRole()    // → 'tenant' | 'admin'
AuthService.clearSession()   // Đăng xuất
```

## Màn hình chưa làm (Sprint 4+)

| Màn hình | Người làm | Sprint |
|----------|-----------|--------|
| RentRequestScreen (Yêu cầu thuê) | Huy | 4 |
| NotificationScreen (Thông báo) | Huy | 4 |
| MyRoomScreen (Phòng của tôi) | Khánh | 3 |
| InvoiceScreen (Hóa đơn tôi) | Khánh | 4 |
| Admin Dashboard + Quản lý phòng | Luân | 2 |

Placeholder hiện tại trong `TenantShell`: tab "Phòng của tôi" (Khánh) và "Thông báo" (Huy Sprint 4).

## Git

Mỗi thành viên làm việc trên nhánh riêng:
- `feature/huy-auth` — Phùng Tuấn Huy
- `feature/khanh-logic` — Phạm Gia Khánh  
- `feature/luan-admin` — Phạm Nguyễn Minh Luân

Merge vào `main` do Minh Luân thực hiện cuối mỗi Sprint.
