------------------------------------------------------------
-- MOCK DATA FOR ASSIGNMENT 2
------------------------------------------------------------
USE Movie;
GO

------------------------------------------------------------
-- LEVEL 0: Independent Tables
------------------------------------------------------------

-- 1. KHACH HANG (10 rows)
INSERT INTO KhachHang (HoTen, LoaiKhachHang) VALUES
(N'Nguyễn Văn An',    N'Thành viên'), -- 1
(N'Trần Thị Bình',    N'Thành viên'), -- 2
(N'Lê Minh Châu',     N'Thường'),     -- 3 (Guest)
(N'Phạm Thị Dung',    N'Thành viên'), -- 4
(N'Hoàng Văn Em',     N'Thường'),     -- 5 (Guest)
(N'Võ Thị Phương',    N'Thành viên'), -- 6 (Our VVIP)
(N'Đặng Văn Giang',   N'Thường'),     -- 7 (Guest)
(N'Bùi Thị Hà',       N'Thành viên'), -- 8
(N'Đinh Văn Khoa',    N'Thường'),     -- 9 (Guest)
(N'Lý Thị Lan',       N'Thành viên'); -- 10
GO

-- 2. RAP CHIEU PHIM (5 rows - Added CGV04, CGV05)
INSERT INTO RapChieuPhim (
    MaRap, TenRap, DiaChi_ChiTiet, TinhThanh, ToaDo,
    NgayKhaiTruong, ThoiGianMoCua, ThoiGianDongCua,
    MoTaTongQuan, TrangThaiHoatDong
)
VALUES
('CGV01', N'CGV Landmark 81', N'Vinhomes Central Park, Bình Thạnh', N'TP HCM', geography::Point(10.7940, 106.7216, 4326), '2018-07-26', '09:00', '23:30', N'Rạp CGV tại Landmark 81.', N'Hoạt động'),
('CGV02', N'CGV Crescent Mall', N'101 Tôn Dật Tiên, Q.7', N'TP HCM', geography::Point(10.7286, 106.7181, 4326), '2012-11-30', '09:00', '23:00', N'Rạp CGV tại Crescent Mall.', N'Hoạt động'),
('CGV03', N'CGV SC VivoCity', N'1058 Nguyễn Văn Linh, Q.7', N'TP HCM', geography::Point(10.7300, 106.7000, 4326), '2015-04-19', '09:00', '23:30', N'CGV tại SC VivoCity.', N'Hoạt động'),
('CGV04', N'CGV Aeon Bình Tân', N'Số 1 Đường số 17A, Bình Tân', N'TP HCM', geography::Point(10.7423, 106.6143, 4326), '2016-07-01', '08:30', '23:00', N'Rạp CGV lớn nhất Bình Tân.', N'Hoạt động'),
('CGV05', N'CGV Vincom Đồng Khởi', N'72 Lê Thánh Tôn, Q.1', N'TP HCM', geography::Point(10.7765, 106.7010, 4326), '2010-08-15', '09:30', '01:00', N'Rạp Premium tại trung tâm Q1.', N'Bảo trì');
GO

