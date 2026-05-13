# DELETE /menus/:id

## Summary
Delete menu by id.

## Auth
Bearer token required (ADMIN only).

## Request
- Method: DELETE
- Path: `/api/v1/menus/:id`
- Params: `id` (uuid)

## Success Response
- Status: 200
- Message: `Menu berhasil dihapus.`
## Example Response
~~~json
{
  "status": 200,
  "success": true,
  "message": "Menu berhasil dihapus.",
  "data": {},
  "errors": null
}
~~~

