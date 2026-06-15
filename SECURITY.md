# Security Policy

## Container Security Scope

У репозиторії реалізовано окремі застосовні практичні рекомендації CIS Docker Benchmark, NIST SP 800-190 та OWASP Docker Security Cheat Sheet. Це не є заявою про повну відповідність цим документам.

Реалізовані заходи:

- production-образи створюються з офіційних версійованих базових образів без тегу `latest`;
- backend використовує багатоступеневу збірку та не містить dev-залежностей;
- backend і frontend запускаються від користувача `node`, а не від `root`;
- реальні секрети виключені з Git і передаються через Docker Secrets у `/run/secrets`;
- PostgreSQL не публікує зовнішній порт у production-подібному режимі;
- сервіси мають healthcheck, а порядок запуску контролюється через `depends_on` з `service_healthy`;
- для backend і frontend увімкнено `no-new-privileges`, видалення Linux capabilities, обмеження ресурсів, `read_only` filesystem і `tmpfs` для необхідних записів;
- `.dockerignore` виключає залежності, локальні env-файли, кеші, логи та інші непотрібні файли з контексту збірки;
- Docker socket не монтується, privileged-контейнери не використовуються.

## Secrets

У Git зберігаються лише шаблони `secrets/*.txt.example`. Реальні файли `secrets/*.txt` потрібно створювати локально, обмежувати на них доступ засобами операційної системи та не передавати через відкриті канали. Для JWT слід генерувати довге випадкове значення, а ключ OpenAI зберігати й ротувати відповідно до політики постачальника.

## Image Verification

Перед розгортанням рекомендовано перевіряти локальні образи сканером вразливостей, наприклад Docker Scout:

```bash
docker scout cves my-lang-platform-backend:latest
docker scout cves my-lang-platform-frontend:latest
```

У production-середовищі також доцільно фіксувати базові образи за digest (`FROM image:tag@sha256:...`) після налаштованого процесу регулярного оновлення.

## Out of Repository Scope

Повніший захист потребує заходів поза межами цього репозиторію: hardening Docker Host і Docker Daemon, rootless Docker, user namespace remapping, захист registry, CI-сканування образів, підписання образів, SBOM, централізоване журналювання, моніторинг, резервне копіювання PostgreSQL, reverse proxy та HTTPS.

## Reporting

Не публікуйте реальні секрети або деталі експлуатації в issue. Повідомлення про вразливість слід передавати власнику репозиторію приватним каналом.