-- 3. PHIM (10 rows)
INSERT INTO Phim (NamSanXuat, ThoiLuong, MoTaTomTat, MoTaMarketing, NgonNguGoc, GioiHanDoTuoi, NgayKhoiChieu_ChinhThuc, TuaDe, TrangThaiPhatHanh) VALUES
(2024, '02:12:00', N'Hành trình vũ trụ.', N'Bom tấn.', N'Tiếng Anh', 13, '2025-05-10', N'Biên Niên Sử Ngân Hà', N'Đang chiếu'), -- 1
(2025, '01:58:00', N'Đội đặc nhiệm.', N'Hành động.', N'Tiếng Anh', 16, '2025-07-01', N'Sứ Mệnh Cuối Cùng', N'Đang chiếu'), -- 2
(2023, '02:05:00', N'Sao Hỏa bí ẩn.', NULL, N'Tiếng Anh', 13, '2024-11-15', N'Bóng Tối Trên Sao Hỏa', N'Đang chiếu'), -- 3
(2024, '01:50:00', N'Bác sĩ cấp cứu.', N'Giật gân.', N'Tiếng Việt', 16, '2025-03-08', N'Lằn Ranh Sinh Tử', N'Đang chiếu'), -- 4
(2023, '02:00:00', N'Bão biển.', NULL, N'Tiếng Anh', 13, '2024-06-21', N'Cơn Bão Trên Đại Dương', N'Ngưng chiếu'), -- 5
(2024, '01:42:00', N'Nhảy đường phố.', N'Âm nhạc.', N'Tiếng Việt', 7, '2025-04-12', N'Nhịp Đập Đường Phố', N'Đang chiếu'), -- 6
(2025, '01:48:00', N'Tương lai.', NULL, N'Tiếng Nhật', 13, '2025-12-05', N'Cô Gái Từ Tương Lai', N'Sắp chiếu'), -- 7
(2024, '02:08:00', N'Tội phạm.', N'Noir.', N'Tiếng Hàn', 16, '2025-02-28', N'Thị Trấn Không Ngủ', N'Đang chiếu'), -- 8
(2023, '01:55:00', N'Thợ săn.', NULL, N'Tiếng Anh', 16, '2024-03-29', N'Kẻ Săn Trong Đêm', N'Ngưng chiếu'), -- 9
(2025, '02:10:00', N'Đặc vụ.', N'Căng thẳng.', N'Tiếng Việt', 16, '2025-09-20', N'Mật Danh: Phượng Hoàng', N'Sắp chiếu'); -- 10
GO

-- 4. COMBO (5 rows)
INSERT INTO Combo (Ten, GiaNiemYet, GiaKhuyenMai, TrangThai, GioiHan) VALUES
(N'Combo Solo',  79000, 69000, N'HoatDong', NULL),
(N'Combo Couple', 129000,109000, N'HoatDong', 100),
(N'Combo Family',  165000, 159000, N'HoatDong', NULL),
(N'Combo Snack',  99000, 89000, N'HoatDong', 80),
(N'Combo VVIP', 199000,189000, N'HoatDong', 50);
GO

------------------------------------------------------------
-- LEVEL 1: Tables depending on Level 0
------------------------------------------------------------

-- 5. TAI KHOAN THANH VIEN (10 rows)
-- NOTE: TongChiTieuLuyKe here is calculated to match exactly the transactions we will insert later.
-- User 6 (Võ Thị Phương) is our VVIP whale with ~1.5M spending.
INSERT INTO TaiKhoanThanhVien (TrangThaiHoatDong, TenDangNhap, CapDoTaiKhoan, TongChiTieuLuyKe, MaKhachHang, RapYeuThich, SoDienThoai, NgaySinh, GioiTinh, Email) VALUES
(1, 'nguyenvanan',    N'Member',  70000,   1, N'CGV Landmark 81', '0901234567', '1990-05-15', N'Nam', 'nguyenvanan@gmail.com'),
(1, 'tranthibinh',    N'VIP',     80000,   2, N'CGV Crescent Mall', '0902345678', '1988-08-22', N'Nữ', 'tranthibinh@gmail.com'),
(1, 'leminhchau',     N'Member',  0,       3, N'CGV SC VivoCity', '0903456789', '1995-01-10', N'Nam', 'leminhchau@gmail.com'),
(1, 'phamthidung',    N'Member',  0,       4, N'CGV Hùng Vương', '0904567890', '1995-03-10', N'Nữ', 'phamthidung@gmail.com'), -- User 4 will cancel trans
(1, 'hoangvanem',     N'Member',  85000,   5, N'CGV Sư Vạn Hạnh', '0905678901', '1992-09-09', N'Nam', 'hoangvanem@gmail.com'),
(1, 'vothiphuong',    N'VVIP',    1590000, 6, N'CGV Sư Vạn Hạnh', '0906789012', '1985-11-30', N'Nữ', 'vothiphuong@gmail.com'), -- WHALE USER
(1, 'dangvangiang',   N'Member',  75000,   7, N'CGV Giga Mall', '0907890123', '1993-04-01', N'Nam', 'dangvangiang@gmail.com'),
(1, 'buithiha',       N'VIP',     585000,  8, N'CGV Giga Mall', '0908901234', '1992-07-18', N'Nữ', 'buithiha@gmail.com'), -- Secondary VIP
(1, 'dinhvankhoa',    N'Member',  90000,   9, N'CGV Aeon Tân Phú', '0909012345', '1991-02-20', N'Nam', 'dinhvankhoa@gmail.com'),
(1, 'lythilan',       N'Member',  80000,   10,N'CGV Aeon Tân Phú', '0900123456', '1993-09-25', N'Nữ', 'lythilan@gmail.com');
GO

