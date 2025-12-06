CREATE DATABASE Movie;
GO

USE Movie;
GO

CREATE TABLE KhachHang (
    MaKhachHang INT IDENTITY(1,1) NOT NULL,
    HoTen NVARCHAR(50) NOT NULL,
    LoaiKhachHang NVARCHAR(50),

    PRIMARY KEY (MaKhachHang),
    CHECK (LoaiKhachHang IN (N'Thường', N'Thành viên'))
);
GO

CREATE TABLE TaiKhoanThanhVien (
    MaTaiKhoan INT IDENTITY(1,1) NOT NULL,
    TrangThaiHoatDong BIT NOT NULL DEFAULT 1,
    TenDangNhap VARCHAR(50) NOT NULL,
    CapDoTaiKhoan NVARCHAR(20),
    TongChiTieuLuyKe DECIMAL(18, 2) DEFAULT 0,
    
    MaKhachHang INT NOT NULL,
    
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
    MaGiaoDich INT IDENTITY(1,1) NOT NULL,
    MaKhachHang INT NOT NULL,
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

    PRIMARY KEY (MaRap),
    CHECK (TrangThaiHoatDong IN (N'Hoạt động', N'Bảo trì', N'Ngưng hoạt động'))
);
GO

CREATE TABLE Phim(
    MaPhim INT IDENTITY(1,1) NOT NULL,
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
    MaSuatChieu INT IDENTITY(1,1) NOT NULL,
    MaPhim INT,
    MaRap CHAR(5) NOT NULL,
    MaPhongChieu TINYINT NOT NULL,
    NgayChieu DATE NOT NULL,
    DinhDangChieu NVARCHAR(10) NOT NULL,
    NgonNgu NVARCHAR(20) NOT NULL,
    TrangThai NVARCHAR(15) NOT NULL,
    HinhThucDichThuat NVARCHAR(10) NOT NULL,
    GioBatDau TIME NOT NULL,

    PRIMARY KEY (MaSuatChieu),
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
    MaVe INT IDENTITY(1,1) NOT NULL,
    MaGhe NVARCHAR(7) NOT NULL,
    TrangThai NVARCHAR(20) NOT NULL,
    PhuThu DECIMAL(18, 2) DEFAULT 0,
    GiaChuan DECIMAL(18, 2) NOT NULL,
    GiaSauUuDai DECIMAL(18, 2) NOT NULL,
    
    MaGiaoDich INT NOT NULL,
    MaPhim INT NOT NULL,
    MaSuatChieu INT,
    ThoiDiemXuatVe DATETIME NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (MaVe),
    CHECK (TrangThai IN (N'Tạm giữ', N'Đã xuất', N'Hoàn/Hủy')),
    
    CONSTRAINT FK_Ve_GiaoDich 
        FOREIGN KEY (MaGiaoDich) REFERENCES GiaoDich(MaGiaoDich),
    
    CONSTRAINT FK_Ve_Phim
        FOREIGN KEY (MaPhim) REFERENCES Phim(MaPhim),
    
    CONSTRAINT FK_Ve_SuatChieu
        FOREIGN KEY (MaSuatChieu) REFERENCES SuatChieu(MaSuatChieu)
);
GO

CREATE TABLE TheThanhVien (
    MaSoThe CHAR(16) NOT NULL,
    NgayDangKy DATE NOT NULL DEFAULT GETDATE(),
    TrangThai BIT NOT NULL DEFAULT 1, 
    LaTheChinh BIT NOT NULL DEFAULT 1,
    
    MaTaiKhoan INT NOT NULL,
    
    PRIMARY KEY (MaSoThe),
    CHECK (MaSoThe NOT LIKE '%[^0-9]%'),
    CONSTRAINT FK_The_TaiKhoan 
        FOREIGN KEY (MaTaiKhoan) REFERENCES TaiKhoanThanhVien(MaTaiKhoan)
);
GO

CREATE TABLE DiemThuong(
    MaDiemThuong INT IDENTITY(1,1) NOT NULL,
    SoLuong SMALLINT NOT NULL,
    TrangThai NVARCHAR(30),
    MaGiaoDich INT NOT NULL,
    MaTaiKhoan INT NOT NULL,
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
    MaSo INT IDENTITY(1,1) NOT NULL,
    GiaTri INT NOT NULL,
    TrangThai NVARCHAR(50) NOT NULL,
    DieuKienApDung INT NOT NULL,
    Loai NVARCHAR(10) NOT NULL,
    NguonPhatHanh NVARCHAR(50) NOT NULL,
    NgayPhatHanh DATE NOT NULL,
    NgayBatDauHieuLuc DATE NOT NULL,
    GioiHanSoLanSuDung TINYINT NOT NULL,
    NgayHetHan DATE NOT NULL,
    MaGiaoDich INT NOT NULL,

    PRIMARY KEY (MaSo),
    CHECK (TrangThai IN (N'Chưa dùng', N'Đã dùng', N'Hết hạn', N'Bị hủy')),
    CHECK (Loai IN ('So tien', 'Phan tram')),
    CHECK (GioiHanSoLanSuDung > 0),
    FOREIGN KEY (MaGiaoDich) REFERENCES GiaoDich(MaGiaoDich)
);
GO

CREATE TABLE MaDoiTuDiem(
    MaSo INT NOT NULL,
    MaTaiKhoan INT NOT NULL,
    MaDiemThuong INT NOT NULL,

    PRIMARY KEY (MaSo),
    UNIQUE (MaTaiKhoan),
    UNIQUE (MaDiemThuong),
    FOREIGN KEY (MaSo) REFERENCES MaUuDai(MaSo),
    FOREIGN KEY (MaDiemThuong) REFERENCES DiemThuong(MaDiemThuong),
    FOREIGN KEY (MaTaiKhoan) REFERENCES TaiKhoanThanhVien(MaTaiKhoan)
);
GO

CREATE TABLE MaTheoSuKien(
    MaSo INT NOT NULL,
    TenSuKien NVARCHAR(50) NOT NULL,

    PRIMARY KEY (MaSo),
    FOREIGN KEY (MaSo) REFERENCES MaUuDai(MaSo)
);
GO

CREATE TABLE Ghe_DanhSachTrangThaiCuaGhe (
    MaSuatChieu INT,
    MaPhim INT,
    TrangThai NVARCHAR(10) NOT NULL,
    MaGhe NVARCHAR(7) NOT NULL,

    PRIMARY KEY (MaSuatChieu, MaPhim, MaGhe),
    FOREIGN KEY (MaSuatChieu) REFERENCES SuatChieu(MaSuatChieu),
    FOREIGN KEY (MaPhim) REFERENCES Phim(MaPhim),
    CHECK (TrangThai IN (N'Trống', N'Tạm giữ', N'Đã bán'))
);
GO

