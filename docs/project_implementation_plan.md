# KẾ HOẠCH TRIỂN KHAI HỆ THỐNG QUẢN LÝ PHÒNG THUÊ: LUMIERE STAY
**Định hướng thiết kế:** "The Ethereal Sanctuary" (Glassmorphism & Neumorphism)
**Lộ trình nước rút:** 12 ngày (6 Sprint - 2 ngày/Sprint)
**Đội ngũ thực hiện (Nhóm 3):** Phạm Nguyễn Minh Luân, Phùng Tuấn Huy, Phạm Gia Khánh

---

## 1. PHÂN BỔ 21 MÀN HÌNH THEO ĐÚNG ĐẶC TẢ HỆ THỐNG LUMIERE STAY

Nhóm sẽ phân chia lập trình 21 màn hình ứng dụng cụ thể theo phân công Figma và năng lực chuyên môn để đảm bảo sự liền mạch:

### 1.1. Nhóm Dùng Chung & Xác Thực (Đảm nhận: Phùng Tuấn Huy)
*   **Màn hình 1:** `Lumiere Stay - Property Management` (Splash Screen / Onboarding giới thiệu).
*   **Màn hình 2:** `Đăng nhập - Lumiere Stay (Fixed BG)` (Xác thực tài khoản với nền tĩnh mờ ảo).
*   **Màn hình 3:** `Đăng ký - Lumiere Stay` (Tạo tài khoản khách hàng mới).
*   **Màn hình 4:** `Quên mật khẩu - Lumiere Stay` (Khôi phục quyền truy cập qua Email/OTP).

### 1.2. Nhóm Khách Hàng / Tenant (Đảm nhận: Phùng Tuấn Huy & Phạm Gia Khánh)
*   **Màn hình 5:** `Trang chủ - Lumiere Stay` (Tổng quan gợi ý phòng, trạng thái thuê của Khách - Huy).
*   **Màn hình 6:** `Khám phá phòng - Lumiere Stay` (Xem danh sách phòng trống để tìm thuê - Huy).
*   **Màn hình 7:** `Chi tiết phòng - Lumiere Stay` (Xem giá, mô tả, hình ảnh phòng - Huy).
*   **Màn hình 8:** `Yêu cầu thuê - Lumiere Stay` (Gửi yêu cầu thuê phòng kèm ngày nhận phòng - Huy).
*   **Màn hình 9:** `Phòng của tôi - Lumiere Stay (Updated Actions)` (Xem phòng đang thuê, lịch sử thanh toán - Khánh).
*   **Màn hình 10:** `Hóa đơn của tôi - Lumiere Stay` (Xem hóa đơn chi tiết hàng tháng - Khánh).
*   **Màn hình 11:** `Thông báo - Lumiere Stay` (Nhận các thông báo từ hệ thống và Admin - Huy).

### 1.3. Nhóm Admin / Chủ Trọ (Đảm nhận: Phạm Nguyễn Minh Luân & Phạm Gia Khánh)
*   **Màn hình 12:** `Trang chủ - Lumiere Stay (Admin)` (Dashboard quản trị phòng, doanh thu, yêu cầu mới - Luân).
*   **Màn hình 13:** `Quản lý phòng - Admin` (Xem danh sách phòng trống/thuê/bảo trì - Luân).
*   **Màn hình 14:** `Thêm phòng mới - Lumiere Stay` (Admin nhập thông tin phòng mới - Luân).
*   **Màn hình 15:** `Quản lý khách - Admin (Updated AppBar)` (Theo dõi hồ sơ, thông tin khách thuê - Luân).
*   **Màn hình 16:** `Cá nhân - Admin (Updated AppBar)` (Thông tin cá nhân Admin & Đăng xuất - Luân).
*   **Màn hình 17:** `Hợp đồng - Lumiere Stay` (Danh sách hợp đồng đang hiệu lực/hết hạn - Khánh).
*   **Màn hình 18:** `Thêm hợp đồng mới - Lumiere Stay` (Tạo hợp đồng khi khách được duyệt - Khánh).
*   **Màn hình 19:** `Hóa đơn - Admin (Updated AppBar)` (Theo dõi công nợ, duyệt đóng tiền - Khánh).
*   **Màn hình 20:** `Thông báo - Yêu cầu thuê phòng mới` (Xử lý các đơn xin thuê phòng từ Khách gửi - Khánh).
*   **Màn hình 21:** `Thống kê - Admin (Updated Room Icon)` (Biểu đồ doanh thu, tỷ lệ phòng trống - Luân).