-- 6. NHAN SU (10 rows)
INSERT INTO NhanSu (CCCD, DiaChi, GioiTinh, NgaySinh, HoTen, NgayBatDauLamViec, MucLuongCoBan, LoaiHopDong, TrangThai, SoDienThoai, Email, MaRap) VALUES
('001', N'Q1', N'Nam', '1985-03-15', N'Trần Văn Quản Lý', '2018-05-01', 25000000, N'Chính thức', N'Đang làm', '0901111111', 'ql1@cgv.vn', 'CGV01'),
('002', N'Q3', N'Nữ', '1990-07-22', N'Lê Thị Khu Vực', '2019-08-15', 20000000, N'Chính thức', N'Đang làm', '0902222222', 'ql2@cgv.vn', 'CGV02'),
('003', N'Q5', N'Nam', '1992-11-30', N'Nguyễn Văn Rạp', '2020-02-01', 18000000, N'Chính thức', N'Đang làm', '0903333333', 'ql3@cgv.vn', 'CGV03'),
('004', N'Q7', N'Nam', '1998-01-10', N'Phạm Văn Bán Vé', '2022-06-01', 8000000, N'Thử việc', N'Đang làm', '0904444444', 'nv1@cgv.vn', 'CGV01'),
('005', N'TB', N'Nữ', '1995-05-18', N'Hoàng Thị Vé', '2021-09-10', 8500000, N'Chính thức', N'Đang làm', '0905555555', 'nv2@cgv.vn', 'CGV01'),
('006', N'BT', N'Nam', '1997-08-25', N'Bùi Văn Đa Năng', '2022-01-15', 9000000, N'Chính thức', N'Đang làm', '0906666666', 'nv3@cgv.vn', 'CGV02'),
('007', N'Q10', N'Nữ', '1996-12-05', N'Trần Thị Đồ Ăn', '2021-12-20', 8200000, N'Chính thức', N'Đang làm', '0907777777', 'nv4@cgv.vn', 'CGV02'),
('008', N'Q1', N'Nam', '1999-04-12', N'Nguyễn Văn Mới', '2023-03-01', 7800000, N'Thử việc', N'Đang làm', '0908888888', 'nv5@cgv.vn', 'CGV03'),
('009', N'Q5', N'Nữ', '1994-09-30', N'Lý Thị Kinh Nghiệm', '2020-11-05', 9500000, N'Chính thức', N'Đang làm', '0909999999', 'nv6@cgv.vn', 'CGV03'),
('010', N'Q3', N'Nam', '1993-02-28', N'Đặng Văn Lâu', '2020-07-20', 9200000, N'Chính thức', N'Đang làm', '0900000000', 'nv7@cgv.vn', 'CGV03');
GO

-- 7. QUAY GIAO DICH (5 rows)
INSERT INTO QuayGiaoDich (MaQuay, MaRap, LoaiQuay) VALUES
(1, 'CGV01', N'Vé'),
(2, 'CGV01', N'Bắp nước'),
(1, 'CGV02', N'Vé'),
(2, 'CGV02', N'Tích hợp'),
(1, 'CGV03', N'Vé');
GO

-- 8. PHONG CHIEU (6 rows)
INSERT INTO PhongChieu (MaPhong, MaRap, SucChua, TrangThai, LoaiPhong, TenHienThi) VALUES
(1, 'CGV01', 100, 1, '2D',        N'Phòng 2D-1'),
(2, 'CGV01', 80,  1, '3D',        N'Phòng 3D-1'),
(1, 'CGV02', 90,  1, '2D',        N'Phòng 2D-2'),
(2, 'CGV02', 70,  1, 'IMAX',      N'Phòng IMAX-2'),
(1, 'CGV03', 100, 1, '2D',        N'Phòng 2D-3'),
(2, 'CGV03', 60,  1, '4DX',       N'Phòng 4DX-3');
GO

