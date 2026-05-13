# GET /profile

## Summary

Mengambil data profil pengguna yang sedang login. Password dan relasi orders tidak dikembalikan.

## Auth

Bearer token required (ADMIN atau CASHIER).

## Request

- Method: GET
- Path: `/api/v1/profile`
- Body: —

## Success Response

- Status: 200
- Message: `Profil berhasil diambil.`
- Data: Objek profil pengguna tanpa field `password` dan `orders`.

## Example Response

```json
{
  "status": 200,
  "success": true,
  "message": "Profil berhasil diambil.",
  "data": {
    "id": "user_uuid",
    "name": "Budi Santoso",
    "username": "budi",
    "role": "CASHIER",
    "created_at": "2024-03-30T00:00:00.000Z",
    "updated_at": "2024-03-30T00:00:00.000Z"
  },
  "errors": null
}
```

## Error Responses

| Status | Message |
|--------|---------|
| 401 | `Unauthorized.` — token tidak valid atau tidak ada |
| 404 | `Pengguna tidak ditemukan.` |
