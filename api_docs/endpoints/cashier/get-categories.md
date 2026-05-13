# GET /cashier/categories

## Summary
Get all categories (non-paginated) for offline sync.

## Auth
Bearer token required (SUPERADMIN, ADMIN, CASHIER).

## Request
- Method: GET
- Path: `/api/v1/cashier/categories`

## Success Response
- Status: 200
- Message: `Daftar kategori (Cashier) berhasil diambil.`

## Example Response
```json
{
  "status": 200,
  "success": true,
  "message": "Daftar kategori (Cashier) berhasil diambil.",
  "data": [
    {
      "id": "uuid-category",
      "name": "Kopi"
    }
  ],
  "errors": null
}
```
