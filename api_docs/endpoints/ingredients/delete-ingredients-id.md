# DELETE /ingredients/:id

## Summary
Delete ingredient by id.

## Auth
Bearer token required (ADMIN only).

## Request
- Method: DELETE
- Path: `/api/v1/ingredients/:id`
- Params: `id` (uuid)

## Success Response
- Status: 200
- Message: `Ingredient berhasil dihapus.`
## Example Response
~~~json
{
  "status": 200,
  "success": true,
  "message": "Ingredient berhasil dihapus.",
  "data": {},
  "errors": null
}
~~~

