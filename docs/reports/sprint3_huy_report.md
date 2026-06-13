# Báo cáo Sprint 3 — Phùng Tuấn Huy

## Thông tin chung

| Mục | Nội dung |
|-----|----------|
| Sprint | 3 |
| Thành viên | Phùng Tuấn Huy |
| Vai trò | Frontend · Auth & Tenant UI |
| Thời gian | Sprint 3 |
| Trạng thái | ✅ Hoàn thành |

---

## Nhiệm vụ Sprint 3

| ID | Nhiệm vụ | Trạng thái |
|----|----------|------------|
| HUY.3.1 | HomeScreen (Trang chủ khách thuê) | ✅ Hoàn thành |
| HUY.3.2 | ExploreScreen (Khám phá phòng trống) | ✅ Hoàn thành |
| HUY.3.3 | RoomDetailScreen (Chi tiết phòng) | ✅ Hoàn thành |

---

## Cấu trúc file tạo ra

```
lib/
├── mock/
│   └── room_mock_data.dart         ← Dữ liệu mock (RoomData + kMockRooms + imageUrl)
├── views/
│   ├── tenant_shell.dart           ← Shell quản lý Bottom Navigation (4 tabs)
│   └── customer/
│       ├── home_page_screen.dart   ← HUY.3.1 HomeScreen
│       ├── explore_screen.dart     ← HUY.3.2 ExploreScreen
│       └── room_detail_screen.dart ← HUY.3.3 RoomDetailScreen
└── theme/
    └── app_theme.dart              ← Thêm kSurfaceContainerLow
```

> **Quy ước thư mục:** Tất cả màn hình phía khách thuê nằm trong `views/customer/`.
> Màn hình auth (Login, Register, ForgotPassword) nằm ở `views/` root. Admin sẽ dùng `views/admin/` (Sprint sau).

---

## Chi tiết từng màn hình

### HUY.3.1 — HomeScreen (`customer/home_page_screen.dart`)

**Mô tả:** Trang chủ cho khách thuê đang có hợp đồng, hiển thị thông tin phòng hiện tại và thông báo mới.

**Thành phần UI:**
- `SliverAppBar` glass blur với title gradient "Lumiere Stay"
- `_AmbientBackground` — 2 orb làm nền mờ (kPrimaryFixed + kTertiaryContainer)
- `_GreetingSection` — Chào hỏi với tên thật từ `AuthService.getUserName()` + nút "Khám phá →" (gọi `onViewAll`)
- `_RoomCard` — Glass card hiển thị phòng đang thuê (P.101, hợp đồng, số người)
- `_UnpaidBillCard` — Card đỏ cảnh báo hóa đơn chưa thanh toán
- `_QuickShortcuts` — 2 nút (Xem hợp đồng / Lịch sử hóa đơn) có press animation
- `_NotificationsSection` — Danh sách thông báo mới (lịch vệ sinh, cúp nước)

**Tham số:**
```dart
class HomeScreen extends StatelessWidget {
  final VoidCallback? onViewAll; // TenantShell gọi để chuyển sang tab Khám phá
}
```

---

### HUY.3.2 — ExploreScreen (`customer/explore_screen.dart`)

**Mô tả:** Màn hình khám phá danh sách phòng trống, có tìm kiếm và lọc theo giá.

**Thành phần UI:**
- `SliverAppBar` glass (giống HomeScreen)
- `_AmbientBackground` — 2 orb nền
- `_SearchBar` — TextField glass blur, có thể gõ thực sự
- `_FilterChips` — 4 chip (Tất cả / Dưới 3tr / 3–5tr / Trên 5tr) với icon, `AnimatedContainer`
- `_RoomListHeader` — Tiêu đề + số phòng tìm thấy (cập nhật theo bộ lọc) + nút Sắp xếp
- `_EmptyState` — Hiển thị khi không có phòng phù hợp
- `_RoomCard` — Card phòng với ảnh network (có fallback gradient), `AnimatedScale` khi nhấn, nút "Xem chi tiết"

**Logic lọc (`_filteredRooms`):**
```dart
// Chỉ hiển thị phòng status == 'empty'
// Filter 0: Tất cả | 1: < 3M | 2: 3–5M | 3: > 5M
```

**Navigation:**
```dart
// Nhấn "Xem chi tiết" → Navigator.push(RoomDetailScreen(room: rooms[i]))
```

---

### HUY.3.3 — RoomDetailScreen (`customer/room_detail_screen.dart`)

**Mô tả:** Màn hình chi tiết một phòng cụ thể, nhận `RoomData` từ màn hình trước.

**Thành phần UI:**
- `_FloatingHeader` — Nút back + Yêu thích (toggle ❤️) + Share, nổi trên ảnh hero
- `_HeroSection` — Ảnh phòng 400px (Image.network với fallback gradient) + badge trạng thái + tên phòng + cơ sở
- `_InfoGrid` — Glass card 3 ô (Giá thuê / Tiền cọc / Số người tối đa)
- `_DescriptionSection` — Mô tả phòng trên card
- `_AmenitiesSection` — Grid 4 cột các tiện ích với icon mapping
- `_BottomActionBar` — 2 nút: "Liên hệ chủ trọ" (outline) + "Gửi yêu cầu thuê" (gradient, disabled nếu phòng đã thuê)

