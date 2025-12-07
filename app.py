"""
CGV Cinema Database Management System
A Streamlit application for managing cinema operations
"""

import streamlit as st
import pyodbc
import pandas as pd
import json
from datetime import date, time, datetime

# =============================================================================
# DATABASE CONNECTION
# =============================================================================

CONN_STR = (
    r"DRIVER={ODBC Driver 17 for SQL Server};"
    r"SERVER=localhost;"
    r"DATABASE=Movie;"
    r"Trusted_Connection=yes;"
)


def get_connection():
    """Create and return a database connection."""
    return pyodbc.connect(CONN_STR)


def execute_query(
    query: str, params: tuple = None, fetch: bool = True, raise_on_error: bool = False
):
    """Execute a query and optionally fetch results."""
    try:
        with get_connection() as conn:
            cursor = conn.cursor()
            if params:
                cursor.execute(query, params)
            else:
                cursor.execute(query)

            if fetch:
                columns = [column[0] for column in cursor.description]
                rows = cursor.fetchall()
                return pd.DataFrame.from_records(rows, columns=columns)
            else:
                # For multi-statement batches, we need to consume all result sets
                # to ensure any errors (like THROW) are properly raised
                while cursor.nextset():
                    pass
                conn.commit()
                return True
    except Exception as e:
        if raise_on_error:
            raise
        st.error(f"Database error: {e}")
        return None


def execute_procedure(proc_name: str, params: dict, fetch: bool = True):
    """Execute a stored procedure."""
    try:
        with get_connection() as conn:
            cursor = conn.cursor()

            # Build parameter string
            param_placeholders = ", ".join([f"@{k}=?" for k in params.keys()])
            query = f"EXEC {proc_name} {param_placeholders}"

            cursor.execute(query, tuple(params.values()))

            if fetch:
                try:
                    columns = [column[0] for column in cursor.description]
                    rows = cursor.fetchall()
                    return pd.DataFrame.from_records(rows, columns=columns)
                except:
                    return pd.DataFrame()
            else:
                conn.commit()
                return True
    except pyodbc.Error as e:
        st.error(f"❌ Database error: {str(e)}")
        return None


def execute_scalar_function(func_name: str, params: list):
    """Execute a scalar function and return the result."""
    try:
        with get_connection() as conn:
            cursor = conn.cursor()
            param_placeholders = ", ".join(["?" for _ in params])
            query = f"SELECT dbo.{func_name}({param_placeholders})"
            cursor.execute(query, params)
            result = cursor.fetchone()[0]
            return result
    except Exception as e:
        st.error(f"Function error: {e}")
        return None


def execute_transaction(queries: list):
    """Execute multiple queries in a single transaction.

    Args:
        queries: List of tuples (query_string, params_tuple)

    Returns:
        True if successful, raises exception on failure
    """
    conn = get_connection()
    try:
        cursor = conn.cursor()
        for query, params in queries:
            if params:
                cursor.execute(query, params)
            else:
                cursor.execute(query)
        conn.commit()
        return True
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        conn.close()


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================


def get_cinemas():
    """Get list of cinemas for dropdown."""
    df = execute_query(
        "SELECT MaRap, TenRap FROM RapChieuPhim WHERE TrangThaiHoatDong = N'Hoạt động'"
    )
    if df is not None and not df.empty:
        return dict(zip(df["TenRap"], df["MaRap"]))
    return {}


def get_movies():
    """Get list of movies for dropdown."""
    df = execute_query(
        "SELECT MaPhim, TuaDe FROM Phim WHERE TrangThaiPhatHanh IN (N'Đang chiếu', N'Sắp chiếu')"
    )
    if df is not None and not df.empty:
        return dict(zip(df["TuaDe"], df["MaPhim"]))
    return {}


def get_rooms(cinema_id: str):
    """Get list of rooms for a cinema."""
    df = execute_query(
        "SELECT MaPhong, TenHienThi, LoaiPhong FROM PhongChieu WHERE MaRap = ? AND TrangThai = 1",
        (cinema_id,),
    )
    if df is not None and not df.empty:
        return df
    return pd.DataFrame()


def get_showtime_details(ma_suat_chieu: int):
    """Get detailed showtime info (MaPhim, MaRap, MaPhongChieu, TenPhong) from SuatChieu table."""
    df = execute_query(
        """
        SELECT sc.MaSuatChieu, sc.MaPhim, sc.MaRap, sc.MaPhongChieu, 
               pc.TenHienThi as TenPhong, pc.LoaiPhong
        FROM SuatChieu sc
        LEFT JOIN PhongChieu pc ON sc.MaRap = pc.MaRap AND sc.MaPhongChieu = pc.MaPhong
        WHERE sc.MaSuatChieu = ?
        """,
        (ma_suat_chieu,),
    )
    if df is not None and not df.empty:
        return df.iloc[0]
    return None


def format_currency(value):
    """Format number as Vietnamese currency."""
    return f"{value:,.0f} VNĐ"


# =============================================================================
# PAGE: SHOWTIME MANAGEMENT
# =============================================================================


