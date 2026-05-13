# POST /orders

## Summary
Create a new POS order. This endpoint handles inventory reduction and revenue tracking.

## Auth
Requires authentication.
Allowed Roles: `SUPERADMIN`, `ADMIN`, `CASHIER`

## Request
- Method: `POST`
- Path: `/api/v1/orders`
- Body Schema:
```json
{
  "customer_name": "Budi",
  "type": "DINE_IN",
  "platform": "ONSITE",
  "discount": 0,
  "table_number": 5,
  "payment_method": "CASH",
  "items": [
    {
      "menu_id": "uuid-menu-1",
      "quantity": 2
    }
  ]
}
```

### Field Details
| Field | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `customer_name` | `string` | Yes | - | Name of the customer. |
| `type` | `enum` | No | `DINE_IN` | `DINE_IN`, `TAKE_AWAY`. |
| `platform` | `enum` | No | `ONSITE` | `ONSITE`, `SHOPEE`, `GOFOOD`. |
| `discount` | `number` | No | `0` | Integer 0-100 (percentage). |
| `table_number` | `number` | Conditional | `null` | Required if `type` is `DINE_IN`. |
| `payment_method`| `enum` | Yes | - | `CASH`, `QRIS`. |
| `items` | `array` | Yes | - | List of objects with `menu_id` and `quantity`. |
| `is_past_order` | `boolean` | No | `false` | If true, allows providing a custom `created_at`. |
| `created_at` | `string` | No | - | ISO Datetime. Only used if `is_past_order` is true. |

## Success Response
- Status: `201`
- Message: `Pesanan berhasil dibuat.`
- Data Structure:
```json
{
  "id": "uuid-order",
  "total_price": 50000,
  "final_price": 50000,
  "discount": 0,
  "customer_name": "Budi",
  "type": "DINE_IN",
  "table_number": 5,
  "payment_method": "CASH",
  "created_at": "2024-03-30T10:00:00Z"
}
```

## Error Responses

### 422 Validation Error
- If `customer_name` is empty.
- If `type` is `DINE_IN` but `table_number` is missing.
- If `items` is empty.
- If `discount` is out of range.

### 400 Bad Request
- If `menu_id` does not exist.
- If an ingredient in the recipe is out of stock.
```json
{
  "status": 400,
  "success": false,
  "message": "Stok bahan baku [Nama Bahan] tidak mencukupi.",
  "data": null,
  "errors": null
}
```