**Tham số:**
```dart
class RoomDetailScreen extends StatefulWidget {
  final RoomData room; // nhận từ ExploreScreen hoặc HomeScreen
}
```

**Icon mapping tiện ích:**
```dart
'Điều hoà' → ac_unit | 'WC riêng' → bathroom | 'Wifi' → wifi
'Bãi xe'   → two_wheeler | 'Tủ lạnh' → kitchen | 'Ban công' → balcony
'Máy giặt' → local_laundry_service | 'Bếp' → soup_kitchen
```

---

## Dữ liệu Mock (`lib/mock/room_mock_data.dart`)

**Cập nhật Sprint 3:** Thêm field `imageUrl` (nullable String?) vào `RoomData`.

```dart
class RoomData {
  final String? imageUrl; // null → hiển thị gradient fallback
}
```

**Bảng mock rooms:**

| ID | Phòng | Cơ sở | Giá | Cọc | Người | Trạng thái | Ảnh |
|----|-------|-------|-----|-----|-------|------------|-----|
| 1 | P.101 | Quận 1 | 3.5M | 7M | 2 | empty | ✅ |
| 2 | P.102 | Quận 1 | 4M | 8M | 3 | empty | ✅ |
| 3 | P.201 | Quận 3 | 2.8M | 5.6M | 1 | rented | — |
| 4 | P.203 | Quận 3 | 3.2M | 6.4M | 2 | empty | ✅ |
| 5 | P.301 | Bình Thạnh | 5.5M | 11M | 4 | empty | — |

---

## Luồng hoạt động (Navigation Flow)

```
main.dart (_SessionGate)
    ↓ đã đăng nhập
TenantShell (IndexedStack 4 tabs)
    ├── Tab 0: HomeScreen ──────────────────────────────────────────────────────┐
    │       onViewAll() → _switchTab(1)                                        │
    │       "Khám phá →" ──────────────────────────────────────────────────────┘
    │                                                                    ↓
    ├── Tab 1: ExploreScreen ───────────────────────────────────────────────────┐
    │       Filter chips (giá) → _filteredRooms                                │
    │       Nhấn "Xem chi tiết" ────────────────────────────────────────────── │
    │                                                                    ↓      │
    │                           RoomDetailScreen (Navigator.push)               │
    │                               ├── Yêu thích toggle                       │
    │                               ├── "Liên hệ chủ trọ" → SnackBar (Sprint 4)|
    │                               └── "Gửi yêu cầu thuê" → SnackBar (Sprint 4)
    │
    ├── Tab 2: PlaceholderTab "Phòng của tôi" (Sprint 3 – Gia Khánh)
    └── Tab 3: PlaceholderTab "Thông báo" (Sprint 4 – Tuấn Huy)
```

### Nguyên tắc navigation:
- **Tab ↔ Tab:** TenantShell dùng `IndexedStack` + `_switchTab()`, giữ nguyên state mỗi tab
- **Tab → Detail:** `Navigator.push()` — RoomDetailScreen nổi lên trên shell, vẫn thấy bottom nav bên dưới khi pop về
- **Quay lại:** `Navigator.maybePop()` từ nút back trong RoomDetailScreen

---

## Kỹ thuật đáng chú ý

| Kỹ thuật | Áp dụng ở |
|----------|----------|
| Glassmorphism (BackdropFilter + blur) | AppBar, SearchBar, RoomCard, InfoGrid, BottomActionBar |
| Neumorphism (double shadow) | ShortcutButton |
| AnimatedContainer | Filter chips, ShortcutButton press effect |
| AnimatedScale | RoomCard image hover/press |
| AnimatedOpacity | GradientButton press |
| FutureBuilder | GreetingSection (đọc AuthService.getUserName()) |
| Image.network + errorBuilder | RoomCard, HeroSection (fallback gradient) |
| IndexedStack | TenantShell giữ state tab |
| Navigator.push | Chuyển đến RoomDetailScreen |

---

## Phụ thuộc với Sprint trước

| Dependency | Từ Sprint | Dùng ở |
|-----------|----------|--------|
| `AuthService.getUserName()` | Sprint 2 (HUY.2.4) | HomeScreen GreetingSection |
| `AuthService.isLoggedIn()` | Sprint 2 (HUY.2.4) | main.dart _SessionGate |
| `kPrimary`, `kSurface`, ... | Sprint 1 (app_theme.dart) | Toàn bộ màn hình |
| `LumiereBottomNavBar.tenant()` | Sprint 2 (widgets) | TenantShell |

---

## Việc còn lại (Sprint 4+)

| Việc | Sprint |
|------|--------|
| "Gửi yêu cầu thuê" → `RentRequestScreen` | Sprint 4 (Tuấn Huy) |
| "Liên hệ chủ trọ" → tích hợp liên lạc | Sprint 4 |
| Tab "Thông báo" → màn hình danh sách thông báo | Sprint 4 (Tuấn Huy) |
| Tab "Phòng của tôi" → màn hình hợp đồng đang thuê | Sprint 3 (Gia Khánh) |
| Thay mock data bằng `DatabaseHelper` (SQLite) | Sprint 5 |
| `HomeScreen`: load phòng thực của user thay vì mock P.101 | Sprint 5 |
