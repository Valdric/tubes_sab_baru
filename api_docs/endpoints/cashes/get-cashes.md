# GET /cashes

## Summary
Mendapatkan daftar catatan kas dengan filter dan paginasi.

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`, `CASHIER`, `KITCHEN`.

## Request
- Method: `GET`
- Path: `/api/v1/cashes`
- Query Parameters:
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `page` | `number` | `1` | Nomor halaman. |
| `per_page` | `number` | `10` | Jumlah data per halaman. |
| `search` | `string` | - | Cari berdasarkan deskripsi. |
| `type` | `string` | - | Filter tipe: `INCOME` atau `OUTCOME`. |
| `date_from` | `string` | - | Filter tanggal mulai (YYYY-MM-DD). |
| `date_to` | `string` | - | Filter tanggal akhir (YYYY-MM-DD). |

## Success Response
- Status: `200`
- Data Structure:
```json
{
  "items": [
    {
      "id": "uuid-cash-123",
      "description": "Beli sabun cuci piring",
      "amount": 25000,
      "type": "OUTCOME",
      "created_at": "2024-03-30T10:00:00.000Z"
    }
  ],
  "pagination": {
    "from": 1,
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total": 100,
    "total_pages": 10
  }
}
```
