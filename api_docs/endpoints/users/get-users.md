# GET /users

## Summary
Get paginated users list.

## Auth
Bearer token required (ADMIN only).

## Request
- Method: GET
- Path: `/api/v1/users`
- Query:
  - `search` (string, optional)
  - `role` (`ADMIN|CASHIER`, optional)
  - `sort_by` (`name|username|role|created_at|updated_at`, default: `created_at`)
  - `sort_direction` (`asc|desc`, default: `desc`)
  - `per_page` (1-100, default: 10)
  - `page` (>=1, default: 1)

## Success Response
- Status: 200
- Message: `Daftar pengguna berhasil diambil.`
- Data: paginated list (field `password` tidak dikembalikan)

## Example Response
```json
{
  "status": 200,
  "success": true,
  "message": "Daftar pengguna berhasil diambil.",
  "data": {
    "items": [
      {
        "id": "uuid",
        "name": "John Doe",
        "username": "johndoe",
        "role": "CASHIER",
        "created_at": "2024-03-30T00:00:00.000Z",
        "updated_at": "2024-03-30T00:00:00.000Z"
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