-- 9. GIAO DICH (12 rows - increased for coherence)
-- Adding extra transactions for User 6 (VVIP)
INSERT INTO GiaoDich (MaKhachHang, ThoiDiemBatDau, ThoiDiemKetThuc, KenhThanhToan, TrangThai, PhuongThuc) VALUES
(1, '2025-11-20 10:00:00', '2025-11-20 10:02:00', N'Ví điện tử',   N'Đã thanh toán', 'Online'), -- 1
(2, '2025-11-20 14:00:00', '2025-11-20 14:01:30', N'Tiền mặt',     N'Đã thanh toán', 'Offline'), -- 2
(3, '2025-11-20 19:00:00', '2025-11-20 19:01:30', N'Thẻ quốc tế',  N'Tạm giữ',       'Online'), -- 3
(4, '2025-11-21 09:30:00', '2025-11-21 09:31:00', N'Tiền mặt',     N'Hủy',           'Offline'), -- 4
(5, '2025-11-21 13:30:00', '2025-11-21 13:31:30', N'Ví điện tử',   N'Đã thanh toán', 'Online'), -- 5
(6, '2025-11-21 18:00:00', '2025-11-21 18:01:30', N'Thẻ nội địa',  N'Đã thanh toán', 'Online'), -- 6
(7, '2025-11-22 10:15:00', '2025-11-22 10:16:30', N'Tiền mặt',     N'Đã thanh toán', 'Offline'), -- 7
(8, '2025-11-22 15:00:00', '2025-11-22 15:01:30', N'Ví điện tử',   N'Đã thanh toán', 'Online'), -- 8
(9, '2025-11-22 20:00:00', '2025-11-22 20:01:30', N'Thẻ quốc tế',  N'Đã thanh toán', 'Online'), -- 9
(10, '2025-11-23 09:00:00', '2025-11-23 09:01:30', N'Tiền mặt',     N'Đã thanh toán', 'Offline'), -- 10
-- Extra High Value Trans for User 6
(6, '2025-11-23 10:00:00', '2025-11-23 10:05:00', N'Thẻ quốc tế',  N'Đã thanh toán', 'Online'), -- 11
(6, '2025-11-24 10:00:00', '2025-11-24 10:05:00', N'Thẻ quốc tế',  N'Đã thanh toán', 'Online'); -- 12
GO

-- 10. PHU TRO PHIM (>5 rows)
INSERT INTO Theloai_Phim (Ma_Phim, TheloaiPhim) VALUES (1, N'Viễn tưởng'), (2, N'Hành động'), (3, N'Giật gân'), (4, N'Tâm lý'), (5, N'Hành động'), (6, N'Âm nhạc');
INSERT INTO DinhDangHoTro_Phim (Ma_Phim, DinhDangHoTro) VALUES (1, N'2D'), (1, N'IMAX'), (2, N'4DX'), (3, N'3D'), (4, N'2D'), (5, N'2D');
INSERT INTO DaoDien_Phim (Ma_Phim, DaoDien) VALUES (1, N'Director A'), (2, N'Director B'), (3, N'Director C'), (4, N'Director D'), (5, N'Director E');
INSERT INTO DienVien_Phim (Ma_Phim, DienVien) VALUES (1, N'Actor A'), (2, N'Actor B'), (3, N'Actor C'), (4, N'Actor D'), (5, N'Actor E');

-- 11. COMBO COMP (11 rows)
INSERT INTO Combo_ThanhPhan (Ma_combo, ThanhPhanCombo, SoLuong) VALUES (1,'Bap',1), (1,'Nuoc',1), (2,'Bap',2), (2,'Nuoc',2), (3,'Bap',1), (3,'Snack',2), (4,'Bap',2), (4,'Nuoc',1), (5,'Bap',3), (5,'Nuoc',2), (5,'Snack',2);

-- 12. DUOC DI KEM (5 rows)
INSERT INTO DuocDiKem (Ma_Combo, Ma_Giaodich, SoLuong) VALUES (1, 1, 1), (2, 2, 1), (3, 5, 2), (4, 6, 1), (5, 8, 1);
GO

------------------------------------------------------------
-- LEVEL 2: Tables depending on Level 1
------------------------------------------------------------