CREATE TABLE Combo (
    MaCombo INT IDENTITY(1,1) NOT NULL,
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
    Ma_combo INT,
    ThanhPhanCombo NVARCHAR(5) NOT NULL,
    SoLuong TINYINT NOT NULL,
    
    PRIMARY KEY (Ma_combo, ThanhPhanCombo),
    CHECK (ThanhPhanCombo IN ('Bap','Nuoc', 'Snack')),
    CONSTRAINT MaComboFK_cbtp
        FOREIGN KEY (Ma_combo) REFERENCES Combo(MaCombo)
);
GO

CREATE TABLE DuocDiKem (
    Ma_Combo INT,
    Ma_Giaodich INT,
    SoLuong TINYINT,
    
    PRIMARY KEY (Ma_Combo, Ma_Giaodich),
    CONSTRAINT MaComboFK_ddk
        FOREIGN KEY (Ma_Combo) REFERENCES Combo(MaCombo)
);
GO

CREATE TABLE Theloai_Phim (
    Ma_Phim INT,
    TheloaiPhim NVARCHAR(50),
    
    PRIMARY KEY (Ma_Phim, TheloaiPhim),
    FOREIGN KEY (Ma_Phim) REFERENCES Phim(MaPhim)
);
GO

CREATE TABLE DinhDangHoTro_Phim (
    Ma_Phim INT,
    DinhDangHoTro NVARCHAR(50),
    
    PRIMARY KEY (Ma_Phim, DinhDangHoTro),
    FOREIGN KEY (Ma_Phim) REFERENCES Phim(MaPhim)
);
GO

CREATE TABLE DienVien_Phim (
    Ma_Phim INT,
    DienVien NVARCHAR(100),
    
    PRIMARY KEY (Ma_Phim, DienVien),
    FOREIGN KEY (Ma_Phim) REFERENCES Phim(MaPhim)
);
GO 

CREATE TABLE DaoDien_Phim (
    Ma_Phim INT,
    DaoDien NVARCHAR(100),
    
    PRIMARY KEY (Ma_Phim, DaoDien),
    FOREIGN KEY (Ma_Phim) REFERENCES Phim(MaPhim)
);
GO

CREATE TABLE NhanSu (
    ID INT IDENTITY(1,1) NOT NULL,
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
    ID INT NOT NULL,
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
    ID INT NOT NULL,
    VaiTro NVARCHAR(50) NOT NULL,
    MaCaLamViec CHAR(8) NOT NULL,
    IDQuanLy INT,
    
    PRIMARY KEY (ID),
    CHECK (VaiTro IN (N'Bán vé', N'Bán đồ ăn', N'Đa năng')),
    CONSTRAINT FK_NhanVienBanVe_NhanSu 
        FOREIGN KEY (ID) REFERENCES NhanSu(ID),
    CONSTRAINT FK_NhanVienBanVe_NguoiQuanLy 
        FOREIGN KEY (IDQuanLy) REFERENCES NguoiQuanLy(ID)
);
GO

CREATE TABLE QuanLy (
    IDQuanLy INT NOT NULL,
    IDQuanLyCapCao INT NOT NULL,
    
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
    ID INT,
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
    MaGiaoDich INT NOT NULL,
    MaQuay TINYINT NOT NULL,
    MaRap CHAR(5) NOT NULL,
    ID_NhanVien INT NOT NULL, 

    PRIMARY KEY (MaGiaoDich),
    CHECK (MaQuay > 0),
    FOREIGN KEY (ID_NhanVien) REFERENCES NhanVienBanVe(ID),
    FOREIGN KEY (MaGiaoDich) REFERENCES GiaoDich(MaGiaoDich),
    FOREIGN KEY (MaQuay, MaRap) REFERENCES QuayGiaoDich(MaQuay, MaRap)
);
GO

CREATE TABLE On_line(
    MaGiaoDich INT NOT NULL,
    SLA TIME NOT NULL,

    PRIMARY KEY (MaGiaoDich),
    FOREIGN KEY (MaGiaoDich) REFERENCES GiaoDich(MaGiaoDich)
);
GO

