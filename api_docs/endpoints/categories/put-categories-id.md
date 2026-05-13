# PUT /categories/:id

## Summary
Update category by id.

## Auth
Bearer token required (ADMIN only).

## Request
- Method: PUT
- Path: `/api/v1/categories/:id`
- Params: `id` (uuid)
- Body:
  - `name` (optional, min 2)

## Success Response
- Status: 200
- Message: `Kategori berhasil diperbarui.`
## Example Response
~~~json
{
  "status": 200,
  "success": true,
  "message": "Kategori berhasil diperbarui.",
  "data": {},
  "errors": null
}
~~~