---

## 2. NGUYÊN TẮC THIẾT KẾ UI/UX: "THE ETHEREAL SANCTUARY"
Để đáp ứng đúng đặc tả thẩm mỹ nhẹ nhàng, hiện đại và cao cấp, nhóm cần tuân thủ:
*   **Font chữ:** Bắt buộc sử dụng **Be Vietnam Pro** cho toàn bộ ứng dụng di động để đảm bảo hiển thị tiếng Việt chuẩn và thanh lịch.
*   **Màu sắc chủ đạo:** Xanh nhạt (Light Blue), Trắng (White), Xám xanh (Gray-Blue). Hạn chế màu đỏ/xanh lá truyền thống chói mắt, thay bằng màu Pastel dịu.
*   **Phong cách tạo hình:** **Glassmorphism** (Hiệu ứng kính mờ bằng cách dùng `BackdropFilter` mờ nền kết hợp opacity) và **Neumorphism** (Tạo độ sâu bằng bóng đổ kép mềm mại, tránh đường viền cứng). Phân cấp giao diện bằng khoảng trắng và các lớp bề mặt đổ bóng mịn.

---

## 3. THIẾT KẾ DỮ LIỆU CỤC BỘ OFFLINE (SQLITE SCHEMA)

Lập trình viên Minh Luân sẽ khởi tạo database SQLite với cấu trúc 7 bảng sau trong lớp `DatabaseHelper`:

