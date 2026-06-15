# Lumiere Stay - Tenant Management App

Lumiere Stay là ứng dụng quản lý phòng trọ được xây dựng bằng Flutter. Dự án hỗ trợ hai vai trò chính: quản trị viên quản lý vận hành nhà trọ và khách thuê theo dõi thông tin phòng, hợp đồng, hóa đơn, thông báo và gửi yêu cầu thuê phòng.

## Tính năng chính

- Đăng nhập, đăng ký, quên mật khẩu bằng Firebase Authentication.
- Đăng nhập bằng Google và tự tạo hồ sơ người dùng trên Cloud Firestore.
- Điều hướng theo vai trò: admin vào màn hình quản trị, tenant vào giao diện khách thuê.
- Quản lý phòng, cơ sở, khách thuê, hợp đồng và hóa đơn.
- Duyệt hoặc từ chối yêu cầu thuê phòng.
- Tạo hóa đơn, đánh dấu hóa đơn đã thanh toán và thống kê doanh thu.
- Theo dõi phòng đang thuê, bạn cùng phòng, lịch sử hợp đồng và hóa đơn của khách thuê.
- Đồng bộ dữ liệu nghiệp vụ giữa Cloud Firestore và SQLite local.
- Hoạt động theo hướng offline-first với dữ liệu mẫu được seed vào SQLite.

## Công nghệ sử dụng

- Flutter / Dart
- Firebase Core, Firebase Auth, Cloud Firestore
- Google Sign-In
- SQLite với `sqflite`
- Provider cho state management
- `fl_chart` cho biểu đồ thống kê
- Google Fonts và Material 3

## Kiến trúc tổng quan

Ứng dụng khởi tạo Firebase trong `lib/main.dart`, sau đó dùng `_SessionGate` để lắng nghe trạng thái đăng nhập từ Firebase Auth. Khi người dùng đã đăng nhập, `_RoleGate` tải hồ sơ qua `AppState.checkAutoLogin()` và điều hướng theo vai trò:

- `admin`: vào `AdminMainLayout`
- `tenant`: vào `TenantShell`

`AppState` là lớp trung tâm quản lý state của ứng dụng. Lớp này gọi `DatabaseHelper` để đọc/ghi SQLite và gọi `FirestoreSyncService` để đồng bộ dữ liệu với Cloud Firestore.

## Cấu trúc thư mục

```text
lib/
├── main.dart
├── firebase_options.dart
├── models/
├── services/
│   ├── app_state.dart
│   ├── auth_service.dart
│   ├── database_helper.dart
│   └── firestore_sync_service.dart
├── theme/
├── views/
│   ├── admin/
│   ├── auth/
│   ├── customer/
│   └── tenant/
└── widgets/

docs/
└── data/
    └── batdongsan_hcm_rooms_sample.json
```

## Yêu cầu môi trường

- Flutter SDK tương thích Dart `^3.10.7`
- Android Studio hoặc VS Code
- Android emulator, thiết bị thật hoặc Chrome
- Firebase project đã cấu hình cho Android/Web/iOS nếu chạy đầy đủ tính năng xác thực và đồng bộ

Kiểm tra môi trường:

```bash
flutter doctor
```

## Cài đặt

Clone dự án và cài dependencies:

```bash
git clone https://github.com/luan2311/tenant_management_app.git
cd tenant_management_app
flutter pub get
```

## Cấu hình Firebase

Dự án không commit trực tiếp Firebase API key. Hãy tạo file `.env` từ file mẫu:

```bash
cp .env.example .env
```

Sau đó điền các biến Firebase tương ứng:

- `FIREBASE_WEB_*`
- `FIREBASE_ANDROID_*`
- `FIREBASE_IOS_*`

File `.env` được khai báo trong `pubspec.yaml` để Flutter bundle khi chạy local, nhưng đã nằm trong `.gitignore` nên không bị commit.

Các file cấu hình native cũng không nên commit:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `macos/Runner/GoogleService-Info.plist`

Nếu tạo Firebase project mới, hãy chạy lại FlutterFire CLI và cập nhật cấu hình tương ứng:

```bash
flutterfire configure
```

Với Google Sign-In trên Android, cần cấu hình SHA-1/SHA-256 trong Firebase Console, sau đó tải lại `google-services.json` vào `android/app/` trên máy local.

## Chạy ứng dụng

Chạy trên Chrome:

```bash
flutter run -d chrome
```

Chạy trên Android emulator:

```bash
flutter run -d emulator-5554
```

Liệt kê thiết bị có sẵn:

```bash
flutter devices
```

## Kiểm tra và build

Phân tích mã nguồn:

```bash
flutter analyze
```

Chạy test:

```bash
flutter test
```

Build APK release:

```bash
flutter build apk --release
```

## Dữ liệu mẫu

SQLite được seed dữ liệu phòng trọ từ:

```text
docs/data/batdongsan_hcm_rooms_sample.json
```

Khi app khởi tạo database local, `DatabaseHelper` tạo các bảng chính như `users`, `facilities`, `rooms`, `tenants`, `contracts`, `invoices`, `notifications` và `rental_requests`.

## Tài khoản và vai trò

Vai trò người dùng được xác định từ hồ sơ trên Firestore. Một số email admin được khai báo trong `AuthService`, ví dụ:

- `admin@gmail.com`
- `luan.admin@lumiere.com`

Người dùng khác mặc định là `tenant` khi đăng ký bằng email hoặc Google.

## Ghi chú phát triển

- `main` là nhánh triển khai chính.
- `project_main` là nhánh tích hợp tính năng trước khi đưa lên `main`.
- Không commit các thư mục build/cache như `build/`, `.dart_tool/`, `.idea/`.
- Khi thay đổi schema SQLite, cần cập nhật version database trong `DatabaseHelper`.
