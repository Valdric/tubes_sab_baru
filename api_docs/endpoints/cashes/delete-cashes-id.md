# DELETE /cashes/:id

## Summary
Menghapus catatan kas.

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`, `CASHIER`.

## Request
- Method: `DELETE`
- Path: `/api/v1/cashes/:id`

## Success Response
- Status: `200`
- Message: `Catatan kas berhasil dihapus.`
- Data: `null`

## Error Responses
- **404 Not Found**: ID tidak ditemukan.
- **403 Forbidden**: Role tidak diizinkan menghapus.
