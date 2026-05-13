# PUT /profile/password

## Summary

Memperbarui password pengguna yang sedang login. Memerlukan password saat ini sebagai verifikasi.

## Auth

Bearer token required (ADMIN atau CASHIER).

## Request

- Method: PUT
- Path: `/api/v1/profile/password`
- Body (JSON):

```json
{
  "password": "password_saat_ini",
  "new_password": "password_baru_minimal6",
  "confirmation_password": "password_baru_minimal6"
}
```

## Validation Rules

| Field                   | Aturan                                                       |
| ----------------------- | ------------------------------------------------------------ |
| `password`              | string, tidak boleh kosong                                   |
| `new_password`          | string, minimal 6 karakter                                   |
| `confirmation_password` | string, minimal 6 karakter, harus sama dengan `new_password` |

## Business Rules

- `password` harus sesuai dengan password yang tersimpan saat ini.
- `new_password` tidak boleh sama dengan `password` lama.
- `confirmation_password` harus identik dengan `new_password`.

## Success Response

- Status: 200
- Message: `Password berhasil diperbarui.`
- Data: `null`

## Example Response

```json
{
  "status": 200,
  "success": true,
  "message": "Password berhasil diperbarui.",
  "data": null,
  "errors": null
}
```

## Error Responses

| Status | Kondisi                                                | Field Error                                                                      |
| ------ | ------------------------------------------------------ | -------------------------------------------------------------------------------- |
| 401    | Token tidak valid atau tidak ada                       | —                                                                                |
| 404    | Pengguna tidak ditemukan                               | —                                                                                |
| 422    | Validasi gagal (field kosong / tidak memenuhi panjang) | `password`, `new_password`, `confirmation_password`                              |
| 422    | Password saat ini tidak sesuai                         | `password: "Password saat ini tidak sesuai."`                                    |
| 422    | Password baru sama dengan password lama                | `new_password: "Password baru tidak boleh sama dengan password saat ini."`       |
| 422    | Konfirmasi tidak cocok                                 | `confirmation_password: "Konfirmasi password tidak cocok dengan password baru."` |
