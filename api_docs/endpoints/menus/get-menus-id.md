# GET /menus/:id

## Summary

Mengambil detail menu berdasarkan ID, termasuk kategori, resep, dan computed fields (`stock`, `is_available`).

## Auth

Bearer token required (ADMIN atau CASHIER).

## Request

- Method: GET
- Path: `/api/v1/menus/:id`
- Params: `id` (uuid)

## Success Response

- Status: 200
- Message: `Detail menu berhasil diambil.`
- Data: Object menu lengkap dengan kategori dan resep.

## Example Response

```json
{
  "status": 200,
  "success": true,
  "message": "Detail menu berhasil diambil.",
  "data": {
    "id": "menu_uuid",
    "name": "Kopi Susu",
    "price": "25000",
    "image_url": "https://...",
    "public_id": "cloudinary_id",
    "is_active": true,
    "division": "BAR",
    "category_id": "cat_uuid",
    "created_at": "2024-03-30T00:00:00.000Z",
    "updated_at": "2024-03-30T00:00:00.000Z",
    "stock": 5,
    "is_available": true,
    "category": {
      "id": "cat_uuid",
      "name": "Minuman",
      "created_at": "2024-03-30T00:00:00.000Z",
      "updated_at": "2024-03-30T00:00:00.000Z"
    },
    "recipes": [
      {
        "menu_id": "menu_uuid",
        "ingredient_id": "ing_uuid",
        "quantity": "2",
        "created_at": "2024-03-30T00:00:00.000Z",
        "updated_at": "2024-03-30T00:00:00.000Z",
        "ingredient": {
          "id": "ing_uuid",
          "name": "Susu Full Cream",
          "unit": "ML",
          "stock": "1000",
          "created_at": "2024-03-30T00:00:00.000Z",
          "updated_at": "2024-03-30T00:00:00.000Z"
        }
      }
    ]
  },
  "errors": null
}
```

## Error Responses

| Status | Kondisi |
|--------|---------|
| 404 | Menu dengan ID tersebut tidak ditemukan |
| 422 | Format `id` bukan UUID yang valid |
