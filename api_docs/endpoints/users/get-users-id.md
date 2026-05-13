# GET /users/:id

## Summary
Get user detail by id.

## Auth
Bearer token required (ADMIN only).

## Request
- Method: GET
- Path: `/api/v1/users/:id`
- Params: `id` (uuid)

## Success Response
- Status: 200
- Message: `Detail pengguna berhasil diambil.`
## Example Response
~~~json
{
  "status": 200,
  "success": true,
  "message": "Detail pengguna berhasil diambil.",
  "data": {},
  "errors": null
}
~~~

