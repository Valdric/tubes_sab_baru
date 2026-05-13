# POST /auth/login

## Summary
Authenticate user and return JWT token.

## Auth
No authentication required.

## Request
- Method: POST
- Path: `/api/v1/auth/login`
- Body:
```json
{
  "username": "admin",
  "password": "admin123"
}
```

## Validation
- `username`: string, min 3
- `password`: string, min 6

## Success Response
- Status: 200
- Message: `Login berhasil.`
- Data: `user`, `token`
## Example Response
~~~json
{
  "status": 200,
  "success": true,
  "message": "Login berhasil.",
  "data": {},
  "errors": null
}
~~~

