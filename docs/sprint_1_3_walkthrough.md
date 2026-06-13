# KẾT QUẢ HOÀN THÀNH 3 SPRINT - PHẠM NGUYỄN MINH LUÂN (ADMIN SYSTEM)

Hệ thống quản lý phòng thuê **Lumiere Stay** đã được lập trình và hoàn thiện toàn bộ **3 Sprint đầu tiên** theo đúng định hướng thiết kế **"The Ethereal Sanctuary"** (Glassmorphism & Neumorphism) sử dụng font chữ **Be Vietnam Pro**.

Dưới đây là sơ đồ tóm tắt các tệp tin đã tạo và cập nhật:

- **Cấu hình & Phông nền:**
  - [pubspec.yaml](file:///C:/code/LTDD/DoAn/tenant_management_app/pubspec.yaml): Đã thêm các thư viện `sqflite`, `path_provider`, `shared_preferences`, `fl_chart`, `provider` và `google_fonts`.
  - [lib/main.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/main.dart): Cấu hình theme Material 3, gán phông chữ **Be Vietnam Pro** và khởi chạy Onboarding screen.
  - [lib/theme/styles.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/theme/styles.dart): Chứa bộ màu sắc thiết kế, Container hiệu ứng kính mờ (Glassmorphism) và bóng kép (Neumorphism).

- **Mô hình Dữ liệu (Models):**
  - [lib/models/user.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/models/user.dart)
  - [lib/models/facility.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/models/facility.dart)
  - [lib/models/room.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/models/room.dart)
  - [lib/models/tenant.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/models/tenant.dart)
  - [lib/models/contract.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/models/contract.dart)
  - [lib/models/invoice.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/models/invoice.dart)
  - [lib/models/notification.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/models/notification.dart)

- **Trực quan hóa & Nghiệp vụ (Service & State Manager):**
  - [lib/services/database_helper.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/services/database_helper.dart): Khởi tạo 7 bảng dữ liệu SQLite, cài đặt tài khoản admin/tenant mặc định và các chỉ số phòng/hóa đơn mẫu để kiểm thử. Chứa các hàm xử lý tìm kiếm không dấu và quét hạn hợp đồng tự động.
  - [lib/services/app_state.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/services/app_state.dart): State Management sử dụng `provider` để xử lý đăng nhập, đồng bộ dữ liệu trực tiếp từ SQLite và lọc danh sách tức thì trên giao diện.

- **Giao diện Người dùng (UI Views):**
  - [lib/views/auth/onboarding_screen.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/views/auth/onboarding_screen.dart): Giao diện Splash / giới thiệu mượt mà tích hợp Glassmorphism.
  - [lib/views/auth/admin_login_screen.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/views/auth/admin_login_screen.dart): Màn hình đăng nhập mờ ảo sang trọng.
  - [lib/views/admin/admin_main_layout.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/views/admin/admin_main_layout.dart): Layout điều hướng chính (Bottom Navigation Bar) cho Admin bao gồm cả màn hình **Cá nhân (Profile - Sprint 4)**.
  - [lib/views/admin/admin_home_page.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/views/admin/admin_home_page.dart): Dashboard Admin hiển thị 4 chỉ số (Tổng phòng, Phòng trống, Phòng đã thuê, Hóa đơn nợ), biểu đồ tròn (Pie Chart) biểu diễn tỉ lệ phòng và danh sách khách nợ tiền phòng.
  - [lib/views/admin/admin_rooms_page.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/views/admin/admin_rooms_page.dart): Quản lý danh sách phòng kèm bộ lọc trực quan theo Cơ sở trọ và Trạng thái phòng.
  - [lib/views/admin/admin_add_room_page.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/views/admin/admin_add_room_page.dart): Form thêm phòng mới có kiểm tra dữ liệu đầu vào chặt chẽ.
  - [lib/views/admin/admin_tenants_page.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/views/admin/admin_tenants_page.dart): Quản lý khách thuê kèm thanh tìm kiếm nhanh (họ tên/SĐT) không phân biệt dấu tiếng Việt.

---

## CHI TIẾT CÁC TÁC VỤ ĐÃ LẬP TRÌNH (CHECKLIST STATUS)

### Sprint 1: Thiết lập nền tảng & Khởi tạo Database
- [x] **Task LUAN.1.1:** Tạo cấu trúc thư mục dạng Model-View-Service rõ ràng.
- [x] **Task LUAN.1.2:** Cài đặt các package bắt buộc và `google_fonts` cho phông chữ tiếng Việt chuẩn.
- [x] **Task LUAN.1.3:** Viết lớp `DatabaseHelper` khởi tạo 7 bảng SQLite đáp ứng đúng kiểu dữ liệu và ràng buộc khóa ngoại.
- [x] **Task LUAN.1.4:** Thiết kế màn hình onboarding **`Lumiere Stay - Property Management`** (Splash giới thiệu).

### Sprint 2: Quản lý Phòng trọ Admin
- [x] **Task LUAN.2.1:** Lập trình **`Trang chủ - Lumiere Stay (Admin)`**: Hiện tổng số phòng, phòng trống, đã thuê, hóa đơn cần xử lý.
- [x] **Task LUAN.2.2:** Thiết kế màn hình **`Quản lý phòng - Admin`**: Hiển thị danh sách phòng theo từng cơ sở trọ bằng các badge pastel nhẹ nhàng.
- [x] **Task LUAN.2.3:** Thiết kế màn hình **`Thêm phòng mới - Lumiere Stay`** với form nhập liệu đầy đủ số phòng, giá thuê, tiền cọc, số người ở tối đa.

### Sprint 3: Quản lý Khách thuê & Tìm kiếm
- [x] **Task LUAN.3.1:** Thiết kế màn hình **`Quản lý khách - Admin (Updated AppBar)`**: Liệt kê thông tin khách hàng, số điện thoại, số CCCD, quê quán.
- [x] **Task LUAN.3.2:** Viết logic tìm kiếm khách thuê theo Họ tên hoặc SĐT (không phân biệt dấu tiếng Việt).
- [x] **Task LUAN.3.3:** Viết logic lọc phòng nhanh theo trạng thái và theo từng Cơ sở trọ trực quan.