-- 13. SUAT CHIEU (12 rows)
INSERT INTO SuatChieu (MaPhim, MaRap, MaPhongChieu, NgayChieu, DinhDangChieu, NgonNgu, TrangThai, HinhThucDichThuat, GioBatDau) VALUES
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

-- 14. GHE (9 rows)
INSERT INTO Ghe (MaGhe, MaRap, MaPhongChieu, So, Hang, TrangThai, Loai) VALUES
('A01', 'CGV01', 1, 1, 'A', N'Hoạt động', 'Normal'), ('A02', 'CGV01', 1, 2, 'A', N'Hoạt động', 'Normal'), ('A03', 'CGV01', 1, 3, 'A', N'Hoạt động', 'VIP'),
('B01', 'CGV02', 1, 1, 'B', N'Hoạt động', 'Normal'), ('B02', 'CGV02', 1, 2, 'B', N'Hoạt động', 'Normal'), ('B03', 'CGV02', 1, 3, 'B', N'Hoạt động', 'VIP'),
('C01', 'CGV03', 1, 1, 'C', N'Hoạt động', 'Normal'), ('C02', 'CGV03', 1, 2, 'C', N'Hoạt động', 'Normal'), ('C03', 'CGV03', 1, 3, 'C', N'Hoạt động', 'VIP');
GO

-- 15. THE THANH VIEN (10 rows)
INSERT INTO TheThanhVien (MaSoThe, NgayDangKy, TrangThai, LaTheChinh, MaTaiKhoan) VALUES
('1234567890123456', '2023-01-15', 1, 1, 1), ('2345678901234567', '2022-08-20', 1, 1, 2), ('3456789012345678', '2024-03-10', 1, 1, 3),
('4567890123456789', '2021-11-25', 1, 1, 4), ('5678901234567890', '2023-07-18', 1, 1, 5), ('6789012345678901', '2024-09-05', 1, 1, 6),
('7890123456789012', '2022-12-15', 1, 1, 7), ('8901234567890123', '2023-04-22', 1, 1, 8), ('9012345678901234', '2021-06-30', 1, 1, 9),
('0123456789012345', '2022-02-02', 1, 1, 10);
GO

-- 16. DIEM THUONG (10 rows)
INSERT INTO DiemThuong (SoLuong, TrangThai, MaGiaoDich, MaTaiKhoan, NgayGhiNhan, NgayHetHan) VALUES
(50, N'Còn hiệu lực', 1, 1, '2025-11-20', '2026-11-20'),
(30, N'Còn hiệu lực', 2, 2, '2025-11-20', '2026-11-20'),
(20, N'Đã dùng',      3, 3, '2025-11-20', '2026-05-20'),
(0,  N'Đã hết hạn',    4, 4, '2025-11-21', '2026-11-21'),
(40, N'Còn hiệu lực', 5, 5, '2025-11-21', '2026-11-21'),
(60, N'Còn hiệu lực', 6, 6, '2025-11-21', '2026-11-21'),
(15, N'Còn hiệu lực', 7, 7, '2025-11-22', '2026-11-22'),
(25, N'Còn hiệu lực', 8, 8, '2025-11-22', '2026-11-22'),
(35, N'Còn hiệu lực', 9, 9, '2025-11-22', '2026-11-22'),
(45, N'Còn hiệu lực', 10, 10, '2025-11-23', '2026-11-23');
GO

-- 17. MA UU DAI (5 rows - Added one more)
INSERT INTO MaUuDai (GiaTri, TrangThai, DieuKienApDung, Loai, NguonPhatHanh, NgayPhatHanh, NgayBatDauHieuLuc, GioiHanSoLanSuDung, NgayHetHan, MaGiaoDich) VALUES
(50000, N'Chưa dùng', 100000, 'So tien',  N'CGV App', '2025-10-01', '2025-10-01', 5, '2025-12-31', 1),
(20,    N'Chưa dùng',  80000, 'Phan tram',N'Galaxy',  '2025-09-15', '2025-09-20', 3, '2025-12-31', 2),
(30000, N'Hết hạn',    60000, 'So tien',  N'Lotte',   '2025-07-01', '2025-07-05', 2, '2025-10-31', 3),
(20000, N'Đã dùng',    60000, 'So tien',  N'Beta',    '2025-11-01', '2025-11-01', 5, '2026-01-01', 4),
(10,    N'Chưa dùng',  50000, 'Phan tram',N'Momo',    '2025-11-05', '2025-11-05', 1, '2025-12-31', 5);
GO