CREATE TABLE DuocTruc (
    ID_NhanVien INT NOT NULL,
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
INSERT INTO KhachHang (HoTen, LoaiKhachHang) VALUES
(N'Nguyễn Văn An',    N'Thành viên'), -- 1
(N'Trần Thị Bình',    N'Thành viên'), -- 2
(N'Lê Minh Châu',     N'Thường'),     -- 3
(N'Phạm Thị Dung',    N'Thành viên'), -- 4
(N'Hoàng Văn Em',     N'Thường'),     -- 5
(N'Võ Thị Phương',    N'Thành viên'), -- 6
(N'Đặng Văn Giang',   N'Thường'),     -- 7
(N'Bùi Thị Hà',       N'Thành viên'), -- 8
(N'Đinh Văn Khoa',    N'Thường'),     -- 9
(N'Lý Thị Lan',       N'Thành viên'); -- 10
GO

---------------------------
-- 2. TÀI KHOẢN THÀNH VIÊN
---------------------------
INSERT INTO TaiKhoanThanhVien (
    TrangThaiHoatDong, TenDangNhap, CapDoTaiKhoan,
    TongChiTieuLuyKe, MaKhachHang, RapYeuThich, SoDienThoai,
    NgaySinh, GioiTinh, Email
) VALUES
(1, 'nguyenvanan',    N'Member',  2500000, 1, N'CGV Landmark 81', '0901234567', '1990-05-15', N'Nam', 'nguyenvanan@gmail.com'),
(1, 'tranthibinh',    N'VIP',     8500000, 2, N'CGV Crescent Mall', '0902345678', '1988-08-22', N'Nữ', 'tranthibinh@gmail.com'),
(1, 'leminhchau',     N'Member',  1200000, 3, N'CGV SC VivoCity', '0903456789', '1995-01-10', N'Nam', 'leminhchau@gmail.com'),
(1, 'phamthidung',    N'Member',  3200000, 4, N'CGV Hùng Vương Plaza', '0904567890', '1995-03-10', N'Nữ', 'phamthidung@gmail.com'),
(1, 'hoangvanem',     N'Member',  2000000, 5, N'CGV Sư Vạn Hạnh', '0905678901', '1992-09-09', N'Nam', 'hoangvanem@gmail.com'),
(1, 'vothiphuong',    N'VVIP',   15000000, 6, N'CGV Sư Vạn Hạnh', '0906789012', '1985-11-30', N'Nữ', 'vothiphuong@gmail.com'),
(1, 'dangvangiang',   N'Member',  1800000, 7, N'CGV Giga Mall', '0907890123', '1993-04-01', N'Nam', 'dangvangiang@gmail.com'),
(1, 'buithiha',       N'VIP',     7800000, 8, N'CGV Giga Mall', '0908901234', '1992-07-18', N'Nữ', 'buithiha@gmail.com'),
(1, 'dinhvankhoa',    N'Member',  3000000, 9, N'CGV Aeon Tân Phú', '0909012345', '1991-02-20', N'Nam', 'dinhvankhoa@gmail.com'),
(1, 'lythilan',       N'Member',  4100000, 10, N'CGV Aeon Tân Phú', '0900123456', '1993-09-25', N'Nữ', 'lythilan@gmail.com');
GO

---------------------------
-- 3. RẠP CHIẾU PHIM (3 rạp)
---------------------------
INSERT INTO RapChieuPhim (
    MaRap, TenRap, DiaChi_ChiTiet, TinhThanh, ToaDo,
    NgayKhaiTruong, ThoiGianMoCua, ThoiGianDongCua,
    MoTaTongQuan, TrangThaiHoatDong
)
VALUES
('CGV01', N'CGV Landmark 81', N'Vinhomes Central Park, Bình Thạnh', N'TP HCM',
    geography::Point(10.7940, 106.7216, 4326),
    '2018-07-26', '09:00', '23:30',
    N'Rạp CGV tại Landmark 81, nhiều phòng chiếu hiện đại.', N'Hoạt động'),

('CGV02', N'CGV Crescent Mall', N'101 Tôn Dật Tiên, Q.7', N'TP HCM',
    geography::Point(10.7286, 106.7181, 4326),
    '2012-11-30', '09:00', '23:00',
    N'Rạp CGV tại Crescent Mall, không gian thoáng.', N'Hoạt động'),

('CGV03', N'CGV SC VivoCity', N'1058 Nguyễn Văn Linh, Q.7', N'TP HCM',
    geography::Point(10.7300, 106.7000, 4326),
    '2015-04-19', '09:00', '23:30',
    N'CGV tại SC VivoCity, âm thanh hình ảnh chuẩn quốc tế.', N'Hoạt động');
GO

---------------------------
-- 4. PHIM (10 phim đầu)
---------------------------
INSERT INTO Phim (
    NamSanXuat, ThoiLuong, MoTaTomTat, MoTaMarketing, NgonNguGoc,
    GioiHanDoTuoi, NgayKhoiChieu_ChinhThuc, TuaDe, TrangThaiPhatHanh
)
VALUES
(2024, '02:12:00',
 N'Hành trình khám phá ranh giới mới của nhân loại giữa vũ trụ vô tận.',
 N'Bom tấn viễn tưởng với hình ảnh ấn tượng.', N'Tiếng Anh',
 13, '2025-05-10', N'Biên Niên Sử Ngân Hà', N'Đang chiếu'), -- 1

(2025, '01:58:00',
 N'Một đội đặc nhiệm thực hiện sứ mệnh cuối cùng để ngăn chặn thảm họa toàn cầu.',
 N'Nhịp độ nghẹt thở, nhiều pha hành động.', N'Tiếng Anh',
 16, '2025-07-01', N'Sứ Mệnh Cuối Cùng', N'Đang chiếu'), -- 2

(2023, '02:05:00',
 N'Khai quật bí ẩn trên Sao Hỏa, nhóm thám hiểm đối mặt thế lực vô hình.',
 NULL, N'Tiếng Anh',
 13, '2024-11-15', N'Bóng Tối Trên Sao Hỏa', N'Đang chiếu'), -- 3

(2024, '01:50:00',
 N'Bác sĩ cấp cứu chạy đua với thời gian để bảo toàn tính mạng bệnh nhân.',
 N'Giật gân đến phút cuối.', N'Tiếng Việt',
 16, '2025-03-08', N'Lằn Ranh Sinh Tử', N'Đang chiếu'), -- 4

(2023, '02:00:00',
 N'Con tàu nghiên cứu đối mặt siêu bão trên biển.', 
 NULL, N'Tiếng Anh',
 13, '2024-06-21', N'Cơn Bão Trên Đại Dương', N'Ngưng chiếu'), -- 5

(2024, '01:42:00',
 N'Vũ điệu đường phố đưa nhóm trẻ vượt qua định kiến.', 
 N'Âm nhạc bốc lửa.', N'Tiếng Việt',
 7, '2025-04-12', N'Nhịp Đập Đường Phố', N'Đang chiếu'), -- 6

(2025, '01:48:00',
 N'Cô gái nhận được thông điệp từ tương lai.', 
 NULL, N'Tiếng Nhật',
 13, '2025-12-05', N'Cô Gái Từ Tương Lai', N'Sắp chiếu'), -- 7

(2024, '02:08:00',
 N'Một đô thị không bao giờ ngủ che giấu mạng lưới tội phạm tinh vi.',
 N'Noir hiện đại với cú twist bất ngờ.', N'Tiếng Hàn',
 16, '2025-02-28', N'Thị Trấn Không Ngủ', N'Đang chiếu'), -- 8

(2023, '01:55:00',
 N'Thợ săn tiền thưởng theo dấu kẻ nguy hiểm.',
 NULL, N'Tiếng Anh',
 16, '2024-03-29', N'Kẻ Săn Trong Đêm', N'Ngưng chiếu'), -- 9

(2025, '02:10:00',
 N'Đội đặc vụ bí mật bảo vệ nhân chứng trong vụ án xuyên quốc gia.',
 N'Hành động căng thẳng.', N'Tiếng Việt',
 16, '2025-09-20', N'Mật Danh: Phượng Hoàng', N'Sắp chiếu'); -- 10
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
(1, N'Khoa học viễn tưởng'),
(1, N'Phiêu lưu'),
(2, N'Hành động'),
(3, N'Giật gân'),
(4, N'Giật gân'),
(5, N'Hành động'),
(6, N'Âm nhạc'),
(7, N'Viễn tưởng'),
(8, N'Hình sự'),
(9, N'Hành động'),
(10, N'Hình sự');
GO

INSERT INTO DinhDangHoTro_Phim (Ma_Phim, DinhDangHoTro) VALUES
(1, N'2D'),
(1, N'IMAX'),
(2, N'2D'),
(2, N'4DX'),
(3, N'2D'),
(3, N'3D'),
(4, N'2D'),
(5, N'2D'),
(6, N'2D'),
(7, N'2D'),
(8, N'2D'),
(9, N'2D'),
(10, N'2D');
GO

INSERT INTO DaoDien_Phim (Ma_Phim, DaoDien) VALUES
(1, N'Trần Minh Khoa'),
(2, N'Lê Hoàng Nam'),
(3, N'Nguyễn Thảo My'),
(4, N'Phạm Quang Huy'),
(5, N'Vũ Hải Yến'),
(6, N'Đặng Nhật Anh'),
(7, N'Suzuki Haru'),
(8, N'Park Joon-ho'),
(9, N'John Miller'),
(10, N'Hoàng Thanh Tùng');
GO

INSERT INTO DienVien_Phim (Ma_Phim, DienVien) VALUES
(1, N'Lan Chi'),
(1, N'Emma Nguyen'),
(2, N'Minh Tú'),
(3, N'Adam Brooks'),
(4, N'Thu Trang'),
(5, N'David Lee'),
(6, N'Isaac'),
(7, N'Yui Nakamura'),
(8, N'Lee Min-ho'),
(9, N'Chris Evans'),
(10, N'Quốc Trường');
GO





---------------------------
-- 8. SUẤT CHIẾU (12 suất)
---------------------------
INSERT INTO SuatChieu (
    MaPhim, MaRap, MaPhongChieu,
    NgayChieu, DinhDangChieu, NgonNgu, TrangThai,
    HinhThucDichThuat, GioBatDau
)
VALUES
(1, 'CGV01', 1, '2025-11-20', N'2D',      N'Tiếng Anh',  N'Mở bán',  'PhuDe',     '10:00:00'), -- 1
(2, 'CGV01', 1, '2025-11-20', N'2D',      N'Tiếng Anh',  N'Mở bán',  'PhuDe',     '14:00:00'), -- 2
(3, 'CGV01', 2, '2025-11-21', N'3D',      N'Tiếng Anh',  N'Khóa bán','PhuDe',     '19:00:00'), -- 3

(4, 'CGV02', 1, '2025-11-20', N'2D',      N'Tiếng Việt', N'Mở bán',  'LongTieng', '09:30:00'), -- 4
(5, 'CGV02', 1, '2025-11-21', N'2D',      N'Tiếng Anh',  N'Đã chiếu','PhuDe',     '13:30:00'), -- 5
(6, 'CGV02', 2, '2025-11-21', N'IMAX',    N'Tiếng Việt', N'Mở bán',  'LongTieng', '18:00:00'), -- 6

(7, 'CGV03', 1, '2025-11-22', N'2D',      N'Tiếng Nhật', N'Mở bán',  'PhuDe',     '10:15:00'), -- 7
(8, 'CGV03', 1, '2025-11-22', N'2D',      N'Tiếng Hàn',  N'Khóa bán','PhuDe',     '15:00:00'), -- 8
(9, 'CGV03', 2, '2025-11-22', N'4DX',     N'Tiếng Anh',  N'Mở bán',  'PhuDe',     '20:00:00'), -- 9

(10, 'CGV01', 1, '2025-11-23', N'2D',      N'Tiếng Việt', N'Mở bán',  'LongTieng', '09:00:00'), -- 10
(1, 'CGV02', 1, '2025-11-23', N'2D',      N'Tiếng Anh',  N'Đã chiếu','PhuDe',     '11:00:00'), -- 11
(6, 'CGV03', 1, '2025-11-23', N'2D',      N'Tiếng Việt', N'Mở bán',  'LongTieng', '16:30:00'); -- 12
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
(1, 1, N'Trống',    'A01'),
(1, 1, N'Đã bán',   'A02'),
(2, 2, N'Tạm giữ',  'A03'),
(4, 4, N'Trống',    'B01'),
(5, 5, N'Đã bán',   'B02'),
(6, 6, N'Trống',    'B03'),
(7, 7, N'Đã bán',   'C01'),
(8, 8, N'Tạm giữ',  'C02'),
(9, 9, N'Trống',    'C03');
GO

---------------------------
-- 14. GIAO DỊCH (10 giao dịch)
---------------------------
INSERT INTO GiaoDich (
    MaKhachHang, ThoiDiemBatDau, ThoiDiemKetThuc,
    KenhThanhToan, TrangThai, PhuongThuc
) VALUES
(1, '2025-11-20 10:00:00', '2025-11-20 10:02:00', N'Ví điện tử',   N'Đã thanh toán', 'Online'), -- 1
(2, '2025-11-20 14:00:00', '2025-11-20 14:01:30', N'Tiền mặt',     N'Đã thanh toán', 'Offline'), -- 2
(3, '2025-11-20 19:00:00', '2025-11-20 19:01:30', N'Thẻ quốc tế',  N'Tạm giữ',       'Online'), -- 3
(4, '2025-11-21 09:30:00', '2025-11-21 09:31:00', N'Tiền mặt',     N'Hủy',           'Offline'), -- 4
(5, '2025-11-21 13:30:00', '2025-11-21 13:31:30', N'Ví điện tử',   N'Đã thanh toán', 'Online'), -- 5
(6, '2025-11-21 18:00:00', '2025-11-21 18:01:30', N'Thẻ nội địa',  N'Đã thanh toán', 'Online'), -- 6
(7, '2025-11-22 10:15:00', '2025-11-22 10:16:30', N'Tiền mặt',     N'Đã thanh toán', 'Offline'), -- 7
(8, '2025-11-22 15:00:00', '2025-11-22 15:01:30', N'Ví điện tử',   N'Đã thanh toán', 'Online'), -- 8
(9, '2025-11-22 20:00:00', '2025-11-22 20:01:30', N'Thẻ quốc tế',  N'Đã thanh toán', 'Online'), -- 9
(10, '2025-11-23 09:00:00', '2025-11-23 09:01:30', N'Tiền mặt',     N'Đã thanh toán', 'Offline'); -- 10
GO

---------------------------
-- 16. VÉ (10 vé – mỗi giao dịch 1 vé demo)
---------------------------
INSERT INTO Ve (
    MaGhe, TrangThai, PhuThu, GiaChuan, GiaSauUuDai,
    MaGiaoDich, MaPhim, MaSuatChieu, ThoiDiemXuatVe
) VALUES
('A01', N'Đã xuất', 0,     80000, 70000, 1, 1, 1, '2025-11-20 10:00:00'),
('A02', N'Đã xuất', 10000, 90000, 80000, 2, 2, 2, '2025-11-20 14:00:00'),
('A03', N'Tạm giữ', 0,     75000, 75000, 3, 3, 3, '2025-11-20 19:00:00'),
('B01', N'Hoàn/Hủy',0,     85000, 85000, 4, 4, 4, '2025-11-21 09:30:00'),
('B02', N'Đã xuất', 0,     90000, 85000, 5, 5, 5, '2025-11-21 13:30:00'),
('B03', N'Đã xuất', 5000,  95000, 90000, 6, 6, 6, '2025-11-21 18:00:00'),
('C01', N'Đã xuất', 0,     80000, 75000, 7, 7, 7, '2025-11-22 10:15:00'),
('C02', N'Đã xuất', 0,     90000, 85000, 8, 8, 8, '2025-11-22 15:00:00'),
('C03', N'Đã xuất', 0,     95000, 90000, 9, 9, 9, '2025-11-22 20:00:00'),
('A01', N'Đã xuất', 0,     80000, 80000, 10, 10, 10, '2025-11-23 09:00:00');
GO

---------------------------
-- 17. THẺ THÀNH VIÊN
---------------------------
INSERT INTO TheThanhVien (MaSoThe, NgayDangKy, TrangThai, LaTheChinh, MaTaiKhoan) VALUES
('1234567890123456', '2023-01-15', 1, 1, 1),
('2345678901234567', '2022-08-20', 1, 1, 2),
('3456789012345678', '2024-03-10', 1, 1, 3),
('4567890123456789', '2021-11-25', 1, 1, 4),
('5678901234567890', '2023-07-18', 1, 1, 5),
('6789012345678901', '2024-09-05', 1, 1, 6),
('7890123456789012', '2022-12-15', 1, 1, 7),
('8901234567890123', '2023-04-22', 1, 1, 8),
('9012345678901234', '2021-06-30', 1, 1, 9),
('0123456789012345', '2022-02-02', 1, 1, 10);
GO

---------------------------
-- 18. ĐIỂM THƯỞNG + MÃ ƯU ĐÃI + MÃ ĐỔI TỪ ĐIỂM + MÃ SỰ KIỆN
---------------------------
INSERT INTO DiemThuong (SoLuong, TrangThai, MaGiaoDich, MaTaiKhoan, NgayGhiNhan, NgayHetHan) VALUES
(50, N'Còn hiệu lực', 1, 1, '2025-11-20', '2026-11-20'), -- 1
(30, N'Còn hiệu lực', 2, 2, '2025-11-20', '2026-11-20'), -- 2
(20, N'Đã dùng',      3, 3, '2025-11-20', '2026-05-20'), -- 3
(0, N'Đã hết hạn',    4, 4, '2025-11-21', '2026-11-21'), -- 4
(40, N'Còn hiệu lực', 5, 5, '2025-11-21', '2026-11-21'), -- 5
(60, N'Còn hiệu lực', 6, 6, '2025-11-21', '2026-11-21'), -- 6
(15, N'Còn hiệu lực', 7, 7, '2025-11-22', '2026-11-22'), -- 7
(25, N'Còn hiệu lực', 8, 8, '2025-11-22', '2026-11-22'), -- 8
(35, N'Còn hiệu lực', 9, 9, '2025-11-22', '2026-11-22'), -- 9
(45, N'Còn hiệu lực', 10, 10, '2025-11-23', '2026-11-23'); -- 10
GO

INSERT INTO MaUuDai (GiaTri, TrangThai, DieuKienApDung, Loai, NguonPhatHanh,
                     NgayPhatHanh, NgayBatDauHieuLuc, GioiHanSoLanSuDung, NgayHetHan, MaGiaoDich)
VALUES
(50000, N'Chưa dùng', 100000, 'So tien',  N'CGV App',
 '2025-10-01', '2025-10-01', 5, '2025-12-31', 1), -- 1
(20,    N'Chưa dùng',  80000, 'Phan tram',N'Galaxy',
 '2025-09-15', '2025-09-20', 3, '2025-12-31', 2), -- 2
(30000, N'Hết hạn',    60000, 'So tien',  N'Lotte',
 '2025-07-01', '2025-07-05', 2, '2025-10-31', 3), -- 3
(20000, N'Đã dùng',    60000, 'So tien',  N'Beta',
 '2025-11-01', '2025-11-01', 5, '2026-01-01', 4); -- 4
GO

INSERT INTO MaDoiTuDiem (MaSo, MaTaiKhoan, MaDiemThuong) VALUES
(1, 1, 1),
(2, 2, 2),
(4, 6, 6);
GO

INSERT INTO MaTheoSuKien (MaSo, TenSuKien) VALUES
(1, N'Sự kiện Halloween Movie Night'),
(2, N'Chương trình Sinh nhật Galaxy'),
(4, N'Tuần lễ phim Việt Nam 2025');
GO

---------------------------
-- 19. COMBO + THÀNH PHẦN + ĐƯỢC ĐI KÈM
---------------------------
INSERT INTO Combo (Ten, GiaNiemYet, GiaKhuyenMai, TrangThai, GioiHan) VALUES
(N'Combo 01',  79000, 69000, N'HoatDong', NULL), -- 1
(N'Combo 02', 129000,109000, N'HoatDong', 100), -- 2
(N'Combo 03',  65000, 59000, N'HoatDong', NULL), -- 3
(N'Combo 04',  99000, 89000, N'HoatDong', 80), -- 4
(N'Combo 05', 159000,139000, N'HoatDong', 50); -- 5
GO

INSERT INTO Combo_ThanhPhan (Ma_combo, ThanhPhanCombo, SoLuong) VALUES
(1, 'Bap',   1),
(1, 'Nuoc',  1),
(2, 'Bap',   2),
(2, 'Nuoc',  2),
(3, 'Bap',   1),
(3, 'Snack', 2),
(4, 'Bap',   2),
(4, 'Nuoc',  1),
(5, 'Bap',   3),
(5, 'Nuoc',  2),
(5, 'Snack', 2);
GO

INSERT INTO DuocDiKem (Ma_Combo, Ma_Giaodich, SoLuong) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 5, 2),
(4, 6, 1),
(5, 8, 1);
GO

