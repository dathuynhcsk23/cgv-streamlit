import pyodbc

conn_str = (
    r"DRIVER={ODBC Driver 17 for SQL Server};"
    r"SERVER=localhost;"
    r"DATABASE=Movie;"
    r"Trusted_Connection=yes;"
)

try:
    with pyodbc.connect(conn_str) as conn:
        print("Successfully connected to Python!")

        cursor = conn.cursor()

        cursor.execute("SELECT name, create_date FROM sys.tables")

        rows = cursor.fetchall()
        print(f"Found {len(rows)} tables:")
        for row in rows:
            print(f"- {row.name} (ID: {row.create_date})")

except Exception as e:
    print("Error connecting:", e)
