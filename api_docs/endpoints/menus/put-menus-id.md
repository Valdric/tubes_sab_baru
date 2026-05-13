# PUT /menus/:id

## Summary
Memperbarui data menu atau resep yang sudah ada.

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`.

## Request
- Method: `PUT`
- Path: `/api/v1/menus/:id`
- Body: (Kirim hanya field yang ingin diubah)
```json
{
  "price": 20000,
  "is_active": false
}
```

### Field Details
Semua field bersifat **opsional**.

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | `string` | Nama menu baru. |
| `price` | `number` | Harga jual baru. |
| `category_id` | `string` | ID kategori baru. |
| `division` | `enum` | `BAR` / `KITCHEN`. |
| `is_active` | `boolean` | Toggle status aktif/non-aktif. |
| `recipes` | `array` | Daftar resep baru (akan menimpa resep lama sepenuhnya). |

## Success Response
- Status: `200`
- Message: `Menu berhasil diperbarui.`
- Data Sample: Objek menu yang telah diupdate.

## Error Responses

### 404 Not Found
ID menu tidak ditemukan.

### 400 Bad Request
ID kategori atau ID bahan baku dalam resep tidak valid/tidak ditemukan.
