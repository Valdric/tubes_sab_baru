# GET /reports/revenue-trend

## Summary
Mengambil data tren pendapatan harian dalam rentang waktu tertentu untuk kebutuhan grafik.

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`, `CASHIER`, `KITCHEN`.

## Request
- Method: `GET`
- Path: `/api/v1/reports/revenue-trend`
- Query Parameters:
  | Parameter | Type | Format | Default | Description |
  | :--- | :--- | :--- | :--- | :--- |
  | `date_from` | `string` | `YYYY-MM-DD` | Last 7 days | Awal rentang tren. |
  | `date_to` | `string` | `YYYY-MM-DD` | Now | Akhir rentang tren. |

## Success Response
- Status: `200`
- Data Sample:
```json
[
  { "date": "2024-03-01", "revenue": 500000 },
  { "date": "2024-03-02", "revenue": 1000000 }
]
```
> [!TIP]
> Jika tidak ada data pada tanggal tertentu, tanggal tersebut tidak akan muncul dalam array. Client-side disarankan untuk melakukan fill-in (zero-filling) jika diperlukan untuk grafik yang kontinu.