-- 18. NGUOI QUAN LY (5 rows - Added 2)
INSERT INTO NguoiQuanLy (ID, CapBac, KhuVucPhuTrach, NgayBoNhiem) VALUES
(1, N'Quản lý cấp cao',  N'Toàn quốc',        '2018-05-01'),
(2, N'Quản lý khu vực', N'Khu vực TP.HCM',   '2019-08-15'),
(3, N'Quản lý rạp',     N'Rạp CGV03',        '2020-02-01'),
(4, N'Quản lý rạp',     N'Rạp CGV01',        '2022-01-01'),
(5, N'Quản lý rạp',     N'Rạp CGV02',        '2022-06-01');
GO

-- 19. NHAN SU CHAM CONG (6 rows)
INSERT INTO NhanSuChamCong (ID, ThoiDiemCheckIn, ThoiDiemCheckOut, CaDangKy, CaThucTe, SaiLech) VALUES
(4, '2025-11-20 08:00:00', '2025-11-20 17:00:00', 'CA000001', 'CA000001', 0),
(5, '2025-11-20 08:15:00', '2025-11-20 17:15:00', 'CA000002', 'CA000002', 15),
(2, '2025-11-20 08:00:00', '2025-11-20 20:00:00', 'CA000001', 'CA000003', 180),
(6, '2025-11-21 08:00:00', NULL,                  'CA000003', 'CA000003', NULL),
(7, '2025-11-21 13:50:00', '2025-11-21 22:00:00', 'CA000004', 'CA000004', -10),
(3, '2025-11-21 08:00:00', '2025-11-21 17:00:00', 'CA000005', 'CA000005', 0);
GO

-- 20. ON_LINE (6 rows)
INSERT INTO On_line (MaGiaoDich, SLA) VALUES (1, '00:05:00'), (3, '00:05:00'), (5, '00:05:00'), (6, '00:05:00'), (8, '00:05:00'), (9, '00:05:00');
GO

------------------------------------------------------------
-- LEVEL 3: Tables depending on Level 2
------------------------------------------------------------

-- 21. VE (12 rows - corresponding to transactions)
-- Prices set to exactly match TaiKhoanThanhVien.TongChiTieuLuyKe
INSERT INTO Ve (MaGhe, TrangThai, PhuThu, GiaChuan, GiaSauUuDai, MaGiaoDich, MaPhim, MaSuatChieu, ThoiDiemXuatVe) VALUES
('A01', N'Đã xuất', 0,     80000, 70000, 1, 1, 1, '2025-11-20 10:00:00'), -- User 1: 70k
('A02', N'Đã xuất', 10000, 90000, 80000, 2, 2, 2, '2025-11-20 14:00:00'), -- User 2: 80k
('A03', N'Tạm giữ', 0,     75000, 75000, 3, 3, 3, '2025-11-20 19:00:00'), -- User 3: Unpaid
('B01', N'Hoàn/Hủy',0,     85000, 85000, 4, 4, 4, '2025-11-21 09:30:00'), -- User 4: Cancelled
('B02', N'Đã xuất', 0,     90000, 85000, 5, 5, 5, '2025-11-21 13:30:00'), -- User 5: 85k
('B03', N'Đã xuất', 5000,  95000, 90000, 6, 6, 6, '2025-11-21 18:00:00'), -- User 6: 90k
('C01', N'Đã xuất', 0,     80000, 75000, 7, 7, 7, '2025-11-22 10:15:00'), -- User 7: 75k
('C02', N'Đã xuất', 0,     90000, 85000, 8, 8, 8, '2025-11-22 15:00:00'), -- User 8: 85k (Need 500k more for VIP status)
('C03', N'Đã xuất', 0,     95000, 90000, 9, 9, 9, '2025-11-22 20:00:00'), -- User 9: 90k
('A01', N'Đã xuất', 0,     80000, 80000, 10, 10, 10, '2025-11-23 09:00:00'), -- User 10: 80k
-- WHALE USER 6 Extra Tickets
('B03', N'Đã xuất', 0,     500000, 500000, 11, 2, 2, '2025-11-23 10:00:00'), -- User 6: +500k
('B03', N'Đã xuất', 0,     1000000, 1000000, 12, 2, 2, '2025-11-24 10:00:00'); -- User 6: +1M -> Total ~1.59M
-- User 8 Extra Ticket logic to hit VIP
INSERT INTO Ve (MaGhe, TrangThai, PhuThu, GiaChuan, GiaSauUuDai, MaGiaoDich, MaPhim, MaSuatChieu, ThoiDiemXuatVe) VALUES
('C02', N'Đã xuất', 0, 500000, 500000, 8, 8, 8, '2025-11-22 15:01:00'); -- Added to Trans 8
GO