---------------------------
-- 11. NHÂN SỰ
---------------------------
INSERT INTO NhanSu (
    CCCD, DiaChi, GioiTinh, NgaySinh,
    HoTen, NgayBatDauLamViec, MucLuongCoBan,
    LoaiHopDong, TrangThai, SoDienThoai, Email, MaRap
) VALUES
('001202012345', N'123 Nguyễn Huệ, Q1', N'Nam', '1985-03-15',
 N'Trần Văn Quản Lý', '2018-05-01', 25000000, N'Chính thức', N'Đang làm', '0901111111', 'ql1@cgv.vn', 'CGV01'), -- 1

('001202012346', N'56 Lê Lai, Q3', N'Nữ', '1990-07-22',
 N'Lê Thị Khu Vực', '2019-08-15', 20000000, N'Chính thức', N'Đang làm', '0902222222', 'ql2@cgv.vn', 'CGV02'), -- 2

('001202012347', N'89 Võ Văn Tần, Q5', N'Nam', '1992-11-30',
 N'Nguyễn Văn Rạp', '2020-02-01', 18000000, N'Chính thức', N'Đang làm', '0903333333', 'ql3@cgv.vn', 'CGV03'), -- 3

('001202012348', N'12 Phan Đình Phùng', N'Nam', '1998-01-10',
 N'Phạm Văn Bán Vé', '2022-06-01', 8000000, N'Thử việc', N'Đang làm', '0904444444', 'nv1@cgv.vn', 'CGV01'), -- 4

