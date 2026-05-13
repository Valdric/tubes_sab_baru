# PUT /profile/username

## Summary
Update the authenticated user's username.

## Auth
Bearer token required.

## Request
- Method: PUT
- Path: `/api/v1/profile/username`
- Body:
```json
{
  "username": "new_username"
}
```

## Rules
- `username` minimal 3 karakter, maksimal 16 karakter.
- Hanya boleh mengandung huruf kecil, angka, dan underscore.
- Username harus unik (belum digunakan oleh pengguna lain).

## Success Response
- Status: 200
- Message: `Username berhasil diperbarui.`

## Example Response
```json
{
  "status": 200,
  "success": true,
  "message": "Username berhasil diperbarui.",
  "data": {
    "id": "uuid-user",
    "name": "User Name",
    "username": "new_username",
    "role": "ADMIN",
    "created_at": "...",
    "updated_at": "..."
  },
  "errors": null
}
```
