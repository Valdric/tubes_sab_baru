# POST /cashes

## Summary
Membuat catatan kas manual baru (pemasukan atau pengeluaran).

## Auth
- Bearer token required.
- Allowed Roles: `SUPERADMIN`, `ADMIN`, `CASHIER`.

## Request
- Method: `POST`
- Path: `/api/v1/cashes`
- Body:
```json
{
  "description": "Beli sabun cuci piring",
  "amount": 25000,
  "type": "OUTCOME",
  "created_at": "2024-03-30T10:00:00.000Z"
}
```

### Field Details
| Field | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `description` | `string` | **Yes** | - | Deskripsi transaksi kas. |
| `amount` | `number` | **Yes** | - | Nominal uang (harus positif). |
| `type` | `string` | **Yes** | - | Tipe kas: `INCOME` atau `OUTCOME`. |
| `created_at` | `string` | No | Current Date | Tanggal transaksi (ISO 8601). Berguna untuk input data masa lalu. |

## Success Response
- Status: `201`
- Message: `Catatan kas berhasil dibuat.`
- Data Sample:
```json
{
  "id": "uuid-cash-123",
  "description": "Beli sabun cuci piring",
  "amount": 25000,
  "type": "OUTCOME",
  "created_at": "2024-03-30T10:00:00.000Z"
}
```

## Error Responses

### 422 Validation Error
Field tidak lengkap atau format salah (misal: amount negatif).

### 401 Unauthorized
Token tidak valid atau tidak disertakan.
