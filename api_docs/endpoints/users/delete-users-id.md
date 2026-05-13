# DELETE /users/:id

## Summary
Delete user by id.

## Auth
Bearer token required (ADMIN only).

## Request
- Method: DELETE
- Path: `/api/v1/users/:id`
- Params: `id` (uuid)

## Success Response
- Status: 200
- Message: `Pengguna berhasil dihapus.`
## Example Response
~~~json
{
  "status": 200,
  "success": true,
  "message": "Pengguna berhasil dihapus.",
  "data": {},
  "errors": null
}
~~~