-- 22. GHE TRANG THAI (9 rows)
INSERT INTO Ghe_DanhSachTrangThaiCuaGhe (MaSuatChieu, MaPhim, TrangThai, MaGhe) VALUES
(1, 1, N'Trống', 'A01'), (1, 1, N'Đã bán', 'A02'), (2, 2, N'Tạm giữ', 'A03'),
(4, 4, N'Trống', 'B01'), (5, 5, N'Đã bán', 'B02'), (6, 6, N'Trống', 'B03'),
(7, 7, N'Đã bán', 'C01'), (8, 8, N'Tạm giữ', 'C02'), (9, 9, N'Trống', 'C03');
GO

-- 23. MA DOI TU DIEM (5 rows - Added 2)
INSERT INTO MaDoiTuDiem (MaSo, MaTaiKhoan, MaDiemThuong) VALUES (1, 1, 1), (2, 2, 2), (4, 6, 6), (3, 3, 3), (5, 5, 5);
GO

-- 24. MA THEO SU KIEN (5 rows - Added 2)
INSERT INTO MaTheoSuKien (MaSo, TenSuKien) VALUES (1, N'Sự kiện Halloween'), (2, N'Sinh nhật Galaxy'), (4, N'Tuần lễ phim Việt'), (3, N'Khuyến mãi Mùa Hè'), (5, N'Black Friday');
GO

-- 25. NHAN VIEN BAN VE (7 rows)
INSERT INTO NhanVienBanVe (ID, VaiTro, MaCaLamViec, IDQuanLy) VALUES
(4, N'Bán vé',     'CA000001', 1), (5, N'Đa năng',    'CA000002', 1), (6, N'Bán đồ ăn',  'CA000003', 2),
(7, N'Bán vé',     'CA000004', 2), (8, N'Đa năng',    'CA000005', 3), (9, N'Bán đồ ăn',  'CA000006', 3), (10, N'Bán vé',     'CA000007', 3);
GO

-- 26. QUAN LY (5 rows - Fixed Hierarchy)
-- 1 (Cao) -> 2 (Khu Vuc) -> 3,4,5 (Rap)
INSERT INTO QuanLy (IDQuanLy, IDQuanLyCapCao) VALUES
(2, 1),
(3, 2),
(4, 2),
(5, 2),
(1, 1); -- Self-ref for top level or handle constraint logic.
-- NOTE: If constraint 'CHK_QuanLy_KhongTuQuanLy' exists, remove the (1,1) line.
-- Assuming Top Manager has no entry in this table or reports to null.
-- Let's remove (1,1) to be safe with your constraint.
DELETE FROM QuanLy WHERE IDQuanLy = 1;
GO

------------------------------------------------------------
-- LEVEL 4: Tables depending on Level 3
------------------------------------------------------------

-- 27. OFF_LINE (5 rows - Added 1)
INSERT INTO Off_line (MaGiaoDich, MaQuay, MaRap, ID_NhanVien) VALUES
(2, 1, 'CGV01', 4), (4, 1, 'CGV02', 6), (7, 2, 'CGV01', 5), (10, 1, 'CGV03', 8), (4, 2, 'CGV02', 7);
GO

-- 28. DUOC TRUC (6 rows)
INSERT INTO DuocTruc (ID_NhanVien, MaQuay, MaRap) VALUES (4, 1, 'CGV01'), (5, 2, 'CGV01'), (6, 1, 'CGV02'), (7, 2, 'CGV02'), (8, 1, 'CGV03'), (9, 1, 'CGV03');
GO