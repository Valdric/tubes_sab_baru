# GET /menus/options

## Summary

Get simplified options for menu form: categories and ingredients (minimal fields, sorted by name).

## Auth

Bearer token required (ADMIN or CASHIER).

## Request

- Method: GET
- Path: `/api/v1/menus/options`

## Success Response

- Status: 200
- Message: `Opsi menu berhasil diambil.`
- Data: Object with `categories` and `ingredients` arrays.

## Example Response

```json
{
  "status": 200,
  "success": true,
  "message": "Opsi menu berhasil diambil.",
  "data": {
    "categories": [
      { "id": "cat_1", "name": "Makanan" },
      { "id": "cat_2", "name": "Minuman" }
    ],
    "ingredients": [
      { "id": "ing_1", "name": "Beras", "unit": "gram" },
      { "id": "ing_2", "name": "Gula", "unit": "gram" }
    ]
  },
  "errors": null
}
```
