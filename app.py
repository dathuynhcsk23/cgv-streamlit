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


def execute_query(query: str, params: tuple = None, fetch: bool = True):
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
                conn.commit()
                return True
    except Exception as e:
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
        error_msg = str(e)
        # Extract the custom error message from SQL Server
        if "[SQL Server]" in error_msg:
            start = error_msg.find("[SQL Server]") + len("[SQL Server]")
            end = (
                error_msg.find("(", start)
                if "(" in error_msg[start:]
                else len(error_msg)
            )
            clean_msg = error_msg[start:end].strip()
            st.error(f"❌ {clean_msg}")
        else:
            st.error(f"❌ Database error: {error_msg}")
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
                    - Mã phim: `{selected_row["MaPhim"]}`
                    - Mã rạp: `{selected_row["MaRap"]}`
                    - Phòng chiếu: `{selected_row["MaPhongChieu"]}`
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
                    rooms_df = get_rooms(selected_row["MaRap"])

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
                        if selected_showtime:
                            params = {
                                "MaSuatChieu": selected_row["MaSuatChieu"],
                                "MaPhim": selected_row["MaPhim"],
                                "GioBatDauMoi": new_time.strftime("%H:%M:%S")
                                if new_time
                                else None,
                                "MaPhongMoi": new_room if new_room else None,
                                "MaRap": selected_row["MaRap"],
                            }
                            result = execute_procedure(
                                "Update_ThongTinSuatChieu", params, fetch=False
                            )
                            if result:
                                st.success("✅ Cập nhật suất chiếu thành công!")
                                st.rerun()

                with col_btn2:
                    if st.button("🗑️ Xóa", type="secondary", key="btn_delete"):
                        if selected_showtime:
                            params = {
                                "MaSuatChieu": selected_row["MaSuatChieu"],
                                "MaPhim": selected_row["MaPhim"],
                            }
                            result = execute_procedure(
                                "Delete_SuatChieu", params, fetch=False
                            )
                            if result:
                                st.success("✅ Xóa suất chiếu thành công!")
                                st.rerun()

    # TAB 2: Add New Showtime
    with tab2:
        st.subheader("Thêm suất chiếu mới")

        with st.form("add_showtime_form"):
            col1, col2 = st.columns(2)

            with col1:
                new_showtime_id = st.text_input(
                    "🎫 Mã suất chiếu", placeholder="VD: SC00013", max_chars=7
                )

                movies = get_movies()
                selected_movie = st.selectbox(
                    "🎥 Chọn phim", list(movies.keys()), key="add_movie"
                )

                cinemas = get_cinemas()
                selected_cinema = st.selectbox(
                    "🏛️ Chọn rạp", list(cinemas.keys()), key="add_cinema"
                )

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
                        selected_room = None

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

            submitted = st.form_submit_button(
                "➕ Thêm suất chiếu", type="primary", use_container_width=True
            )

            if submitted:
                # Validation
                if not new_showtime_id:
                    st.error("❌ Vui lòng nhập mã suất chiếu")
                elif len(new_showtime_id) != 7:
                    st.error("❌ Mã suất chiếu phải có đúng 7 ký tự")
                elif not selected_room:
                    st.error("❌ Vui lòng chọn phòng chiếu")
                else:
                    room_id = int(selected_room.split(" - ")[0])

                    params = {
                        "MaSuatChieu": new_showtime_id,
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
                        st.success("✅ Thêm suất chiếu mới thành công!")


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

                            # Display with medals
                            medals = ["🥇", "🥈", "🥉", "4️⃣", "5️⃣"]

                            for i, row in df.iterrows():
                                medal = medals[i] if i < len(medals) else f"{i + 1}."
                                col1, col2, col3 = st.columns([1, 3, 2])

                                with col1:
                                    st.markdown(f"### {medal}")
                                with col2:
                                    st.markdown(f"**{row['TuaDe']}**")
                                    st.caption(f"Mã phim: {row['MaPhim']}")
                                with col3:
                                    st.metric(
                                        "Doanh thu", format_currency(row["DoanhThu"])
                                    )

                                st.divider()

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

# Demo data constants
DEMO_CUSTOMER_ID = "KH_DEMO_01"
DEMO_ACCOUNT_ID = "TK_DEMO_001"
DEMO_TRANSACTION_ID = "GD_DEMO01"
DEMO_TICKET_ID = "VE_DEMO01"


def check_demo_data_exists():
    """Check if demo data already exists."""
    result = execute_query(
        "SELECT COUNT(*) as cnt FROM KhachHang WHERE MaKhachHang = ?",
        (DEMO_CUSTOMER_ID,),
    )
    if result is not None and not result.empty:
        return result.iloc[0]["cnt"] > 0
    return False


def delete_demo_data():
    """Delete all demo data."""
    execute_query("DELETE FROM Ve WHERE MaVe = ?", (DEMO_TICKET_ID,), fetch=False)
    execute_query(
        "DELETE FROM GiaoDich WHERE MaGiaoDich = ?", (DEMO_TRANSACTION_ID,), fetch=False
    )
    execute_query(
        "DELETE FROM TaiKhoanThanhVien WHERE MaTaiKhoan = ?",
        (DEMO_ACCOUNT_ID,),
        fetch=False,
    )
    execute_query(
        "DELETE FROM KhachHang WHERE MaKhachHang = ?", (DEMO_CUSTOMER_ID,), fetch=False
    )


def get_demo_account_data():
    """Get demo account data as DataFrame."""
    return execute_query(
        """SELECT MaTaiKhoan, MaKhachHang, TenDangNhap, CapDoTaiKhoan, TongChiTieuLuyKe 
           FROM TaiKhoanThanhVien WHERE MaTaiKhoan = ?""",
        (DEMO_ACCOUNT_ID,),
    )


def get_demo_transaction_data():
    """Get demo transaction data as DataFrame."""
    return execute_query(
        """SELECT MaGiaoDich, MaKhachHang, TrangThai, KenhThanhToan, PhuongThuc 
           FROM GiaoDich WHERE MaGiaoDich = ?""",
        (DEMO_TRANSACTION_ID,),
    )


def get_demo_ticket_data():
    """Get demo ticket data as DataFrame."""
    return execute_query(
        """SELECT MaVe, MaGiaoDich, MaGhe, TrangThai, GiaChuan, GiaSauUuDai 
           FROM Ve WHERE MaVe = ?""",
        (DEMO_TICKET_ID,),
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
            | `KhachHang` | 1 khách hàng mới (MaKhachHang = `KH_DEMO_01`) |
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
                            INSERT INTO KhachHang (MaKhachHang, HoTen, LoaiKhachHang) 
                            VALUES (?, N'Demo User - Trigger Test', N'Thành viên')
                        """,
                            (DEMO_CUSTOMER_ID,),
                            fetch=False,
                        )

                        # Create demo account with 0 spending
                        execute_query(
                            """
                            INSERT INTO TaiKhoanThanhVien 
                            (MaTaiKhoan, MaKhachHang, TenDangNhap, CapDoTaiKhoan, NgaySinh, GioiTinh, 
                             SoDienThoai, Email, RapYeuThich, TongChiTieuLuyKe, TrangThaiHoatDong)
                            VALUES (?, ?, 'demo_trigger_user', 'Member', '1990-01-01', N'Nam', 
                                    '0999999999', 'demo_trigger@test.com', N'CGV Demo', 0, 1)
                        """,
                            (DEMO_ACCOUNT_ID, DEMO_CUSTOMER_ID),
                            fetch=False,
                        )

                        # Create demo transaction with status 'Tạm giữ'
                        execute_query(
                            """
                            INSERT INTO GiaoDich 
                            (MaGiaoDich, MaKhachHang, ThoiDiemBatDau, ThoiDiemKetThuc, 
                             KenhThanhToan, TrangThai, PhuongThuc)
                            VALUES (?, ?, GETDATE(), GETDATE(), N'Tiền mặt', N'Tạm giữ', 'Offline')
                        """,
                            (DEMO_TRANSACTION_ID, DEMO_CUSTOMER_ID),
                            fetch=False,
                        )

                        # Create demo ticket worth 150,000 VND
                        execute_query(
                            """
                            INSERT INTO Ve 
                            (MaVe, MaGhe, TrangThai, GiaChuan, GiaSauUuDai, PhuThu,
                             MaGiaoDich, MaPhim, MaSuatChieu, ThoiDiemXuatVe)
                            VALUES (?, ?, N'Tạm giữ', 150000, 150000, 0, ?, ?, ?, GETDATE())
                        """,
                            (
                                DEMO_TICKET_ID,
                                sc["MaGhe"],
                                DEMO_TRANSACTION_ID,
                                sc["MaPhim"],
                                sc["MaSuatChieu"],
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
                st.markdown("""
                **Thanh toán giao dịch:**
                ```sql
                UPDATE GiaoDich 
                SET TrangThai = N'Đã thanh toán' 
                WHERE MaGiaoDich = 'GD_DEMO01'
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
                            (DEMO_TRANSACTION_ID,),
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
                st.markdown("""
                **Hủy giao dịch (hoàn tiền):**
                ```sql
                UPDATE GiaoDich 
                SET TrangThai = N'Hủy' 
                WHERE MaGiaoDich = 'GD_DEMO01'
                ```
                *Kỳ vọng: Trigger sẽ **trừ** 150,000 VNĐ khỏi `TongChiTieuLuyKe`*
                """)
                if current_status == "Đã thanh toán":
                    if st.button(
                        "▶️ Chạy UPDATE (Hủy)", type="secondary", key="cancel_payment"
                    ):
                        execute_query(
                            "UPDATE GiaoDich SET TrangThai = N'Hủy' WHERE MaGiaoDich = ?",
                            (DEMO_TRANSACTION_ID,),
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
        MaTaiKhoan CHAR(12),
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
        # Constraints: MaPhim=CHAR(10), MaRap=CHAR(5), MaKhachHang=CHAR(11), MaTaiKhoan=CHAR(12), MaGiaoDich=CHAR(9)
        AGE_DEMO_MOVIE_ID = "PHIM_AGE01"  # 10 chars
        AGE_DEMO_RAP_ID = "RAPAG"  # 5 chars
        AGE_DEMO_ADULT_KH = "KH_ADULT_01"  # 11 chars
        AGE_DEMO_ADULT_TK = "TK_ADULT_001"  # 12 chars
        AGE_DEMO_MINOR_KH = "KH_MINOR_01"  # 11 chars
        AGE_DEMO_MINOR_TK = "TK_MINOR_001"  # 12 chars

        def check_age_demo_exists():
            result = execute_query(
                "SELECT COUNT(*) as cnt FROM Phim WHERE MaPhim = ?",
                (AGE_DEMO_MOVIE_ID,),
            )
            if result is not None and not result.empty:
                return result.iloc[0]["cnt"] > 0
            return False

        def delete_age_demo_data():
            # Delete in reverse order of dependencies
            execute_query(
                "DELETE FROM Ve WHERE MaPhim = ?", (AGE_DEMO_MOVIE_ID,), fetch=False
            )
            execute_query(
                "DELETE FROM GiaoDich WHERE MaKhachHang IN (?, ?)",
                (AGE_DEMO_ADULT_KH, AGE_DEMO_MINOR_KH),
                fetch=False,
            )
            execute_query(
                "DELETE FROM SuatChieu WHERE MaPhim = ?",
                (AGE_DEMO_MOVIE_ID,),
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
                "DELETE FROM Phim WHERE MaPhim = ?", (AGE_DEMO_MOVIE_ID,), fetch=False
            )
            execute_query(
                "DELETE FROM RapChieuPhim WHERE MaRap = ?",
                (AGE_DEMO_RAP_ID,),
                fetch=False,
            )
            execute_query(
                "DELETE FROM TaiKhoanThanhVien WHERE MaTaiKhoan IN (?, ?)",
                (AGE_DEMO_ADULT_TK, AGE_DEMO_MINOR_TK),
                fetch=False,
            )
            execute_query(
                "DELETE FROM KhachHang WHERE MaKhachHang IN (?, ?)",
                (AGE_DEMO_ADULT_KH, AGE_DEMO_MINOR_KH),
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
                        INSERT INTO Phim (MaPhim, TuaDe, GioiHanDoTuoi, ThoiLuong, TrangThaiPhatHanh, NgayKhoiChieu_ChinhThuc)
                        VALUES (?, N'Phim Demo 18+ (T18)', 18, '02:00:00', N'Đang chiếu', '2025-01-01')
                    """,
                        (AGE_DEMO_MOVIE_ID,),
                        fetch=False,
                    )

                    # Create demo cinema
                    execute_query(
                        """
                        INSERT INTO RapChieuPhim (MaRap, TenRap, DiaChi_ChiTiet, TinhThanh, NgayKhaiTruong, 
                                                   ThoiGianMoCua, ThoiGianDongCua, MoTaTongQuan, TrangThaiHoatDong, 
                                                   SoSuatChieu_MotNgay, TyLeLapDay)
                        VALUES (?, 'CGV Demo Age Check', N'123 Demo Street', 'TP.HCM', '2020-01-01', 
                                '08:00', '23:59', 'Demo Cinema', N'Hoạt động', 50, 0.7)
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

                    # Create showtime for tomorrow (MaSuatChieu = CHAR(7))
                    execute_query(
                        """
                        INSERT INTO SuatChieu (MaSuatChieu, MaPhim, MaRap, MaPhongChieu, NgayChieu, 
                                               DinhDangChieu, NgonNgu, TrangThai, HinhThucDichThuat, GioBatDau)
                        VALUES ('SC_AG01', ?, ?, 1, DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 
                                '2D', N'Anh', N'Mở bán', 'PhuDe', '21:00:00')
                    """,
                        (AGE_DEMO_MOVIE_ID, AGE_DEMO_RAP_ID),
                        fetch=False,
                    )

                    # Create adult customer (35 years old, born 1990)
                    execute_query(
                        """
                        INSERT INTO KhachHang (MaKhachHang, HoTen, LoaiKhachHang)
                        VALUES (?, N'Nguyễn Văn A', N'Thành viên')
                    """,
                        (AGE_DEMO_ADULT_KH,),
                        fetch=False,
                    )
                    execute_query(
                        """
                        INSERT INTO TaiKhoanThanhVien 
                        (MaTaiKhoan, MaKhachHang, TenDangNhap, CapDoTaiKhoan, NgaySinh, GioiTinh, 
                         SoDienThoai, Email, RapYeuThich, TongChiTieuLuyKe, TrangThaiHoatDong)
                        VALUES (?, ?, 'adult_demo_user', 'VIP', '1990-01-15', N'Nam', 
                                '0911111111', 'adult@demo.com', N'CGV Demo', 0, 1)
                    """,
                        (AGE_DEMO_ADULT_TK, AGE_DEMO_ADULT_KH),
                        fetch=False,
                    )

                    # Create minor customer (15 years old, born 2010)
                    execute_query(
                        """
                        INSERT INTO KhachHang (MaKhachHang, HoTen, LoaiKhachHang)
                        VALUES (?, N'Trần Thị B', N'Thành viên')
                    """,
                        (AGE_DEMO_MINOR_KH,),
                        fetch=False,
                    )
                    execute_query(
                        """
                        INSERT INTO TaiKhoanThanhVien 
                        (MaTaiKhoan, MaKhachHang, TenDangNhap, CapDoTaiKhoan, NgaySinh, GioiTinh, 
                         SoDienThoai, Email, RapYeuThich, TongChiTieuLuyKe, TrangThaiHoatDong)
                        VALUES (?, ?, 'minor_demo_user', 'Member', '2010-06-20', N'Nữ', 
                                '0922222222', 'minor@demo.com', N'CGV Demo', 0, 1)
                    """,
                        (AGE_DEMO_MINOR_TK, AGE_DEMO_MINOR_KH),
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
                    (AGE_DEMO_MOVIE_ID,),
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
                    (AGE_DEMO_ADULT_KH, AGE_DEMO_MINOR_KH),
                )
                if customers_df is not None and not customers_df.empty:
                    st.dataframe(
                        customers_df, use_container_width=True, hide_index=True
                    )

            st.markdown("---")

            # --- INSERT buttons ---
            st.markdown("#### ⚡ Thực hiện INSERT để kích hoạt Trigger")

            col1, col2 = st.columns(2)

            with col1:
                st.markdown("""
                **🧑 Mua vé cho khách hàng 35 tuổi:**
                ```sql
                INSERT INTO GiaoDich (...) -- MaKhachHang = 'KH_ADULT_01'
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
                    (AGE_DEMO_ADULT_KH, AGE_DEMO_MOVIE_ID),
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
                            # Create transaction (MaGiaoDich = CHAR(9))
                            execute_query(
                                """
                                INSERT INTO GiaoDich (MaGiaoDich, MaKhachHang, ThoiDiemBatDau, ThoiDiemKetThuc, 
                                                      KenhThanhToan, TrangThai, PhuongThuc)
                                VALUES ('GD_ADT_01', ?, GETDATE(), GETDATE(), N'Tiền mặt', N'Tạm giữ', 'Online')
                            """,
                                (AGE_DEMO_ADULT_KH,),
                                fetch=False,
                            )

                            # Create ticket - this triggers trg_CheckTuoiXemPhim (MaVe = CHAR(9), MaSuatChieu = CHAR(7))
                            execute_query(
                                """
                                INSERT INTO Ve (MaVe, MaGhe, TrangThai, GiaChuan, GiaSauUuDai, PhuThu,
                                                MaGiaoDich, MaPhim, MaSuatChieu, ThoiDiemXuatVe)
                                VALUES ('VE_ADT_01', 'A1', N'Tạm giữ', 100000, 100000, 0, 
                                        'GD_ADT_01', ?, 'SC_AG01', GETDATE())
                            """,
                                (AGE_DEMO_MOVIE_ID,),
                                fetch=False,
                            )

                            st.success(
                                "✅ INSERT thành công! Khách hàng 35 tuổi ĐỦ TUỔI xem phim T18."
                            )
                            st.rerun()

                        except Exception as e:
                            st.error(f"❌ INSERT thất bại: {e}")

            with col2:
                st.markdown("""
                **👶 Mua vé cho khách hàng 15 tuổi:**
                ```sql
                INSERT INTO GiaoDich (...) -- MaKhachHang = 'KH_MINOR_01'
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
                    (AGE_DEMO_MINOR_KH, AGE_DEMO_MOVIE_ID),
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
                            # Try to create transaction and ticket - should be rolled back by trigger
                            execute_query(
                                """
                                INSERT INTO GiaoDich (MaGiaoDich, MaKhachHang, ThoiDiemBatDau, ThoiDiemKetThuc, 
                                                      KenhThanhToan, TrangThai, PhuongThuc)
                                VALUES ('GD_MNR_01', ?, GETDATE(), GETDATE(), N'Tiền mặt', N'Tạm giữ', 'Online')
                            """,
                                (AGE_DEMO_MINOR_KH,),
                                fetch=False,
                            )

                            execute_query(
                                """
                                INSERT INTO Ve (MaVe, MaGhe, TrangThai, GiaChuan, GiaSauUuDai, PhuThu,
                                                MaGiaoDich, MaPhim, MaSuatChieu, ThoiDiemXuatVe)
                                VALUES ('VE_MNR_01', 'A2', N'Tạm giữ', 100000, 100000, 0, 
                                        'GD_MNR_01', ?, 'SC_AG01', GETDATE())
                            """,
                                (AGE_DEMO_MOVIE_ID,),
                                fetch=False,
                            )

                            st.warning(
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
                                st.error(f"🔥 **TRIGGER ĐÃ CHẶN GIAO DỊCH!**")
                                st.info(f"Lỗi từ trigger: `{error_msg}`")
                                st.success(
                                    "✅ Đây là kết quả mong đợi - khách hàng 15 tuổi KHÔNG được mua vé phim T18!"
                                )
                            else:
                                st.error(f"❌ Lỗi: {e}")

            # Show current tickets
            st.markdown("---")
            st.markdown("#### 📊 Kiểm tra kết quả trong bảng `Ve`")

            if st.button("🔍 SELECT * FROM Ve (demo)", key="check_tickets"):
                tickets_df = execute_query(
                    """
                    SELECT v.MaVe, v.MaPhim, gd.MaKhachHang, kh.HoTen, v.TrangThai
                    FROM Ve v
                    JOIN GiaoDich gd ON v.MaGiaoDich = gd.MaGiaoDich
                    JOIN KhachHang kh ON gd.MaKhachHang = kh.MaKhachHang
                    WHERE v.MaPhim = ?
                """,
                    (AGE_DEMO_MOVIE_ID,),
                )

                if tickets_df is not None and not tickets_df.empty:
                    st.dataframe(tickets_df, use_container_width=True, hide_index=True)
                    st.info(
                        f"Tìm thấy {len(tickets_df)} vé. Nếu trigger hoạt động đúng, chỉ có vé của khách hàng 35 tuổi."
                    )
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
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN GiaoDich gd ON i.MaGiaoDich = gd.MaGiaoDich
        JOIN TaiKhoanThanhVien tk ON gd.MaKhachHang = tk.MaKhachHang
        JOIN Phim p ON i.MaPhim = p.MaPhim
        JOIN SuatChieu sc ON i.MaSuatChieu = sc.MaSuatChieu
        WHERE DATEADD(YEAR, p.GioiHanDoTuoi, tk.NgaySinh) > sc.NgayChieu
    )
    BEGIN
        RAISERROR (N'Có khách hàng thành viên chưa đủ tuổi xem phim này!', 16, 1);
        ROLLBACK TRANSACTION;
    END
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
