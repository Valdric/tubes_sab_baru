# Kopitiam Arunika API - General Guide

Dokumen ini hanya menjelaskan hal-hal general API.
Dokumentasi detail per endpoint ada di folder `api_docs/endpoints/`.

## 1. Base URL

- Base path: `/api/v1`

## 2. Authentication

- Auth type: Bearer JWT
- Header: `Authorization: Bearer <token>`

## 3. Standard Response Shape

```json
{
  "status": 200,
  "success": true,
  "message": "Request succeeded.",
  "data": {},
  "errors": null
}
```

Validation error shape:

```json
{
  "status": 422,
  "success": false,
  "message": "Validasi data gagal.",
  "data": null,
  "errors": {
    "field": "validation message"
  }
}
```

General error shape:

```json
{
  "status": 500,
  "success": false,
  "message": "Terjadi kesalahan pada server.",
  "data": null,
  "errors": null
}
```

## 4. Pagination Format

List endpoint yang paginated menggunakan format berikut:

```json
{
  "items": [],
  "filter": {
    "search": "",
    "sort_by": "created_at",
    "sort_direction": "desc",
    "per_page": 10
  },
  "pagination": {
    "from": 1,
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total": 100,
    "total_pages": 10
  }
}
```

- `from` adalah nomor urut data pertama di halaman aktif.
- Jika halaman kosong, `from = 0`.
- Field `filter` bisa mengandung extra filter tergantung endpoint (misal: `category_id`, `division`, `is_active` pada endpoint menus). Detail per endpoint lihat dokumentasinya masing-masing.

## 5. Access Rules (Ringkas)

- Public:
  - `POST /auth/login`
- Authenticated (semua role):
  - `GET /auth/me`
  - `GET /profile`
  - `PUT /profile/name`
  - `PUT /profile/username`
  - `PUT /profile/password`
  - `GET /categories`
  - `GET /ingredients`
  - `GET /menus`
  - `GET /cashier/menus`
  - `GET /cashier/categories`
  - `GET /cashier/ingredients`
  - `GET /orders`
  - `GET /reports/*`
- SUPERADMIN:
  - Semua endpoint di `/users`
- SUPERADMIN dan ADMIN:
  - `POST|PUT|DELETE` di `/categories`
  - `POST|PUT|DELETE` di `/ingredients`
  - `POST|PUT|DELETE` di `/menus`
- SUPERADMIN, ADMIN, dan CASHIER:
  - `POST /orders` (Membuat Pesanan)
- KITCHEN:
  - Hanya akses Read-only (GET) dan tidak bisa membuat pesanan (tidak ada akses ke fitur cashier).

## 6. Endpoint Documentation Map

Lihat detail per endpoint di folder berikut:

- **Global Context**:
  - `GLOBAL.md`: Struktur response, error codes, enums global.
- **Auth & Profile**:
  - `auth/post-login.md`: Login & JWT.
  - `auth/get-me.md`: Cek session user.
  - `profile/`: Pengaturan profil user.
- **Master Data**:
  - `categories/categories.md`: CRUD Kategori.
  - `ingredients/ingredients.md`: CRUD Bahan Baku.
  - `menus/menus.md`: CRUD Menu & Resep.
- **Transactional**:
  - `orders/post-orders.md`: Membuat pesanan baru.
  - `orders/get-orders.md`: List & detail pesanan.
  - `cashier/`: Khusus data untuk tampilan kasir.
- **Management**:
  - `users/`: Pengelolaan akun (Superadmin only).
- **Analytics**:
  - `reports/get-dashboard.md`: Ringkasan dashboard.
  - `reports/revenue-trend.md`: Data grafik pendapatan.
  - `reports/peak-hours.md`: Statistik jam sibuk.
