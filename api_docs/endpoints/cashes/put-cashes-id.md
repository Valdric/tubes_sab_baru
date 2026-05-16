# PUT /cashes/:id

## Summary
Memperbarui data catatan kas yang sudah ada.

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`, `CASHIER`.

## Request
- Method: `PUT`
- Path: `/api/v1/cashes/:id`
- Body:
```json
{
  "description": "Beli sabun cuci piring (update)",
  "amount": 26000,
  "type": "OUTCOME",
  "created_at": "2024-03-30T10:00:00.000Z"
}
```

## Success Response
- Status: `200`
- Message: `Catatan kas berhasil diperbarui.`
- Data Sample:
```json
{
  "id": "uuid-cash-123",
  "description": "Beli sabun cuci piring (update)",
  "amount": 26000,
  "type": "OUTCOME",
  "created_at": "2024-03-30T10:00:00.000Z"
}
```

## Error Responses
- **404 Not Found**: ID catatan kas tidak ditemukan.
- **403 Forbidden**: User bukan pembuat catatan ini atau tidak punya akses (tergantung kebijakan bisnis).
- **422 Validation Error**: Data tidak valid.