('001202012349', N'34 Hoàng Văn Thụ', N'Nữ', '1995-05-18',
 N'Hoàng Thị Vé', '2021-09-10', 8500000, N'Chính thức', N'Đang làm', '0905555555', 'nv2@cgv.vn', 'CGV01'), -- 5

('001202012350', N'56 Bùi Thị Xuân', N'Nam', '1997-08-25',
 N'Bùi Văn Đa Năng', '2022-01-15', 9000000, N'Chính thức', N'Đang làm', '0906666666', 'nv3@cgv.vn', 'CGV02'), -- 6

('001202012351', N'78 Trần Hưng Đạo', N'Nữ', '1996-12-05',
 N'Trần Thị Đồ Ăn', '2021-12-20', 8200000, N'Chính thức', N'Đang làm', '0907777777', 'nv4@cgv.vn', 'CGV02'), -- 7

('001202012352', N'90 Nguyễn Thị Minh Khai', N'Nam', '1999-04-12',
 N'Nguyễn Văn Mới', '2023-03-01', 7800000, N'Thử việc', N'Đang làm', '0908888888', 'nv5@cgv.vn', 'CGV03'), -- 8

('001202012353', N'45 Lý Thường Kiệt', N'Nữ', '1994-09-30',
 N'Lý Thị Kinh Nghiệm', '2020-11-05', 9500000, N'Chính thức', N'Đang làm', '0909999999', 'nv6@cgv.vn', 'CGV03'), -- 9