def page_showtime_management():
    st.header("🎬 Quản Lý Suất Chiếu")

    tab1, tab2 = st.tabs(["🔍 Tìm Kiếm & Quản Lý", "➕ Thêm Suất Chiếu Mới"])

    # TAB 1: Search & Manage
    with tab1:
        st.subheader("Tìm kiếm suất chiếu")

        col1, col2, col3, col4 = st.columns(4)

        with col1:
            search_date = st.date_input("📅 Ngày chiếu", value=None, key="search_date")

        with col2:
            search_time = st.time_input(
                "⏰ Giờ bắt đầu từ", value=None, key="search_time"
            )

        with col3:
            cinemas = get_cinemas()
            cinema_options = ["Tất cả"] + list(cinemas.keys())
            search_cinema = st.selectbox(
                "🏛️ Rạp chiếu", cinema_options, key="search_cinema"
            )

        with col4:
            movies = get_movies()
            movie_options = ["Tất cả"] + list(movies.keys())
            search_movie = st.selectbox("🎥 Phim", movie_options, key="search_movie")

        if st.button("🔍 Tìm kiếm", type="primary", key="btn_search"):
            params = {
                "NgayChieu": search_date if search_date else None,
                "Gio": search_time.strftime("%H:%M:%S") if search_time else None,
                "TenRap": search_cinema if search_cinema != "Tất cả" else None,
                "TuaDe": search_movie if search_movie != "Tất cả" else None,
            }

            result = execute_procedure("TimSuatChieu", params)

            if result is not None and not result.empty:
                st.success(f"✅ Tìm thấy {len(result)} suất chiếu")
                st.session_state["search_results"] = result
            elif result is not None:
                st.warning("⚠️ Không tìm thấy suất chiếu nào phù hợp")
                st.session_state["search_results"] = pd.DataFrame()

        # Display search results
        if (
            "search_results" in st.session_state
            and not st.session_state["search_results"].empty
        ):
            st.divider()
            st.subheader("Kết quả tìm kiếm")

            df = st.session_state["search_results"]

            # Get room info for each showtime
            room_info = []
            for _, row in df.iterrows():
                details = get_showtime_details(row["MaSuatChieu"])
                if details is not None:
                    room_info.append(
                        f"{details['TenPhong']} ({details['LoaiPhong']})"
                        if details["TenPhong"]
                        else "N/A"
                    )
                else:
                    room_info.append("N/A")
            df["PhongChieu"] = room_info

            # Sort by MaSuatChieu descending
            df = df.sort_values("MaSuatChieu", ascending=False)

            # Format display
            display_df = df.copy()
            if "NgayChieu" in display_df.columns:
                display_df["NgayChieu"] = pd.to_datetime(
                    display_df["NgayChieu"]
                ).dt.strftime("%d/%m/%Y")
            if "GioBatDau" in display_df.columns:
                display_df["GioBatDau"] = display_df["GioBatDau"].astype(str).str[:5]
            if "ThoiLuong" in display_df.columns:
                display_df["ThoiLuong"] = display_df["ThoiLuong"].astype(str).str[:5]

            st.dataframe(display_df, use_container_width=True, hide_index=True)

            # Update/Delete section
            st.divider()
            st.subheader("Cập nhật / Xóa suất chiếu")

            # Display success message from session state (persists across rerun)
            if "showtime_success_msg" in st.session_state:
                st.success(st.session_state.pop("showtime_success_msg"))

            col1, col2 = st.columns(2)

            with col1:
                showtime_options = [
                    f"{row['MaSuatChieu']} - {row['TuaDe']} ({row['TenRap']})"
                    for _, row in df.iterrows()
                ]
                selected_showtime = st.selectbox(
                    "Chọn suất chiếu", showtime_options, key="select_showtime"
                )

                if selected_showtime:
                    selected_idx = showtime_options.index(selected_showtime)
                    selected_row = df.iloc[selected_idx]

                    st.info(f"""
                    **Thông tin suất chiếu:**
                    - Mã suất chiếu: `{selected_row["MaSuatChieu"]}`
                    - Phim: `{selected_row["TuaDe"]}`
                    - Rạp: `{selected_row["TenRap"]}`
                    - Phòng chiếu: `{selected_row["PhongChieu"]}`
                    - Giờ chiếu: `{selected_row["GioBatDau"]}`
                    """)

            with col2:
                st.write("**Cập nhật thông tin:**")

                new_time = st.time_input(
                    "⏰ Giờ bắt đầu mới", value=None, key="new_time"
                )

                # Get rooms for selected cinema
                if selected_showtime:
                    selected_idx = showtime_options.index(selected_showtime)
                    selected_row = df.iloc[selected_idx]
                    # Get detailed info from SuatChieu table (MaPhim, MaRap, MaPhongChieu)
                    showtime_details = get_showtime_details(
                        int(selected_row["MaSuatChieu"])
                    )
                    rooms_df = (
                        get_rooms(str(showtime_details["MaRap"]))
                        if showtime_details is not None
                        else pd.DataFrame()
                    )

                    if not rooms_df.empty:
                        room_options = [None] + [
                            f"{row['MaPhong']} - {row['TenHienThi']} ({row['LoaiPhong']})"
                            for _, row in rooms_df.iterrows()
                        ]
                        new_room_selection = st.selectbox(
                            "🚪 Phòng chiếu mới", room_options, key="new_room"
                        )
                        new_room = (
                            int(new_room_selection.split(" - ")[0])
                            if new_room_selection
                            else None
                        )
                    else:
                        new_room = None

                col_btn1, col_btn2 = st.columns(2)

                with col_btn1:
                    if st.button("✏️ Cập nhật", type="primary", key="btn_update"):
                        if selected_showtime and showtime_details is not None:
                            params = {
                                "MaSuatChieu": int(selected_row["MaSuatChieu"]),
                                "MaPhim": int(showtime_details["MaPhim"]),
                                "GioBatDauMoi": new_time.strftime("%H:%M:%S")
                                if new_time
                                else None,
                                "MaPhongMoi": new_room if new_room else None,
                                "MaRap": str(showtime_details["MaRap"]),
                            }
                            result = execute_procedure(
                                "Update_ThongTinSuatChieu", params, fetch=False
                            )
                            if result:
                                st.session_state["showtime_success_msg"] = (
                                    "✅ Cập nhật suất chiếu thành công!"
                                )
                                st.rerun()

                with col_btn2:
                    if st.button("🗑️ Xóa", type="secondary", key="btn_delete"):
                        if selected_showtime and showtime_details is not None:
                            params = {
                                "MaSuatChieu": int(selected_row["MaSuatChieu"]),
                                "MaPhim": int(showtime_details["MaPhim"]),
                            }
                            result = execute_procedure(
                                "Delete_SuatChieu", params, fetch=False
                            )
                            if result:
                                st.session_state["showtime_success_msg"] = (
                                    "✅ Xóa suất chiếu thành công!"
                                )
                                st.rerun()

            # =================================================================
            # WORKFLOW 2 HELPER: Ticket Inspection Section
            # Shows existing tickets for the selected showtime to explain
            # why delete/update operations fail (Data Integrity Lock)
            # =================================================================
            st.divider()
            st.subheader("🎫 Kiểm tra vé đã bán")
            st.caption(
                "Xem danh sách vé đã phát sinh cho suất chiếu để hiểu lý do không thể xóa/sửa."
            )

            if st.button("🔍 Hiển thị vé của suất chiếu này", key="btn_show_tickets"):
                if selected_showtime and showtime_details is not None:
                    ma_suat_chieu = int(selected_row["MaSuatChieu"])
                    ma_phim = int(showtime_details["MaPhim"])

                    # Query tickets for this showtime
                    tickets_query = """
                    SELECT 
                        v.MaVe,
                        v.MaGhe,
                        v.TrangThai,
                        v.GiaChuan,
                        v.GiaSauUuDai,
                        v.ThoiDiemXuatVe,
                        gd.MaGiaoDich,
                        gd.TrangThai AS TrangThaiGiaoDich,
                        kh.HoTen AS TenKhachHang
                    FROM Ve v
                    JOIN GiaoDich gd ON v.MaGiaoDich = gd.MaGiaoDich
                    JOIN KhachHang kh ON gd.MaKhachHang = kh.MaKhachHang
                    WHERE v.MaSuatChieu = ? AND v.MaPhim = ?
                    ORDER BY v.MaVe
                    """
                    tickets_df = execute_query(tickets_query, (ma_suat_chieu, ma_phim))

                    # Store in session state for persistence
                    st.session_state["showtime_tickets_result"] = tickets_df
                    st.session_state["showtime_tickets_info"] = {
                        "ma_suat_chieu": ma_suat_chieu,
                        "ten_phim": selected_row["TuaDe"],
                        "ten_rap": selected_row["TenRap"],
                    }

            # Display persisted ticket results
            if "showtime_tickets_result" in st.session_state:
                tickets_df = st.session_state["showtime_tickets_result"]
                tickets_info = st.session_state.get("showtime_tickets_info", {})

                if tickets_df is not None and not tickets_df.empty:
                    st.warning(
                        f"⚠️ Suất chiếu **{tickets_info.get('ma_suat_chieu', 'N/A')}** - "
                        f"**{tickets_info.get('ten_phim', 'N/A')}** tại **{tickets_info.get('ten_rap', 'N/A')}** "
                        f"đã có **{len(tickets_df)} vé** được phát sinh!"
                    )

                    # Format for display
                    display_tickets = tickets_df.copy()
                    if "ThoiDiemXuatVe" in display_tickets.columns:
                        display_tickets["ThoiDiemXuatVe"] = pd.to_datetime(
                            display_tickets["ThoiDiemXuatVe"]
                        ).dt.strftime("%d/%m/%Y %H:%M")
                    if "GiaChuan" in display_tickets.columns:
                        display_tickets["GiaChuan"] = display_tickets["GiaChuan"].apply(
                            format_currency
                        )
                    if "GiaSauUuDai" in display_tickets.columns:
                        display_tickets["GiaSauUuDai"] = display_tickets[
                            "GiaSauUuDai"
                        ].apply(format_currency)

                    display_tickets.columns = [
                        "Mã Vé",
                        "Mã Ghế",
                        "Trạng Thái Vé",
                        "Giá Chuẩn",
                        "Giá Sau Ưu Đãi",
                        "Thời Điểm Xuất Vé",
                        "Mã GD",
                        "Trạng Thái GD",
                        "Khách Hàng",
                    ]
                    st.dataframe(
                        display_tickets, use_container_width=True, hide_index=True
                    )

                    # Expandable explanation
                    with st.expander("💡 Giải thích"):
                        st.markdown("""
                        **Tại sao không thể xóa suất chiếu này?**
                        
                        Stored procedure `Delete_SuatChieu` kiểm tra bảng `Ve` trước khi xóa:
                        
                        ```sql
                        IF EXISTS (
                            SELECT 1 FROM Ve 
                            WHERE MaSuatChieu = @MaSuatChieu AND MaPhim = @MaPhim
                        )
                        BEGIN
                            RAISERROR(N'Lỗi: Không thể xóa suất chiếu này vì đã phát sinh vé...', 16, 1);
                            RETURN;
                        END
                        ```
                        
                        **Giải thích lý do:**
                        - Bảo toàn lịch sử giao dịch (Data Integrity)
                        - Không làm mất dữ liệu vé đã bán
                        - Kể cả vé đã hủy cũng được lưu lại để kiểm tra
                        """)

                elif tickets_df is not None:
                    st.success("✅ Suất chiếu này chưa có vé nào được phát sinh.")
                    # Clear stored results when no tickets
                    if "showtime_tickets_result" in st.session_state:
                        del st.session_state["showtime_tickets_result"]
                    if "showtime_tickets_info" in st.session_state:
                        del st.session_state["showtime_tickets_info"]

    # TAB 2: Add New Showtime
    with tab2:
        # =====================================================================
        # WORKFLOW 1 HELPER: Movie Format Inspection Panel
        # Shows which formats each movie supports to explain validation errors
        # =====================================================================
        st.subheader("📋 Thông tin định dạng phim")
        st.caption(
            "Mỗi phim chỉ hỗ trợ một số định dạng chiếu nhất định. Kiểm tra trước khi thêm suất chiếu."
        )

        # Query to get all movies with their supported formats
        movie_formats_query = """
        SELECT 
            p.MaPhim,
            p.TuaDe,
            p.TrangThaiPhatHanh,
            STRING_AGG(d.DinhDangHoTro, ', ') AS DinhDangHoTro
        FROM Phim p
        LEFT JOIN DinhDangHoTro_Phim d ON p.MaPhim = d.Ma_Phim
        WHERE p.TrangThaiPhatHanh IN (N'Đang chiếu', N'Sắp chiếu')
        GROUP BY p.MaPhim, p.TuaDe, p.TrangThaiPhatHanh
        ORDER BY p.MaPhim
        """
        movie_formats_df = execute_query(movie_formats_query)

        if movie_formats_df is not None and not movie_formats_df.empty:
            # Highlight movies with no format support (will cause errors)
            display_formats_df = movie_formats_df.copy()
            display_formats_df["DinhDangHoTro"] = display_formats_df[
                "DinhDangHoTro"
            ].fillna("⚠️ Chưa có định dạng")
            display_formats_df.columns = [
                "Mã Phim",
                "Tựa Đề",
                "Trạng Thái",
                "Định Dạng Hỗ Trợ",
            ]
            st.dataframe(display_formats_df, use_container_width=True, hide_index=True)

            # Expandable note for demonstration
            with st.expander("💡 Giải thích"):
                st.markdown("""
                **Mục tiêu:** Chứng minh phim phải hỗ trợ định dạng chiếu.
                
                **Các bước:**
                1. Chọn **Phim**: `Bóng Tối Trên Sao Hỏa` (chỉ hỗ trợ **3D**)
                2. Chọn **Rạp**: `CGV Landmark 81`
                3. Chọn **Phòng**: `Phòng 2D-1` (phòng 2D hợp lệ)
                4. Chọn **Định dạng**: `2D`
                5. Nhấn **Thêm suất chiếu**
                
                **Kết quả mong đợi:** Lỗi "Phim... không hỗ trợ định dạng chiếu (2D)".
                
                **Giải thích:** Stored procedure `sp_Insert_SuatChieu` kiểm tra bảng `DinhDangHoTro_Phim`.
                """)
        else:
            st.warning("Không có dữ liệu phim.")

        st.divider()

        # =====================================================================
        # Original Add Showtime Section
        # =====================================================================
        st.subheader("Thêm suất chiếu mới")

        # Display success message from session state (persists across rerun)
        if "add_showtime_success_msg" in st.session_state:
            st.success(st.session_state.pop("add_showtime_success_msg"))

        col1, col2 = st.columns(2)

        with col1:
            # Movie and Cinema selection OUTSIDE form for dynamic room updates
            movies = get_movies()
            selected_movie = st.selectbox(
                "🎥 Chọn phim", list(movies.keys()), key="add_movie"
            )

            cinemas = get_cinemas()
            selected_cinema = st.selectbox(
                "🏛️ Chọn rạp", list(cinemas.keys()), key="add_cinema"
            )

            # Room selection - updates dynamically when cinema changes
            selected_room = None
            if selected_cinema:
                rooms_df = get_rooms(cinemas[selected_cinema])
                if not rooms_df.empty:
                    room_options = [
                        f"{row['MaPhong']} - {row['TenHienThi']} ({row['LoaiPhong']})"
                        for _, row in rooms_df.iterrows()
                    ]
                    selected_room = st.selectbox(
                        "🚪 Chọn phòng chiếu", room_options, key="add_room"
                    )
                else:
                    st.warning("Không có phòng chiếu khả dụng")

            show_date = st.date_input(
                "📅 Ngày chiếu", value=date.today(), key="add_date"
            )

        with col2:
            show_time = st.time_input(
                "⏰ Giờ bắt đầu", value=time(10, 0), key="add_time"
            )

            format_options = ["2D", "3D", "IMAX", "4DX", "GOLDCLASS", "STARIUM"]
            show_format = st.selectbox(
                "📺 Định dạng chiếu", format_options, key="add_format"
            )

            language_options = [
                "Tiếng Việt",
                "Tiếng Anh",
                "Tiếng Hàn",
                "Tiếng Nhật",
                "Tiếng Trung",
            ]
            show_language = st.selectbox(
                "🌐 Ngôn ngữ", language_options, key="add_language"
            )

            status_options = ["Mở bán", "Khóa bán"]
            show_status = st.selectbox(
                "📊 Trạng thái", status_options, key="add_status"
            )

            subtitle_options = {"Phụ đề": "PhuDe", "Lồng tiếng": "LongTieng"}
            show_subtitle = st.selectbox(
                "💬 Hình thức dịch thuật",
                list(subtitle_options.keys()),
                key="add_subtitle",
            )

        # Submit button outside form
        if st.button("➕ Thêm suất chiếu", type="primary", use_container_width=True):
            # Validation
            if not selected_room:
                st.error("❌ Vui lòng chọn phòng chiếu")
            else:
                room_id = int(selected_room.split(" - ")[0])

                params = {
                    "MaPhim": movies[selected_movie],
                    "MaRap": cinemas[selected_cinema],
                    "MaPhongChieu": room_id,
                    "NgayChieu": show_date,
                    "DinhDangChieu": show_format,
                    "NgonNgu": show_language,
                    "TrangThai": show_status,
                    "HinhThucDichThuat": subtitle_options[show_subtitle],
                    "GioBatDau": show_time.strftime("%H:%M:%S"),
                }

                result = execute_procedure("sp_Insert_SuatChieu", params)
                if result is not None:
                    st.session_state["add_showtime_success_msg"] = (
                        "✅ Thêm suất chiếu mới thành công!"
                    )
                    st.rerun()


