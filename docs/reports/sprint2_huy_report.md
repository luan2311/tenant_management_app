# Báo Cáo Sprint 2 — Phùng Tuấn Huy

**Dự án:** Lumiere Stay — Hệ thống Quản lý Phòng thuê  
**Sprint:** Sprint 2 (Ngày 3–4)  
**Thành viên:** Phùng Tuấn Huy  
**Vai trò:** Frontend / Auth & Tenant UI  
**Ngày hoàn thành:** 2026-06-05  
**Trạng thái:** ✅ Hoàn thành 100%

---

## 1. Tổng Quan Nhiệm Vụ Sprint 2

> **Mục tiêu:** Xây dựng toàn bộ quy trình xác thực (Authentication Flow) gồm 3 màn hình: Đăng nhập, Đăng ký và Khôi phục mật khẩu — theo đúng phong cách "The Ethereal Sanctuary" đã thiết lập ở Sprint 1. Đồng thời cài đặt dịch vụ lưu phiên đăng nhập bằng `SharedPreferences`.

---

## 2. Chi Tiết Kết Quả Từng Task

### Task HUY.2.1 — Màn hình Đăng nhập ✅

**File:** `lib/views/auth/login_screen.dart`

Màn hình `LoginScreen` được xây dựng theo kiến trúc 3 layer (Stack):

| Layer | Nội dung |
|-------|---------|
| Layer 1 | Gradient nền pastel blue-white + 2 blur orbs trang trí (góc trên-phải và dưới-trái) |
| Layer 2 | Nội dung cuộn chính: Brand Section + Login Card + Footer link |
| Layer 3 | Nút Help nổi cố định góc dưới-phải |

**Brand Section:**
- Logo icon dạng Glass Card nhỏ (80×80px, bo góc 16, `BackdropFilter blur(20)`)
- Tên app `Lumiere Stay` — font w800, size 28
- Tagline `Ethereal Sanctuary Management` — style nhẹ

**Login Card (Glassmorphism):**
- Nền trắng mờ `Colors.white.withOpacity(0.65)` + `BackdropFilter blur(20)`
- Viền kính `Colors.white.withOpacity(0.35)` + bóng đổ nhẹ `kPrimary/8%`
- **Input Email/SĐT:** TextField fill trắng mờ, bo góc 16, focused border `kPrimaryFixed 2px`
- **Input Mật khẩu:** Toggle visibility icon (ẩn/hiện mật khẩu)
- **Link "Quên mật khẩu?":** Navigate đến `ForgotPasswordScreen`
- **Nút Đăng nhập:** Gradient pill `kPrimaryFixed → kPrimary`, full-width 56px, bóng xanh nhẹ
- **Divider "HOẶC ĐĂNG NHẬP NHANH":** Gradient fade hai bên, chữ hoa letterSpacing
- **Nút Biometric:** 2 nút Glass vuông (fingerprint + face recognition), 64×64px

**Footer Link:** "Chưa có tài khoản?" → Navigate đến `RegisterScreen`

**Cách dùng:**
```dart
// main.dart — App entry point
home: const LoginScreen(),
```

---

### Task HUY.2.2 — Màn hình Đăng ký ✅

**File:** `lib/views/auth/register_screen.dart`

Màn hình `RegisterScreen` hỗ trợ **Responsive Layout**:

| Màn hình | Layout |
|---------|--------|
| Mobile (`width < 1024px`) | 1 cột: chỉ hiện Form Card |
| Desktop (`width ≥ 1024px`) | 2 cột: Branding Section (trái) + Form Card (phải) |

**Background:**
- Gradient `#EBF4FB → #F7F9FB → #EEEFD` (top-left → bottom-right)
- Orb xanh nhạt `kPrimaryFixed/30%` góc trên-trái
- Orb tím nhạt `kTertiaryContainer/30%` góc dưới-phải

**Branding Section (Desktop):**
- Headline lớn (fontSize 64, w800): "Lumiere" + gradient text "Stay" (`kPrimary → kPrimaryDim`)
- Mô tả ứng dụng
- 2 Feature Card Glassmorphism/Neumorphism: **Nhanh chóng** và **An toàn**

**Form Card (Glassmorphism + Neumorphic inputs):**

