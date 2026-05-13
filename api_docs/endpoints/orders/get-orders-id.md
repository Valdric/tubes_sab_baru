# GET /orders/:id

## Summary
Get order detail by id with user, items, and payment info.

## Auth
Bearer token required (authenticated users).

## Request
- Method: GET
- Path: `/api/v1/orders/:id`
- Params: `id` (uuid)

## Success Response
- Status: 200
- Message: `Detail pesanan berhasil diambil.`
## Example Response
~~~json
{
  "status": 200,
  "success": true,
  "message": "Detail pesanan berhasil diambil.",
  "data": {},
  "errors": null
}
~~~

