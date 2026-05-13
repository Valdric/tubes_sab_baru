# GET /auth/me

## Summary

Get authenticated user profile.

## Auth

Bearer token required.

## Request

- Method: GET
- Path: `/api/v1/auth/me`

## Success Response

- Status: 200
- Message: `Profil pengguna berhasil diambil.`
- Data: `user`

## Example Response

```json
{
  "status": 200,
  "success": true,
  "message": "Profil pengguna berhasil diambil.",
  "data": {
    "id": 1,
    "name": "Admin",
    "username": "admin",
    "role": "ADMIN",
    "created_at": "2026-04-03T03:10:45.000000Z",
    "updated_at": "2026-04-03T03:10:45.000000Z"
  },
  "errors": null
}
```