```sql
-- 1. Bảng users
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    role TEXT CHECK(role IN ('admin', 'tenant')) NOT NULL,
    is_logged_in INTEGER DEFAULT 0
);

-- 2. Bảng facilities (Hỗ trợ cấu trúc phân cấp nhiều cơ sở trọ)
CREATE TABLE facilities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    status INTEGER DEFAULT 1 -- 1: Đang hoạt động, 0: Tạm ngừng
);

-- 3. Bảng rooms
CREATE TABLE rooms (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    facility_id INTEGER,
    room_number TEXT NOT NULL,
    price REAL NOT NULL,
    deposit REAL NOT NULL,
    max_tenants INTEGER DEFAULT 2,
    status TEXT CHECK(status IN ('empty', 'rented', 'maintenance')) DEFAULT 'empty',
    FOREIGN KEY(facility_id) REFERENCES facilities(id) ON DELETE CASCADE
);

-- 4. Bảng tenants (Thông tin khách lưu trú)
CREATE TABLE tenants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NULL,
    full_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    cccd TEXT UNIQUE NOT NULL,
    hometown TEXT,
    start_date TEXT, -- Định dạng YYYY-MM-DD
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 5. Bảng contracts (Hợp đồng thuê)
CREATE TABLE contracts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    room_id INTEGER,
    tenant_id INTEGER,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    deposit REAL NOT NULL,
    status TEXT CHECK(status IN ('active', 'expired', 'terminated')) DEFAULT 'active',
    FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE,
    FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- 6. Bảng invoices (Hóa đơn điện nước hàng tháng)
CREATE TABLE invoices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    room_id INTEGER,
    contract_id INTEGER,
    billing_month TEXT NOT NULL, -- YYYY-MM
    old_electricity REAL NOT NULL,
    new_electricity REAL NOT NULL,
    old_water REAL NOT NULL,
    new_water REAL NOT NULL,
    electricity_price REAL NOT NULL,
    water_price REAL NOT NULL,
    service_price REAL DEFAULT 0,
    other_price REAL DEFAULT 0,
    total_price REAL NOT NULL,
    status TEXT CHECK(status IN ('paid', 'unpaid')) DEFAULT 'unpaid',
    payment_date TEXT,
    FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE,
    FOREIGN KEY(contract_id) REFERENCES contracts(id) ON DELETE CASCADE
);

-- 7. Bảng notifications
CREATE TABLE notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    type TEXT CHECK(type IN ('booking_request', 'rent_reminder', 'contract_expiry', 'payment_success')) NOT NULL,
    created_at TEXT NOT NULL, -- YYYY-MM-DD HH:MM:SS
    is_read INTEGER DEFAULT 0,
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

---

## 4. CHI TIẾT CHECKLIST NHIỆM VỤ THEO NGƯỜI (COPY-PASTE ĐỂ CHIA VIỆC)

---

### 4.1. CHECKLIST PHẠM NGUYỄN MINH LUÂN (Trưởng nhóm / Core Backend & Admin UI)

#### **Sprint 1 (Ngày 1 - 2): Thiết lập nền tảng & Khởi tạo Database**
*   [ ] **Task LUAN.1.1:** Khởi tạo project di động (Flutter/Kotlin), tạo cấu trúc thư mục dạng Model-View-Service rõ ràng.
*   [ ] **Task LUAN.1.2:** Cài đặt các package bắt buộc: `sqflite`, `path_provider`, `shared_preferences`, `fl_chart` (vẽ biểu đồ), state management (`provider`).
*   [ ] **Task LUAN.1.3:** Viết lớp `DatabaseHelper` khởi tạo 7 bảng SQLite đáp ứng đúng kiểu dữ liệu và ràng buộc.
*   [ ] **Task LUAN.1.4:** Thiết kế màn hình onboarding: **`Lumiere Stay - Property Management`** (Splash giới thiệu phần mềm mượt mà).

#### **Sprint 2 (Ngày 3 - 4): Quản lý Phòng trọ Admin**
*   [ ] **Task LUAN.2.1:** Lập trình **`Trang chủ - Lumiere Stay (Admin)`**: Hiện tổng số phòng, phòng trống, đã thuê, hóa đơn cần xử lý.
*   [ ] **Task LUAN.2.2:** Thiết kế màn hình **`Quản lý phòng - Admin`**: Hiển thị danh sách phòng theo từng cơ sở trọ, hiển thị trạng thái bằng các badge pastel nhẹ nhàng.
*   [ ] **Task LUAN.2.3:** Thiết kế màn hình **`Thêm phòng mới - Lumiere Stay`**: Cho phép Admin nhập số phòng, giá thuê, tiền cọc, số người ở tối đa.

#### **Sprint 3 (Ngày 5 - 6): Quản lý Khách thuê & Tìm kiếm**
*   [ ] **Task LUAN.3.1:** Thiết kế màn hình **`Quản lý khách - Admin (Updated AppBar)`**: Liệt kê thông tin khách hàng, số điện thoại, số CCCD, quê quán.
*   [ ] **Task LUAN.3.2:** Viết logic tìm kiếm khách thuê theo Họ tên hoặc SĐT (không phân biệt dấu tiếng Việt).
*   [ ] **Task LUAN.3.3:** Viết logic lọc phòng nhanh theo trạng thái và theo từng Cơ sở trọ trực quan.

#### **Sprint 4 (Ngày 7 - 8): Hồ sơ Admin & SQLite Query nâng cao**
*   [x] **Task LUAN.4.1:** Thiết kế màn hình **`Cá nhân - Admin (Updated AppBar)`**: Xem thông tin tài khoản admin, tùy chọn đổi mật khẩu và nút Đăng xuất.
*   [x] **Task LUAN.4.2:** Viết các hàm truy vấn SQL nâng cao phục vụ cho nghiệp vụ thống kê doanh thu và báo cáo nợ tiền phòng.
*   [x] **Task LUAN.4.3:** Hỗ trợ Gia Khánh tích hợp SQLite vào phân hệ Quản lý hợp đồng và Hóa đơn.

#### **Sprint 5 (Ngày 9 - 10): Thống kê doanh thu đồ họa**
*   [x] **Task LUAN.5.1:** Thiết kế màn hình **`Thống kê - Admin (Updated Room Icon)`**: Vẽ biểu đồ cột trực quan hiển thị doanh thu thực nhận từng tháng.
*   [x] **Task LUAN.5.2:** Lập trình danh sách hiển thị các khách thuê nợ tiền phòng trong tháng hiện tại (`status = 'unpaid'`).
*   [x] **Task LUAN.5.3:** Viết hàm quét offline kiểm tra toàn bộ hoạt động của app khi không có kết nối Internet.

#### **Sprint 6 (Ngày 11 - 12): Git Merge & Đóng gói sản phẩm**
*   [ ] **Task LUAN.6.1:** Nhận toàn bộ code từ nhánh của Tuấn Huy và Gia Khánh, tiến hành Git Merge và giải quyết các conflict.
*   [ ] **Task LUAN.6.2:** Đo đạc hiệu năng ứng dụng, tối ưu hóa các hàm truy vấn DB đảm bảo tốc độ tải trang dưới 5 giây.
*   [ ] **Task LUAN.6.3:** Đóng gói sản phẩm cuối cùng xuất ra file cài đặt `.apk` Android hoàn chỉnh.

---

### 4.2. CHECKLIST PHÙNG TUẤN HUY (Frontend / Auth & Tenant UI)

#### **Sprint 1 (Ngày 1 - 2): Thiết kế Style Guide & Theme mờ ảo**
*   [ ] **Task HUY.1.1:** Định cấu hình hệ thống theme theo phong cách "The Ethereal Sanctuary": màu xanh nhạt, trắng và xám xanh; font chữ **Be Vietnam Pro**.
*   [ ] **Task HUY.1.2:** Lập trình các Widget Glassmorphism và Neumorphism dùng chung: Custom Button, Custom Input Text Field, Loading Spinner, Custom Card.
*   [ ] **Task HUY.1.3:** Tạo khung Navigation Bar phía dưới (Bottom Navigation Bar) cho cả hai phân hệ Admin và Tenant.

#### **Sprint 2 (Ngày 3 - 4): Quy trình Đăng nhập & Đăng ký**
*   [ ] **Task HUY.2.1:** Thiết kế màn hình **`Đăng nhập - Lumiere Stay (Fixed BG)`** với nền tĩnh mờ ảo sang trọng.
*   [ ] **Task HUY.2.2:** Thiết kế màn hình **`Đăng ký - Lumiere Stay`** dành cho khách thuê mới.
*   [ ] **Task HUY.2.3:** Thiết kế màn hình **`Quên mật khẩu - Lumiere Stay`** để khôi phục tài khoản qua Email/OTP.
*   [ ] **Task HUY.2.4:** Lập trình dịch vụ lưu phiên đăng nhập sử dụng `SharedPreferences`.

#### **Sprint 3 (Ngày 5 - 6): Khám phá phòng & Trang chủ Khách**
*   [ ] **Task HUY.3.1:** Thiết kế màn hình **`Trang chủ - Lumiere Stay`** (Khách): Hiển thị lời chào, thanh tìm kiếm nhanh, gợi ý phòng trống và lối tắt.
*   [ ] **Task HUY.3.2:** Thiết kế màn hình **`Khám phá phòng - Lumiere Stay`**: Xem danh sách phòng trống kèm giá thuê.
*   [ ] **Task HUY.3.3:** Thiết kế màn hình **`Chi tiết phòng - Lumiere Stay`**: Xem hình ảnh phòng, diện tích, giá thuê, cọc, tiện ích đi kèm.

#### **Sprint 4 (Ngày 7 - 8): Yêu cầu thuê & Trung tâm thông báo**
*   [ ] **Task HUY.4.1:** Thiết kế màn hình **`Yêu cầu thuê - Lumiere Stay`**: Form điền ngày dự kiến nhận phòng, số người ở và nút gửi yêu cầu thuê phòng.
*   [ ] **Task HUY.4.2:** Thiết kế màn hình **`Thông báo - Lumiere Stay`**: Nơi khách thuê nhận thông báo trạng thái yêu cầu duyệt phòng, nhắc nợ đóng tiền.
*   [ ] **Task HUY.4.3:** Lập trình tính năng click vào thông báo để chuyển trạng thái `is_read = 1` trong SQLite.

#### **Sprint 5 (Ngày 9 - 10): Tích hợp luồng Khách thuê với Database**
*   [ ] **Task HUY.5.1:** Phối hợp kết nối toàn bộ các giao diện của Khách thuê vào database SQLite cục bộ thông qua DatabaseHelper.
*   [ ] **Task HUY.5.2:** Lập trình giả lập (Mock) dữ liệu phòng trống để hỗ trợ kiểm thử luồng tìm phòng.
*   [ ] **Task HUY.5.3:** Viết hàm cập nhật hồ sơ cá nhân của Khách thuê từ màn hình chính.

#### **Sprint 6 (Ngày 11 - 12): Sửa lỗi Overflow & Đẩy code**
*   [ ] **Task HUY.6.1:** Đẩy toàn bộ mã nguồn sạch lên Git repository của nhóm để Minh Luân thực hiện merge code.
*   [ ] **Task HUY.6.2:** Rà soát giao diện trên nhiều dòng máy khác nhau, dùng `SingleChildScrollView` sửa triệt để các lỗi tràn viền (UI Overflow).
*   [ ] **Task HUY.6.3:** Thêm các hiệu ứng micro-animations khi người dùng thao tác chuyển trang hoặc thực hiện các nút hành động.

---

### 4.3. CHECKLIST PHẠM GIA KHÁNH (Business Logic / Hợp Đồng, Hóa Đơn & Xử lý Yêu cầu)

#### **Sprint 1 (Ngày 1 - 2): Khởi tạo Model & Mock Service**
*   [ ] **Task KHANH.1.1:** Định nghĩa cấu trúc dữ liệu các Model: `ContractModel`, `InvoiceModel`, `NotificationModel`.
*   [ ] **Task KHANH.1.2:** Viết các hàm chuyển đổi `fromMap()` và `toMap()` để hỗ trợ ghi/đọc dữ liệu từ SQLite.
*   [ ] **Task KHANH.1.3:** Thiết lập các Mock Service cho Hợp đồng và Hóa đơn để Tuấn Huy có thể lấy dữ liệu dựng giao diện trước.

#### **Sprint 2 (Ngày 3 - 4): Hợp đồng & Xử lý Yêu cầu thuê**
*   [ ] **Task KHANH.2.1:** Thiết kế màn hình **`Thông báo - Yêu cầu thuê phòng mới`** phía Admin: Xem thông tin khách hàng gửi yêu cầu, duyệt/từ chối yêu cầu thuê.
*   [ ] **Task KHANH.2.2:** Thiết kế màn hình **`Thêm hợp đồng mới - Lumiere Stay`**: Chọn phòng trống, chọn khách thuê, nhập thời hạn, giá cọc thực tế.
*   [ ] **Task KHANH.2.3:** Lập trình logic tự động cập nhật: Khi hợp đồng được tạo, lập tức chuyển trạng thái phòng tương ứng thành `status = 'rented'` trong SQLite.

#### **Sprint 3 (Ngày 5 - 6): Quản lý Hợp đồng & Phòng của tôi**
*   [ ] **Task KHANH.3.1:** Thiết kế màn hình **`Hợp đồng - Lumiere Stay`** phía Admin: Danh sách hợp đồng đang hiệu lực, sắp hết hạn, đã hết hạn.
*   [ ] **Task KHANH.3.2:** Lập trình tính năng kết thúc hợp đồng (Trả phòng), tự động đưa phòng trọ về trạng thái trống `'empty'`.
*   [ ] **Task KHANH.3.3:** Thiết kế màn hình **`Phòng của tôi - Lumiere Stay (Updated Actions)`** dành cho Khách thuê để theo dõi hợp đồng của mình.

#### **Sprint 4 (Ngày 7 - 8): Hóa đơn điện nước & Billing Engine**
*   [ ] **Task KHANH.4.1:** Thiết kế màn hình **`Hóa đơn - Admin (Updated AppBar)`**: Admin nhập chỉ số điện/nước cũ/mới, đơn giá, phí dịch vụ.
*   [ ] **Task KHANH.4.2:** Thiết kế màn hình **`Hóa đơn của tôi - Lumiere Stay`** phía Khách thuê để kiểm tra số tiền cần đóng mỗi tháng.
*   [ ] **Task KHANH.4.3:** Lập trình **Billing Engine**:
    *   Tổng tiền = Tiền phòng + Tiền điện + Tiền nước + Dịch vụ + Phát sinh.
    *   Validate chặt chẽ: Điện/Nước mới bắt buộc phải `>=` cũ. Mỗi phòng chỉ có 1 hóa đơn/tháng.
    *   Cập nhật trạng thái `'paid'` kèm ghi nhận ngày thanh toán thực tế.

#### **Sprint 5 (Ngày 9 - 10): Thuật toán quét thông báo ngầm**
*   [ ] **Task KHANH.5.1:** Lập trình thuật toán quét nền tự động khi mở app:
    *   *Quét hết hạn hợp đồng:* Nếu hợp đồng cách ngày kết thúc dưới 30 ngày, tự động tạo bản ghi thông báo loại `'contract_expiry'`.
    *   *Quét nhắc nợ tiền phòng:* Nếu ngày hiện tại nằm từ ngày 1 đến ngày 5 đầu tháng và hóa đơn là `'unpaid'`, tự động tạo bản ghi thông báo loại `'rent_reminder'`.
*   [ ] **Task KHANH.5.2:** Tích hợp logic xử lý gửi thông báo sự kiện từ Admin đến Khách hàng.

#### **Sprint 6 (Ngày 11 - 12): Unit Test nghiệp vụ & Git Merge**
*   [ ] **Task KHANH.6.1:** Đẩy toàn bộ mã nguồn nghiệp vụ lên Git repository của nhóm để Minh Luân thực hiện merge code.
*   [ ] **Task KHANH.6.2:** Viết các kịch bản kiểm thử (Test Cases) kiểm tra tính đúng đắn của công thức tính tiền hóa đơn và các logic trigger cập nhật trạng thái phòng tự động.
*   [ ] **Task KHANH.6.3:** Phối hợp sửa các bug nghiệp vụ phát sinh trong quá trình ghép nối liên luồng.

---

## 5. NGUYÊN TẮC PHỐI HỢP & GIAO TIẾP NHÓM
1.  **Họp Daily Standup (21:00 hàng ngày):** Mỗi thành viên báo cáo nhanh qua Discord/Zalo: *Hôm nay làm được gì? Ngày mai làm gì? Có gặp khó khăn (blocker) gì không?* để trưởng nhóm hỗ trợ kịp thời.
2.  **Quản lý nhánh Git:** Tuyệt đối không code trực tiếp trên `main`. Mỗi người code trên nhánh riêng (`feature/luan-admin`, `feature/huy-auth`, `feature/khanh-logic`), và push code vào cuối mỗi Sprint (mỗi 2 ngày) để Minh Luân duyệt và merge code, giải quyết conflict ngay lập tức.