# =============================================================================
# PAGE: REVENUE STATISTICS
# =============================================================================


def page_revenue_statistics():
    st.header("📊 Thống Kê Doanh Thu")

    tab1, tab2 = st.tabs(["🏛️ Doanh Thu Theo Rạp", "🎬 Top 5 Phim Doanh Thu Cao"])

    # TAB 1: Cinema Revenue
    with tab1:
        st.subheader("Thống kê doanh thu vé theo rạp")

        col1, col2, col3 = st.columns([1, 1, 1])

        with col1:
            start_date = st.date_input(
                "📅 Từ ngày", value=date(2025, 11, 1), key="rev_start"
            )

        with col2:
            end_date = st.date_input(
                "📅 Đến ngày", value=date(2025, 11, 30), key="rev_end"
            )

        with col3:
            st.write("")
            st.write("")
            run_query = st.button(
                "📊 Xem thống kê", type="primary", key="btn_cinema_revenue"
            )

        if run_query:
            if start_date > end_date:
                st.error("❌ Ngày bắt đầu không được lớn hơn ngày kết thúc!")
            else:
                result = execute_scalar_function(
                    "ThongKeDoanhThuVeCuaRap", [start_date, end_date]
                )

                if result and not result.startswith("Lỗi"):
                    try:
                        data = json.loads(result)

                        if data:
                            df = pd.DataFrame(data)
                            total_revenue = df["DoanhThu"].sum()
                            num_cinemas = len(df)
                            avg_revenue = total_revenue / num_cinemas
                            df["TyLe"] = (df["DoanhThu"] / total_revenue * 100).round(2)
                            df["DoanhThuFormatted"] = df["DoanhThu"].apply(
                                format_currency
                            )

                            # Summary metrics using markdown table
                            st.markdown(f"""
                            | 🏛️ Số rạp | 💰 Tổng doanh thu | 📈 Trung bình/rạp |
                            |:---:|:---:|:---:|
                            | **{num_cinemas}** | **{format_currency(total_revenue)}** | **{format_currency(avg_revenue)}** |
                            """)

                            st.divider()

                            # Display table
                            display_df = df[
                                [
                                    "MaRap",
                                    "TenRap",
                                    "TinhThanh",
                                    "DoanhThuFormatted",
                                    "TyLe",
                                ]
                            ].copy()
                            display_df.columns = [
                                "Mã Rạp",
                                "Tên Rạp",
                                "Tỉnh/Thành",
                                "Doanh Thu",
                                "Tỷ Lệ (%)",
                            ]

                            st.dataframe(
                                display_df, use_container_width=True, hide_index=True
                            )

                        else:
                            st.warning("⚠️ Không có dữ liệu trong khoảng thời gian này")
                    except json.JSONDecodeError:
                        st.error(f"❌ Lỗi phân tích dữ liệu: {result}")
                else:
                    st.error(result if result else "❌ Không thể lấy dữ liệu")

    # TAB 2: Top 5 Movies
    with tab2:
        st.subheader("Top 5 phim doanh thu cao nhất")

        col1, col2, col3 = st.columns([1, 1, 1])

        with col1:
            start_date_movie = st.date_input(
                "📅 Từ ngày", value=date(2025, 11, 1), key="movie_start"
            )

        with col2:
            end_date_movie = st.date_input(
                "📅 Đến ngày", value=date(2025, 11, 30), key="movie_end"
            )

        with col3:
            st.write("")
            st.write("")
            run_query_movie = st.button(
                "🎬 Xem Top 5", type="primary", key="btn_top5_movies"
            )

        if run_query_movie:
            if start_date_movie > end_date_movie:
                st.error("❌ Ngày bắt đầu không được lớn hơn ngày kết thúc!")
            else:
                result = execute_scalar_function(
                    "Top5PhimDoanhThuCaoNhat", [start_date_movie, end_date_movie]
                )

                if result and not result.startswith("Lỗi"):
                    try:
                        data = json.loads(result)

                        if data:
                            df = pd.DataFrame(data)

                            # Display with medals using markdown table for dark mode compatibility
                            medals = ["🥇", "🥈", "🥉", "4️⃣", "5️⃣"]

                            for i, row in df.iterrows():
                                medal = medals[i] if i < len(medals) else f"{i + 1}."
                                st.markdown(f"""
                                | {medal} | **{row["TuaDe"]}** | **{format_currency(row["DoanhThu"])}** |
                                |:---:|:---|---:|
                                | | Mã phim: `{row["MaPhim"]}` | |
                                """)

                        else:
                            st.warning("⚠️ Không có dữ liệu trong khoảng thời gian này")
                    except json.JSONDecodeError:
                        st.error(f"❌ Lỗi phân tích dữ liệu: {result}")
                else:
                    st.error(result if result else "❌ Không thể lấy dữ liệu")


# =============================================================================
# PAGE: HIGH-SPENDING ACCOUNTS
# =============================================================================


