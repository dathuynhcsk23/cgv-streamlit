CREATE DATABASE Movie;
GO

USE Movie;
GO

CREATE TABLE KhachHang (
    MaKhachHang CHAR(11) NOT NULL,
    HoTen NVARCHAR(50) NOT NULL,
    LoaiKhachHang NVARCHAR(50),

    PRIMARY KEY (MaKhachHang),
    CHECK (LoaiKhachHang IN (N'Thường', N'Thành viên'))
);
GO

CREATE TABLE TaiKhoanThanhVien (
    MaTaiKhoan CHAR(12) NOT NULL,
    TrangThaiHoatDong BIT NOT NULL DEFAULT 1,
    TenDangNhap VARCHAR(50) NOT NULL,
    CapDoTaiKhoan NVARCHAR(20),
    TongChiTieuLuyKe DECIMAL(18, 2) DEFAULT 0,
    
    MaKhachHang CHAR(11) NOT NULL,
    
    RapYeuThich NVARCHAR(100) NOT NULL,
    SoDienThoai CHAR(10) NOT NULL,
    NgaySinh DATE NOT NULL,
    GioiTinh NVARCHAR(10) NOT NULL,
    Email VARCHAR(70) NOT NULL,
    
    PRIMARY KEY (MaTaiKhoan),
    UNIQUE (TenDangNhap),
    UNIQUE (MaKhachHang),
    UNIQUE (SoDienThoai),
    UNIQUE (Email),
    CHECK (CapDoTaiKhoan IN (N'Member', N'VIP', N'VVIP')),
    CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
    CONSTRAINT FK_TaiKhoan_KhachHang 
        FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang)
);
GO

CREATE TABLE GiaoDich(
    MaGiaoDich CHAR(9) NOT NULL,
    MaKhachHang CHAR(11) NOT NULL,
    ThoiDiemBatDau DATETIME NOT NULL,
    ThoiDiemKetThuc DATETIME NOT NULL,
    KenhThanhToan NVARCHAR(30) NOT NULL, 
    TrangThai NVARCHAR(30) NOT NULL,
    PhuongThuc NVARCHAR(7) NOT NULL,

    PRIMARY KEY (MaGiaoDich),
    CHECK (TrangThai IN (N'Khởi tạo', N'Tạm giữ', N'Đã thanh toán', N'Hủy')),
    CHECK (KenhThanhToan IN (N'Tiền mặt', N'Thẻ nội địa', N'Thẻ quốc tế', N'Ví điện tử')),
    CHECK (PhuongThuc IN ('Online','Offline')),
    FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang)
);
GO

CREATE TABLE RapChieuPhim (
    MaRap CHAR(5) NOT NULL,
    TenRap NVARCHAR(100) NOT NULL,
    DiaChi_ChiTiet NVARCHAR(300) NOT NULL,
    TinhThanh NVARCHAR(25) NOT NULL,
    ToaDo GEOGRAPHY,
    NgayKhaiTruong DATE NOT NULL,
    ThoiGianMoCua TIME NOT NULL,
    ThoiGianDongCua TIME NOT NULL,
    MoTaTongQuan NVARCHAR(200) NOT NULL,
    TrangThaiHoatDong NVARCHAR(20) NOT NULL,
    SoSuatChieu_MotNgay INT NOT NULL,
    TyLeLapDay DECIMAL(3,2) NOT NULL,

    PRIMARY KEY (MaRap),
    CHECK (TrangThaiHoatDong IN (N'Hoạt động', N'Bảo trì', N'Ngưng hoạt động'))
);
GO

CREATE TABLE Phim(
    MaPhim CHAR(10) NOT NULL,
    NamSanXuat SMALLINT,
    ThoiLuong TIME NOT NULL,
    MoTaTomTat NVARCHAR(4000),
    MoTaMarketing NVARCHAR(4000),
    NgonNguGoc NVARCHAR(20),
    GioiHanDoTuoi TINYINT NOT NULL,
    NgayKhoiChieu_ChinhThuc DATE NOT NULL,
    TuaDe NVARCHAR(50) NOT NULL,
    TrangThaiPhatHanh NVARCHAR(30) NOT NULL,

    PRIMARY KEY (MaPhim),
    CHECK (TrangThaiPhatHanh IN (N'Đang chiếu', N'Sắp chiếu', N'Ngưng chiếu', N'Trailer'))
);
GO

CREATE TABLE QuayGiaoDich (
    MaQuay TINYINT NOT NULL,
    MaRap CHAR(5) NOT NULL,
    LoaiQuay NVARCHAR(10) NOT NULL,

    PRIMARY KEY (MaQuay, MaRap),
    CHECK (MaQuay > 0),
    CHECK (LoaiQuay IN (N'Vé', N'Bắp nước', N'Tích hợp')),
    FOREIGN KEY (MaRap) REFERENCES RapChieuPhim(MaRap)
);
GO

CREATE TABLE PhongChieu (
    MaPhong TINYINT,
    MaRap CHAR(5),
    SucChua SMALLINT NOT NULL, 
    TrangThai BIT NOT NULL DEFAULT 1,
    LoaiPhong NVARCHAR(10) NOT NULL,
    TenHienThi NVARCHAR(20) NOT NULL,

    PRIMARY KEY (MaPhong, MaRap),
    CHECK (MaPhong > 0),
    CHECK (SucChua > 0),
    CHECK (LoaiPhong IN ('2D','3D','IMAX','GOLDCLASS','STARIUM','4DX')),
    FOREIGN KEY (MaRap) REFERENCES RapChieuPhim(MaRap)
);
GO

CREATE TABLE SuatChieu (
    MaSuatChieu CHAR(7),
    MaPhim CHAR(10),
    MaRap CHAR(5) NOT NULL,
    MaPhongChieu TINYINT NOT NULL,
    NgayChieu DATE NOT NULL,
    DinhDangChieu NVARCHAR(10) NOT NULL,
    NgonNgu NVARCHAR(20) NOT NULL,
    TrangThai NVARCHAR(15) NOT NULL,
    HinhThucDichThuat NVARCHAR(10) NOT NULL,
    GioBatDau TIME NOT NULL,

    PRIMARY KEY (MaSuatChieu, MaPhim),
    CHECK (MaPhongChieu > 0),
    CHECK (TrangThai IN (N'Mở bán', N'Khóa bán', N'Đã chiếu', N'Hủy')),
    CHECK (HinhThucDichThuat IN ('PhuDe','LongTieng')),
    FOREIGN KEY (MaPhim) REFERENCES Phim(MaPhim),
    FOREIGN KEY (MaPhongChieu, MaRap) REFERENCES PhongChieu(MaPhong, MaRap)
);
GO

CREATE TABLE Ghe (
    MaGhe NVARCHAR(7),
    MaRap CHAR(5),
    MaPhongChieu TINYINT,
    So TINYINT NOT NULL,
    Hang CHAR(1) NOT NULL,
    TrangThai NVARCHAR(10) NOT NULL,
    Loai NVARCHAR(10) NOT NULL,

    PRIMARY KEY (MaGhe, MaRap, MaPhongChieu),
    CHECK (MaPhongChieu > 0),
    CHECK (TrangThai IN (N'Hoạt động', N'Bảo trì')),
    CHECK (Loai IN ('Normal','VIP','Couple','Sweetbox','Special')),
    FOREIGN KEY (MaPhongChieu, MaRap) REFERENCES PhongChieu(MaPhong, MaRap)
);
GO

CREATE TABLE Ve (
    MaVe CHAR(9) NOT NULL,
    MaGhe NVARCHAR(7) NOT NULL,
    TrangThai NVARCHAR(20) NOT NULL,
    PhuThu DECIMAL(18, 2) DEFAULT 0,
    GiaChuan DECIMAL(18, 2) NOT NULL,
    GiaSauUuDai DECIMAL(18, 2) NOT NULL,
    
    MaGiaoDich CHAR(9) NOT NULL,
    MaPhim CHAR(10) NOT NULL,
    MaSuatChieu CHAR(7),
    ThoiDiemXuatVe DATETIME NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (MaVe),
    CHECK (TrangThai IN (N'Tạm giữ', N'Đã xuất', N'Hoàn/Hủy')),
    
    CONSTRAINT FK_Ve_GiaoDich 
        FOREIGN KEY (MaGiaoDich) REFERENCES GiaoDich(MaGiaoDich),
    
    CONSTRAINT FK_Ve_Phim
        FOREIGN KEY (MaPhim) REFERENCES Phim(MaPhim),
    
    CONSTRAINT FK_Ve_SuatChieu
        FOREIGN KEY (MaSuatChieu, MaPhim) REFERENCES SuatChieu(MaSuatChieu, MaPhim)
);
GO

CREATE TABLE TheThanhVien (
    MaSoThe CHAR(16) NOT NULL,
    NgayDangKy DATE NOT NULL DEFAULT GETDATE(),
    TrangThai BIT NOT NULL DEFAULT 1, 
    LaTheChinh BIT NOT NULL DEFAULT 1,
    
    MaTaiKhoan CHAR(12) NOT NULL,
    
    PRIMARY KEY (MaSoThe),
    CHECK (MaSoThe NOT LIKE '%[^0-9]%'),
    CONSTRAINT FK_The_TaiKhoan 
        FOREIGN KEY (MaTaiKhoan) REFERENCES TaiKhoanThanhVien(MaTaiKhoan)
);
GO

