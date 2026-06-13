# Sprint 4-5 Walkthrough - LUAN

Tài liệu này ghi lại phần hoàn thiện Sprint 4 và Sprint 5 của LUAN cho ứng dụng **Lumiere Stay**.

## Sprint 4: Hồ sơ Admin & SQLite Query nâng cao

- [x] **Task LUAN.4.1:** Hoàn thiện màn hình **Cá nhân - Admin** trong [lib/views/admin/admin_main_layout.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/views/admin/admin_main_layout.dart).
  - Hiển thị thông tin tài khoản admin.
  - Bổ sung nút **Đổi mật khẩu** với kiểm tra mật khẩu hiện tại.
  - Giữ nút **Đăng xuất** và luồng quay về màn hình đăng nhập.

- [x] **Task LUAN.4.2:** Bổ sung query SQLite nâng cao trong [lib/services/database_helper.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/services/database_helper.dart).
  - `getRevenueByMonth()`: tổng doanh thu đã thanh toán theo tháng.
  - `getRevenueSummary({billingMonth})`: tổng tiền đã thu và còn nợ theo tháng.
  - `getDebtorList({billingMonth})`: danh sách khách thuê còn nợ, có thể lọc theo tháng.

- [x] **Task LUAN.4.3:** Mở rộng tích hợp SQLite cho hợp đồng và hóa đơn.
  - `getActiveContractByRoom()`.
  - `createContractWithRoomSync()`.
  - `updateContract()`.
  - `terminateContractWithRoomSync()`.
  - `updateInvoice()`.
  - Các hàm tương ứng được expose qua [lib/services/app_state.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/services/app_state.dart).

## Sprint 5: Thống kê doanh thu đồ họa

- [x] **Task LUAN.5.1:** Thêm màn hình **Thống kê - Admin** tại [lib/views/admin/admin_statistics_page.dart](file:///C:/code/LTDD/DoAn/tenant_management_app/lib/views/admin/admin_statistics_page.dart).
  - Dùng `fl_chart` để vẽ biểu đồ cột doanh thu thực nhận theo tháng.
  - Thêm tab **Thống kê** vào bottom navigation của Admin.

- [x] **Task LUAN.5.2:** Hiển thị danh sách khách thuê nợ tiền phòng trong tháng hiện tại.
  - `AppState.currentBillingMonth` tự sinh dạng `YYYY-MM`.
  - `AppState.debtorList` hiện chỉ nạp các hóa đơn `status = 'unpaid'` của tháng hiện tại.

- [x] **Task LUAN.5.3:** Thêm hàm quét offline.
  - `DatabaseHelper.runOfflineHealthCheck()` kiểm tra khả năng truy vấn các bảng lõi và các query thống kê/nợ mà không cần Internet.
  - Màn **Thống kê** có nút chạy quét offline và hiển thị kết quả.

## Ghi chú kiểm thử

- Đã chạy `git diff --check`: không có lỗi whitespace.
- `dart format` và `flutter analyze` đều bị timeout trong môi trường hiện tại, kể cả khi tăng timeout lên 5 phút. Các process Dart bị treo sau timeout đã được dọn lại.
