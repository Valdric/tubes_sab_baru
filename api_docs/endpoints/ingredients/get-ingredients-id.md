# GET /ingredients/:id

## Summary
Get ingredient detail by id.

## Auth
Bearer token required (ADMIN only).

## Request
- Method: GET
- Path: `/api/v1/ingredients/:id`
- Params: `id` (uuid)

## Success Response
- Status: 200
- Message: `Detail ingredient berhasil diambil.`
## Example Response
~~~json
{
  "status": 200,
  "success": true,
  "message": "Detail ingredient berhasil diambil.",
  "data": {},
  "errors": null
}
~~~

