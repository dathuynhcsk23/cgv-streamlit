# 🎬 CGV Cinema Management System

Ứng dụng Streamlit để quản lý và minh họa các workflow của hệ thống quản lý rạp chiếu phim CGV.

## 📋 Mục lục

- [Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
- [Cài đặt Database](#-cài-đặt-database)
- [Cài đặt Dependencies](#-cài-đặt-dependencies)
- [Chạy ứng dụng](#-chạy-ứng-dụng)
- [Tính năng](#-tính-năng)

## 💻 Yêu cầu hệ thống

- **Python**: >= 3.12
- **SQL Server**: 2019 trở lên (hoặc SQL Server Express)
- **ODBC Driver**: Microsoft ODBC Driver 17 for SQL Server

### Cài đặt ODBC Driver (nếu chưa có)

Tải và cài đặt từ: [Microsoft ODBC Driver 17 for SQL Server](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)

## 🗄️ Cài đặt Database

### Bước 1: Mở SQL Server Management Studio (SSMS)

Kết nối đến SQL Server instance của bạn (thường là `localhost` hoặc `.\SQLEXPRESS`).

### Bước 2: Chạy script khởi tạo database

1. Mở file `setup/BTL2_DBS_HK251.sql` trong SSMS
2. Nhấn **F5** hoặc click **Execute** để chạy toàn bộ script
3. Script sẽ tự động:
   - Tạo database `Movie`
   - Tạo tất cả các bảng (KhachHang, Phim, RapChieuPhim, Ve, GiaoDich, ...)
   - Tạo các Stored Procedures (sp_Insert_SuatChieu, Update_ThongTinSuatChieu, ...)
   - Tạo các Scalar Functions (ThongKeDoanhThuVeCuaRap, Top5PhimDoanhThuCaoNhat)
   - Tạo các Triggers (trg_UpdateTongChiTieuLuyKe, trg_CheckTuoiXemPhim)
   - Chèn dữ liệu mẫu

### Bước 3: Kiểm tra kết nối

Đảm bảo SQL Server đang chạy và cho phép **Windows Authentication** (Trusted Connection).

## 📦 Cài đặt Dependencies

### Cách 1: Sử dụng `uv` (khuyến nghị)

[uv](https://github.com/astral-sh/uv) là package manager hiện đại cho Python.

```powershell
# Cài đặt dependencies
uv sync
```

### Cách 2: Sử dụng `pip`

```powershell
# Tạo virtual environment
python -m venv .venv

# Kích hoạt virtual environment
.\.venv\Scripts\Activate.ps1

# Cài đặt dependencies
pip install streamlit pyodbc
```

## 🚀 Chạy ứng dụng

### Sử dụng `uv`

```powershell
uv run streamlit run app.py
```

### Sử dụng `pip` (sau khi đã activate venv)

```powershell
streamlit run app.py
```

Sau đó truy cập ứng dụng tại: **http://localhost:8501**

## ✨ Tính năng

### 1. 🎬 Quản Lý Suất Chiếu

- Tìm kiếm suất chiếu theo ngày, giờ, rạp, phim
- Thêm suất chiếu mới
- Cập nhật thông tin suất chiếu
- Xóa suất chiếu

### 2. 📊 Thống Kê Doanh Thu

- Thống kê doanh thu vé theo rạp
- Top 5 phim doanh thu cao nhất

### 3. 💳 Tài Khoản Chi Tiêu Cao

- Liệt kê tài khoản thành viên có tổng chi tiêu lũy kế cao
- Lọc theo mức chi tiêu tối thiểu

### 4. ⚡ Demo Trigger

- **trg_UpdateTongChiTieuLuyKe**: Demo cập nhật tự động tổng chi tiêu khi thanh toán/hủy giao dịch
- **trg_CheckTuoiXemPhim**: Demo kiểm tra tuổi - ngăn mua vé nếu khách hàng chưa đủ tuổi xem phim

### 5. ℹ️ Thông Tin Database

- Xem danh sách bảng
- Xem Stored Procedures, Functions, Triggers

## 🔧 Cấu hình kết nối Database

Nếu cần thay đổi thông tin kết nối, chỉnh sửa biến `CONN_STR` trong file `app.py`:

```python
CONN_STR = (
    r"DRIVER={ODBC Driver 17 for SQL Server};"
    r"SERVER=localhost;"  # Thay đổi nếu server khác
    r"DATABASE=Movie;"
    r"Trusted_Connection=yes;"
)
```

## 📁 Cấu trúc thư mục

```
cgv-streamlit/
├── app.py              # Ứng dụng Streamlit chính
├── pyproject.toml      # Cấu hình project và dependencies
├── README.md           # File hướng dẫn này
├── setup/
│   └── BTL2_DBS_HK251.sql  # Script khởi tạo database
└── .streamlit/
    └── config.toml     # Cấu hình Streamlit
```

## ❓ Xử lý sự cố

### Lỗi kết nối database

- Kiểm tra SQL Server đang chạy
- Kiểm tra tên server trong `CONN_STR`
- Đảm bảo đã cài đặt ODBC Driver 17

### Lỗi "Module not found"

- Đảm bảo đã cài đặt dependencies: `uv sync` hoặc `pip install streamlit pyodbc`

### Lỗi "Database 'Movie' does not exist"

- Chạy script `setup/BTL2_DBS_HK251.sql` trong SSMS

---

**Đây là sản phẩm cho Bài tập lớn môn Hệ Cơ Sở Dữ Liệu (CO2013) ở Trường Đại học Bách khoa (HCMUT)**