CREATE TABLE DiemThuong(
    MaDiemThuong CHAR(9) NOT NULL,
    SoLuong SMALLINT NOT NULL,
    TrangThai NVARCHAR(30),
    MaGiaoDich CHAR(9) NOT NULL,
    MaTaiKhoan CHAR(12) NOT NULL,
    NgayGhiNhan DATE NOT NULL,
    NgayHetHan DATE NOT NULL,

    PRIMARY KEY (MaDiemThuong),
    CHECK (TrangThai IN (N'Còn hiệu lực', N'Đã dùng', N'Đã hết hạn')),
    UNIQUE (MaGiaoDich),
    FOREIGN KEY (MaGiaoDich) REFERENCES GiaoDich(MaGiaoDich),
    FOREIGN KEY (MaTaiKhoan) REFERENCES TaiKhoanThanhVien(MaTaiKhoan)
);
GO

CREATE TABLE MaUuDai(
    MaSo CHAR(7) NOT NULL,
    GiaTri INT NOT NULL,
    TrangThai NVARCHAR(50) NOT NULL,
    DieuKienApDung INT NOT NULL,
    Loai NVARCHAR(10) NOT NULL,
    NguonPhatHanh NVARCHAR(50) NOT NULL,
    NgayPhatHanh DATE NOT NULL,
    NgayBatDauHieuLuc DATE NOT NULL,
    GioiHanSoLanSuDung TINYINT NOT NULL,
    NgayHetHan DATE NOT NULL,
    MaGiaoDich CHAR(9) NOT NULL,

    PRIMARY KEY (MaSo),
    CHECK (TrangThai IN (N'Chưa dùng', N'Đã dùng', N'Hết hạn', N'Bị hủy')),
    CHECK (Loai IN ('So tien', 'Phan tram')),
    CHECK (GioiHanSoLanSuDung > 0),
    FOREIGN KEY (MaGiaoDich) REFERENCES GiaoDich(MaGiaoDich)
);
GO

CREATE TABLE MaDoiTuDiem(
    MaSo CHAR(7) NOT NULL,
    MaTaiKhoan CHAR(12) NOT NULL,
    MaDiemThuong CHAR(9) NOT NULL,

    PRIMARY KEY (MaSo),
    UNIQUE (MaTaiKhoan),
    UNIQUE (MaDiemThuong),
    FOREIGN KEY (MaSo) REFERENCES MaUuDai(MaSo),
    FOREIGN KEY (MaDiemThuong) REFERENCES DiemThuong(MaDiemThuong),
    FOREIGN KEY (MaTaiKhoan) REFERENCES TaiKhoanThanhVien(MaTaiKhoan)
);
GO

CREATE TABLE MaTheoSuKien(
    MaSo CHAR(7) NOT NULL,
    TenSuKien NVARCHAR(50) NOT NULL,

    PRIMARY KEY (MaSo),
    FOREIGN KEY (MaSo) REFERENCES MaUuDai(MaSo)
);
GO

CREATE TABLE Ghe_DanhSachTrangThaiCuaGhe (
    MaSuatChieu CHAR(7),
    MaPhim CHAR(10),
    TrangThai NVARCHAR(10) NOT NULL,
    MaGhe NVARCHAR(7) NOT NULL,

    PRIMARY KEY (MaSuatChieu, MaPhim, MaGhe),
    FOREIGN KEY (MaSuatChieu, MaPhim) REFERENCES SuatChieu(MaSuatChieu, MaPhim),
    CHECK (TrangThai IN (N'Trống', N'Tạm giữ', N'Đã bán'))
);
GO

CREATE TABLE Combo (
    MaCombo CHAR(10) NOT NULL,
    Ten NVARCHAR(30) NOT NULL,
    GiaNiemYet INT NOT NULL,
    GiaKhuyenMai INT,
    TrangThai NVARCHAR(20) NOT NULL,
    GioiHan INT,

    PRIMARY KEY (MaCombo),
    CHECK (GiaNiemYet >= 0 AND GiaNiemYet <= 399000),
    CHECK (GiaKhuyenMai IS NULL OR (GiaKhuyenMai >= 0 AND GiaKhuyenMai <= 399000))
);
GO

CREATE TABLE Combo_ThanhPhan (
    Ma_combo CHAR(10),
    ThanhPhanCombo NVARCHAR(5) NOT NULL,
    SoLuong TINYINT NOT NULL,
    
    PRIMARY KEY (Ma_combo, ThanhPhanCombo),
    CHECK (ThanhPhanCombo IN ('Bap','Nuoc', 'Snack')),
    CONSTRAINT MaComboFK_cbtp
        FOREIGN KEY (Ma_combo) REFERENCES Combo(MaCombo)
);
GO

CREATE TABLE DuocDiKem (
    Ma_Combo CHAR(10),
    Ma_Giaodich CHAR(15),
    SoLuong TINYINT,
    
    PRIMARY KEY (Ma_Combo, Ma_Giaodich),
    CONSTRAINT MaComboFK_ddk
        FOREIGN KEY (Ma_Combo) REFERENCES Combo(MaCombo)
);
GO

CREATE TABLE Theloai_Phim (
    Ma_Phim CHAR(10),
    TheloaiPhim NVARCHAR(50),
    
    PRIMARY KEY (Ma_Phim, TheloaiPhim),
    FOREIGN KEY (Ma_Phim) REFERENCES Phim(MaPhim)
);
GO

CREATE TABLE DinhDangHoTro_Phim (
    Ma_Phim CHAR(10),
    DinhDangHoTro NVARCHAR(50),
    
    PRIMARY KEY (Ma_Phim, DinhDangHoTro),
    FOREIGN KEY (Ma_Phim) REFERENCES Phim(MaPhim)
);
GO

CREATE TABLE DienVien_Phim (
    Ma_Phim CHAR(10),
    DienVien NVARCHAR(100),
    
    PRIMARY KEY (Ma_Phim, DienVien),
    FOREIGN KEY (Ma_Phim) REFERENCES Phim(MaPhim)
);
GO 

CREATE TABLE DaoDien_Phim (
    Ma_Phim CHAR(10),
    DaoDien NVARCHAR(100),
    
    PRIMARY KEY (Ma_Phim, DaoDien),
    FOREIGN KEY (Ma_Phim) REFERENCES Phim(MaPhim)
);
GO

CREATE TABLE NhanSu (
    ID CHAR(8) NOT NULL,
    CCCD CHAR(12) NOT NULL,
    DiaChi NVARCHAR(200) NOT NULL,
    GioiTinh NVARCHAR(10) NOT NULL,
    NgaySinh DATE NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    NgayBatDauLamViec DATE NOT NULL,
    MucLuongCoBan DECIMAL(18, 2) NOT NULL,
    LoaiHopDong NVARCHAR(50) NOT NULL,
    TrangThai NVARCHAR(20) NOT NULL,
    SoDienThoai CHAR(10) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    MaRap CHAR(5) NOT NULL,
    
    PRIMARY KEY (ID),
    UNIQUE (CCCD),
    UNIQUE (SoDienThoai),
    UNIQUE (Email),
    CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
    CHECK (MucLuongCoBan >= 0),
    CHECK (LoaiHopDong IN (N'Chính thức', N'Thử việc', N'Hợp đồng ngắn hạn')),
    CHECK (TrangThai IN (N'Đang làm', N'Nghỉ tạm', N'Thôi việc')),
    CHECK (DATEDIFF(YEAR, NgaySinh, NgayBatDauLamViec) >= 18),
    CONSTRAINT FK_NhanSu_RapChieuPhim 
        FOREIGN KEY (MaRap) REFERENCES RapChieuPhim(MaRap)
);
GO

CREATE TABLE NguoiQuanLy (
    ID CHAR(8) NOT NULL,
    CapBac NVARCHAR(50) NOT NULL,
    KhuVucPhuTrach NVARCHAR(200),
    NgayBoNhiem DATE NOT NULL,
    
    PRIMARY KEY (ID),
    CHECK (CapBac IN (N'Quản lý rạp', N'Quản lý khu vực', N'Quản lý vùng', N'Quản lý cấp cao')),
    CONSTRAINT FK_NguoiQuanLy_NhanSu 
        FOREIGN KEY (ID) REFERENCES NhanSu(ID)
);
GO

CREATE TABLE NhanVienBanVe (
    ID CHAR(8) NOT NULL,
    VaiTro NVARCHAR(50) NOT NULL,
    MaCaLamViec CHAR(8) NOT NULL,
    IDQuanLy CHAR(8),
    
    PRIMARY KEY (ID),
    CHECK (VaiTro IN (N'Bán vé', N'Bán đồ ăn', N'Đa năng')),
    CONSTRAINT FK_NhanVienBanVe_NhanSu 
        FOREIGN KEY (ID) REFERENCES NhanSu(ID),
    CONSTRAINT FK_NhanVienBanVe_NguoiQuanLy 
        FOREIGN KEY (IDQuanLy) REFERENCES NguoiQuanLy(ID)
);
GO

CREATE TABLE QuanLy (
    IDQuanLy CHAR(8) NOT NULL,
    IDQuanLyCapCao CHAR(8) NOT NULL,
    
    PRIMARY KEY (IDQuanLy),
    CONSTRAINT FK_QuanLy_CapDuoi 
        FOREIGN KEY (IDQuanLy) REFERENCES NguoiQuanLy(ID),
    CONSTRAINT FK_QuanLy_CapCao 
        FOREIGN KEY (IDQuanLyCapCao) REFERENCES NguoiQuanLy(ID),
    CONSTRAINT CHK_QuanLy_KhongTuQuanLy 
        CHECK (IDQuanLy <> IDQuanLyCapCao)
);
GO

CREATE TABLE NhanSuChamCong (
    ID CHAR(8),
    ThoiDiemCheckIn DATETIME,
    ThoiDiemCheckOut DATETIME,
    CaDangKy CHAR(8) NOT NULL,
    CaThucTe CHAR(8),
    SaiLech INT,
    
    PRIMARY KEY (ID, CaThucTe),
    CONSTRAINT FK_NhanSuChamCong_NhanSu 
        FOREIGN KEY (ID) REFERENCES NhanSu(ID),
    CONSTRAINT CHK_NhanSuChamCong_ThoiGian 
        CHECK (ThoiDiemCheckOut IS NULL OR ThoiDiemCheckIn IS NULL OR ThoiDiemCheckOut > ThoiDiemCheckIn)
);
GO