def page_high_spending_accounts():
    st.header("💳 Tài Khoản Chi Tiêu Cao")

    st.subheader("Danh sách tài khoản thành viên có tổng chi tiêu lũy kế cao")

    col1, col2 = st.columns([2, 1])

    with col1:
        min_spending = st.number_input(
            "💰 Mức chi tiêu tối thiểu (VNĐ)",
            min_value=0,
            value=1000000,
            step=100000,
            format="%d",
            key="min_spending",
        )

    with col2:
        st.write("")
        st.write("")
        run_query = st.button("🔍 Tìm kiếm", type="primary", key="btn_spending")

    if run_query:
        params = {"TongChiTieu": min_spending if min_spending > 0 else None}
        result = execute_procedure("LietKeTaiKhoanTieuNhieu", params)

        if result is not None and not result.empty:
            # Statistics
            total_accounts = len(result)
            total_spending = result["TongChiTieu"].sum()
            avg_spending = result["TongChiTieu"].mean()
            max_spending = result["TongChiTieu"].max()

            st.markdown(f"""
            | 👥 Số tài khoản | 💰 Tổng chi tiêu | 📈 Trung bình | 🏆 Cao nhất |
            |:---:|:---:|:---:|:---:|
            | **{total_accounts}** | **{format_currency(total_spending)}** | **{format_currency(avg_spending)}** | **{format_currency(max_spending)}** |
            """)

            st.divider()

            # Sort by TongChiTieu (numeric) before formatting, then format for display
            display_df = result.sort_values("TongChiTieu", ascending=False).copy()
            display_df["TongChiTieu"] = display_df["TongChiTieu"].apply(format_currency)
            display_df.columns = ["Mã Khách Hàng", "Họ Tên", "Tổng Chi Tiêu"]

            st.dataframe(display_df, use_container_width=True, hide_index=True)

        elif result is not None:
            st.warning(
                f"⚠️ Không tìm thấy tài khoản nào có chi tiêu từ {format_currency(min_spending)} trở lên"
            )


# =============================================================================
# PAGE: TRIGGER DEMO
# =============================================================================

# Demo data constants (using unique identifiers for lookup)
DEMO_EMAIL = "demo_trigger@test.com"
DEMO_PHONE = "0999999999"


def get_demo_customer_id():
    """Get demo customer ID by email (via TaiKhoanThanhVien)."""
    res = execute_query(
        "SELECT MaKhachHang FROM TaiKhoanThanhVien WHERE Email = ?", (DEMO_EMAIL,)
    )
    if res is not None and not res.empty:
        return int(res.iloc[0]["MaKhachHang"])
    return None


def get_demo_account_id():
    """Get demo account ID."""
    res = execute_query(
        "SELECT MaTaiKhoan FROM TaiKhoanThanhVien WHERE Email = ?", (DEMO_EMAIL,)
    )
    if res is not None and not res.empty:
        return int(res.iloc[0]["MaTaiKhoan"])
    return None


def get_demo_transaction_id(customer_id):
    """Get latest demo transaction ID."""
    if not customer_id:
        return None
    res = execute_query(
        "SELECT TOP 1 MaGiaoDich FROM GiaoDich WHERE MaKhachHang = ? ORDER BY ThoiDiemBatDau DESC",
        (customer_id,),
    )
    if res is not None and not res.empty:
        return int(res.iloc[0]["MaGiaoDich"])
    return None


def get_demo_ticket_id(transaction_id):
    """Get demo ticket ID."""
    if not transaction_id:
        return None
    res = execute_query(
        "SELECT TOP 1 MaVe FROM Ve WHERE MaGiaoDich = ?", (transaction_id,)
    )
    if res is not None and not res.empty:
        return int(res.iloc[0]["MaVe"])
    return None


def check_demo_data_exists():
    """Check if demo data already exists."""
    return get_demo_customer_id() is not None


def delete_demo_data():
    """Delete all demo data."""
    cust_id = get_demo_customer_id()
    if not cust_id:
        return

    # Find related records
    acc_id = get_demo_account_id()
    trans_id = get_demo_transaction_id(cust_id)

    if trans_id:
        execute_query("DELETE FROM Ve WHERE MaGiaoDich = ?", (trans_id,), fetch=False)
        execute_query(
            "DELETE FROM GiaoDich WHERE MaGiaoDich = ?", (trans_id,), fetch=False
        )

    if acc_id:
        execute_query(
            "DELETE FROM TaiKhoanThanhVien WHERE MaTaiKhoan = ?", (acc_id,), fetch=False
        )

    execute_query(
        "DELETE FROM KhachHang WHERE MaKhachHang = ?", (cust_id,), fetch=False
    )


def get_demo_account_data():
    """Get demo account data as DataFrame."""
    acc_id = get_demo_account_id()
    if not acc_id:
        return None
    return execute_query(
        """SELECT MaTaiKhoan, MaKhachHang, TenDangNhap, CapDoTaiKhoan, TongChiTieuLuyKe 
           FROM TaiKhoanThanhVien WHERE MaTaiKhoan = ?""",
        (acc_id,),
    )


def get_demo_transaction_data():
    """Get demo transaction data as DataFrame."""
    cust_id = get_demo_customer_id()
    trans_id = get_demo_transaction_id(cust_id)
    if not trans_id:
        return None
    return execute_query(
        """SELECT MaGiaoDich, MaKhachHang, TrangThai, KenhThanhToan, PhuongThuc 
           FROM GiaoDich WHERE MaGiaoDich = ?""",
        (trans_id,),
    )


def get_demo_ticket_data():
    """Get demo ticket data as DataFrame."""
    cust_id = get_demo_customer_id()
    trans_id = get_demo_transaction_id(cust_id)
    ticket_id = get_demo_ticket_id(trans_id)
    if not ticket_id:
        return None
    return execute_query(
        """SELECT MaVe, MaGiaoDich, MaGhe, TrangThai, GiaChuan, GiaSauUuDai 
           FROM Ve WHERE MaVe = ?""",
        (ticket_id,),
    )


