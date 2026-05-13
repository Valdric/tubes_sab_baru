# POST /users

## Summary
Mendaftarkan pengguna (staf) baru ke dalam sistem.

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`.
- *Catatan: Hanya `SUPERADMIN` yang bisa mendaftarkan user dengan role `ADMIN` atau `SUPERADMIN` lainnya.*

## Request
- Method: `POST`
- Path: `/api/v1/users`
- Body:
```json
{
  "name": "Jane Doe",
  "username": "janedoe",
  "password": "password123",
  "role": "CASHIER"
}
```

### Field Details
| Field | Type | Required | Validation | Description |
| :--- | :--- | :--- | :--- | :--- |
| `name` | `string` | **Yes** | min 2 chars | Nama lengkap staf. |
| `username` | `string` | **Yes** | min 3 chars, unik | Username untuk login. |
| `password` | `string` | **Yes** | min 6 chars | Password minimal 6 karakter. |
| `role` | `enum` | No | default: `CASHIER` | `SUPERADMIN`, `ADMIN`, `CASHIER`, `KITCHEN`. |

## Success Response
- Status: `201`
- Message: `Pengguna berhasil dibuat.`
- Data Sample:
```json
{
  "id": "uuid-user-123",
  "name": "Jane Doe",
  "username": "janedoe",
  "role": "CASHIER",
  "created_at": "2024-03-30T10:00:00.000Z"
}
```

## Error Responses

### 422 Validation Error
Terjadi jika format data salah (misal password kurang dari 6 karakter).
```json
{
  "status": 422,
  "success": false,
  "message": "Validasi data gagal.",
  "data": null,
  "errors": {
    "username": ["Username minimal 3 karakter."],
    "password": ["Password minimal 6 karakter."]
  }
}
```

### 409 Conflict
Terjadi jika `username` sudah digunakan oleh pengguna lain.
```json
{
  "status": 409,
  "success": false,
  "message": "Username sudah digunakan.",
  "data": null,
  "errors": {
    "username": ["Username sudah digunakan."]
  }
}
```