CREATE TABLE Off_line(
    MaGiaoDich CHAR(9) NOT NULL,
    MaQuay TINYINT NOT NULL,
    MaRap CHAR(5) NOT NULL,
    ID_NhanVien CHAR(8) NOT NULL, 

    PRIMARY KEY (MaGiaoDich),
    CHECK (MaQuay > 0),
    FOREIGN KEY (ID_NhanVien) REFERENCES NhanVienBanVe(ID),
    FOREIGN KEY (MaGiaoDich) REFERENCES GiaoDich(MaGiaoDich),
    FOREIGN KEY (MaQuay, MaRap) REFERENCES QuayGiaoDich(MaQuay, MaRap)
);
GO

CREATE TABLE On_line(
    MaGiaoDich CHAR(9) NOT NULL,
    SLA TIME NOT NULL,

    PRIMARY KEY (MaGiaoDich),
    FOREIGN KEY (MaGiaoDich) REFERENCES GiaoDich(MaGiaoDich)
);
GO

CREATE TABLE DuocTruc (
    ID_NhanVien CHAR(8) NOT NULL,
    MaQuay TINYINT,
    MaRap CHAR(5),

    PRIMARY KEY (ID_NhanVien, MaQuay, MaRap),
    CHECK (MaQuay > 0),
    FOREIGN KEY (ID_NhanVien) REFERENCES NhanVienBanVe(ID),
    FOREIGN KEY (MaQuay, MaRap) REFERENCES QuayGiaoDich(MaQuay, MaRap)
);
GO

------------------------------------------------------------
-- PHẦN DATASET BASIC – MỨC 1
-- Giả định: toàn bộ CREATE TABLE ở trên đã chạy thành công
------------------------------------------------------------

---------------------------
-- 1. KHÁCH HÀNG
---------------------------
INSERT INTO KhachHang (MaKhachHang, HoTen, LoaiKhachHang) VALUES
('KH000000001', N'Nguyễn Văn An',    N'Thành viên'),
('KH000000002', N'Trần Thị Bình',    N'Thành viên'),
('KH000000003', N'Lê Minh Châu',     N'Thường'),
('KH000000004', N'Phạm Thị Dung',    N'Thành viên'),
('KH000000005', N'Hoàng Văn Em',     N'Thường'),
('KH000000006', N'Võ Thị Phương',    N'Thành viên'),
('KH000000007', N'Đặng Văn Giang',   N'Thường'),
('KH000000008', N'Bùi Thị Hà',       N'Thành viên'),
('KH000000009', N'Đinh Văn Khoa',    N'Thường'),
('KH000000010', N'Lý Thị Lan',       N'Thành viên');
GO

---------------------------
-- 2. TÀI KHOẢN THÀNH VIÊN
---------------------------
INSERT INTO TaiKhoanThanhVien (
    MaTaiKhoan, TrangThaiHoatDong, TenDangNhap, CapDoTaiKhoan,
    TongChiTieuLuyKe, MaKhachHang, RapYeuThich, SoDienThoai,
    NgaySinh, GioiTinh, Email
) VALUES
('TK0000000001', 1, 'nguyenvanan',    N'Member',  2500000, 'KH000000001', N'CGV Landmark 81', '0901234567', '1990-05-15', N'Nam', 'nguyenvanan@gmail.com'),
('TK0000000002', 1, 'tranthibinh',    N'VIP',     8500000, 'KH000000002', N'CGV Crescent Mall', '0902345678', '1988-08-22', N'Nữ', 'tranthibinh@gmail.com'),
('TK0000000003', 1, 'leminhchau',     N'Member',  1200000, 'KH000000003', N'CGV SC VivoCity', '0903456789', '1995-01-10', N'Nam', 'leminhchau@gmail.com'),
('TK0000000004', 1, 'phamthidung',    N'Member',  3200000, 'KH000000004', N'CGV Hùng Vương Plaza', '0904567890', '1995-03-10', N'Nữ', 'phamthidung@gmail.com'),
('TK0000000005', 1, 'hoangvanem',     N'Member',  2000000, 'KH000000005', N'CGV Sư Vạn Hạnh', '0905678901', '1992-09-09', N'Nam', 'hoangvanem@gmail.com'),
('TK0000000006', 1, 'vothiphuong',    N'VVIP',   15000000, 'KH000000006', N'CGV Sư Vạn Hạnh', '0906789012', '1985-11-30', N'Nữ', 'vothiphuong@gmail.com'),
('TK0000000007', 1, 'dangvangiang',   N'Member',  1800000, 'KH000000007', N'CGV Giga Mall', '0907890123', '1993-04-01', N'Nam', 'dangvangiang@gmail.com'),
('TK0000000008', 1, 'buithiha',       N'VIP',     7800000, 'KH000000008', N'CGV Giga Mall', '0908901234', '1992-07-18', N'Nữ', 'buithiha@gmail.com'),
('TK0000000009', 1, 'dinhvankhoa',    N'Member',  3000000, 'KH000000009', N'CGV Aeon Tân Phú', '0909012345', '1991-02-20', N'Nam', 'dinhvankhoa@gmail.com'),
('TK0000000010', 1, 'lythilan',       N'Member',  4100000, 'KH000000010', N'CGV Aeon Tân Phú', '0900123456', '1993-09-25', N'Nữ', 'lythilan@gmail.com');
GO

---------------------------
-- 3. RẠP CHIẾU PHIM (3 rạp)
---------------------------
INSERT INTO RapChieuPhim (
    MaRap, TenRap, DiaChi_ChiTiet, TinhThanh, ToaDo,
    NgayKhaiTruong, ThoiGianMoCua, ThoiGianDongCua,
    MoTaTongQuan, TrangThaiHoatDong, SoSuatChieu_MotNgay, TyLeLapDay
)
VALUES
('CGV01', N'CGV Landmark 81', N'Vinhomes Central Park, Bình Thạnh', N'TP HCM',
    geography::Point(10.7940, 106.7216, 4326),
    '2018-07-26', '09:00', '23:30',
    N'Rạp CGV tại Landmark 81, nhiều phòng chiếu hiện đại.', N'Hoạt động', 40, 0.75),

('CGV02', N'CGV Crescent Mall', N'101 Tôn Dật Tiên, Q.7', N'TP HCM',
    geography::Point(10.7286, 106.7181, 4326),
    '2012-11-30', '09:00', '23:00',
    N'Rạp CGV tại Crescent Mall, không gian thoáng.', N'Hoạt động', 35, 0.70),

('CGV03', N'CGV SC VivoCity', N'1058 Nguyễn Văn Linh, Q.7', N'TP HCM',
    geography::Point(10.7300, 106.7000, 4326),
    '2015-04-19', '09:00', '23:30',
    N'CGV tại SC VivoCity, âm thanh hình ảnh chuẩn quốc tế.', N'Hoạt động', 38, 0.72);
GO

---------------------------
-- 4. PHIM (10 phim đầu)
---------------------------
INSERT INTO Phim (
    MaPhim, NamSanXuat, ThoiLuong, MoTaTomTat, MoTaMarketing, NgonNguGoc,
    GioiHanDoTuoi, NgayKhoiChieu_ChinhThuc, TuaDe, TrangThaiPhatHanh
)
VALUES
('PHIM000001', 2024, '02:12:00',
 N'Hành trình khám phá ranh giới mới của nhân loại giữa vũ trụ vô tận.',
 N'Bom tấn viễn tưởng với hình ảnh ấn tượng.', N'Tiếng Anh',
 13, '2025-05-10', N'Biên Niên Sử Ngân Hà', N'Đang chiếu'),

('PHIM000002', 2025, '01:58:00',
 N'Một đội đặc nhiệm thực hiện sứ mệnh cuối cùng để ngăn chặn thảm họa toàn cầu.',
 N'Nhịp độ nghẹt thở, nhiều pha hành động.', N'Tiếng Anh',
 16, '2025-07-01', N'Sứ Mệnh Cuối Cùng', N'Đang chiếu'),

('PHIM000003', 2023, '02:05:00',
 N'Khai quật bí ẩn trên Sao Hỏa, nhóm thám hiểm đối mặt thế lực vô hình.',
 NULL, N'Tiếng Anh',
 13, '2024-11-15', N'Bóng Tối Trên Sao Hỏa', N'Ngưng chiếu'),

('PHIM000004', 2024, '01:50:00',
 N'Bác sĩ cấp cứu chạy đua với thời gian để bảo toàn tính mạng bệnh nhân.',
 N'Giật gân đến phút cuối.', N'Tiếng Việt',
 16, '2025-03-08', N'Lằn Ranh Sinh Tử', N'Đang chiếu'),

('PHIM000005', 2023, '02:00:00',
 N'Con tàu nghiên cứu đối mặt siêu bão trên biển.', 
 NULL, N'Tiếng Anh',
 13, '2024-06-21', N'Cơn Bão Trên Đại Dương', N'Ngưng chiếu'),

('PHIM000006', 2024, '01:42:00',
 N'Vũ điệu đường phố đưa nhóm trẻ vượt qua định kiến.', 
 N'Âm nhạc bốc lửa.', N'Tiếng Việt',
 7, '2025-04-12', N'Nhịp Đập Đường Phố', N'Đang chiếu'),

('PHIM000007', 2025, '01:48:00',
 N'Cô gái nhận được thông điệp từ tương lai.', 
 NULL, N'Tiếng Nhật',
 13, '2025-12-05', N'Cô Gái Từ Tương Lai', N'Sắp chiếu'),

