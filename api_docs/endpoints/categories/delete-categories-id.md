# DELETE /categories/:id

## Summary
Delete category by id.

## Auth
Bearer token required (ADMIN only).

## Request
- Method: DELETE
- Path: `/api/v1/categories/:id`
- Params: `id` (uuid)

## Success Response
- Status: 200
- Message: `Kategori berhasil dihapus.`
## Example Response
~~~json
{
  "status": 200,
  "success": true,
  "message": "Kategori berhasil dihapus.",
  "data": {},
  "errors": null
}
~~~

