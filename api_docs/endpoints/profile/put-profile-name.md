# PATCH /profile/name

## Summary

Memperbarui nama pengguna yang sedang login.

## Auth

Bearer token required (ADMIN atau CASHIER).

## Request

- Method: PUT
- Path: `/api/v1/profile/name`
- Body (JSON):

```json
{
  "name": "Nama Baru"
}
```

## Validation Rules

| Field  | Aturan                                  |
| ------ | --------------------------------------- |
| `name` | string, minimal 2 karakter, wajib diisi |

## Success Response

- Status: 200
- Message: `Nama berhasil diperbarui.`
- Data: Objek profil yang sudah diperbarui (tanpa `password` dan `orders`).

## Example Response

```json
{
  "status": 200,
  "success": true,
  "message": "Nama berhasil diperbarui.",
  "data": {
    "id": "user_uuid",
    "name": "Nama Baru",
    "username": "budi",
    "role": "CASHIER",
    "created_at": "2024-03-30T00:00:00.000Z",
    "updated_at": "2024-04-02T00:00:00.000Z"
  },
  "errors": null
}
```

## Error Responses

| Status | Message                                            |
| ------ | -------------------------------------------------- |
| 401    | `Unauthorized.` — token tidak valid atau tidak ada |
| 404    | `Pengguna tidak ditemukan.`                        |
| 422    | `Validasi data gagal.` — lihat `errors.name`       |
