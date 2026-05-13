# GET /cashier/menus

## Summary
Mengambil daftar menu yang dioptimalkan untuk tampilan kasir (hanya menu aktif).

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`, `CASHIER`.

## Request
- Method: `GET`
- Path: `/api/v1/cashier/menus`

## Success Response
- Status: `200`
- Data: Array of menu objects.
- Response Detail:
  - Berbeda dengan `/menus`, endpoint ini biasanya mengembalikan semua data sekaligus (tanpa pagination) untuk kebutuhan search client-side yang cepat di POS.
  - Setiap objek menu berisi: `id`, `name`, `price`, `image_url`, dan objek `category`.

## Example Response
```json
{
  "status": 200,
  "success": true,
  "message": "Data menu kasir berhasil diambil.",
  "data": [
    {
      "id": "uuid",
      "name": "Kopi Susu",
      "price": 15000,
      "image_url": "...",
      "category": { "id": "uuid-cat", "name": "Kopi" }
    }
  ],
  "errors": null
}
```