| Field | Loại input | Keyboard |
|-------|-----------|---------|
| Họ tên | Neumorphic pill | `TextInputType.name` |
| Số điện thoại | Neumorphic pill | `TextInputType.phone` |
| Email | Neumorphic pill | `TextInputType.emailAddress` |
| Mật khẩu | Neumorphic pill + toggle visibility | — |
| Nhập lại mật khẩu | Neumorphic pill + toggle visibility | — |

- **Custom Animated Checkbox điều khoản:** `AnimatedContainer` chuyển màu khi tick, kèm checkmark icon
- **Nút Đăng ký:** Gradient pill, **bị disable khi chưa đồng ý điều khoản** (`_agreedToTerms == false`)
- **Floating Status Pill:** Badge glass "HỆ THỐNG ỔN ĐỊNH" với green dot nhấp nháy (`TweenAnimationBuilder`)

**Cách dùng:**
```dart
// Từ LoginScreen:
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const RegisterScreen()),
);
```

---

### Task HUY.2.3 — Màn hình Quên Mật Khẩu ✅

**File:** `lib/views/auth/forgot_password_screen.dart`

Màn hình `ForgotPasswordScreen` gồm 3 layer:

| Layer | Nội dung |
|-------|---------|
| Layer 1 | Nền `kSurface` + 2 blur orbs: `kPrimaryFixed/20%` (trên-trái) + `kTertiaryFixed/20%` (dưới-phải) |
| Layer 2 | Decorative Card nghiêng (chỉ Desktop): card glass xoay `-6°`, gradient trang trí |
| Layer 3 | Brand Header + Forgot Card + Security Badge |

**Brand Header:**
- Shield icon với gradient `kPrimaryFixed → kPrimary`, bo góc 16 kiểu Neumorphism
- Gradient text "Ethereal Sanctuary" dùng `ShaderMask` (`kPrimary → kOnPrimaryFixedVariant`)

**Forgot Password Card (Glassmorphism):**
- Nền trắng mờ 70% + `BackdropFilter blur(20)`
- Tiêu đề "Quên mật khẩu?" + mô tả hướng dẫn
- **Label** "ĐỊA CHỈ EMAIL" — uppercase letterSpacing
- **Email Input:** Neumorphic style (double outer shadow), bo góc 16, focused border `kPrimaryFixed 2px`
- **Nút "Gửi mã xác nhận":** Gradient pill full-width 56px
- **Back Link:** `← Quay lại Đăng nhập` với `Navigator.pop(context)`

**Security Badge:**
- Hiệu ứng **grayscale 40% opacity** dùng `ColorFilter.matrix`
- 2 badge: `SECURE ACCESS` + `SSL PROTECTED` với icon và dot ngăn cách

**Cách dùng:**
```dart
// Từ LoginScreen (link "Quên mật khẩu?"):
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
);
```

---

### Task HUY.2.4 — Dịch vụ lưu phiên đăng nhập (SharedPreferences) ✅

**File mới:** `lib/services/auth_service.dart`

Lớp `AuthService` (static methods) cung cấp 5 hàm:

| Hàm | Mô tả |
|-----|-------|
| `saveSession({userId, role, name})` | Lưu phiên sau khi đăng nhập thành công |
| `isLoggedIn()` | Kiểm tra phiên còn hiệu lực (`bool`) |
| `getUserId()` | Đọc `user_id` đã lưu (`int?`) |
| `getUserRole()` | Đọc vai trò: `'admin'` hoặc `'tenant'` |
| `clearSession()` | Xoá toàn bộ dữ liệu phiên (đăng xuất) |

**Keys lưu trong SharedPreferences:**

| Key | Kiểu | Nội dung |
|-----|------|---------|
| `is_logged_in` | `bool` | Trạng thái đăng nhập |
| `user_id` | `int` | ID người dùng |
| `user_role` | `String` | Vai trò: admin / tenant |
| `user_name` | `String` | Email hoặc tên hiển thị |

**Tích hợp vào `LoginScreen._handleLogin()`:**
- Validate: kiểm tra 2 field không rỗng trước khi gửi
- Loading state: button chuyển sang `CircularProgressIndicator` khi đang xử lý, disable tránh double-tap
- Gọi `AuthService.saveSession()` sau khi xác thực thành công
- Navigate bằng `Navigator.pushReplacementNamed(context, '/home')` — không cho back về Login
- Xử lý lỗi với `try/catch/finally`, đảm bảo `_isLoading = false` trong mọi trường hợp

