# GET /reports/peak-hours

## Summary
Mengambil statistik jumlah pesanan per jam untuk mengidentifikasi jam sibuk (Peak Hours).

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`, `CASHIER`, `KITCHEN`.

## Request
- Method: `GET`
- Path: `/api/v1/reports/peak-hours`
- Query Parameters:
  | Parameter | Type | Format | Description |
  | :--- | :--- | :--- | :--- |
  | `date_from` | `string` | `YYYY-MM-DD` | Tanggal spesifik yang ingin dicek (default: hari ini). |

## Success Response
- Status: `200`
- Data Structure: Array berisi 24 objek (mewakili 00:00 s/d 23:00).
- Data Sample:
```json
[
  { "hour": "00:00", "count": 0 },
  { "hour": "01:00", "count": 0 },
  ...
  { "hour": "14:00", "count": 15 },
  { "hour": "15:00", "count": 12 },
  ...
]
```
> [!NOTE]
> Server secara otomatis menjamin kembalinya 24 jam penuh. Jika pada jam tertentu tidak ada pesanan, `count` akan bernilai `0`.