('001202012354', N'67 Cách Mạng Tháng 8', N'Nam', '1993-02-28',
 N'Đặng Văn Lâu', '2020-07-20', 9200000, N'Chính thức', N'Đang làm', '0900000000', 'nv7@cgv.vn', 'CGV03'); -- 10
GO

---------------------------
-- 12. NGƯỜI QUẢN LÝ & NHÂN VIÊN BÁN VÉ
---------------------------
INSERT INTO NguoiQuanLy (ID, CapBac, KhuVucPhuTrach, NgayBoNhiem) VALUES
(1, N'Quản lý cấp cao',  N'Toàn quốc',        '2018-05-01'),
(2, N'Quản lý khu vực', N'Khu vực TP.HCM',   '2019-08-15'),
(3, N'Quản lý rạp',     N'Rạp CGV03',        '2020-02-01');
GO

INSERT INTO NhanVienBanVe (ID, VaiTro, MaCaLamViec, IDQuanLy) VALUES
(4, N'Bán vé',     'CA000001', 1),
(5, N'Đa năng',    'CA000002', 1),
(6, N'Bán đồ ăn',  'CA000003', 2),
(7, N'Bán vé',     'CA000004', 2),
(8, N'Đa năng',    'CA000005', 3),
(9, N'Bán đồ ăn',  'CA000006', 3),
(10, N'Bán vé',     'CA000007', 3);
GO

INSERT INTO QuanLy (IDQuanLy, IDQuanLyCapCao) VALUES
(2, 1),
(3, 2);
GO

---------------------------
-- 13. CHẤM CÔNG & ĐƯỢC TRỰC
---------------------------
INSERT INTO NhanSuChamCong (ID, ThoiDiemCheckIn, ThoiDiemCheckOut, CaDangKy, CaThucTe, SaiLech) VALUES
(4, '2025-11-20 08:00:00', '2025-11-20 17:00:00', 'CA000001', 'CA000001', 0),
(5, '2025-11-20 08:15:00', '2025-11-20 17:15:00', 'CA000002', 'CA000002', 15),
(2, '2025-11-20 08:00:00', '2025-11-20 20:00:00', 'CA000001', 'CA000003', 180),
(6, '2025-11-21 08:00:00', NULL,                  'CA000003', 'CA000003', NULL),
(7, '2025-11-21 13:50:00', '2025-11-21 22:00:00', 'CA000004', 'CA000004', -10),
(3, '2025-11-21 08:00:00', '2025-11-21 17:00:00', 'CA000005', 'CA000005', 0);
GO

INSERT INTO DuocTruc (ID_NhanVien, MaQuay, MaRap) VALUES
(4, 1, 'CGV01'),
(5, 2, 'CGV01'),
(6, 1, 'CGV02'),
(7, 2, 'CGV02'),
(8, 1, 'CGV03'),
(9, 1, 'CGV03');
GO



---------------------------
-- 15. OFFLINE & ONLINE
---------------------------
INSERT INTO Off_line (MaGiaoDich, MaQuay, MaRap, ID_NhanVien) VALUES
(2, 1, 'CGV01', 4),
(4, 1, 'CGV02', 6),
(7, 2, 'CGV01', 5),
(10, 1, 'CGV03', 8);
GO

INSERT INTO On_line (MaGiaoDich, SLA) VALUES
(1, '00:05:00'),
(3, '00:05:00'),
(5, '00:05:00'),
(6, '00:05:00'),
(8, '00:05:00'),
(9, '00:05:00');
GO

----2.1-----


