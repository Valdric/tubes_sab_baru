# GET /menus

## Summary
Mengambil daftar menu dengan dukungan pencarian, pengurutan, dan filter kategori/divisi.

## Auth
- Bearer token required.
- Allowed Roles: Semua role yang terautentikasi.

## Request
- Method: `GET`
- Path: `/api/v1/menus`
- Query Parameters:
  | Parameter | Type | Default | Description |
  | :--- | :--- | :--- | :--- |
  | `page` | `number` | `1` | Halaman data. |
  | `per_page` | `number` | `10` | Jumlah data per halaman. |
  | `search` | `string` | `""` | Cari berdasarkan nama menu. |
  | `sort_by` | `enum` | `created_at` | `name`, `price`, `created_at`, `updated_at`. |
  | `sort_direction` | `enum` | `desc` | `asc` atau `desc`. |
  | `category_id` | `string` | - | Filter berdasarkan ID kategori tertentu. |
  | `division` | `enum` | - | `BAR` atau `KITCHEN`. |
  | `is_active` | `boolean` | - | `true` (aktif) atau `false` (tidak aktif). |

## Success Response
- Status: `200`
- Data Structure: Paginated list.
- Field Detail dalam `items`:
  - `id`: UUID.
  - `name`: String.
  - `price`: Number.
  - `is_active`: Boolean.
  - `division`: Enum (`BAR`|`KITCHEN`).
  - `category`: Objek kategori (`id`, `name`).
  - `recipes`: Array bahan baku (opsional tergantung include di backend).

## Example Response
Lihat format pagination standar di [GLOBAL.md](../../GLOBAL.md).
