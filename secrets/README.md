# Docker Secrets

Створи локальні файли секретів у цій директорії перед запуском `docker compose`.

Потрібні файли:

- `postgres_password.txt`
- `jwt_secret.txt`
- `openai_api_key.txt`

Швидкий старт:

```powershell
Copy-Item .\secrets\postgres_password.txt.example .\secrets\postgres_password.txt
Copy-Item .\secrets\jwt_secret.txt.example .\secrets\jwt_secret.txt
Copy-Item .\secrets\openai_api_key.txt.example .\secrets\openai_api_key.txt
```

Після цього заміни прикладові значення на реальні.
