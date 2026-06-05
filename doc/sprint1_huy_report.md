# Báo Cáo Sprint 1 — Phùng Tuấn Huy

**Dự án:** Lumiere Stay — Hệ thống Quản lý Phòng thuê  
**Sprint:** Sprint 1 (Ngày 1–2)  
**Thành viên:** Phùng Tuấn Huy  
**Vai trò:** Frontend / Auth & Tenant UI  
**Ngày hoàn thành:** 2026-06-05  
**Trạng thái:** ✅ Hoàn thành 100%

---

## 1. Tổng Quan Nhiệm Vụ Sprint 1

> **Mục tiêu:** Thiết lập nền tảng giao diện dùng chung (Style Guide, Theme, Widget Library, Navigation) cho toàn bộ ứng dụng Lumiere Stay theo phong cách "The Ethereal Sanctuary".

---

## 2. Chi Tiết Kết Quả Từng Task

### Task HUY.1.1 — Cấu hình Theme ✅

**File:** `lib/theme/app_theme.dart`

- Định nghĩa đầy đủ **bảng màu chủ đạo** theo đặc tả "The Ethereal Sanctuary":
  - `kPrimary` — Xanh dương đậm `#2E6486`
  - `kPrimaryFixed` — Xanh pastel nhạt `#A5D8FF`
  - `kSurface` — Nền trắng xám `#F7F9FB`
  - `kOnSurface`, `kOnSurfaceVariant`, `kOutline`, `kOutlineVariant` — Hệ màu chữ/viền chuẩn
  - `kSecondaryContainer`, `kTertiaryContainer` — Màu accent phụ nhẹ nhàng
- Cấu hình `ThemeData` với **font Be Vietnam Pro** (via `google_fonts`) cho toàn app.
- Sử dụng `Material3: true` để tương thích chuẩn thiết kế hiện đại.

---

### Task HUY.1.2 — Widget Glassmorphism & Neumorphism dùng chung ✅

Toàn bộ widget được đặt trong thư mục `lib/widgets/`, sẵn sàng import vào mọi màn hình.

#### 2.1. `GlassCard` & `NeuCard` — `glass_card.dart`

| Widget | Phong cách | Mô tả |
|--------|-----------|-------|
| `GlassCard` | Glassmorphism | Card kính mờ với `BackdropFilter` blur, viền trong suốt, bóng đổ nhẹ. Có thể tùy chỉnh `borderRadius`, `blurSigma`, `opacity`. |
| `NeuCard` | Neumorphism | Card nổi nhẹ bằng kỹ thuật double shadow (tối + sáng), tạo chiều sâu không cần viền cứng. |

**Cách dùng:**
```dart
GlassCard(
  padding: const EdgeInsets.all(24),
  child: Text('Nội dung'),
)

NeuCard(
  padding: const EdgeInsets.all(16),
  child: Icon(Icons.home),
)
```

---

#### 2.2. `PrimaryButton` & `SecondaryButton` — `primary_button.dart`

| Widget | Mô tả |
|--------|-------|
| `PrimaryButton` | Nút hành động chính: gradient `kPrimaryFixed → kPrimary`, bo tròn pill, hỗ trợ `isLoading` (hiện spinner), `trailingIcon`. |
| `SecondaryButton` | Nút phụ: outlined, viền `kPrimary`, nền trong suốt, hỗ trợ `leadingIcon`. |

**Cách dùng:**
```dart
PrimaryButton(
  label: 'Đăng nhập',
  trailingIcon: Icons.arrow_forward_rounded,
  isLoading: _isLoading,
  onPressed: _handleLogin,
)

SecondaryButton(
  label: 'Hủy',
  leadingIcon: Icons.close,
  onPressed: () => Navigator.pop(context),
)
```

---

#### 2.3. `GlassTextField` & `NeuTextField` — `lumiere_text_field.dart`

| Widget | Dùng khi nào |
|--------|-------------|
| `GlassTextField` | Nền tối / gradient (màn Đăng nhập). Fill trắng mờ, border kính. |
| `NeuTextField` | Nền sáng (màn Đăng ký, Form). Neumorphic pill-shape với double shadow. |

Cả hai đều hỗ trợ: `label`, `hint`, `prefixIcon`, `suffixIcon`, `obscureText`, `keyboardType`.

**Cách dùng:**
```dart
GlassTextField(
  controller: _emailController,
  hint: 'example@lumiere.com',
  prefixIcon: Icons.alternate_email_rounded,
  label: 'Email hoặc Số điện thoại',
)

NeuTextField(
  controller: _passwordController,
  hint: '••••••••',
  prefixIcon: Icons.lock_outline_rounded,
  label: 'Mật khẩu',
  obscureText: true,
  suffixIcon: IconButton(icon: Icon(Icons.visibility_outlined), onPressed: () {}),
)
```