def page_trigger_demo():
    st.header("⚡ Demo Trigger")

    st.info("""
    Trang này dùng để minh họa hoạt động của 2 trigger trong database:
    
    1. **trg_UpdateTongChiTieuLuyKe**: Tự động cập nhật tổng chi tiêu lũy kế khi trạng thái thanh toán thay đổi
    2. **trg_CheckTuoiXemPhim**: Kiểm tra tuổi - ngăn mua vé nếu khách hàng chưa đủ tuổi xem phim
    """)

    tab1, tab2 = st.tabs(["💰 Trigger Cập Nhật Chi Tiêu", "👶 Trigger Kiểm Tra Tuổi"])

    with tab1:
        st.subheader("Trigger: trg_UpdateTongChiTieuLuyKe")

        st.markdown("""
        **Mô tả:** Trigger này được kích hoạt sau khi cập nhật bảng `GiaoDich`. 
        - Khi trạng thái giao dịch chuyển **thành** `Đã thanh toán` → **Cộng** tiền vé vào `TongChiTieuLuyKe`
        - Khi trạng thái giao dịch chuyển **từ** `Đã thanh toán` sang trạng thái khác → **Trừ** tiền vé khỏi `TongChiTieuLuyKe`
        """)

        st.divider()

        # Check current state
        demo_exists = check_demo_data_exists()

        # =================================================================
        # STEP 1: CREATE DEMO DATA
        # =================================================================
        st.markdown("### 🔧 Bước 1: Tạo dữ liệu demo")

        if demo_exists:
            st.success(
                "✅ Dữ liệu demo đã tồn tại. Chuyển sang Bước 2 để thực hiện demo, hoặc xóa dữ liệu ở Bước 3 để tạo lại."
            )
        else:
            st.markdown("""
            Nhấn nút bên dưới để tạo dữ liệu demo. Các bản ghi sau sẽ được **INSERT** vào database:
            
            | Bảng | Mô tả dữ liệu |
            |:-----|:--------------|
            | `KhachHang` | 1 khách hàng mới (Email: `demo_trigger@test.com`) |
            | `TaiKhoanThanhVien` | 1 tài khoản thành viên với **TongChiTieuLuyKe = 0** |
            | `GiaoDich` | 1 giao dịch với trạng thái **'Tạm giữ'** (chưa thanh toán) |
            | `Ve` | 1 vé với giá **150,000 VNĐ** |
            """)

            if st.button(
                "🚀 INSERT dữ liệu demo vào database", type="primary", key="create_demo"
            ):
                try:
                    # Get first available showtime for demo
                    showtime = execute_query("""
                        SELECT TOP 1 sc.MaSuatChieu, sc.MaPhim, g.MaGhe, sc.MaRap, sc.MaPhongChieu
                        FROM SuatChieu sc
                        JOIN Ghe g ON sc.MaRap = g.MaRap AND sc.MaPhongChieu = g.MaPhongChieu
                        WHERE sc.TrangThai = N'Mở bán'
                    """)

                    if showtime is None or showtime.empty:
                        st.error("❌ Không tìm thấy suất chiếu nào đang mở bán!")
                    else:
                        sc = showtime.iloc[0]

                        # Create demo customer
                        execute_query(
                            """
                            INSERT INTO KhachHang (HoTen, LoaiKhachHang) 
                            VALUES (N'Demo User - Trigger Test', N'Thành viên')
                        """,
                            fetch=False,
                        )

                        # Get the newly created customer ID
                        cust_res = execute_query(
                            "SELECT TOP 1 MaKhachHang FROM KhachHang WHERE HoTen = N'Demo User - Trigger Test' ORDER BY MaKhachHang DESC"
                        )
                        cust_id = (
                            int(cust_res.iloc[0]["MaKhachHang"])
                            if cust_res is not None and not cust_res.empty
                            else None
                        )

                        if cust_id is None:
                            st.error("❌ Không thể tạo khách hàng demo!")
                        else:
                            # Create demo account with 0 spending
                            execute_query(
                                """
                                INSERT INTO TaiKhoanThanhVien 
                                (MaKhachHang, TenDangNhap, CapDoTaiKhoan, NgaySinh, GioiTinh, 
                                 SoDienThoai, Email, RapYeuThich, TongChiTieuLuyKe, TrangThaiHoatDong)
                                VALUES (?, 'demo_trigger_user', 'Member', '1990-01-01', N'Nam', 
                                        ?, ?, N'CGV Demo', 0, 1)
                            """,
                                (cust_id, DEMO_PHONE, DEMO_EMAIL),
                                fetch=False,
                            )

                            # Create demo transaction with status 'Tạm giữ'
                            execute_query(
                                """
                                INSERT INTO GiaoDich 
                                (MaKhachHang, ThoiDiemBatDau, ThoiDiemKetThuc, 
                                 KenhThanhToan, TrangThai, PhuongThuc)
                                VALUES (?, GETDATE(), GETDATE(), N'Tiền mặt', N'Tạm giữ', 'Offline')
                            """,
                                (cust_id,),
                                fetch=False,
                            )

                            trans_id = get_demo_transaction_id(cust_id)
                            # Convert trans_id to native Python int
                            trans_id = int(trans_id) if trans_id is not None else None

                            # Create demo ticket worth 150,000 VND
                            execute_query(
                                """
                                INSERT INTO Ve 
                                (MaGhe, TrangThai, GiaChuan, GiaSauUuDai, PhuThu,
                                 MaGiaoDich, MaPhim, MaSuatChieu, ThoiDiemXuatVe)
                                VALUES (?, N'Tạm giữ', 150000, 150000, 0, ?, ?, ?, GETDATE())
                            """,
                                (
                                    str(sc["MaGhe"]),
                                    trans_id,
                                    int(sc["MaPhim"]),
                                    int(sc["MaSuatChieu"]),
                                ),
                                fetch=False,
                            )

                            st.success("✅ Đã INSERT dữ liệu demo thành công!")
                            st.rerun()

                except Exception as e:
                    st.error(f"❌ Lỗi khi tạo dữ liệu demo: {e}")

        # =================================================================
        # STEP 2: DEMO THE TRIGGER (only if demo data exists)
        # =================================================================
        if demo_exists:
            st.divider()
            st.markdown("### 🧪 Bước 2: Demo Trigger")

            cust_id = get_demo_customer_id()
            trans_id = get_demo_transaction_id(cust_id)

            # --- Query buttons ---
            st.markdown("#### 🔍 Truy vấn dữ liệu hiện tại")
            st.markdown(
                "Nhấn các nút bên dưới để thực hiện `SELECT` và xem dữ liệu thực tế từ database:"
            )

            col1, col2, col3 = st.columns(3)

            with col1:
                if st.button(
                    "📋 SELECT TaiKhoanThanhVien",
                    key="query_account",
                    use_container_width=True,
                ):
                    st.session_state.show_account = True
            with col2:
                if st.button(
                    "📋 SELECT GiaoDich",
                    key="query_transaction",
                    use_container_width=True,
                ):
                    st.session_state.show_transaction = True
            with col3:
                if st.button(
                    "📋 SELECT Ve", key="query_ticket", use_container_width=True
                ):
                    st.session_state.show_ticket = True

            # Display query results
            if st.session_state.get("show_account", False):
                st.markdown(
                    "**Bảng `TaiKhoanThanhVien`** (chú ý cột `TongChiTieuLuyKe`):"
                )
                account_df = get_demo_account_data()
                if account_df is not None and not account_df.empty:
                    st.dataframe(account_df, use_container_width=True, hide_index=True)

            if st.session_state.get("show_transaction", False):
                st.markdown("**Bảng `GiaoDich`** (chú ý cột `TrangThai`):")
                transaction_df = get_demo_transaction_data()
                if transaction_df is not None and not transaction_df.empty:
                    st.dataframe(
                        transaction_df, use_container_width=True, hide_index=True
                    )

            if st.session_state.get("show_ticket", False):
                st.markdown("**Bảng `Ve`** (chú ý cột `GiaSauUuDai`):")
                ticket_df = get_demo_ticket_data()
                if ticket_df is not None and not ticket_df.empty:
                    st.dataframe(ticket_df, use_container_width=True, hide_index=True)

            st.markdown("---")

            # --- UPDATE buttons ---
            st.markdown("#### ⚡ Thực hiện UPDATE để kích hoạt Trigger")

            # Get current transaction status
            transaction_df = get_demo_transaction_data()
            current_status = (
                transaction_df.iloc[0]["TrangThai"]
                if transaction_df is not None and not transaction_df.empty
                else None
            )

            col1, col2 = st.columns(2)

            with col1:
                st.markdown(f"""
                **Thanh toán giao dịch:**
                ```sql
                UPDATE GiaoDich 
                SET TrangThai = N'Đã thanh toán' 
                WHERE MaGiaoDich = {trans_id}
                ```
                *Kỳ vọng: Trigger sẽ **cộng** 150,000 VNĐ vào `TongChiTieuLuyKe`*
                """)
                if current_status == "Tạm giữ":
                    if st.button(
                        "▶️ Chạy UPDATE (Thanh toán)",
                        type="primary",
                        key="confirm_payment",
                    ):
                        execute_query(
                            "UPDATE GiaoDich SET TrangThai = N'Đã thanh toán' WHERE MaGiaoDich = ?",
                            (trans_id,),
                            fetch=False,
                        )
                        st.success("✅ UPDATE thành công! Trigger đã được kích hoạt.")
                        st.session_state.show_account = True
                        st.session_state.show_transaction = True
                        st.rerun()
                elif current_status == "Đã thanh toán":
                    st.info("ℹ️ Giao dịch đã ở trạng thái 'Đã thanh toán'")
                else:
                    st.warning(f"⚠️ Trạng thái hiện tại: {current_status}")

            with col2:
                st.markdown(f"""
                **Hủy giao dịch (hoàn tiền):**
                ```sql
                UPDATE GiaoDich 
                SET TrangThai = N'Hủy' 
                WHERE MaGiaoDich = {trans_id}
                ```
                *Kỳ vọng: Trigger sẽ **trừ** 150,000 VNĐ khỏi `TongChiTieuLuyKe`*
                """)
                if current_status == "Đã thanh toán":
                    if st.button(
                        "▶️ Chạy UPDATE (Hủy)", type="secondary", key="cancel_payment"
                    ):
                        execute_query(
                            "UPDATE GiaoDich SET TrangThai = N'Hủy' WHERE MaGiaoDich = ?",
                            (trans_id,),
                            fetch=False,
                        )
                        st.success("✅ UPDATE thành công! Trigger đã được kích hoạt.")
                        st.session_state.show_account = True
                        st.session_state.show_transaction = True
                        st.rerun()
                elif current_status == "Hủy":
                    st.info("ℹ️ Giao dịch đã bị hủy")
                else:
                    st.info("ℹ️ Cần thanh toán trước mới có thể hủy")

            # =================================================================
            # STEP 3: CLEANUP
            # =================================================================
            st.divider()
            st.markdown("### 🗑️ Bước 3: Xóa dữ liệu demo")

            st.markdown("""
            Sau khi demo xong, nhấn nút bên dưới để **DELETE** tất cả dữ liệu demo khỏi database.
            Nếu muốn demo lại, hãy quay lại Bước 1 để tạo dữ liệu mới.
            """)

            if st.button("🗑️ DELETE dữ liệu demo", type="secondary", key="delete_demo"):
                delete_demo_data()
                # Clear session state
                st.session_state.show_account = False
                st.session_state.show_transaction = False
                st.session_state.show_ticket = False
                st.success("✅ Đã DELETE tất cả dữ liệu demo")
                st.rerun()

        # =================================================================
        # SQL CODE REFERENCE
        # =================================================================
        st.divider()
        with st.expander("📝 Xem mã SQL của Trigger"):
            st.code(
                """
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

    -- Cộng tiền khi chuyển THÀNH 'Đã thanh toán'
    INSERT INTO @Adjustments (MaTaiKhoan, AdjustmentAmount)
    SELECT tk.MaTaiKhoan, SUM(v.GiaSauUuDai) AS TotalAdjustment
    FROM inserted i
    JOIN TaiKhoanThanhVien tk ON i.MaKhachHang = tk.MaKhachHang
    LEFT JOIN deleted d ON i.MaGiaoDich = d.MaGiaoDich
    JOIN Ve v ON i.MaGiaoDich = v.MaGiaoDich
    WHERE i.TrangThai = N'Đã thanh toán'
      AND (d.TrangThai IS NULL OR d.TrangThai <> N'Đã thanh toán')
    GROUP BY tk.MaTaiKhoan;

    -- Trừ tiền khi chuyển TỪ 'Đã thanh toán' sang trạng thái khác
    INSERT INTO @Adjustments (MaTaiKhoan, AdjustmentAmount)
    SELECT tk.MaTaiKhoan, -SUM(v.GiaSauUuDai) AS TotalAdjustment
    FROM deleted d
    JOIN TaiKhoanThanhVien tk ON d.MaKhachHang = tk.MaKhachHang
    JOIN inserted i ON d.MaGiaoDich = i.MaGiaoDich
    JOIN Ve v ON d.MaGiaoDich = v.MaGiaoDich
    WHERE d.TrangThai = N'Đã thanh toán'
      AND i.TrangThai <> N'Đã thanh toán'
    GROUP BY tk.MaTaiKhoan;

    -- Áp dụng thay đổi
    UPDATE tk
    SET tk.TongChiTieuLuyKe = tk.TongChiTieuLuyKe + adj.TotalAmount
    FROM TaiKhoanThanhVien tk
    JOIN (
        SELECT MaTaiKhoan, SUM(AdjustmentAmount) AS TotalAmount
        FROM @Adjustments
        GROUP BY MaTaiKhoan
    ) AS adj ON tk.MaTaiKhoan = adj.MaTaiKhoan;
END
            """,
                language="sql",
            )

    with tab2:
        st.subheader("Trigger: trg_CheckTuoiXemPhim")

        st.markdown("""
        **Mô tả:** Trigger này được kích hoạt khi INSERT hoặc UPDATE bảng `Ve`. 
        Nó kiểm tra xem khách hàng thành viên có đủ tuổi để xem phim không.
        Nếu không đủ tuổi, giao dịch sẽ bị **ROLLBACK** (hủy toàn bộ transaction).
        """)

        st.divider()

        # Demo constants for age check trigger
        AGE_DEMO_MOVIE_TITLE = "Phim Demo 18+ (T18)"
        AGE_DEMO_RAP_ID = "RAPAG"
        AGE_DEMO_ADULT_EMAIL = "adult@demo.com"
        AGE_DEMO_MINOR_EMAIL = "minor@demo.com"

        def get_age_demo_movie_id():
            res = execute_query(
                "SELECT MaPhim FROM Phim WHERE TuaDe = ?", (AGE_DEMO_MOVIE_TITLE,)
            )
            if res is not None and not res.empty:
                return int(res.iloc[0]["MaPhim"])
            return None

        def get_age_demo_customer_id(email):
            res = execute_query(
                "SELECT MaKhachHang FROM TaiKhoanThanhVien WHERE Email = ?", (email,)
            )
            if res is not None and not res.empty:
                return int(res.iloc[0]["MaKhachHang"])
            return None

        def check_age_demo_exists():
            return get_age_demo_movie_id() is not None

        def delete_age_demo_data():
            movie_id = get_age_demo_movie_id()
            adult_id = get_age_demo_customer_id(AGE_DEMO_ADULT_EMAIL)
            minor_id = get_age_demo_customer_id(AGE_DEMO_MINOR_EMAIL)

            if movie_id:
                execute_query(
                    "DELETE FROM Ve WHERE MaPhim = ?", (movie_id,), fetch=False
                )
                execute_query(
                    "DELETE FROM SuatChieu WHERE MaPhim = ?", (movie_id,), fetch=False
                )
                execute_query(
                    "DELETE FROM Phim WHERE MaPhim = ?", (movie_id,), fetch=False
                )

            if adult_id:
                execute_query(
                    "DELETE FROM GiaoDich WHERE MaKhachHang = ?",
                    (adult_id,),
                    fetch=False,
                )
                execute_query(
                    "DELETE FROM TaiKhoanThanhVien WHERE MaKhachHang = ?",
                    (adult_id,),
                    fetch=False,
                )
                execute_query(
                    "DELETE FROM KhachHang WHERE MaKhachHang = ?",
                    (adult_id,),
                    fetch=False,
                )

            if minor_id:
                execute_query(
                    "DELETE FROM GiaoDich WHERE MaKhachHang = ?",
                    (minor_id,),
                    fetch=False,
                )
                execute_query(
                    "DELETE FROM TaiKhoanThanhVien WHERE MaKhachHang = ?",
                    (minor_id,),
                    fetch=False,
                )
                execute_query(
                    "DELETE FROM KhachHang WHERE MaKhachHang = ?",
                    (minor_id,),
                    fetch=False,
                )

            execute_query(
                "DELETE FROM Ghe WHERE MaRap = ?", (AGE_DEMO_RAP_ID,), fetch=False
            )
            execute_query(
                "DELETE FROM PhongChieu WHERE MaRap = ?",
                (AGE_DEMO_RAP_ID,),
                fetch=False,
            )
            execute_query(
                "DELETE FROM RapChieuPhim WHERE MaRap = ?",
                (AGE_DEMO_RAP_ID,),
                fetch=False,
            )

        age_demo_exists = check_age_demo_exists()

        # =================================================================
        # STEP 1: CREATE DEMO DATA
        # =================================================================
        st.markdown("### 🔧 Bước 1: Tạo dữ liệu demo")

        if age_demo_exists:
            st.success(
                "✅ Dữ liệu demo đã tồn tại. Chuyển sang Bước 2 để thực hiện demo, hoặc xóa dữ liệu ở Bước 3 để tạo lại."
            )
        else:
            st.markdown("""
            Nhấn nút bên dưới để tạo dữ liệu demo. Các bản ghi sau sẽ được **INSERT** vào database:
            
            | Bảng | Mô tả dữ liệu |
            |:-----|:--------------|
            | `Phim` | 1 phim **T18** (giới hạn 18 tuổi) |
            | `RapChieuPhim` | 1 rạp chiếu demo |
            | `PhongChieu` | 1 phòng chiếu |
            | `Ghe` | 2 ghế (A1, A2) |
            | `SuatChieu` | 1 suất chiếu vào ngày mai |
            | `KhachHang` | 2 khách hàng: 1 người lớn (35 tuổi) và 1 trẻ vị thành niên (15 tuổi) |
            | `TaiKhoanThanhVien` | 2 tài khoản thành viên với ngày sinh tương ứng |
            """)

            if st.button(
                "🚀 INSERT dữ liệu demo vào database",
                type="primary",
                key="create_age_demo",
            ):
                try:
                    # Create 18+ movie
                    execute_query(
                        """
                        INSERT INTO Phim (TuaDe, GioiHanDoTuoi, ThoiLuong, TrangThaiPhatHanh, NgayKhoiChieu_ChinhThuc)
                        VALUES (?, 18, '02:00:00', N'Đang chiếu', '2025-01-01')
                    """,
                        (AGE_DEMO_MOVIE_TITLE,),
                        fetch=False,
                    )

                    movie_id = get_age_demo_movie_id()

                    # Create demo cinema
                    execute_query(
                        """
                        INSERT INTO RapChieuPhim (MaRap, TenRap, DiaChi_ChiTiet, TinhThanh, NgayKhaiTruong, 
                                                   ThoiGianMoCua, ThoiGianDongCua, MoTaTongQuan, TrangThaiHoatDong)
                        VALUES (?, 'CGV Demo Age Check', N'123 Demo Street', 'TP.HCM', '2020-01-01', 
                                '08:00', '23:59', 'Demo Cinema', N'Hoạt động')
                    """,
                        (AGE_DEMO_RAP_ID,),
                        fetch=False,
                    )

                    # Create room
                    execute_query(
                        """
                        INSERT INTO PhongChieu (MaPhong, MaRap, SucChua, LoaiPhong, TenHienThi) 
                        VALUES (1, ?, 100, '2D', N'Phòng Demo 01')
                    """,
                        (AGE_DEMO_RAP_ID,),
                        fetch=False,
                    )

                    # Create 2 seats
                    execute_query(
                        """
                        INSERT INTO Ghe (MaGhe, MaRap, MaPhongChieu, So, Hang, TrangThai, Loai) 
                        VALUES ('A1', ?, 1, 1, 'A', N'Hoạt động', 'Normal')
                    """,
                        (AGE_DEMO_RAP_ID,),
                        fetch=False,
                    )
                    execute_query(
                        """
                        INSERT INTO Ghe (MaGhe, MaRap, MaPhongChieu, So, Hang, TrangThai, Loai) 
                        VALUES ('A2', ?, 1, 2, 'A', N'Hoạt động', 'Normal')
                    """,
                        (AGE_DEMO_RAP_ID,),
                        fetch=False,
                    )

                    # Create showtime for tomorrow
                    execute_query(
                        """
                        INSERT INTO SuatChieu (MaPhim, MaRap, MaPhongChieu, NgayChieu, 
                                               DinhDangChieu, NgonNgu, TrangThai, HinhThucDichThuat, GioBatDau)
                        VALUES (?, ?, 1, DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 
                                '2D', N'Anh', N'Mở bán', 'PhuDe', '21:00:00')
                    """,
                        (movie_id, AGE_DEMO_RAP_ID),
                        fetch=False,
                    )

                    # Create adult customer (35 years old, born 1990)
                    execute_query(
                        """
                        INSERT INTO KhachHang (HoTen, LoaiKhachHang)
                        VALUES (N'Nguyễn Văn A', N'Thành viên')
                    """,
                        fetch=False,
                    )
                    # Get the newly created customer ID
                    adult_res = execute_query(
                        "SELECT TOP 1 MaKhachHang FROM KhachHang WHERE HoTen = N'Nguyễn Văn A' ORDER BY MaKhachHang DESC"
                    )
                    adult_id = (
                        int(adult_res.iloc[0]["MaKhachHang"])
                        if adult_res is not None and not adult_res.empty
                        else None
                    )

                    execute_query(
                        """
                        INSERT INTO TaiKhoanThanhVien 
                        (MaKhachHang, TenDangNhap, CapDoTaiKhoan, NgaySinh, GioiTinh, 
                         SoDienThoai, Email, RapYeuThich, TongChiTieuLuyKe, TrangThaiHoatDong)
                        VALUES (?, 'adult_demo_user', 'VIP', '1990-01-15', N'Nam', 
                                '0911111111', ?, N'CGV Demo', 0, 1)
                    """,
                        (adult_id, AGE_DEMO_ADULT_EMAIL),
                        fetch=False,
                    )

                    # Create minor customer (15 years old, born 2010)
                    execute_query(
                        """
                        INSERT INTO KhachHang (HoTen, LoaiKhachHang)
                        VALUES (N'Trần Thị B', N'Thành viên')
                    """,
                        fetch=False,
                    )
                    # Get the newly created customer ID
                    minor_res = execute_query(
                        "SELECT TOP 1 MaKhachHang FROM KhachHang WHERE HoTen = N'Trần Thị B' ORDER BY MaKhachHang DESC"
                    )
                    minor_id = (
                        int(minor_res.iloc[0]["MaKhachHang"])
                        if minor_res is not None and not minor_res.empty
                        else None
                    )

                    execute_query(
                        """
                        INSERT INTO TaiKhoanThanhVien 
                        (MaKhachHang, TenDangNhap, CapDoTaiKhoan, NgaySinh, GioiTinh, 
                         SoDienThoai, Email, RapYeuThich, TongChiTieuLuyKe, TrangThaiHoatDong)
                        VALUES (?, 'minor_demo_user', 'Member', '2010-06-20', N'Nữ', 
                                '0922222222', ?, N'CGV Demo', 0, 1)
                    """,
                        (minor_id, AGE_DEMO_MINOR_EMAIL),
                        fetch=False,
                    )

                    st.success("✅ Đã INSERT dữ liệu demo thành công!")
                    st.rerun()

                except Exception as e:
                    st.error(f"❌ Lỗi khi tạo dữ liệu demo: {e}")

        # =================================================================
        # STEP 2: DEMO THE TRIGGER (only if demo data exists)
        # =================================================================
        if age_demo_exists:
            st.divider()
            st.markdown("### 🧪 Bước 2: Demo Trigger")

            movie_id = get_age_demo_movie_id()
            adult_id = get_age_demo_customer_id(AGE_DEMO_ADULT_EMAIL)
            minor_id = get_age_demo_customer_id(AGE_DEMO_MINOR_EMAIL)

            # Get showtime ID
            sc_res = execute_query(
                "SELECT TOP 1 MaSuatChieu FROM SuatChieu WHERE MaPhim = ?", (movie_id,)
            )
            sc_id = (
                int(sc_res.iloc[0]["MaSuatChieu"])
                if sc_res is not None and not sc_res.empty
                else None
            )

            # --- Query buttons ---
            st.markdown("#### 🔍 Truy vấn dữ liệu hiện tại")

            col1, col2 = st.columns(2)
            with col1:
                if st.button(
                    "📋 SELECT Phim Demo", key="query_movie", use_container_width=True
                ):
                    st.session_state.show_movie = True
            with col2:
                if st.button(
                    "📋 SELECT Khách Hàng Demo",
                    key="query_customers",
                    use_container_width=True,
                ):
                    st.session_state.show_customers = True

            # Display movie info
            if st.session_state.get("show_movie", False):
                st.markdown("**Bảng `Phim`** (chú ý cột `GioiHanDoTuoi`):")
                movie_df = execute_query(
                    """
                    SELECT MaPhim, TuaDe, GioiHanDoTuoi, TrangThaiPhatHanh
                    FROM Phim WHERE MaPhim = ?
                """,
                    (movie_id,),
                )
                if movie_df is not None and not movie_df.empty:
                    st.dataframe(movie_df, use_container_width=True, hide_index=True)

            # Display customer info
            if st.session_state.get("show_customers", False):
                st.markdown(
                    "**Bảng `KhachHang` và `TaiKhoanThanhVien`** (chú ý cột `NgaySinh`):"
                )
                customers_df = execute_query(
                    """
                    SELECT kh.MaKhachHang, kh.HoTen, tk.NgaySinh, 
                           DATEDIFF(YEAR, tk.NgaySinh, GETDATE()) as Tuoi
                    FROM KhachHang kh
                    JOIN TaiKhoanThanhVien tk ON kh.MaKhachHang = tk.MaKhachHang
                    WHERE kh.MaKhachHang IN (?, ?)
                """,
                    (adult_id, minor_id),
                )
                if customers_df is not None and not customers_df.empty:
                    st.dataframe(
                        customers_df, use_container_width=True, hide_index=True
                    )

            st.markdown("---")

            # --- INSERT buttons ---
            st.markdown("#### ⚡ Thực hiện INSERT để kích hoạt Trigger")

            # Display persisted messages from session state
            if st.session_state.get("age_adult_success_msg"):
                st.success(st.session_state["age_adult_success_msg"])
                del st.session_state["age_adult_success_msg"]
            if st.session_state.get("age_minor_warning_msg"):
                st.warning(st.session_state["age_minor_warning_msg"])
                del st.session_state["age_minor_warning_msg"]
            if st.session_state.get("age_minor_error_msg"):
                st.error(st.session_state["age_minor_error_msg"])
                del st.session_state["age_minor_error_msg"]
            if st.session_state.get("age_minor_info_msg"):
                st.info(st.session_state["age_minor_info_msg"])
                del st.session_state["age_minor_info_msg"]
            if st.session_state.get("age_minor_success_msg"):
                st.success(st.session_state["age_minor_success_msg"])
                del st.session_state["age_minor_success_msg"]

            col1, col2 = st.columns(2)

            with col1:
                st.markdown("""
                **🧑 Mua vé cho khách hàng 35 tuổi:**
                ```sql
                INSERT INTO GiaoDich (...) 
                INSERT INTO Ve (...) -- Vé phim T18
                ```
                *Kỳ vọng: ✅ INSERT **THÀNH CÔNG** (đủ 18 tuổi)*
                """)

                # Check if adult ticket already exists
                adult_ticket = execute_query(
                    """
                    SELECT COUNT(*) as cnt FROM Ve v
                    JOIN GiaoDich gd ON v.MaGiaoDich = gd.MaGiaoDich
                    WHERE gd.MaKhachHang = ? AND v.MaPhim = ?
                """,
                    (adult_id, movie_id),
                )
                adult_exists = (
                    adult_ticket is not None
                    and not adult_ticket.empty
                    and adult_ticket.iloc[0]["cnt"] > 0
                )

                if adult_exists:
                    st.success("✅ Vé đã được mua thành công!")
                else:
                    if st.button(
                        "▶️ INSERT vé cho người lớn (35 tuổi)",
                        type="primary",
                        key="buy_adult",
                    ):
                        try:
                            # Execute both INSERTs in a single transaction
                            # Note: We need to get the generated GiaoDich ID to insert into Ve
                            # Since we can't easily do that in one batch with pyodbc without stored proc,
                            # we will insert GiaoDich, get ID, then insert Ve.
                            # BUT, if we do that separately, the trigger on Ve won't rollback GiaoDich automatically unless we use a transaction.

                            # We will use a stored procedure or a single batch script for atomicity

                            sql_script = """
                            BEGIN TRANSACTION;
                            BEGIN TRY
                                DECLARE @NewTransID INT;
                                
                                INSERT INTO GiaoDich (MaKhachHang, ThoiDiemBatDau, ThoiDiemKetThuc, 
                                                      KenhThanhToan, TrangThai, PhuongThuc)
                                VALUES (?, GETDATE(), GETDATE(), N'Tiền mặt', N'Tạm giữ', 'Online');
                                
                                SET @NewTransID = SCOPE_IDENTITY();
                                
                                INSERT INTO Ve (MaGhe, TrangThai, GiaChuan, GiaSauUuDai, PhuThu,
                                                MaGiaoDich, MaPhim, MaSuatChieu, ThoiDiemXuatVe)
                                VALUES ('A1', N'Tạm giữ', 100000, 100000, 0, 
                                        @NewTransID, ?, ?, GETDATE());
                                        
                                COMMIT TRANSACTION;
                            END TRY
                            BEGIN CATCH
                                ROLLBACK TRANSACTION;
                                THROW;
                            END CATCH
                            """

                            execute_query(
                                sql_script,
                                (adult_id, movie_id, sc_id),
                                fetch=False,
                                raise_on_error=True,
                            )

                            st.session_state["age_adult_success_msg"] = (
                                "✅ INSERT thành công! Khách hàng 35 tuổi ĐỦ TUỔI xem phim T18."
                            )
                            st.rerun()

                        except Exception as e:
                            st.error(f"❌ INSERT thất bại: {e}")

            with col2:
                st.markdown("""
                **👶 Mua vé cho khách hàng 15 tuổi:**
                ```sql
                INSERT INTO GiaoDich (...) 
                INSERT INTO Ve (...) -- Vé phim T18
                ```
                *Kỳ vọng: ❌ INSERT **THẤT BẠI** + ROLLBACK (chưa đủ 18 tuổi)*
                """)

                # Check if minor ticket exists (it shouldn't due to trigger)
                minor_ticket = execute_query(
                    """
                    SELECT COUNT(*) as cnt FROM Ve v
                    JOIN GiaoDich gd ON v.MaGiaoDich = gd.MaGiaoDich
                    WHERE gd.MaKhachHang = ? AND v.MaPhim = ?
                """,
                    (minor_id, movie_id),
                )
                minor_exists = (
                    minor_ticket is not None
                    and not minor_ticket.empty
                    and minor_ticket.iloc[0]["cnt"] > 0
                )

                if minor_exists:
                    st.warning("⚠️ Vé đã tồn tại (trigger không hoạt động đúng?)")
                else:
                    if st.button(
                        "▶️ INSERT vé cho trẻ vị thành niên (15 tuổi)",
                        type="secondary",
                        key="buy_minor",
                    ):
                        try:
                            sql_script = """
                            BEGIN TRANSACTION;
                            BEGIN TRY
                                DECLARE @NewTransID INT;
                                
                                INSERT INTO GiaoDich (MaKhachHang, ThoiDiemBatDau, ThoiDiemKetThuc, 
                                                      KenhThanhToan, TrangThai, PhuongThuc)
                                VALUES (?, GETDATE(), GETDATE(), N'Tiền mặt', N'Tạm giữ', 'Online');
                                
                                SET @NewTransID = SCOPE_IDENTITY();
                                
                                INSERT INTO Ve (MaGhe, TrangThai, GiaChuan, GiaSauUuDai, PhuThu,
                                                MaGiaoDich, MaPhim, MaSuatChieu, ThoiDiemXuatVe)
                                VALUES ('A2', N'Tạm giữ', 100000, 100000, 0, 
                                        @NewTransID, ?, ?, GETDATE());
                                        
                                COMMIT TRANSACTION;
                            END TRY
                            BEGIN CATCH
                                ROLLBACK TRANSACTION;
                                THROW;
                            END CATCH
                            """

                            execute_query(
                                sql_script,
                                (minor_id, movie_id, sc_id),
                                fetch=False,
                                raise_on_error=True,
                            )

                            st.session_state["age_minor_warning_msg"] = (
                                "⚠️ INSERT thành công? Trigger có thể không hoạt động đúng."
                            )
                            st.rerun()

                        except Exception as e:
                            error_msg = str(e)
                            if (
                                "tuổi" in error_msg.lower()
                                or "age" in error_msg.lower()
                                or "50001" in error_msg
                            ):
                                st.session_state["age_minor_error_msg"] = (
                                    "🔥 **TRIGGER ĐÃ CHẶN GIAO DỊCH!**"
                                )
                                st.session_state["age_minor_info_msg"] = (
                                    f"Lỗi từ trigger: `{error_msg}`"
                                )
                                st.session_state["age_minor_success_msg"] = (
                                    "✅ Đây là kết quả mong đợi - khách hàng 15 tuổi KHÔNG được mua vé phim T18!"
                                )
                                st.rerun()
                            else:
                                st.error(f"❌ Lỗi: {e}")

            # Show current transactions and tickets
            st.markdown("---")
            st.markdown("#### 📊 Kiểm tra kết quả trong bảng `GiaoDich` và `Ve`")

            if st.button("🔍 SELECT giao dịch và vé (demo)", key="check_tickets"):
                # Show GiaoDich (transactions) table
                st.markdown("**Bảng `GiaoDich`** (giao dịch của các tài khoản demo):")
                transactions_df = execute_query(
                    """
                    SELECT gd.MaGiaoDich, gd.MaKhachHang, kh.HoTen, gd.TrangThai, gd.ThoiDiemBatDau
                    FROM GiaoDich gd
                    JOIN KhachHang kh ON gd.MaKhachHang = kh.MaKhachHang
                    WHERE gd.MaKhachHang IN (?, ?)
                    ORDER BY gd.ThoiDiemBatDau DESC
                """,
                    (adult_id, minor_id),
                )

                if transactions_df is not None and not transactions_df.empty:
                    st.dataframe(
                        transactions_df, use_container_width=True, hide_index=True
                    )
                else:
                    st.info("Chưa có giao dịch nào.")

                # Show Ve (tickets) table
                st.markdown("**Bảng `Ve`** (vé của các tài khoản demo):")
                tickets_df = execute_query(
                    """
                    SELECT v.MaVe, v.MaGiaoDich, v.MaPhim, gd.MaKhachHang, kh.HoTen, v.TrangThai
                    FROM Ve v
                    JOIN GiaoDich gd ON v.MaGiaoDich = gd.MaGiaoDich
                    JOIN KhachHang kh ON gd.MaKhachHang = kh.MaKhachHang
                    WHERE v.MaPhim = ?
                """,
                    (movie_id,),
                )

                if tickets_df is not None and not tickets_df.empty:
                    st.dataframe(tickets_df, use_container_width=True, hide_index=True)
                else:
                    st.info("Chưa có vé nào được mua.")

            # =================================================================
            # STEP 3: CLEANUP
            # =================================================================
            st.divider()
            st.markdown("### 🗑️ Bước 3: Xóa dữ liệu demo")

            st.markdown("""
            Sau khi demo xong, nhấn nút bên dưới để **DELETE** tất cả dữ liệu demo khỏi database.
            Nếu muốn demo lại, hãy quay lại Bước 1 để tạo dữ liệu mới.
            """)

            if st.button(
                "🗑️ DELETE dữ liệu demo (Age Check)",
                type="secondary",
                key="delete_age_demo",
            ):
                delete_age_demo_data()
                st.session_state.show_movie = False
                st.session_state.show_customers = False
                st.success("✅ Đã DELETE tất cả dữ liệu demo")
                st.rerun()

        # =================================================================
        # SQL CODE REFERENCE
        # =================================================================
        st.divider()
        with st.expander("📝 Xem mã SQL của Trigger"):
            st.code(
                """
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
            """,
                language="sql",
            )


