# GET /ingredients

## Summary

Get paginated list of ingredients. Each ingredient includes id, name, stock, unit, created_at, updated_at.

## Auth

Bearer token required (Semua Role).

## Request

- Method: GET
- Path: `/api/v1/ingredients`
- Query:
  - `search` (string, optional)
  - `sort_by` (`name|stock|unit|created_at|updated_at`, default: `created_at`)
  - `sort_direction` (`asc|desc`)
  - `per_page` (number, optional)
  - `page` (number, optional)

## Success Response

- Status: 200
- Message: `Daftar ingredient berhasil diambil.`
- Data: Paginated list with full ingredient details.

## Example Response

```json
{
  "status": 200,
  "success": true,
  "message": "Daftar ingredient berhasil diambil.",
  "data": {
    "items": [
      {
        "id": "ing_1",
        "name": "Beras",
        "stock": "1000",
        "threshold": "300",
        "unit": "GRAM",
        "created_at": "2024-03-30T00:00:00.000Z",
        "updated_at": "2024-03-30T00:00:00.000Z"
      }
    ],
    "filter": {
      "search": "",
      "sort_by": "name",
      "sort_direction": "asc",
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
