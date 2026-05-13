# PUT /users/:id

## Summary
Memperbarui data pengguna (staf) yang sudah ada.

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`.

## Request
- Method: `PUT`
- Path: `/api/v1/users/:id`
- Body:
```json
{
  "name": "Jane Doe Updated",
  "role": "ADMIN"
}
```

### Field Details
Semua field bersifat **opsional**. Field yang tidak dikirim tidak akan diubah.

| Field | Type | Required | Validation | Description |
| :--- | :--- | :--- | :--- | :--- |
| `name` | `string` | No | min 2 chars | Nama lengkap staf. |
| `username` | `string` | No | min 3 chars, unik | Username baru. |
| `password` | `string` | No | min 6 chars | Password baru. |
| `role` | `enum` | No | - | `SUPERADMIN`, `ADMIN`, `CASHIER`, `KITCHEN`. |

## Success Response
- Status: `200`
- Message: `Pengguna berhasil diperbarui.`
- Data Sample:
```json
{
  "id": "uuid-user-123",
  "name": "Jane Doe Updated",
  "username": "janedoe",
  "role": "ADMIN",
  "updated_at": "2024-03-30T11:00:00.000Z"
}
```

## Error Responses

### 404 Not Found
ID pengguna tidak ditemukan.

### 422 Validation Error
Format data tidak sesuai kriteria minimal.
