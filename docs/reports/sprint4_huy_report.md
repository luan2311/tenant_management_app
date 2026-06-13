# Báo cáo Sprint 4 — Phùng Tuấn Huy

## Thông tin chung

| Mục | Nội dung |
|-----|----------|
| Sprint | 4 |
| Thành viên | Phùng Tuấn Huy |
| Vai trò | Frontend · Auth & Tenant UI |
| Thời gian | Sprint 4 |
| Trạng thái | ✅ Hoàn thành |

---

## Nhiệm vụ Sprint 4

| ID | Nhiệm vụ | Trạng thái |
|----|----------|------------|
| HUY.4.1 | RentalRequestScreen (Gửi yêu cầu thuê) | ✅ Hoàn thành |
| HUY.4.2 | NotificationScreen (Thông báo) | ✅ Hoàn thành |
| HUY.4.3 | Logic `is_read` lưu SQLite | ⏳ Chờ Sprint 5 (`DatabaseHelper`) |

---

## Cấu trúc file tạo ra / chỉnh sửa

```
lib/
├── views/
│   ├── tenant_shell.dart                    ← Nối tab "Thông báo" → NotificationScreen
│   └── customer/
│       ├── rental_request_screen.dart       ← HUY.4.1 RentalRequestScreen (mới)
│       ├── notification_screen.dart         ← HUY.4.2 NotificationScreen (mới)
│       └── room_detail_screen.dart          ← Nối nút "Gửi yêu cầu thuê" → RentalRequestScreen
```

> Quy ước thư mục giữ nguyên: 2 màn hình mới đều thuộc phía khách thuê → đặt trong `views/customer/`.

---

## Chi tiết từng màn hình

### HUY.4.1 — RentalRequestScreen (`customer/rental_request_screen.dart`)

**Mô tả:** Form gửi yêu cầu thuê cho 1 phòng cụ thể, hiển thị dạng bottom sheet nổi lên trên `RoomDetailScreen`.

**Thành phần UI:**
- `_GlassPanel` — panel kính mờ bo góc trên (glassmorphism, `BackdropFilter` blur 20px), có drag handle
- Header: tiêu đề "Gửi yêu cầu thuê" + `_CloseButton` + dòng phụ hiển thị `Phòng {roomNumber} · {facility}` lấy từ `RoomData` truyền vào
- `_NeumorphicField` — ô chọn ngày dự kiến thuê (inset shadow, mở `showDatePicker` với theme `kPrimary`/`kOnPrimary`)
- `_OccupantsField` — bộ đếm số người ở (`_StepperButton` tăng/giảm, giới hạn 1–10, đồng bộ với `TextEditingController`)
- `_GradientButton` — nút "Gửi yêu cầu" gradient `kPrimaryFixed → kPrimary`, có animation scale khi nhấn

**Tham số:**
```dart
class RentalRequestScreen extends StatefulWidget {
  final RoomData room; // nhận từ RoomDetailScreen qua Navigator.push
}
```

**Logic gửi yêu cầu (`_submit`):**
```dart
// Validate: bắt buộc chọn ngày, báo SnackBar nếu thiếu
// Sprint 5: thay bằng DatabaseHelper.insertRentalRequest(room, date, occupants)
// Hiện tại: hiện SnackBar xác nhận "Đã gửi yêu cầu thuê phòng {roomNumber}: {ngày} · {số người}"
//           rồi Navigator.maybePop(context) đóng bottom sheet
```

---

### HUY.4.2 — NotificationScreen (`customer/notification_screen.dart`)

**Mô tả:** Trung tâm thông báo cho khách thuê, hiển thị dưới dạng 1 tab trong `TenantShell` (không tự vẽ Scaffold/bottom nav riêng — dùng chung `LumiereBottomNavBar.tenant()` của shell).

**Thành phần UI:**
- `_BackgroundPainter` — vẽ nền radial gradient blobs (map từ CSS `background-image` gốc)
- `_MobileHeader` — sticky header với tiêu đề + nút "Đánh dấu tất cả đã đọc" (`onMarkAllRead`)
- `_DateDivider` — chia nhóm thông báo theo "HÔM NAY" / "TUẦN TRƯỚC"
- `_NotificationCard` — card thông báo: `_NotificationIcon`, `_ActionChip`, `_TagChip`, thanh accent bên trái khi chưa đọc, độ mờ giảm khi đã đọc (`isRead`)

**Model dữ liệu (`NotificationItem`):**
```dart
class NotificationItem {
  final String title, body, time;
  final Color accentColor, iconColor;
  final IconData icon;
  final bool isRead, isUrgent;
  final String? amount;  // card nhắc thanh toán
  final String? tag;     // card hợp đồng sắp hết hạn
  final NotificationCategory category; // today | lastWeek
}
```

**Dữ liệu mẫu (`_notifications`):** 4 thông báo mock — nhắc thanh toán (urgent, có `amount`), hợp đồng sắp hết hạn (có `tag`), bảo trì thang máy, cúp nước tạm thời.

**Logic `_markAllRead`:** hiện chỉ show SnackBar xác nhận "Đã đánh dấu tất cả là đã đọc" — **chưa cập nhật state/DB thật** (đây chính là phần HUY.4.3 chờ `DatabaseHelper` ở Sprint 5).

---

## Refactor để phù hợp với kiến trúc dự án

