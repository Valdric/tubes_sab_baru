# POST /ingredients

## Summary
Menambah bahan baku baru ke dalam inventaris.

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`.

## Request
- Method: `POST`
- Path: `/api/v1/ingredients`
- Body:
```json
{
  "name": "Biji Kopi Arabica",
  "stock": 5000,
  "unit": "GRAM",
  "threshold": 500
}
```

### Field Details
| Field | Type | Required | Validation | Description |
| :--- | :--- | :--- | :--- | :--- |
| `name` | `string` | **Yes** | min 2 chars, unik | Nama bahan baku. |
| `stock` | `number` | **Yes** | >= 0 | Stok awal saat pendaftaran. |
| `unit` | `enum` | **Yes** | - | `GRAM`, `ML`, `PCS`. |
| `threshold` | `number` | No | default: `0` | Batas minimal stok sebelum dianggap "Low Stock". |

## Success Response
- Status: `201`
- Message: `Bahan baku berhasil dibuat.`
- Data Sample: Objek bahan baku (`id`, `name`, `stock`, `unit`, `threshold`).

## Error Responses

### 422 Validation Error
Format unit salah atau field wajib tidak diisi.

### 409 Conflict
Nama bahan baku sudah terdaftar.
