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
