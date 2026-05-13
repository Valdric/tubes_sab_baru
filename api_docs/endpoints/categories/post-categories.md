# POST /categories

## Summary
Membuat kategori menu baru.

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`.

## Request
- Method: `POST`
- Path: `/api/v1/categories`
- Body:
```json
{
  "name": "Minuman Segar"
}
```

### Field Details
| Field | Type | Required | Validation | Description |
| :--- | :--- | :--- | :--- | :--- |
| `name` | `string` | **Yes** | min 2 chars, unik | Nama kategori (misal: Kopi, Makanan Berat, Snack). |

## Success Response
- Status: `201`
- Message: `Kategori berhasil dibuat.`
- Data Sample:
```json
{
  "id": "uuid-cat-123",
  "name": "Minuman Segar",
  "created_at": "2024-03-30T10:00:00.000Z"
}
```

## Error Responses

### 422 Validation Error
Nama kategori kurang dari 2 karakter.

### 409 Conflict
Nama kategori sudah ada dalam database.
```json
{
  "status": 409,
  "success": false,
  "message": "Nama kategori sudah ada.",
  "data": null,
  "errors": {
    "name": ["Nama kategori sudah ada."]
  }
}
```