-- Thủ tục Insert suất chiếu --
CREATE OR ALTER PROCEDURE sp_Insert_SuatChieu
    @MaPhim INT,
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

        -- 2. Kiểm tra CHECK: MaPhongChieu > 0
        IF @MaPhongChieu <= 0
        BEGIN
            SET @ErrorMessage = N'Lỗi ràng buộc CHECK: Mã Phòng Chiếu phải là một số nguyên dương lớn hơn 0. Giá trị nhập: ' + CAST(@MaPhongChieu AS NVARCHAR(5));
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 3. Kiểm tra CHECK: TrangThai
        IF @TrangThai NOT IN (N'Mở bán', N'Khóa bán', N'Đã chiếu', N'Hủy')
        BEGIN
            SET @ErrorMessage = N'Lỗi ràng buộc CHECK: Trạng Thái phải là một trong các giá trị: "Mở bán", "Khóa bán", "Đã chiếu", hoặc "Hủy". Giá trị nhập: ' + @TrangThai;
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 4. Kiểm tra CHECK: HinhThucDichThuat
        IF @HinhThucDichThuat NOT IN ('PhuDe', 'LongTieng')
        BEGIN
            SET @ErrorMessage = N'Lỗi ràng buộc CHECK: Hình Thức Dịch Thuật phải là "PhuDe" (Phụ Đề) hoặc "LongTieng" (Lồng Tiếng). Giá trị nhập: ' + @HinhThucDichThuat;
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 5. Kiểm tra FOREIGN KEY: MaPhim (Kiểm tra sự tồn tại trong bảng Phim)
        IF NOT EXISTS (SELECT 1 FROM Phim WHERE MaPhim = @MaPhim)
        BEGIN
            SET @ErrorMessage = N'Lỗi ràng buộc FOREIGN KEY: Mã Phim (' + CAST(@MaPhim AS NVARCHAR(10)) + N') không tồn tại trong bảng Phim.';
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 6. Kiểm tra FOREIGN KEY: (MaPhongChieu, MaRap) (Kiểm tra sự tồn tại trong bảng PhongChieu)
        IF NOT EXISTS (SELECT 1 FROM PhongChieu WHERE MaPhong = @MaPhongChieu AND MaRap = @MaRap)
        BEGIN
            SET @ErrorMessage = N'Lỗi ràng buộc FOREIGN KEY: Mã Phòng Chiếu (' + CAST(@MaPhongChieu AS NVARCHAR(5)) + N') hoặc Mã Rạp (' + @MaRap + N') không tồn tại trong bảng PhongChieu.';
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 7. KIỂM TRA LOGIC: LoaiPhong phải nằm trong DinhDangHoTro_Phim và tương thích với DinhDangChieu
        -- 7a. Kiểm tra phòng chiếu có hỗ trợ định dạng chiếu không
        DECLARE @LoaiPhong NVARCHAR(10);
        SELECT @LoaiPhong = LoaiPhong FROM PhongChieu WHERE MaPhong = @MaPhongChieu AND MaRap = @MaRap;
        
        IF @LoaiPhong <> @DinhDangChieu
        BEGIN
            SET @ErrorMessage = N'Lỗi logic: Phòng chiếu (' + CAST(@MaPhongChieu AS NVARCHAR(5)) +
                                N') tại Rạp (' + @MaRap +
                                N') có loại phòng (' + @LoaiPhong + 
                                N') không khớp với định dạng chiếu yêu cầu (' + @DinhDangChieu + N').';
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 7b. Kiểm tra phim có hỗ trợ định dạng chiếu không
        IF NOT EXISTS (
            SELECT 1 
            FROM DinhDangHoTro_Phim 
            WHERE Ma_Phim = @MaPhim AND DinhDangHoTro = @DinhDangChieu
        )
        BEGIN
            DECLARE @TenPhim NVARCHAR(255);
            SELECT @TenPhim = TuaDe FROM Phim WHERE MaPhim = @MaPhim;
            SET @ErrorMessage = N'Lỗi logic: Phim "' + @TenPhim + 
                                N'" (Mã: ' + CAST(@MaPhim AS NVARCHAR(10)) +
                                N') không hỗ trợ định dạng chiếu (' + @DinhDangChieu + N').';
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END
        ---

        -- 8. KIỂM TRA LOGIC: Kiểm tra thời gian quá khứ
        DECLARE @FullShowTime DATETIME = CAST(@NgayChieu AS DATETIME) + CAST(@GioBatDau AS DATETIME);
        IF @FullShowTime < GETDATE()
        BEGIN
            SET @ErrorMessage = N'Lỗi logic: Không thể tạo suất chiếu trong quá khứ (' + CONVERT(NVARCHAR, @FullShowTime, 120) + N').';
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- 9. KIỂM TRA LOGIC: Kiểm tra overlap và 15 phút giãn cách
        
        DECLARE @ThoiLuongNew TIME;
        SELECT @ThoiLuongNew = ThoiLuong FROM Phim WHERE MaPhim = @MaPhim;

        IF EXISTS (
            SELECT 1 
            FROM SuatChieu SC
            JOIN Phim P ON SC.MaPhim = P.MaPhim
            WHERE 
                SC.MaRap = @MaRap 
                AND SC.MaPhongChieu = @MaPhongChieu
                AND SC.NgayChieu = @NgayChieu
                AND SC.TrangThai <> N'Hủy' -- Bỏ qua các suất đã hủy
                AND (
                    (CAST(@GioBatDau AS DATETIME) < DATEADD(MINUTE, 15, DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', P.ThoiLuong), CAST(SC.GioBatDau AS DATETIME))))
                    AND 
                    (DATEADD(MINUTE, 15, DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', @ThoiLuongNew), CAST(@GioBatDau AS DATETIME))) > CAST(SC.GioBatDau AS DATETIME))
                )
        )
        BEGIN
            SET @ErrorMessage = N'Lỗi nghiệp vụ: Suất chiếu bị trùng lịch hoặc vi phạm khoảng cách nghỉ 15 phút với suất khác.';
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- Nếu tất cả kiểm tra đều hợp lệ, thực hiện INSERT
        INSERT INTO SuatChieu (
            MaPhim, MaRap, MaPhongChieu, NgayChieu, 
            DinhDangChieu, NgonNgu, TrangThai, HinhThucDichThuat, GioBatDau
        )
        VALUES (
            @MaPhim, @MaRap, @MaPhongChieu, @NgayChieu, 
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

-- Thủ tục Update thông tin suất chiếu --
CREATE OR ALTER PROCEDURE Update_ThongTinSuatChieu
    @MaSuatChieu INT,
    @MaPhim INT,
    @GioBatDauMoi TIME = NULL,   
    @MaPhongMoi TINYINT = NULL, 
    @MaRap CHAR(5)
AS
BEGIN
    -- 1. Kiểm tra tồn tại
    IF NOT EXISTS (SELECT 1 FROM SuatChieu WHERE MaSuatChieu = @MaSuatChieu AND MaPhim = @MaPhim)
    BEGIN
        RAISERROR(N'Lỗi: Suất chiếu không tồn tại.', 16, 1);
        RETURN;
    END

    -- 2. Kiểm tra vé đã bán
    IF EXISTS (
        SELECT 1 FROM Ve 
        WHERE MaSuatChieu = @MaSuatChieu 
          AND MaPhim = @MaPhim 
          AND TrangThai IN (N'Đã xuất', N'Tạm giữ')
    )
    BEGIN
        RAISERROR(N'Lỗi nghiệp vụ: Không thể cập nhật suất chiếu này vì đã có vé được bán hoặc tạm giữ.', 16, 1);
        RETURN;
    END

    -- 3. Chuẩn bị dữ liệu
    DECLARE @NgayChieu DATE;
    DECLARE @ThoiLuongCurrent TIME;
    DECLARE @FinalPhong TINYINT;
    DECLARE @FinalGio TIME;

    SELECT 
        @NgayChieu = SC.NgayChieu, 
        @ThoiLuongCurrent = P.ThoiLuong, 
        @FinalPhong = ISNULL(@MaPhongMoi, SC.MaPhongChieu),
        @FinalGio = ISNULL(@GioBatDauMoi, SC.GioBatDau)
    FROM SuatChieu SC
    JOIN Phim P ON SC.MaPhim = P.MaPhim
    WHERE SC.MaSuatChieu = @MaSuatChieu AND SC.MaPhim = @MaPhim;

    -- 3b. Kiểm tra phòng mới có hỗ trợ định dạng chiếu không (chỉ khi đổi phòng)
    IF @MaPhongMoi IS NOT NULL
    BEGIN
        DECLARE @DinhDangChieu NVARCHAR(10);
        DECLARE @LoaiPhongMoi NVARCHAR(10);
        DECLARE @TenPhim NVARCHAR(255);
        
        -- Lấy định dạng chiếu hiện tại của suất chiếu
        SELECT @DinhDangChieu = DinhDangChieu FROM SuatChieu WHERE MaSuatChieu = @MaSuatChieu;
        
        -- Lấy loại phòng của phòng mới
        SELECT @LoaiPhongMoi = LoaiPhong FROM PhongChieu WHERE MaPhong = @MaPhongMoi AND MaRap = @MaRap;
        
        -- Kiểm tra phòng mới có tồn tại không
        IF @LoaiPhongMoi IS NULL
        BEGIN
            RAISERROR(N'Lỗi: Phòng chiếu mới không tồn tại trong rạp này.', 16, 1);
            RETURN;
        END
        
        -- Kiểm tra loại phòng mới có khớp với định dạng chiếu không
        IF @LoaiPhongMoi <> @DinhDangChieu
        BEGIN
            DECLARE @ErrorMsg1 NVARCHAR(500);
            SET @ErrorMsg1 = N'Lỗi logic: Phòng chiếu mới (' + CAST(@MaPhongMoi AS NVARCHAR(5)) +
                            N') có loại phòng (' + @LoaiPhongMoi + 
                            N') không khớp với định dạng chiếu của suất chiếu (' + @DinhDangChieu + N').';
            RAISERROR(@ErrorMsg1, 16, 1);
            RETURN;
        END
        
        -- Kiểm tra phim có hỗ trợ định dạng này không (phòng hợp lệ nhưng phim không hỗ trợ)
        IF NOT EXISTS (
            SELECT 1 
            FROM DinhDangHoTro_Phim 
            WHERE Ma_Phim = @MaPhim AND DinhDangHoTro = @LoaiPhongMoi
        )
        BEGIN
            SELECT @TenPhim = TuaDe FROM Phim WHERE MaPhim = @MaPhim;
            DECLARE @ErrorMsg2 NVARCHAR(500);
            SET @ErrorMsg2 = N'Lỗi logic: Phim "' + @TenPhim + 
                            N'" không hỗ trợ định dạng chiếu (' + @LoaiPhongMoi + N') của phòng mới.';
            RAISERROR(@ErrorMsg2, 16, 1);
            RETURN;
        END
    END

    -- 4. Kiểm tra Thời gian Quá khứ
    DECLARE @FullNewShowTime DATETIME = CAST(@NgayChieu AS DATETIME) + CAST(@FinalGio AS DATETIME);
    IF @FullNewShowTime < GETDATE()
    BEGIN
        RAISERROR(N'Lỗi logic: Không thể cập nhật suất chiếu về thời điểm trong quá khứ.', 16, 1);
        RETURN;
    END

    -- 5. Kiểm tra trùng lịch
    IF EXISTS (
        SELECT 1 
        FROM SuatChieu SC_Khac
        JOIN Phim P_Khac ON SC_Khac.MaPhim = P_Khac.MaPhim
        WHERE 
            SC_Khac.MaRap = @MaRap 
            AND SC_Khac.MaPhongChieu = @FinalPhong 
            AND SC_Khac.NgayChieu = @NgayChieu
            AND SC_Khac.TrangThai <> N'Hủy'
            AND SC_Khac.MaSuatChieu != @MaSuatChieu
            AND (
                (CAST(@FinalGio AS DATETIME) < DATEADD(MINUTE, 15, DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', P_Khac.ThoiLuong), CAST(SC_Khac.GioBatDau AS DATETIME))))
                AND 
                (DATEADD(MINUTE, 15, DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', @ThoiLuongCurrent), CAST(@FinalGio AS DATETIME))) > CAST(SC_Khac.GioBatDau AS DATETIME))
            )
    )
    BEGIN
        RAISERROR(N'Lỗi nghiệp vụ: Cập nhật thất bại do trùng lịch hoặc vi phạm khoảng cách nghỉ 15 phút.', 16, 1);
        RETURN;
    END

    -- 6. Thực hiện Update
    UPDATE SuatChieu
    SET 
        GioBatDau = @FinalGio,
        MaPhongChieu = @FinalPhong
    WHERE MaSuatChieu = @MaSuatChieu AND MaPhim = @MaPhim;

    PRINT N'Cập nhật suất chiếu thành công!';
END
GO

-- Thủ tục Delete suất chiếu -- 
CREATE OR ALTER PROCEDURE Delete_SuatChieu
    @MaSuatChieu INT, 
    @MaPhim INT
AS
BEGIN
    -- 1. Kiểm tra tồn tại
    IF NOT EXISTS (SELECT 1 FROM SuatChieu WHERE MaSuatChieu = @MaSuatChieu AND MaPhim = @MaPhim)
    BEGIN
        RAISERROR(N'Lỗi: Suất chiếu không tồn tại.', 16, 1);
        RETURN;
    END

    -- 2. Kiểm tra ràng buộc dữ liệu (Data Integrity)
    -- Nếu đã có bất kỳ vé nào được tạo ra (dù là Tạm giữ, hay Đã hủy)
    -- thì không xóa suất chiếu vì sẽ làm mất lịch sử giao dịch.
    IF EXISTS (
        SELECT 1 
        FROM Ve 
        WHERE MaSuatChieu = @MaSuatChieu AND MaPhim = @MaPhim
    )
    BEGIN
        -- Thay vì xóa, hãy hướng dẫn người dùng Update trạng thái
        RAISERROR(N'Lỗi: Không thể xóa suất chiếu này vì đã phát sinh vé (bao gồm cả vé đã hủy).', 16, 1);
        RETURN;
    END

    -- 3. Thực hiện Xóa (Chỉ khi chưa có vé nào)
    BEGIN TRY
        BEGIN TRANSACTION;
            
            DELETE FROM SuatChieu
            WHERE MaSuatChieu = @MaSuatChieu AND MaPhim = @MaPhim;

        COMMIT TRANSACTION;
        PRINT N'Xóa suất chiếu thành công.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
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
        MaTaiKhoan INT,
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
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if any inserted ticket violates age restriction
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
        -- Use THROW to propagate error to the caller's TRY/CATCH
        ;THROW 50001, N'LỖI: Không thể thêm vé. Có ít nhất một khách hàng thành viên không đủ tuổi xem phim này.', 1;
    END;

    -- If age check passes, perform the actual insert
    INSERT INTO Ve (MaGhe, TrangThai, GiaChuan, GiaSauUuDai, PhuThu,
                    MaGiaoDich, MaPhim, MaSuatChieu, ThoiDiemXuatVe)
    SELECT MaGhe, TrangThai, GiaChuan, GiaSauUuDai, PhuThu,
           MaGiaoDich, MaPhim, MaSuatChieu, ThoiDiemXuatVe
    FROM inserted;
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
    DECLARE @MaPhim INT;
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
            N',"MaPhim":"' + CAST(@MaPhim AS NVARCHAR) +
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
