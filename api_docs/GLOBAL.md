# Global API Overview

This document provides the global context for the Kopitiam Arunika API.

## Base URL
- Development: `http://localhost:8080/api/v1`
- Production: `[CLIENT_URL]/api/v1`

## Standard Response Format
All API responses follow a consistent wrapper:

### Success Response
```json
{
  "status": 200,
  "success": true,
  "message": "Operasi berhasil.",
  "data": { ... },
  "errors": null
}
```

### Error Response (Generic)
```json
{
  "status": 404,
  "success": false,
  "message": "Data tidak ditemukan.",
  "data": null,
  "errors": null
}
```

### Validation Error (422 Unprocessable Entity)
```json
{
  "status": 422,
  "success": false,
  "message": "Validasi data gagal.",
  "data": null,
  "errors": {
    "field_name": ["Pesan error 1", "Pesan error 2"]
  }
}
```

## Standard Query Parameters (List Endpoints)
Most endpoints that return a list of items support these parameters:

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `page` | `number` | `1` | Page number for pagination. |
| `per_page` | `number` | `10` | Items per page. |
| `search` | `string` | `""` | Search query for names/fields. |
| `sort_by` | `string` | `created_at` | Field to sort by. |
| `sort_direction` | `string` | `desc` | `asc` or `desc`. |

## Common HTTP Status Codes

| Status | Title | Description |
| :--- | :--- | :--- |
| `200` | OK | Request was successful. |
| `201` | Created | Resource was created successfully. |
| `400` | Bad Request | Request body or parameters are malformed. |
| `401` | Unauthorized | Token is missing or expired. |
| `403` | Forbidden | Authenticated but lacks required permissions (role mismatch). |
| `404` | Not Found | Resource (ID) does not exist. |
| `422` | Unprocessable Entity | Validation failed (check `errors` field). |
| `429` | Too Many Requests | Rate limit exceeded. |
| `500` | Internal Server Error | Unexpected server error. |

## Validation Error Detail

Kopitiam Arunika uses Zod for validation. When a validation error occurs (`422`), the `errors` field contains a record where the key is the field path and the value is an array of messages.

### Example: Nested Field Error
If you submit an order with invalid items:
```json
{
  "status": 422,
  "success": false,
  "message": "Validasi data gagal.",
  "data": null,
  "errors": {
    "items.0.quantity": ["Jumlah item harus lebih dari 0."],
    "table_number": ["Nomor meja wajib diisi untuk pesanan Dine In."]
  }
}
```

## Common Enums

### User Roles
- `SUPERADMIN`: Full access to everything including user management.
- `ADMIN`: Management of menus, categories, ingredients.
- `CASHIER`: Limited to cashier and order management.
- `KITCHEN`: Read-only access to orders and reports.

### Order Types
- `DINE_IN`: Requires a `table_number`.
- `TAKE_AWAY`: `table_number` is optional/null.

### Order Platforms
- `ONSITE`: Orders placed directly at the cashier.
- `SHOPEE`: Orders from ShopeeFood.
- `GOFOOD`: Orders from GoFood.

### Payment Methods
- `CASH`: Physical money.
- `QRIS`: Digital payment via QR code.

### Ingredient Units
- `GRAM`, `ML`, `PCS`

### Menu Division
- `BAR`: Beverage items.
- `KITCHEN`: Food items.
