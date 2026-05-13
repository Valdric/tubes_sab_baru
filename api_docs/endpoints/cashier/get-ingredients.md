# GET /cashier/ingredients

## Summary
Get all ingredients (non-paginated) for offline sync.

## Auth
Bearer token required (SUPERADMIN, ADMIN, CASHIER).

## Request
- Method: GET
- Path: `/api/v1/cashier/ingredients`

## Success Response
- Status: 200
- Message: `Daftar ingredient (Cashier) berhasil diambil.`

## Example Response
```json
{
  "status": 200,
  "success": true,
  "message": "Daftar ingredient (Cashier) berhasil diambil.",
  "data": [
    {
      "id": "uuid-ingredient",
      "name": "Biji Kopi",
      "stock": "5000",
      "threshold": "1000",
      "unit": "GRAM"
    }
  ],
  "errors": null
}
```