('PHIM000008', 2024, '02:08:00',
 N'Một đô thị không bao giờ ngủ che giấu mạng lưới tội phạm tinh vi.',
 N'Noir hiện đại với cú twist bất ngờ.', N'Tiếng Hàn',
 16, '2025-02-28', N'Thị Trấn Không Ngủ', N'Đang chiếu'),

('PHIM000009', 2023, '01:55:00',
 N'Thợ săn tiền thưởng theo dấu kẻ nguy hiểm.',
 NULL, N'Tiếng Anh',
 16, '2024-03-29', N'Kẻ Săn Trong Đêm', N'Ngưng chiếu'),

('PHIM000010', 2025, '02:10:00',
 N'Đội đặc vụ bí mật bảo vệ nhân chứng trong vụ án xuyên quốc gia.',
 N'Hành động căng thẳng.', N'Tiếng Việt',
 16, '2025-09-20', N'Mật Danh: Phượng Hoàng', N'Sắp chiếu');
GO

---------------------------
-- 6. QUẦY GIAO DỊCH
---------------------------
INSERT INTO QuayGiaoDich (MaQuay, MaRap, LoaiQuay) VALUES
(1, 'CGV01', N'Vé'),
(2, 'CGV01', N'Bắp nước'),
(1, 'CGV02', N'Vé'),
(2, 'CGV02', N'Tích hợp'),
(1, 'CGV03', N'Vé');
GO

---------------------------
-- 7. PHÒNG CHIẾU
---------------------------
INSERT INTO PhongChieu (MaPhong, MaRap, SucChua, TrangThai, LoaiPhong, TenHienThi) VALUES
(1, 'CGV01', 100, 1, '2D',        N'Phòng 2D-1'),
(2, 'CGV01', 80,  1, '3D',        N'Phòng 3D-1'),
(1, 'CGV02', 90,  1, '2D',        N'Phòng 2D-2'),
(2, 'CGV02', 70,  1, 'IMAX',      N'Phòng IMAX-2'),
(1, 'CGV03', 100, 1, '2D',        N'Phòng 2D-3'),
(2, 'CGV03', 60,  1, '4DX',       N'Phòng 4DX-3');
GO

---------------------------
-- 5. THỂ LOẠI, ĐỊNH DẠNG, ĐẠO DIỄN, DIỄN VIÊN (basic)
---------------------------
INSERT INTO Theloai_Phim (Ma_Phim, TheloaiPhim) VALUES
('PHIM000001', N'Khoa học viễn tưởng'),
('PHIM000001', N'Phiêu lưu'),
('PHIM000002', N'Hành động'),
('PHIM000003', N'Giật gân'),
('PHIM000004', N'Giật gân'),
('PHIM000005', N'Hành động'),
('PHIM000006', N'Âm nhạc'),
('PHIM000007', N'Viễn tưởng'),
('PHIM000008', N'Hình sự'),
('PHIM000009', N'Hành động'),
('PHIM000010', N'Hình sự');
GO

INSERT INTO DinhDangHoTro_Phim (Ma_Phim, DinhDangHoTro) VALUES
('PHIM000001', N'2D'),
('PHIM000001', N'IMAX'),
('PHIM000002', N'2D'),
('PHIM000002', N'4DX'),
('PHIM000003', N'2D'),
('PHIM000003', N'3D'),
('PHIM000004', N'2D'),
('PHIM000005', N'2D'),
('PHIM000006', N'2D'),
('PHIM000007', N'2D'),
('PHIM000008', N'2D'),
('PHIM000009', N'2D'),
('PHIM000010', N'2D');
GO

INSERT INTO DaoDien_Phim (Ma_Phim, DaoDien) VALUES
('PHIM000001', N'Trần Minh Khoa'),
('PHIM000002', N'Lê Hoàng Nam'),
('PHIM000003', N'Nguyễn Thảo My'),
('PHIM000004', N'Phạm Quang Huy'),
('PHIM000005', N'Vũ Hải Yến'),
('PHIM000006', N'Đặng Nhật Anh'),
('PHIM000007', N'Suzuki Haru'),
('PHIM000008', N'Park Joon-ho'),
('PHIM000009', N'John Miller'),
('PHIM000010', N'Hoàng Thanh Tùng');
GO

INSERT INTO DienVien_Phim (Ma_Phim, DienVien) VALUES
('PHIM000001', N'Lan Chi'),
('PHIM000001', N'Emma Nguyen'),
('PHIM000002', N'Minh Tú'),
('PHIM000003', N'Adam Brooks'),
('PHIM000004', N'Thu Trang'),
('PHIM000005', N'David Lee'),
('PHIM000006', N'Isaac'),
('PHIM000007', N'Yui Nakamura'),
('PHIM000008', N'Lee Min-ho'),
('PHIM000009', N'Chris Evans'),
('PHIM000010', N'Quốc Trường');
GO





---------------------------
-- 8. SUẤT CHIẾU (12 suất)
---------------------------
INSERT INTO SuatChieu (
    MaSuatChieu, MaPhim, MaRap, MaPhongChieu,
    NgayChieu, DinhDangChieu, NgonNgu, TrangThai,
    HinhThucDichThuat, GioBatDau
)
VALUES
('SC00001', 'PHIM000001', 'CGV01', 1, '2025-11-20', N'2D',      N'Tiếng Anh',  N'Mở bán',  'PhuDe',     '10:00:00'),
('SC00002', 'PHIM000002', 'CGV01', 1, '2025-11-20', N'2D',      N'Tiếng Anh',  N'Mở bán',  'PhuDe',     '14:00:00'),
('SC00003', 'PHIM000003', 'CGV01', 2, '2025-11-21', N'3D',      N'Tiếng Anh',  N'Khóa bán','PhuDe',     '19:00:00'),

('SC00004', 'PHIM000004', 'CGV02', 1, '2025-11-20', N'2D',      N'Tiếng Việt', N'Mở bán',  'LongTieng', '09:30:00'),
('SC00005', 'PHIM000005', 'CGV02', 1, '2025-11-21', N'2D',      N'Tiếng Anh',  N'Đã chiếu','PhuDe',     '13:30:00'),
('SC00006', 'PHIM000006', 'CGV02', 2, '2025-11-21', N'IMAX',    N'Tiếng Việt', N'Mở bán',  'LongTieng', '18:00:00'),

('SC00007', 'PHIM000007', 'CGV03', 1, '2025-11-22', N'2D',      N'Tiếng Nhật', N'Mở bán',  'PhuDe',     '10:15:00'),
('SC00008', 'PHIM000008', 'CGV03', 1, '2025-11-22', N'2D',      N'Tiếng Hàn',  N'Khóa bán','PhuDe',     '15:00:00'),
('SC00009', 'PHIM000009', 'CGV03', 2, '2025-11-22', N'4DX',     N'Tiếng Anh',  N'Mở bán',  'PhuDe',     '20:00:00'),

('SC00010', 'PHIM000010', 'CGV01', 1, '2025-11-23', N'2D',      N'Tiếng Việt', N'Mở bán',  'LongTieng', '09:00:00'),
('SC00011', 'PHIM000001', 'CGV02', 1, '2025-11-23', N'2D',      N'Tiếng Anh',  N'Đã chiếu','PhuDe',     '11:00:00'),
('SC00012', 'PHIM000006', 'CGV03', 1, '2025-11-23', N'2D',      N'Tiếng Việt', N'Mở bán',  'LongTieng', '16:30:00');
GO

---------------------------
-- 9. GHẾ (mỗi phòng vài ghế demo)
---------------------------
INSERT INTO Ghe (MaGhe, MaRap, MaPhongChieu, So, Hang, TrangThai, Loai) VALUES
('A01', 'CGV01', 1, 1,  'A', N'Hoạt động', 'Normal'),
('A02', 'CGV01', 1, 2,  'A', N'Hoạt động', 'Normal'),
('A03', 'CGV01', 1, 3,  'A', N'Hoạt động', 'VIP'),

('B01', 'CGV02', 1, 1,  'B', N'Hoạt động', 'Normal'),
('B02', 'CGV02', 1, 2,  'B', N'Hoạt động', 'Normal'),
('B03', 'CGV02', 1, 3,  'B', N'Hoạt động', 'VIP'),

('C01', 'CGV03', 1, 1,  'C', N'Hoạt động', 'Normal'),
('C02', 'CGV03', 1, 2,  'C', N'Hoạt động', 'Normal'),
('C03', 'CGV03', 1, 3,  'C', N'Hoạt động', 'VIP');

GO

---------------------------
-- 10. TRẠNG THÁI GHẾ THEO SUẤT
---------------------------
INSERT INTO Ghe_DanhSachTrangThaiCuaGhe (MaSuatChieu, MaPhim, TrangThai, MaGhe) VALUES
('SC00001', 'PHIM000001', N'Trống',    'A01'),
('SC00001', 'PHIM000001', N'Đã bán',   'A02'),
('SC00002', 'PHIM000002', N'Tạm giữ',  'A03'),
('SC00004', 'PHIM000004', N'Trống',    'B01'),
('SC00005', 'PHIM000005', N'Đã bán',   'B02'),
('SC00006', 'PHIM000006', N'Trống',    'B03'),
('SC00007', 'PHIM000007', N'Đã bán',   'C01'),
('SC00008', 'PHIM000008', N'Tạm giữ',  'C02'),
('SC00009', 'PHIM000009', N'Trống',    'C03');
GO