Cả 2 màn hình ban đầu là code prototype độc lập (tự có `main()`/`MyApp`/class `AppColors` riêng, dùng `.withOpacity()` deprecated). Đã refactor lại để khớp `CLAUDE.md`:

| Việc đã làm | Chi tiết |
|---|---|
| Bỏ standalone app wrapper | Xoá `main()`, `MyApp`, `AppColors` ở cả 2 file |
| Map màu theo `app_theme.dart` | `AppColors.X` → `kPrimary`, `kSurface`, `kOnSurface`, `kSurfaceContainerHigh`, `kPrimaryFixed`, `kSecondaryContainer`, `kTertiaryContainer`... |
| Thêm local `_k` constants | Cho tông màu chưa có trong theme (`_kError`, `_kErrorContainer`, `_kSecondary`, `_kTertiary`...) — theo đúng tiền lệ ở `home_page_screen.dart` (`_kErrorContainer`) |
| `.withOpacity()` → `.withValues(alpha:)` | Thay toàn bộ theo quy ước chống deprecation trong `CLAUDE.md` |
| Bỏ Scaffold/bottom-nav thừa trong NotificationScreen | Vì đã chạy như 1 tab trong `IndexedStack` của `TenantShell` — xoá luôn 3 class thừa `_NavItem`, `_GlassBottomNav`, `_NavItemWidget` |
| Giữ quy ước "private widget per screen" | Không ép refactor sang `GlassCard`/`PrimaryButton` dùng chung — giữ `_GradientButton`, `_GlassPanel` riêng theo đúng tiền lệ `room_detail_screen.dart` |

---

## Nối luồng điều hướng (Navigation Flow)

```
TenantShell (IndexedStack 4 tabs)
    ├── Tab 1: ExploreScreen
    │       Nhấn "Xem chi tiết" → RoomDetailScreen (Navigator.push)
    │           └── "Gửi yêu cầu thuê" ──→ Navigator.push(RentalRequestScreen(room: ...)) ✅ MỚI
    │                                          ├── Chọn ngày + số người ở
    │                                          └── "Gửi yêu cầu" → SnackBar xác nhận → maybePop()
    │
    └── Tab 3: NotificationScreen ✅ MỚI (thay PlaceholderTab)
            └── "Đánh dấu tất cả đã đọc" → SnackBar (chờ DB ở Sprint 5)
```

**Thay đổi cụ thể:**
- `room_detail_screen.dart`: thêm `import 'rental_request_screen.dart';`, sửa `onTap` của nút "Gửi yêu cầu thuê" trong `_BottomActionBar` từ SnackBar placeholder → `Navigator.push(MaterialPageRoute(builder: (_) => RentalRequestScreen(room: room)))`. Đồng thời thêm field `room` vào `_BottomActionBar` (vì đây là `StatelessWidget` riêng, không truy cập được `widget.room` của `_RoomDetailScreenState`).
- `tenant_shell.dart`: import `customer/notification_screen.dart`, thay `_PlaceholderTab('Thông báo', Icons.notifications_rounded, 'Sprint 4 — Tuấn Huy')` ở tab index 3 bằng `const NotificationScreen()`.

---

## Kỹ thuật đáng chú ý

| Kỹ thuật | Áp dụng ở |
|----------|-----------|
| Glassmorphism (BackdropFilter + blur) | `_GlassPanel` (RentalRequest), `_MobileHeader` (Notification) |
| Neumorphism (inset double shadow) | `_NeumorphicField`, `_OccupantsField`, `_StepperButton` |
| `showDatePicker` với theme tuỳ biến | RentalRequestScreen — đồng bộ `kPrimary`/`kOnPrimary`/`kSurface` |
| `AnimatedScale` | `_GradientButton` press effect |
| `CustomPaint` | `_BackgroundPainter` vẽ radial gradient blobs cho NotificationScreen |
| `ScaffoldMessenger` SnackBar | Xác nhận hành động (gửi yêu cầu, đánh dấu đã đọc) |

---

## Phụ thuộc với Sprint trước

| Dependency | Từ Sprint | Dùng ở |
|-----------|-----------|--------|
| `RoomData` (mock model) | Sprint 3 (`room_mock_data.dart`) | RentalRequestScreen nhận tham số `room` |
| `kPrimary`, `kSurface`, ... | Sprint 1 (`app_theme.dart`) | Toàn bộ 2 màn hình mới |
| `RoomDetailScreen._BottomActionBar` | Sprint 3 (HUY.3.3) | Điểm khởi đầu luồng push sang RentalRequestScreen |
| `TenantShell` IndexedStack + `LumiereBottomNavBar.tenant()` | Sprint 2/3 | NotificationScreen chạy như 1 tab, không cần Scaffold riêng |

---

## Việc còn lại (Sprint 5+)

| Việc | Ghi chú |
|------|---------|
| `_submit()` trong RentalRequestScreen → `DatabaseHelper.insertRentalRequest(room, date, occupants)` | Comment `// Sprint 5: ...` đã để sẵn trong code |
| HUY.4.3 — `_markAllRead()` cập nhật cột `is_read` thật trong bảng `notifications` (SQLite) | Hiện chỉ là SnackBar placeholder, chờ `DatabaseHelper` của Minh Luân |
| Thay `_notifications` mock list bằng query từ SQLite theo user đăng nhập | Sprint 5 |
| "Liên hệ chủ trọ" trong RoomDetailScreen → tích hợp liên lạc thật | Việc tồn đọng từ Sprint 3, vẫn là SnackBar placeholder |
