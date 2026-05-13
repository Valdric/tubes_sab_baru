# POST /menus

## Summary
Membuat menu baru beserta komposisi resepnya.

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`.

## Request
- Method: `POST`
- Path: `/api/v1/menus`
- Body:
```json
{
  "name": "Kopi Susu Gula Aren",
  "price": 18000,
  "category_id": "uuid-kategori-kopi",
  "division": "BAR",
  "is_active": true,
  "recipes": [
    {
      "ingredient_id": "uuid-bahan-biji-kopi",
      "quantity": 18
    },
    {
      "ingredient_id": "uuid-bahan-susu",
      "quantity": 150
    }
  ]
}
```

### Field Details
| Field | Type | Required | Validation | Description |
| :--- | :--- | :--- | :--- | :--- |
| `name` | `string` | **Yes** | min 2 chars | Nama menu. |
| `price` | `number` | **Yes** | >= 0 | Harga jual menu (integer). |
| `category_id` | `string` | **Yes** | UUID valid | ID kategori dari `/categories`. |
| `division` | `enum` | No | default: `BAR` | `BAR` (Minuman) atau `KITCHEN` (Makanan). |
| `is_active` | `boolean` | No | default: `true` | Status ketersediaan menu. |
| `recipes` | `array` | No | min 1 item | Daftar bahan baku yang digunakan. |

#### Recipes Item Field
| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `ingredient_id` | `string` | Yes | ID bahan baku dari `/ingredients`. |
| `quantity` | `number` | Yes | Jumlah pemakaian bahan per 1 porsi menu. |

## Success Response
- Status: `201`
- Message: `Menu berhasil dibuat.`
- Data Sample: Objek menu lengkap termasuk detail `category` dan `recipes`.

## Error Responses

### 422 Validation Error
Field wajib tidak diisi atau format UUID salah.

### 400 Bad Request
- ID Kategori tidak ditemukan.
- Salah satu `ingredient_id` dalam resep tidak ditemukan.
