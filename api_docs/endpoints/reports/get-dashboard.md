# GET /reports/dashboard

## Summary
Get a comprehensive summary of dashboard statistics including revenue, orders, AOV, and trends.

## Auth
Requires authentication.
Allowed Roles: `SUPERADMIN`, `ADMIN`, `CASHIER`, `KITCHEN`

## Request
- Method: `GET`
- Path: `/api/v1/reports/dashboard`
- Query Parameters:
  | Parameter | Type | Format | Description |
  | :--- | :--- | :--- | :--- |
  | `date_from` | `string` | `YYYY-MM-DD` | Start date for report range. |
  | `date_to` | `string` | `YYYY-MM-DD` | End date for report range. |

> [!NOTE]
> If `date_from` or `date_to` is missing, the report defaults to "All Time" (last 1 year) and comparison metrics will return 0%.

## Success Response
- Status: `200`
- Data Structure:
```json
{
  "revenue": {
    "value": 1500000,
    "percentage_change": 0.15
  },
  "total_orders": {
    "value": 45,
    "percentage_change": -0.05
  },
  "average_order_value": {
    "value": 33333,
    "percentage_change": 0.2
  },
  "nett_revenue": {
    "value": 1450000,
    "percentage_change": 0.12
  },
  "total_cash_income": 50000,
  "total_cash_outcome": 100000,
  "revenue_trend": [
    { "date": "2024-03-01", "revenue": 500000 },
    { "date": "2024-03-02", "revenue": 1000000 }
  ],
  "category_sales": [
    { "category": "Kopi", "revenue": 800000, "quantity": 40 },
    { "category": "Makanan", "revenue": 700000, "quantity": 20 }
  ],
  "payment_methods": [
    { "method": "CASH", "count": 30, "amount": 900000 },
    { "method": "QRIS", "count": 15, "amount": 600000 }
  ],
  "order_types": [
    { "type": "DINE_IN", "count": 35 },
    { "type": "TAKE_AWAY", "count": 10 }
  ],
  "platforms": [
    { "platform": "ONSITE", "count": 40 },
    { "platform": "GOFOOD", "count": 5 }
  ],
  "most_sold_items": [
    {
      "menu": { "name": "Kopi Susu", "price": "15000", "image_url": "..." },
      "total_sold": 25
    }
  ],
  "low_stock_items": [
    { "id": "uuid", "name": "Biji Kopi", "stock": "500", "unit": "GRAM" }
  ],
  "is_all_time": false
}
```

## Error Responses

### 401 Unauthorized
If token is missing or invalid.

### 403 Forbidden
If the user's role is not authorized (though all roles are allowed here).

### 500 Internal Server Error
Database connection issues or SQL syntax errors.
```json
{
  "status": 500,
  "success": false,
  "message": "Terjadi kesalahan pada server.",
  "data": null,
  "errors": null
}
```
