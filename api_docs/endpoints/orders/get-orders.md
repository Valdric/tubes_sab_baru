# GET /orders

## Summary
Get paginated orders list.

## Auth
Bearer token required (authenticated users).

## Request
- Method: GET
- Path: `/api/v1/orders`
- Query:
  - `search` (string, optional)
  - `user_id` (uuid, optional)
  - `date_from` (date string, optional)
  - `date_to` (date string, optional)
  - `sort_by` (`created_at|total_price`, default: `created_at`)
  - `sort_direction` (`asc|desc`, default: `desc`)
  - `per_page` (1-100, default: 10)
  - `page` (>=1, default: 1)

## Success Response
- Status: 200
- Message: `Daftar pesanan berhasil diambil.`

## Example Response
```json
{
  "status": 200,
  "success": true,
  "message": "Daftar pesanan berhasil diambil.",
  "data": {
    "items": [
      {
        "id": "uuid",
        "total_price": "25000",
        "customer_name": "Rizky",
        "type": "DINE_IN",
        "platform": "ONSITE",
        "payment_method": "CASH",
        "user_id": "uuid-user",
        "created_at": "2024-03-30T00:00:00.000Z",
        "updated_at": "2024-03-30T00:00:00.000Z",
        "user": { "id": "uuid-user", "name": "Admin", "role": "ADMIN" },
        "order_items": [
          {
            "id": "uuid-item",
            "order_id": "uuid-order",
            "menu_id": "uuid-menu",
            "quantity": 2,
            "price": "12500",
            "created_at": "2024-03-30T00:00:00.000Z",
            "menu": { "name": "Nasi Goreng", "image_url": "https://..." }
          }
        ]
      }
    ],
    "filter": {
      "search": "",
      "sort_by": "created_at",
      "sort_direction": "desc",
      "per_page": 10
    },
    "pagination": {
      "from": 1,
      "current_page": 1,
      "next_page": null,
      "prev_page": null,
      "total": 1,
      "total_pages": 1
    }
  },
  "errors": null
}
```