---------------------------
-- 14. GIAO DỊCH (10 giao dịch)
---------------------------
INSERT INTO GiaoDich (
    MaGiaoDich, MaKhachHang, ThoiDiemBatDau, ThoiDiemKetThuc,
    KenhThanhToan, TrangThai, PhuongThuc
) VALUES
('GD0000001', 'KH000000001', '2025-11-20 10:00:00', '2025-11-20 10:02:00', N'Ví điện tử',   N'Đã thanh toán', 'Online'),
('GD0000002', 'KH000000002', '2025-11-20 14:00:00', '2025-11-20 14:01:30', N'Tiền mặt',     N'Đã thanh toán', 'Offline'),
('GD0000003', 'KH000000003', '2025-11-20 19:00:00', '2025-11-20 19:01:30', N'Thẻ quốc tế',  N'Tạm giữ',       'Online'),
('GD0000004', 'KH000000004', '2025-11-21 09:30:00', '2025-11-21 09:31:00', N'Tiền mặt',     N'Hủy',           'Offline'),
('GD0000005', 'KH000000005', '2025-11-21 13:30:00', '2025-11-21 13:31:30', N'Ví điện tử',   N'Đã thanh toán', 'Online'),
('GD0000006', 'KH000000006', '2025-11-21 18:00:00', '2025-11-21 18:01:30', N'Thẻ nội địa',  N'Đã thanh toán', 'Online'),
('GD0000007', 'KH000000007', '2025-11-22 10:15:00', '2025-11-22 10:16:30', N'Tiền mặt',     N'Đã thanh toán', 'Offline'),
('GD0000008', 'KH000000008', '2025-11-22 15:00:00', '2025-11-22 15:01:30', N'Ví điện tử',   N'Đã thanh toán', 'Online'),
('GD0000009', 'KH000000009', '2025-11-22 20:00:00', '2025-11-22 20:01:30', N'Thẻ quốc tế',  N'Đã thanh toán', 'Online'),
('GD0000010', 'KH000000010', '2025-11-23 09:00:00', '2025-11-23 09:01:30', N'Tiền mặt',     N'Đã thanh toán', 'Offline');
GO

---------------------------
-- 16. VÉ (10 vé – mỗi giao dịch 1 vé demo)
---------------------------
INSERT INTO Ve (
    MaVe, MaGhe, TrangThai, PhuThu, GiaChuan, GiaSauUuDai,
    MaGiaoDich, MaPhim, MaSuatChieu, ThoiDiemXuatVe
) VALUES
('VE0000001', 'A01', N'Đã xuất', 0,     80000, 70000, 'GD0000001', 'PHIM000001', 'SC00001', '2025-11-20 10:00:00'),
('VE0000002', 'A02', N'Đã xuất', 10000, 90000, 80000, 'GD0000002', 'PHIM000002', 'SC00002', '2025-11-20 14:00:00'),
('VE0000003', 'A03', N'Tạm giữ', 0,     75000, 75000, 'GD0000003', 'PHIM000003', 'SC00003', '2025-11-20 19:00:00'),
('VE0000004', 'B01', N'Hoàn/Hủy',0,     85000, 85000, 'GD0000004', 'PHIM000004', 'SC00004', '2025-11-21 09:30:00'),
('VE0000005', 'B02', N'Đã xuất', 0,     90000, 85000, 'GD0000005', 'PHIM000005', 'SC00005', '2025-11-21 13:30:00'),
('VE0000006', 'B03', N'Đã xuất', 5000,  95000, 90000, 'GD0000006', 'PHIM000006', 'SC00006', '2025-11-21 18:00:00'),
('VE0000007', 'C01', N'Đã xuất', 0,     80000, 75000, 'GD0000007', 'PHIM000007', 'SC00007', '2025-11-22 10:15:00'),
('VE0000008', 'C02', N'Đã xuất', 0,     90000, 85000, 'GD0000008', 'PHIM000008', 'SC00008', '2025-11-22 15:00:00'),
('VE0000009', 'C03', N'Đã xuất', 0,     95000, 90000, 'GD0000009', 'PHIM000009', 'SC00009', '2025-11-22 20:00:00'),
('VE0000010', 'A01', N'Đã xuất', 0,     80000, 80000, 'GD0000010', 'PHIM000010', 'SC00010', '2025-11-23 09:00:00');
GO

---------------------------
-- 17. THẺ THÀNH VIÊN
---------------------------
INSERT INTO TheThanhVien (MaSoThe, NgayDangKy, TrangThai, LaTheChinh, MaTaiKhoan) VALUES
('1234567890123456', '2023-01-15', 1, 1, 'TK0000000001'),
('2345678901234567', '2022-08-20', 1, 1, 'TK0000000002'),
('3456789012345678', '2024-03-10', 1, 1, 'TK0000000003'),
('4567890123456789', '2021-11-25', 1, 1, 'TK0000000004'),
('5678901234567890', '2023-07-18', 1, 1, 'TK0000000005'),
('6789012345678901', '2024-09-05', 1, 1, 'TK0000000006'),
('7890123456789012', '2022-12-15', 1, 1, 'TK0000000007'),
('8901234567890123', '2023-04-22', 1, 1, 'TK0000000008'),
('9012345678901234', '2021-06-30', 1, 1, 'TK0000000009'),
('0123456789012345', '2022-02-02', 1, 1, 'TK0000000010');
GO

---------------------------
-- 18. ĐIỂM THƯỞNG + MÃ ƯU ĐÃI + MÃ ĐỔI TỪ ĐIỂM + MÃ SỰ KIỆN
---------------------------
INSERT INTO DiemThuong (MaDiemThuong, SoLuong, TrangThai, MaGiaoDich, MaTaiKhoan, NgayGhiNhan, NgayHetHan) VALUES
('DT0000001', 50, N'Còn hiệu lực', 'GD0000001', 'TK0000000001', '2025-11-20', '2026-11-20'),
('DT0000002', 30, N'Còn hiệu lực', 'GD0000002', 'TK0000000002', '2025-11-20', '2026-11-20'),
('DT0000003', 20, N'Đã dùng',      'GD0000003', 'TK0000000003', '2025-11-20', '2026-05-20'),
('DT0000004',  0, N'Đã hết hạn',    'GD0000004', 'TK0000000004', '2025-11-21', '2026-11-21'),
('DT0000005', 40, N'Còn hiệu lực', 'GD0000005', 'TK0000000005', '2025-11-21', '2026-11-21'),
('DT0000006', 60, N'Còn hiệu lực', 'GD0000006', 'TK0000000006', '2025-11-21', '2026-11-21'),
('DT0000007', 15, N'Còn hiệu lực', 'GD0000007', 'TK0000000007', '2025-11-22', '2026-11-22'),
('DT0000008', 25, N'Còn hiệu lực', 'GD0000008', 'TK0000000008', '2025-11-22', '2026-11-22'),
('DT0000009', 35, N'Còn hiệu lực', 'GD0000009', 'TK0000000009', '2025-11-22', '2026-11-22'),
('DT0000010', 45, N'Còn hiệu lực', 'GD0000010', 'TK0000000010', '2025-11-23', '2026-11-23');
GO

INSERT INTO MaUuDai (MaSo, GiaTri, TrangThai, DieuKienApDung, Loai, NguonPhatHanh,
                     NgayPhatHanh, NgayBatDauHieuLuc, GioiHanSoLanSuDung, NgayHetHan, MaGiaoDich)
VALUES
('UD00001', 50000, N'Chưa dùng', 100000, 'So tien',  N'CGV App',
 '2025-10-01', '2025-10-01', 5, '2025-12-31', 'GD0000001'),
('UD00002', 20,    N'Chưa dùng',  80000, 'Phan tram',N'Galaxy',
 '2025-09-15', '2025-09-20', 3, '2025-12-31', 'GD0000002'),
('UD00003', 30000, N'Hết hạn',    60000, 'So tien',  N'Lotte',
 '2025-07-01', '2025-07-05', 2, '2025-10-31', 'GD0000003'),
('UD00004', 20000, N'Đã dùng',    60000, 'So tien',  N'Beta',
 '2025-11-01', '2025-11-01', 5, '2026-01-01', 'GD0000004');
GO

INSERT INTO MaDoiTuDiem (MaSo, MaTaiKhoan, MaDiemThuong) VALUES
('UD00001', 'TK0000000001', 'DT0000001'),
('UD00002', 'TK0000000002', 'DT0000002'),
('UD00004', 'TK0000000006', 'DT0000006');
GO

INSERT INTO MaTheoSuKien (MaSo, TenSuKien) VALUES
('UD00001', N'Sự kiện Halloween Movie Night'),
('UD00002', N'Chương trình Sinh nhật Galaxy'),
('UD00004', N'Tuần lễ phim Việt Nam 2025');
GO

---------------------------
-- 19. COMBO + THÀNH PHẦN + ĐƯỢC ĐI KÈM
---------------------------
INSERT INTO Combo (MaCombo, Ten, GiaNiemYet, GiaKhuyenMai, TrangThai, GioiHan) VALUES
('CB00000001', N'Combo 01',  79000, 69000, N'HoatDong', NULL),
('CB00000002', N'Combo 02', 129000,109000, N'HoatDong', 100),
('CB00000003', N'Combo 03',  65000, 59000, N'HoatDong', NULL),
('CB00000004', N'Combo 04',  99000, 89000, N'HoatDong', 80),
('CB00000005', N'Combo 05', 159000,139000, N'HoatDong', 50);
GO

INSERT INTO Combo_ThanhPhan (Ma_combo, ThanhPhanCombo, SoLuong) VALUES
('CB00000001', 'Bap',   1),
('CB00000001', 'Nuoc',  1),
('CB00000002', 'Bap',   2),
('CB00000002', 'Nuoc',  2),
('CB00000003', 'Bap',   1),
('CB00000003', 'Snack', 2),
('CB00000004', 'Bap',   2),
('CB00000004', 'Nuoc',  1),
('CB00000005', 'Bap',   3),
('CB00000005', 'Nuoc',  2),
('CB00000005', 'Snack', 2);
GO