# =============================================================================
# PAGE: DATABASE INFO
# =============================================================================


def page_database_info():
    st.header("ℹ️ Thông Tin Database")

    col1, col2 = st.columns(2)

    with col1:
        st.subheader("📋 Danh sách bảng")

        # --- CHANGED SECTION START ---
        tables = execute_query("""
            SELECT name, create_date 
            FROM sys.tables 
            ORDER BY name
        """)

        if tables is not None and not tables.empty:
            # Format the date to be readable (DD/MM/YYYY)
            tables["create_date"] = pd.to_datetime(tables["create_date"]).dt.strftime(
                "%d/%m/%Y"
            )
            # Update headers to match the new simple query
            tables.columns = ["Tên Bảng", "Ngày Tạo"]
            st.dataframe(tables, use_container_width=True, hide_index=True)
        # --- CHANGED SECTION END ---

    with col2:
        st.subheader("⚙️ Stored Procedures")
        procs = execute_query("""
            SELECT name, create_date, modify_date
            FROM sys.procedures
            ORDER BY name
        """)

        if procs is not None and not procs.empty:
            procs["create_date"] = pd.to_datetime(procs["create_date"]).dt.strftime(
                "%d/%m/%Y"
            )
            procs["modify_date"] = pd.to_datetime(procs["modify_date"]).dt.strftime(
                "%d/%m/%Y"
            )
            procs.columns = ["Tên Procedure", "Ngày Tạo", "Ngày Sửa"]
            st.dataframe(procs, use_container_width=True, hide_index=True)

        st.subheader("📐 Functions")
        funcs = execute_query("""
            SELECT name, create_date
            FROM sys.objects
            WHERE type IN ('FN', 'IF', 'TF')
            ORDER BY name
        """)

        if funcs is not None and not funcs.empty:
            funcs["create_date"] = pd.to_datetime(funcs["create_date"]).dt.strftime(
                "%d/%m/%Y"
            )
            funcs.columns = ["Tên Function", "Ngày Tạo"]
            st.dataframe(funcs, use_container_width=True, hide_index=True)

        st.subheader("⚡ Triggers")
        triggers = execute_query("""
            SELECT name, parent_id, create_date
            FROM sys.triggers
            WHERE is_disabled = 0
            ORDER BY name
        """)

        if triggers is not None and not triggers.empty:
            triggers["create_date"] = pd.to_datetime(
                triggers["create_date"]
            ).dt.strftime("%d/%m/%Y")
            triggers.columns = ["Tên Trigger", "Parent ID", "Ngày Tạo"]
            st.dataframe(triggers, use_container_width=True, hide_index=True)


