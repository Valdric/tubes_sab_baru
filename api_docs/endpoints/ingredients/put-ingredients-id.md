# PUT /ingredients/:id

## Summary
Update ingredient by id.

## Auth
Bearer token required (SUPERADMIN or ADMIN).

## Request
- Method: PUT
- Path: `/api/v1/ingredients/:id`
- Params: `id` (uuid)
- Body fields (optional):
  - `name`
  - `stock` (number)
  - `threshold` (number)
  - `unit`

## Success Response
- Status: 200
- Message: `Ingredient berhasil diperbarui.`
## Example Response
~~~json
{
  "status": 200,
  "success": true,
  "message": "Ingredient berhasil diperbarui.",
  "data": {},
  "errors": null
}
~~~