---

#### 2.4. `LumiereSpinner` & `LoadingOverlay` — `loading_spinner.dart`

| Widget | Mô tả |
|--------|-------|
| `LumiereSpinner` | Spinner nhỏ inline, có thể tùy chỉnh `size` và `color`. |
| `LoadingOverlay` | Wrap toàn màn hình — khi `isLoading = true`, hiện overlay kính mờ blur + card spinner + tuỳ chọn `message`. |

**Cách dùng:**
```dart
// Inline
LumiereSpinner(size: 32)

// Toàn màn hình
LoadingOverlay(
  isLoading: _isLoading,
  message: 'Đang đăng nhập...',
  child: _buildContent(),
)
```

---

### Task HUY.1.3 — Bottom Navigation Bar ✅

**File:** `lib/widgets/bottom_nav_bar.dart`

Thiết kế 1 widget `LumiereBottomNavBar` có **2 preset** cho 2 phân hệ:

#### Phân hệ Khách thuê (Tenant) — 4 tab:

| Tab | Icon | Điều hướng đến |
|-----|------|---------------|
| Trang chủ | `home_rounded` | HomeScreen (Tenant) |
| Khám phá | `search_rounded` | ExploreScreen |
| Phòng của tôi | `meeting_room_rounded` | MyRoomScreen |
| Thông báo | `notifications_rounded` | NotificationScreen |

#### Phân hệ Admin / Chủ trọ — 5 tab:

| Tab | Icon | Điều hướng đến |
|-----|------|---------------|
| Tổng quan | `dashboard_rounded` | AdminDashboard |
| Phòng | `apartment_rounded` | RoomManagementScreen |
| Khách thuê | `people_rounded` | TenantManagementScreen |
| Hóa đơn | `receipt_long_rounded` | InvoiceScreen |
| Thống kê | `bar_chart_rounded` | StatisticsScreen |

**Đặc điểm kỹ thuật:**
- Hiệu ứng Glassmorphism với `BackdropFilter blur(24)`.
- Active tab có nền `kPrimary` mờ nhẹ + icon đặc + chữ đậm.
- `AnimatedSwitcher` + `AnimatedDefaultTextStyle` cho chuyển tab mượt mà.
- Floating style (padding bottom 20px, bo góc 28px) — không che nội dung.

**Cách dùng:**
```dart
// Trong Scaffold:
bottomNavigationBar: LumiereBottomNavBar.tenant(
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
),

// Admin:
bottomNavigationBar: LumiereBottomNavBar.admin(
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
),
```

---

## 3. Cấu Trúc File Sau Sprint 1

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart          ✅ HUY.1.1
└── widgets/
    ├── glass_card.dart         ✅ HUY.1.2 — GlassCard, NeuCard
    ├── primary_button.dart     ✅ HUY.1.2 — PrimaryButton, SecondaryButton
    ├── lumiere_text_field.dart ✅ HUY.1.2 — GlassTextField, NeuTextField
    ├── loading_spinner.dart    ✅ HUY.1.2 — LumiereSpinner, LoadingOverlay
    └── bottom_nav_bar.dart     ✅ HUY.1.3 — LumiereBottomNavBar (tenant + admin)
```

---

## 4. Ghi Chú Kỹ Thuật

| Điểm chú ý | Chi tiết |
|-----------|---------|
| API màu | Dùng `.withValues(alpha: x)` thay `.withOpacity(x)` — tránh warning deprecated trên Flutter SDK mới |
| Font | `GoogleFonts.beVietnamProTextTheme()` — cần có kết nối lần đầu để tải font cache |
| Blur Effect | `BackdropFilter` hoạt động chính xác khi widget cha có `ClipRRect` bọc ngoài |
| Neumorphism | Kỹ thuật double outer shadow (tối góc phải-dưới, sáng góc trái-trên) thay thế `inset shadow` không hỗ trợ trong Flutter |

---

## 5. Checklist Sprint 1

- [x] **HUY.1.1** — Theme màu + font Be Vietnam Pro
- [x] **HUY.1.2** — Widget dùng chung: GlassCard, NeuCard, PrimaryButton, SecondaryButton, GlassTextField, NeuTextField, LumiereSpinner, LoadingOverlay
- [x] **HUY.1.3** — Bottom Navigation Bar cho Tenant (4 tab) và Admin (5 tab)

**Sprint 1: ✅ Hoàn thành 3/3 task — 100%**

---

*Báo cáo tổng hợp bởi Claude Code — 2026-06-05*