INSERT INTO DuocDiKem (Ma_Combo, Ma_Giaodich, SoLuong) VALUES
('CB00000001', 'GD0000001', 1),
('CB00000002', 'GD0000002', 1),
('CB00000003', 'GD0000005', 2),
('CB00000004', 'GD0000006', 1),
('CB00000005', 'GD0000008', 1);
GO

---------------------------
-- 11. NHÂN SỰ
---------------------------
INSERT INTO NhanSu (
    ID, CCCD, DiaChi, GioiTinh, NgaySinh,
    HoTen, NgayBatDauLamViec, MucLuongCoBan,
    LoaiHopDong, TrangThai, SoDienThoai, Email, MaRap
) VALUES
('QL000001', '001202012345', N'123 Nguyễn Huệ, Q1', N'Nam', '1985-03-15',
 N'Trần Văn Quản Lý', '2018-05-01', 25000000, N'Chính thức', N'Đang làm', '0901111111', 'ql1@cgv.vn', 'CGV01'),

('QL000002', '001202012346', N'56 Lê Lai, Q3', N'Nữ', '1990-07-22',
 N'Lê Thị Khu Vực', '2019-08-15', 20000000, N'Chính thức', N'Đang làm', '0902222222', 'ql2@cgv.vn', 'CGV02'),

('QL000003', '001202012347', N'89 Võ Văn Tần, Q5', N'Nam', '1992-11-30',
 N'Nguyễn Văn Rạp', '2020-02-01', 18000000, N'Chính thức', N'Đang làm', '0903333333', 'ql3@cgv.vn', 'CGV03'),

('NV000001', '001202012348', N'12 Phan Đình Phùng', N'Nam', '1998-01-10',
 N'Phạm Văn Bán Vé', '2022-06-01', 8000000, N'Thử việc', N'Đang làm', '0904444444', 'nv1@cgv.vn', 'CGV01'),

('NV000002', '001202012349', N'34 Hoàng Văn Thụ', N'Nữ', '1995-05-18',
 N'Hoàng Thị Vé', '2021-09-10', 8500000, N'Chính thức', N'Đang làm', '0905555555', 'nv2@cgv.vn', 'CGV01'),

('NV000003', '001202012350', N'56 Bùi Thị Xuân', N'Nam', '1997-08-25',
 N'Bùi Văn Đa Năng', '2022-01-15', 9000000, N'Chính thức', N'Đang làm', '0906666666', 'nv3@cgv.vn', 'CGV02'),

('NV000004', '001202012351', N'78 Trần Hưng Đạo', N'Nữ', '1996-12-05',
 N'Trần Thị Đồ Ăn', '2021-12-20', 8200000, N'Chính thức', N'Đang làm', '0907777777', 'nv4@cgv.vn', 'CGV02'),

('NV000005', '001202012352', N'90 Nguyễn Thị Minh Khai', N'Nam', '1999-04-12',
 N'Nguyễn Văn Mới', '2023-03-01', 7800000, N'Thử việc', N'Đang làm', '0908888888', 'nv5@cgv.vn', 'CGV03'),

('NV000006', '001202012353', N'45 Lý Thường Kiệt', N'Nữ', '1994-09-30',
 N'Lý Thị Kinh Nghiệm', '2020-11-05', 9500000, N'Chính thức', N'Đang làm', '0909999999', 'nv6@cgv.vn', 'CGV03'),

('NV000007', '001202012354', N'67 Cách Mạng Tháng 8', N'Nam', '1993-02-28',
 N'Đặng Văn Lâu', '2020-07-20', 9200000, N'Chính thức', N'Đang làm', '0900000000', 'nv7@cgv.vn', 'CGV03');
GO

---------------------------
-- 12. NGƯỜI QUẢN LÝ & NHÂN VIÊN BÁN VÉ
---------------------------
INSERT INTO NguoiQuanLy (ID, CapBac, KhuVucPhuTrach, NgayBoNhiem) VALUES
('QL000001', N'Quản lý cấp cao',  N'Toàn quốc',        '2018-05-01'),
('QL000002', N'Quản lý khu vực', N'Khu vực TP.HCM',   '2019-08-15'),
('QL000003', N'Quản lý rạp',     N'Rạp CGV03',        '2020-02-01');
GO

INSERT INTO NhanVienBanVe (ID, VaiTro, MaCaLamViec, IDQuanLy) VALUES
('NV000001', N'Bán vé',     'CA000001', 'QL000001'),
('NV000002', N'Đa năng',    'CA000002', 'QL000001'),
('NV000003', N'Bán đồ ăn',  'CA000003', 'QL000002'),
('NV000004', N'Bán vé',     'CA000004', 'QL000002'),
('NV000005', N'Đa năng',    'CA000005', 'QL000003'),
('NV000006', N'Bán đồ ăn',  'CA000006', 'QL000003'),
('NV000007', N'Bán vé',     'CA000007', 'QL000003');
GO

INSERT INTO QuanLy (IDQuanLy, IDQuanLyCapCao) VALUES
('QL000002', 'QL000001'),
('QL000003', 'QL000002');
GO

---------------------------
-- 13. CHẤM CÔNG & ĐƯỢC TRỰC
---------------------------
INSERT INTO NhanSuChamCong (ID, ThoiDiemCheckIn, ThoiDiemCheckOut, CaDangKy, CaThucTe, SaiLech) VALUES
('NV000001', '2025-11-20 08:00:00', '2025-11-20 17:00:00', 'CA000001', 'CA000001', 0),
('NV000002', '2025-11-20 08:15:00', '2025-11-20 17:15:00', 'CA000002', 'CA000002', 15),
('QL000002', '2025-11-20 08:00:00', '2025-11-20 20:00:00', 'CA000001', 'CA000003', 180),
('NV000003', '2025-11-21 08:00:00', NULL,                  'CA000003', 'CA000003', NULL),
('NV000004', '2025-11-21 13:50:00', '2025-11-21 22:00:00', 'CA000004', 'CA000004', -10),
('QL000003', '2025-11-21 08:00:00', '2025-11-21 17:00:00', 'CA000005', 'CA000005', 0);
GO

INSERT INTO DuocTruc (ID_NhanVien, MaQuay, MaRap) VALUES
('NV000001', 1, 'CGV01'),
('NV000002', 2, 'CGV01'),
('NV000003', 1, 'CGV02'),
('NV000004', 2, 'CGV02'),
('NV000005', 1, 'CGV03'),
('NV000006', 1, 'CGV03');
GO



---------------------------
-- 15. OFFLINE & ONLINE
---------------------------
INSERT INTO Off_line (MaGiaoDich, MaQuay, MaRap, ID_NhanVien) VALUES
('GD0000002', 1, 'CGV01', 'NV000001'),
('GD0000004', 1, 'CGV02', 'NV000003'),
('GD0000007', 2, 'CGV01', 'NV000002'),
('GD0000010', 1, 'CGV03', 'NV000005');
GO

INSERT INTO On_line (MaGiaoDich, SLA) VALUES
('GD0000001', '00:05:00'),
('GD0000003', '00:05:00'),
('GD0000005', '00:05:00'),
('GD0000006', '00:05:00'),
('GD0000008', '00:05:00'),
('GD0000009', '00:05:00');
GO

----2.1-----

