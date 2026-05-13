# GET /categories/:id

## Summary
Get category detail by id.

## Auth
Bearer token required (ADMIN only).

## Request
- Method: GET
- Path: `/api/v1/categories/:id`
- Params: `id` (uuid)

## Success Response
- Status: 200
- Message: `Detail kategori berhasil diambil.`
## Example Response
~~~json
{
  "status": 200,
  "success": true,
  "message": "Detail kategori berhasil diambil.",
  "data": {},
  "errors": null
}
~~~