# =============================================================================
# MAIN APPLICATION
# =============================================================================


def main():
    st.set_page_config(
        page_title="CGV Cinema Management",
        page_icon="🎬",
        layout="wide",
        initial_sidebar_state="expanded",
    )

    # Custom CSS
    st.markdown(
        """
    <style>
    .stApp {
        max-width: 1400px;
        margin: 0 auto;
    }
    .stMetric {
        background-color: #f0f2f6;
        padding: 15px;
        border-radius: 10px;
    }
    </style>
    """,
        unsafe_allow_html=True,
    )

    # Sidebar
    st.sidebar.image(
        "https://upload.wikimedia.org/wikipedia/vi/4/43/CGV_Logo_Global_BI_V9-02.png",
        width=150,
    )
    st.sidebar.title("CGV Cinema")
    st.sidebar.markdown("---")

    # Navigation
    pages = {
        "🎬 Quản Lý Suất Chiếu": page_showtime_management,
        "📊 Thống Kê Doanh Thu": page_revenue_statistics,
        "💳 Tài Khoản Chi Tiêu Cao": page_high_spending_accounts,
        "⚡ Demo Trigger": page_trigger_demo,
        "ℹ️ Thông Tin Database": page_database_info,
    }

    selection = st.sidebar.radio("Chọn chức năng", list(pages.keys()))

    st.sidebar.markdown("---")
    st.sidebar.info("""
    **Hướng dẫn:**
    - Sử dụng menu bên trái để điều hướng
    - Mỗi trang minh họa một workflow
    - Dữ liệu được kết nối trực tiếp với SQL Server
    """)

    # Connection test
    try:
        with get_connection() as conn:
            st.sidebar.success("✅ Đã kết nối Database")
    except Exception as e:
        st.sidebar.error("❌ Lỗi kết nối Database")
        st.error(f"Không thể kết nối đến database: {e}")
        return

    # Run selected page
    pages[selection]()


if __name__ == "__main__":
    main()