CREATE OR ALTER PROCEDURE sp_Insert_SuatChieu
    @MaSuatChieu CHAR(7),
    @MaPhim CHAR(10),
    @MaRap CHAR(5),
    @MaPhongChieu TINYINT,
    @NgayChieu DATE,
    @DinhDangChieu NVARCHAR(10),
    @NgonNgu NVARCHAR(20),
    @TrangThai NVARCHAR(15),
    @HinhThucDichThuat NVARCHAR(10),
    @GioBatDau TIME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT = 16; -- Mức độ nghiêm trọng cho lỗi
    DECLARE @ErrorState INT = 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Kiểm tra NOT NULL
        IF @MaRap IS NULL OR @MaPhongChieu IS NULL OR @NgayChieu IS NULL OR @DinhDangChieu IS NULL OR @NgonNgu IS NULL OR @TrangThai IS NULL OR @HinhThucDichThuat IS NULL OR @GioBatDau IS NULL
        BEGIN
            SET @ErrorMessage = N'Lỗi ràng buộc NOT NULL: Các trường MaRap, MaPhongChieu, NgayChieu, DinhDangChieu, NgonNgu, TrangThai, HinhThucDichThuat, GioBatDau không được để trống.';
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 2. Kiểm tra PRIMARY KEY (MaSuatChieu, MaPhim) - Đã tồn tại
        IF EXISTS (SELECT 1 FROM SuatChieu WHERE MaSuatChieu = @MaSuatChieu AND MaPhim = @MaPhim)
        BEGIN
            SET @ErrorMessage = N'Lỗi ràng buộc PRIMARY KEY: Suất chiếu có Mã Suất Chiếu (' + @MaSuatChieu + N') và Mã Phim (' + @MaPhim + N') này đã tồn tại.';
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 3. Kiểm tra CHECK: MaPhongChieu > 0
        IF @MaPhongChieu <= 0
        BEGIN
            SET @ErrorMessage = N'Lỗi ràng buộc CHECK: Mã Phòng Chiếu phải là một số nguyên dương lớn hơn 0. Giá trị nhập: ' + CAST(@MaPhongChieu AS NVARCHAR(5));
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 4. Kiểm tra CHECK: TrangThai
        IF @TrangThai NOT IN (N'Mở bán', N'Khóa bán', N'Đã chiếu', N'Hủy')
        BEGIN
            SET @ErrorMessage = N'Lỗi ràng buộc CHECK: Trạng Thái phải là một trong các giá trị: "Mở bán", "Khóa bán", "Đã chiếu", hoặc "Hủy". Giá trị nhập: ' + @TrangThai;
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 5. Kiểm tra CHECK: HinhThucDichThuat
        IF @HinhThucDichThuat NOT IN ('PhuDe', 'LongTieng')
        BEGIN
            SET @ErrorMessage = N'Lỗi ràng buộc CHECK: Hình Thức Dịch Thuật phải là "PhuDe" (Phụ Đề) hoặc "LongTieng" (Lồng Tiếng). Giá trị nhập: ' + @HinhThucDichThuat;
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 6. Kiểm tra FOREIGN KEY: MaPhim (Kiểm tra sự tồn tại trong bảng Phim)
        IF NOT EXISTS (SELECT 1 FROM Phim WHERE MaPhim = @MaPhim)
        BEGIN
            SET @ErrorMessage = N'Lỗi ràng buộc FOREIGN KEY: Mã Phim (' + @MaPhim + N') không tồn tại trong bảng Phim.';
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 7. Kiểm tra FOREIGN KEY: (MaPhongChieu, MaRap) (Kiểm tra sự tồn tại trong bảng PhongChieu)
        IF NOT EXISTS (SELECT 1 FROM PhongChieu WHERE MaPhong = @MaPhongChieu AND MaRap = @MaRap)
        BEGIN
            SET @ErrorMessage = N'Lỗi ràng buộc FOREIGN KEY: Mã Phòng Chiếu (' + CAST(@MaPhongChieu AS NVARCHAR(5)) + N') hoặc Mã Rạp (' + @MaRap + N') không tồn tại trong bảng PhongChieu.';
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 8. KIỂM TRA LOGIC NGHIỆP VỤ: LoaiPhong phải nằm trong DinhDangHoTro_Phim
        IF NOT EXISTS (
            SELECT 1 
            FROM PhongChieu AS PC 
            INNER JOIN DinhDangHoTro_Phim AS DDH 
                ON PC.LoaiPhong = DDH.DinhDangHoTro
            WHERE 
                PC.MaPhong = @MaPhongChieu AND PC.MaRap = @MaRap
                AND DDH.Ma_Phim = @MaPhim
        )
        BEGIN
            -- Lấy LoaiPhong của phòng chiếu để hiển thị lỗi chi tiết
            DECLARE @LoaiPhong NVARCHAR(10);
            SELECT @LoaiPhong = LoaiPhong FROM PhongChieu WHERE MaPhong = @MaPhongChieu AND MaRap = @MaRap;

            SET @ErrorMessage = N'Lỗi logic nghiệp vụ: Phim có Mã (' + @MaPhim + 
                                N') không hỗ trợ định dạng phòng chiếu (' + @LoaiPhong + 
                                N') của Phòng (' + CAST(@MaPhongChieu AS NVARCHAR(5)) + 
                                N') tại Rạp (' + @MaRap + N').';
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END
        ---

        -- Nếu tất cả kiểm tra đều hợp lệ, thực hiện INSERT
        INSERT INTO SuatChieu (
            MaSuatChieu, MaPhim, MaRap, MaPhongChieu, NgayChieu, 
            DinhDangChieu, NgonNgu, TrangThai, HinhThucDichThuat, GioBatDau
        )
        VALUES (
            @MaSuatChieu, @MaPhim, @MaRap, @MaPhongChieu, @NgayChieu, 
            @DinhDangChieu, @NgonNgu, @TrangThai, @HinhThucDichThuat, @GioBatDau
        );

        -- Nếu INSERT thành công, thực hiện COMMIT
        COMMIT TRANSACTION;
        SELECT N'Thêm suất chiếu mới thành công!' AS Result;

    END TRY
    BEGIN CATCH
        -- Nếu có lỗi xảy ra, kiểm tra xem có Transaction đang mở không
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Lấy thông tin lỗi
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(), 
            @ErrorSeverity = ERROR_SEVERITY(), 
            @ErrorState = ERROR_STATE();

        -- Đảm bảo báo lỗi hệ thống nếu lỗi không phải do RAISERROR tùy chỉnh
        IF @ErrorState = 0 AND @ErrorSeverity = 10 
        BEGIN
             SET @ErrorSeverity = 16;
             SET @ErrorState = 1;
        END
        
        -- Đưa ra lỗi
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Update_ThongTinSuatChieu
    @MaSuatChieu CHAR(7),
    @MaPhim CHAR(10),
    @GioBatDauMoi TIME = NULL,   
    @MaPhongMoi TINYINT = NULL, 
    @MaRap CHAR(5)      
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM SuatChieu WHERE MaSuatChieu = @MaSuatChieu AND MaPhim = @MaPhim)
    BEGIN
        RAISERROR(N'Lỗi: Suất chiếu không tồn tại.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Ve 
        WHERE MaSuatChieu = @MaSuatChieu AND MaPhim = @MaPhim 
        AND TrangThai IN (N'Đã bán', N'Đang đặt')
    )
    BEGIN
        RAISERROR(N'Lỗi: Không thể cập nhật suất chiếu này vì đã có vé bán ra.', 16, 1);
        RETURN;
    END

    IF (@GioBatDauMoi IS NOT NULL OR @MaPhongMoi IS NOT NULL)
    BEGIN
        DECLARE @NgayChieu DATE;
        DECLARE @ThoiLuong TIME;
        DECLARE @PhongCheck TINYINT;
        DECLARE @GioCheck TIME;

        SELECT @NgayChieu = SC.NgayChieu, @ThoiLuong = P.ThoiLuong, 
               @PhongCheck = ISNULL(@MaPhongMoi, SC.MaPhongChieu),
               @GioCheck = ISNULL(@GioBatDauMoi, SC.GioBatDau)
        FROM SuatChieu SC
        JOIN Phim P ON SC.MaPhim = P.MaPhim
        WHERE SC.MaSuatChieu = @MaSuatChieu AND SC.MaPhim = @MaPhim;

        DECLARE @GioKetThucCheck TIME = CAST(DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', @ThoiLuong), CAST(@GioCheck AS DATETIME)) AS TIME);

        IF EXISTS (
            SELECT 1 FROM SuatChieu SC_Khac
            JOIN Phim P_Khac ON SC_Khac.MaPhim = P_Khac.MaPhim
            WHERE SC_Khac.MaRap = @MaRap 
              AND SC_Khac.MaPhongChieu = @PhongCheck
              AND SC_Khac.NgayChieu = @NgayChieu
              AND SC_Khac.MaSuatChieu != @MaSuatChieu
              AND (
                  (@GioCheck < CAST(DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', P_Khac.ThoiLuong), CAST(SC_Khac.GioBatDau AS DATETIME)) AS TIME))
                  AND 
                  (@GioKetThucCheck > SC_Khac.GioBatDau)
              )
        )
        BEGIN
            RAISERROR(N'Lỗi: Phòng chiếu đã bị trùng lịch với suất chiếu khác vào giờ này.', 16, 1);
            RETURN;
        END
    END

    UPDATE SuatChieu
    SET 
        GioBatDau = ISNULL(@GioBatDauMoi, GioBatDau),
        MaPhongChieu = ISNULL(@MaPhongMoi, MaPhongChieu)
    WHERE MaSuatChieu = @MaSuatChieu AND MaPhim = @MaPhim;

    PRINT N'Cập nhật suất chiếu thành công!';
END
GO

CREATE OR ALTER PROCEDURE Delete_SuatChieu
	@MaSuatChieu CHAR(7), 
	@MaPhim CHAR(10)
AS
BEGIN
	IF NOT EXISTS(
		SELECT 1
		FROM SuatChieu
		WHERE @MaSuatChieu = MaSuatChieu AND @MaPhim = MaPhim
	)
	BEGIN
		RAISERROR('Lỗi: Không tìm thấy suất chiếu này.', 16,1);
	END

	IF EXISTS(
		SELECT 1
		FROM Ve
		WHERE @MaSuatChieu = Ve.MaSuatChieu AND @MaPhim = Ve.MaPhim
	)
	BEGIN
		DECLARE @date DATE, 
				@end_time TIME,		
				@current_time TIME = CAST(GETDATE() AS TIME),
				@current_date DATE  = CAST(GETDATE() AS DATE);

		SELECT @date= sc.NgayChieu, 
			   @end_time = CAST(
                    DATEADD(
                        SECOND,
                        DATEDIFF(SECOND, '00:00:00', p.ThoiLuong),
                        CAST(sc.GioBatDau AS datetime)
                    ) 
                AS time)
		FROM SuatChieu sc, Phim p
		WHERE @MaSuatChieu = sc.MaSuatChieu AND @MaPhim = sc.MaPhim

		IF (@current_date > @date) OR (@current_date = @date AND @current_time > @end_time)
			BEGIN
				DELETE FROM Ve
				WHERE @MaSuatChieu = Ve.MaSuatChieu AND @MaPhim = Ve.MaPhim

				DELETE FROM SuatChieu
				WHERE @MaSuatChieu = MaSuatChieu AND @MaPhim = MaPhim
				PRINT 'Xóa suất chiếu thành công!';
			END
		ELSE
			BEGIN
				RAISERROR('Lỗi: Có vé đang đặt suất chiếu này.', 16,1);
			END
	END
	ELSE
	BEGIN
		DELETE FROM SuatChieu
		WHERE @MaSuatChieu = MaSuatChieu AND @MaPhim = MaPhim
		PRINT 'Xóa suất chiếu thành công!';
	END
END
GO
---2.2---

CREATE TRIGGER trg_UpdateTongChiTieuLuyKe
ON GiaoDich
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(TrangThai) RETURN;

    DECLARE @Adjustments TABLE (
        MaTaiKhoan CHAR(12),
        AdjustmentAmount DECIMAL(18, 2)
    );

    INSERT INTO @Adjustments (MaTaiKhoan, AdjustmentAmount)
    SELECT
        tk.MaTaiKhoan,
        SUM(v.GiaSauUuDai) AS TotalAdjustment
    FROM inserted i
    JOIN TaiKhoanThanhVien tk ON i.MaKhachHang = tk.MaKhachHang
    LEFT JOIN deleted d ON i.MaGiaoDich = d.MaGiaoDich
    JOIN Ve v ON i.MaGiaoDich = v.MaGiaoDich
    WHERE 
        i.TrangThai = N'Đã thanh toán'
        AND (d.TrangThai IS NULL OR d.TrangThai <> N'Đã thanh toán')
    GROUP BY tk.MaTaiKhoan;

    INSERT INTO @Adjustments (MaTaiKhoan, AdjustmentAmount)
    SELECT
        tk.MaTaiKhoan,
        -SUM(v.GiaSauUuDai) AS TotalAdjustment
    FROM deleted d
    JOIN TaiKhoanThanhVien tk ON d.MaKhachHang = tk.MaKhachHang
    JOIN inserted i ON d.MaGiaoDich = i.MaGiaoDich
    JOIN Ve v ON d.MaGiaoDich = v.MaGiaoDich
    WHERE 
        d.TrangThai = N'Đã thanh toán'
        AND i.TrangThai <> N'Đã thanh toán'
    GROUP BY tk.MaTaiKhoan;

    UPDATE tk
    SET
        tk.TongChiTieuLuyKe = tk.TongChiTieuLuyKe + adj.TotalAmount
    FROM TaiKhoanThanhVien tk
    JOIN (
        SELECT MaTaiKhoan, SUM(AdjustmentAmount) AS TotalAmount
        FROM @Adjustments
        GROUP BY MaTaiKhoan
    ) AS adj ON tk.MaTaiKhoan = adj.MaTaiKhoan;
END
GO

CREATE TRIGGER trg_CheckTuoiXemPhim
ON Ve
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN GiaoDich gd ON i.MaGiaoDich = gd.MaGiaoDich
        JOIN SuatChieu sc ON i.MaSuatChieu = sc.MaSuatChieu AND i.MaPhim = sc.MaPhim
        JOIN Phim p ON sc.MaPhim = p.MaPhim
        LEFT JOIN TaiKhoanThanhVien tk ON gd.MaKhachHang = tk.MaKhachHang
        
        WHERE 
            tk.NgaySinh IS NOT NULL 
            AND
            DATEADD(YEAR, p.GioiHanDoTuoi, tk.NgaySinh) > sc.NgayChieu
    )
    BEGIN
        RAISERROR('LỖI: Không thể thêm vé. Có ít nhất một khách hàng thành viên không đủ tuổi xem phim này. Giao dịch đã bị hủy.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END
GO

-- ================================
-- PHẦN 2.3 - Truy vấn có WHERE, ORDER BY, GROUP BY, HAVING
-- ================================

--  Thủ tục 1: Truy vấn suất chiếu có WHERE, ORDER BY
CREATE OR ALTER PROCEDURE TimSuatChieu
    @NgayChieu DATE = NULL,
    @Gio TIME = NULL,
    @TenRap NVARCHAR(100) = NULL,
    @TuaDe NVARCHAR(50) = NULL
AS
BEGIN
    SELECT
        SC.MaSuatChieu,
        SC.MaPhim,
        SC.MaRap,
        SC.MaPhongChieu,
        P.TuaDe,
        P.ThoiLuong,
        SC.GioBatDau,
        SC.NgayChieu,
        R.TenRap,
        SC.DinhDangChieu,
        SC.NgonNgu
    FROM
        SuatChieu SC
        JOIN Phim P ON SC.MaPhim = P.MaPhim
        JOIN RapChieuPhim R ON SC.MaRap = R.MaRap
    WHERE
        (@NgayChieu IS NULL OR SC.NgayChieu = @NgayChieu)
        AND (@Gio IS NULL OR SC.GioBatDau >= @Gio)
        AND (@TenRap IS NULL OR R.TenRap = @TenRap)
        AND (@TuaDe IS NULL OR P.TuaDe = @TuaDe)
    ORDER BY
        SC.NgayChieu DESC, SC.GioBatDau ASC;
END;
GO



-- Thủ tục 2: Truy vấn tài khoản có tổng chi tiêu theo GROUP BY, HAVING
CREATE OR ALTER PROCEDURE LietKeTaiKhoanTieuNhieu
    @TongChiTieu DECIMAL(18,2) = NULL
AS
BEGIN
    SELECT 
        KH.MaKhachHang,
        KH.HoTen,
        SUM(TV.TongChiTieuLuyKe) AS TongChiTieu
    FROM 
        KhachHang KH
        JOIN TaiKhoanThanhVien TV ON KH.MaKhachHang = TV.MaKhachHang
    WHERE 
        TV.TrangThaiHoatDong = 1
    GROUP BY 
        KH.MaKhachHang, KH.HoTen
    HAVING 
        @TongChiTieu IS NULL OR SUM(TV.TongChiTieuLuyKe) >= @TongChiTieu
    ORDER BY 
        TongChiTieu DESC;
END;
GO


             -----2.4------

-- Hàm tính doanh thu vé của rạp trong khoảng ngày
CREATE FUNCTION ThongKeDoanhThuVeCuaRap
(
    @NgayBatDau DATE,
    @NgayKetThuc DATE
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    IF @NgayBatDau IS NULL OR @NgayKetThuc IS NULL
        RETURN N'Lỗi: Ngày không được để trống!';

    IF @NgayBatDau > @NgayKetThuc
        RETURN N'Lỗi: Ngày bắt đầu không được lớn hơn ngày kết thúc!';

    DECLARE @KetQua NVARCHAR(MAX) = N'[';
    DECLARE @MaRap CHAR(5);
    DECLARE @TenRap NVARCHAR(100);
    DECLARE @Tinh NVARCHAR(25);
    DECLARE @DoanhThu DECIMAL(18,2);

    DECLARE curRap CURSOR FOR
        SELECT DISTINCT rcp.MaRap, rcp.TenRap, rcp.TinhThanh
        FROM RapChieuPhim rcp
        JOIN SuatChieu sc ON rcp.MaRap = sc.MaRap
        WHERE sc.NgayChieu BETWEEN @NgayBatDau AND @NgayKetThuc;

    OPEN curRap;
    FETCH NEXT FROM curRap INTO @MaRap, @TenRap, @Tinh;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @DoanhThu = SUM(v.GiaSauUuDai)
        FROM Ve v
        JOIN GiaoDich gd ON v.MaGiaoDich = gd.MaGiaoDich
        JOIN SuatChieu sc ON v.MaSuatChieu = sc.MaSuatChieu AND v.MaPhim = sc.MaPhim
        WHERE sc.MaRap = @MaRap
        AND gd.ThoiDiemBatDau BETWEEN @NgayBatDau AND @NgayKetThuc;

        IF @DoanhThu IS NULL SET @DoanhThu = 0;

        SET @KetQua = @KetQua +
            N'{"MaRap":"' + @MaRap +
            N'","TenRap":"' + @TenRap +
            N'","TinhThanh":"' + @Tinh +
            N'","DoanhThu":' + CAST(@DoanhThu AS NVARCHAR) + N'},';

        FETCH NEXT FROM curRap INTO @MaRap, @TenRap, @Tinh;
    END;

    CLOSE curRap;
    DEALLOCATE curRap;

    IF RIGHT(@KetQua,1) = ',' 
        SET @KetQua = LEFT(@KetQua, LEN(@KetQua)-1);

    SET @KetQua = @KetQua + N']';

    RETURN @KetQua;
END;
GO

-- Hàm tìm top 5 phim có doanh thu cao nhất trong khoảng ngày
CREATE FUNCTION Top5PhimDoanhThuCaoNhat
(
    @NgayBatDau DATE,
    @NgayKetThuc DATE
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    IF @NgayBatDau IS NULL OR @NgayKetThuc IS NULL
        RETURN N'Lỗi: Ngày không được để trống!';

    IF @NgayBatDau > @NgayKetThuc
        RETURN N'Lỗi: Ngày bắt đầu không được lớn hơn ngày kết thúc!';

    DECLARE @KetQua NVARCHAR(MAX) = N'[';
    DECLARE @MaPhim CHAR(10);
    DECLARE @TuaDe NVARCHAR(50);
    DECLARE @DoanhThu DECIMAL(18,2);
    DECLARE @Rank INT = 0;

    DECLARE curFilm CURSOR FOR
        SELECT TOP 5 p.MaPhim, p.TuaDe, SUM(v.GiaSauUuDai) AS DoanhThu
        FROM Ve v
        JOIN SuatChieu sc ON v.MaSuatChieu = sc.MaSuatChieu AND v.MaPhim = sc.MaPhim
        JOIN Phim p ON p.MaPhim = v.MaPhim
        JOIN GiaoDich gd ON gd.MaGiaoDich = v.MaGiaoDich
        WHERE gd.ThoiDiemBatDau BETWEEN @NgayBatDau AND @NgayKetThuc
        GROUP BY p.MaPhim, p.TuaDe
        ORDER BY DoanhThu DESC;

    OPEN curFilm;
    FETCH NEXT FROM curFilm INTO @MaPhim, @TuaDe, @DoanhThu;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Rank = @Rank + 1;

        SET @KetQua = @KetQua +
            N'{"XepHang":' + CAST(@Rank AS NVARCHAR) +
            N',"MaPhim":"' + @MaPhim +
            N'","TuaDe":"' + @TuaDe +
            N'","DoanhThu":' + CAST(@DoanhThu AS NVARCHAR) + N'},';

        FETCH NEXT FROM curFilm INTO @MaPhim, @TuaDe, @DoanhThu;
    END;

    CLOSE curFilm;
    DEALLOCATE curFilm;

    IF RIGHT(@KetQua,1) = ',' 
        SET @KetQua = LEFT(@KetQua, LEN(@KetQua)-1);

    SET @KetQua = @KetQua + N']';
    RETURN @KetQua;
END;
GO







