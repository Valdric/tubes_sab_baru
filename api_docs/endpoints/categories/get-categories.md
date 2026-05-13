# GET /categories

## Summary

Get paginated list of categories. Each category includes id, name, created_at, updated_at.

## Auth

Bearer token required (ADMIN only).

## Request

- Method: GET
- Path: `/api/v1/categories`
- Query:
  - `search` (string, optional)
  - `sort_by` (`name|created_at|updated_at`)
  - `sort_direction` (`asc|desc`)
  - `per_page` (number, optional)
  - `page` (number, optional)

## Success Response

- Status: 200
- Message: `Daftar kategori berhasil diambil.`
- Data: Paginated list with full category details.

## Example Response

```json
{
  "status": 200,
  "success": true,
  "message": "Daftar kategori berhasil diambil.",
  "data": {
    "items": [
      {
        "id": "cat_1",
        "name": "Makanan",
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