**Tích hợp vào `main.dart` — Startup Session Gate:**
- `WidgetsFlutterBinding.ensureInitialized()` trong `main()`
- Widget `_SessionGate` dùng `FutureBuilder<bool>` gọi `AuthService.isLoggedIn()` ngay khi khởi động
- Nếu có phiên → vào `_TempHomeScreen` (placeholder Sprint 3); nếu không → `LoginScreen`
- `_TempHomeScreen` có nút Đăng xuất gọi `AuthService.clearSession()` + `Navigator.pushAndRemoveUntil`

> **Ghi chú:** `_handleLogin()` hiện dùng mock delay 600ms. Sprint 5 (HUY.5.1) sẽ thay bằng `DatabaseHelper.getUserByCredentials(email, password)` thực tế.

---

## 3. Navigation Flow Đã Hoàn Thiện

```
LoginScreen  ──────────────────────────►  RegisterScreen
     │                                         │
     │ (link "Quên mật khẩu?")                 │ (link "Đăng nhập ngay")
     ▼                                         │
ForgotPasswordScreen ◄────────────────────────┘
     │
     │ (back arrow)
     ▼
LoginScreen
```

---

## 4. Cấu Trúc File Sau Sprint 2

```
lib/
├── main.dart                          ✅ Session gate + routing + placeholder home
├── theme/
│   └── app_theme.dart                 ✅ Sprint 1 — Không thay đổi
├── services/
│   └── auth_service.dart              ✅ HUY.2.4 — SharedPreferences session
├── views/
│   ├── login_screen.dart              ✅ HUY.2.1 + HUY.2.4 — Đăng nhập + lưu phiên
│   ├── register_screen.dart           ✅ HUY.2.2 — Màn hình đăng ký
│   └── forgot_password_screen.dart    ✅ HUY.2.3 — Màn hình quên mật khẩu
└── widgets/
    ├── glass_card.dart                ✅ Sprint 1
    ├── primary_button.dart            ✅ Sprint 1
    ├── lumiere_text_field.dart        ✅ Sprint 1
    ├── loading_spinner.dart           ✅ Sprint 1
    └── bottom_nav_bar.dart            ✅ Sprint 1
```

---

## 5. Ghi Chú Kỹ Thuật

| Điểm chú ý | Chi tiết |
|-----------|---------|
| Responsive breakpoint | `MediaQuery.of(context).size.width >= 1024` — layout 2 cột chỉ kích hoạt trên màn ≥ 1024px |
| Gradient text | Dùng `ShaderMask` với `LinearGradient.createShader(bounds)` — `Text` phải set `color: Colors.white` để ShaderMask override |
| Neumorphic pill input | Double outer shadow (tối góc dưới-phải + sáng góc trên-trái) — mô phỏng `inset shadow` không hỗ trợ native trong Flutter |
| Grayscale effect | `ColorFilter.matrix` với ma trận luminosity — không cần package bên thứ ba |
| Animated checkbox | `AnimatedContainer` với `duration: 200ms` — chuyển màu fill mượt khi toggle |
| Decorative card (desktop) | `Transform.rotate(angle: -0.105)` tương đương `-6°` — `angle` tính bằng radian |
| `withOpacity` | Đã dùng `.withOpacity()` — sẽ chuyển sang `.withValues(alpha: x)` ở Sprint 6 khi rà soát deprecation warning |

---

## 6. Dependencies Đã Sử Dụng

| Package | Phiên bản | Mục đích |
|---------|----------|---------|
| `google_fonts` | `^6.2.1` | Font Be Vietnam Pro (từ Sprint 1) |
| `shared_preferences` | `^2.3.2` | Lưu phiên đăng nhập (khai báo, tích hợp ở Sprint 5) |

---

## 7. Checklist Sprint 2

- [x] **HUY.2.1** — Màn hình Đăng nhập với Glassmorphism, biometric buttons, navigation đến Register & ForgotPassword
- [x] **HUY.2.2** — Màn hình Đăng ký với Neumorphic inputs, animated checkbox, responsive layout 2 cột (desktop)
- [x] **HUY.2.3** — Màn hình Quên mật khẩu với decorative tilted card, security badge, gradient brand header
- [x] **HUY.2.4** — `AuthService` SharedPreferences + tích hợp login handler + startup session gate

**Sprint 2: ✅ Hoàn thành 4/4 task — 100%**

---

*Báo cáo tổng hợp bởi Claude Code — 2026-06-05*
