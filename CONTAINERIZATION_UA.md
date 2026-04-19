# Контейнеризація Проєкту

## 1. Призначення контейнеризації

Контейнеризація в цьому проєкті потрібна для того, щоб увесь стек запускався однаково в будь-якому середовищі без ручного налаштування Node.js, PostgreSQL, Prisma та окремих сервісів фронтенду й бекенду.

У поточній реалізації Docker-підхід вирішує такі задачі:

- ізолює `frontend`, `backend` і `database` один від одного;
- забезпечує повторюваний запуск у локальному середовищі;
- централізує конфігурацію через `.env`;
- автоматично застосовує Prisma-міграції під час старту бекенда;
- дозволяє піднімати весь стек однією командою `docker compose up --build`.

---

## 2. Склад контейнеризованого стеку

У проєкті використовується базовий `docker-compose.yml` і два файли-надбудови:

- `docker-compose.dev.yml`
- `docker-compose.prod.yml`

Базовий файл описує спільні сервіси, а файли-надбудови вмикають відповідний режим запуску.

### `db`

Контейнер бази даних PostgreSQL.

- образ: `postgres:17-alpine`;
- зберігає дані у volume `postgres_data`;
- ініціалізується через директорію `db-init/`;
- має `healthcheck`, щоб інші сервіси чекали готовності БД.

### `backend`

Контейнер серверної частини на Node.js + Express + Prisma.

- будується з директорії `backend/`;
- запускає REST API і Socket.IO;
- чекає, поки PostgreSQL стане `healthy`;
- автоматично виконує `prisma migrate deploy` перед стартом застосунку;
- має власний `/health` endpoint для перевірки стану контейнера.

### `frontend`

Контейнер клієнтської частини на Next.js.

- будується з директорії `frontend_NEXT/`;
- працює у production-режимі;
- чекає, поки бекенд стане `healthy`;
- використовує змінні середовища для адрес API та Socket.IO;
- публікує застосунок на зовнішній порт.

### Режими запуску

#### `dev`

Режим локальної розробки:

- використовує `backend/Dockerfile.dev` і `frontend_NEXT/Dockerfile.dev`;
- монтує вихідний код через bind mounts;
- запускає `nodemon` для бекенда;
- запускає `next dev` для фронтенда;
- зберігає `node_modules` і `.next` у Docker volumes.

#### `prod`

Production-style режим:

- використовує стандартні `Dockerfile`;
- запускає production-сервери;
- не монтує код з хоста;
- орієнтований на стабільний запуск, а не на автоматичне перезавантаження під час розробки.

---

## 3. Архітектура взаємодії контейнерів

Логіка роботи стеку така:

1. Піднімається `db`.
2. Docker Compose перевіряє готовність БД через `pg_isready`.
3. Після цього стартує `backend`.
4. Під час запуску `backend` виконує Prisma-міграції.
5. Після успішного healthcheck бекенда стартує `frontend`.

Всередині Docker-мережі сервіси звертаються один до одного за сервісними іменами:

- `backend` -> `db:5432`
- `frontend` -> `backend:5000`

При цьому зовнішні адреси для браузера залишаються окремими, наприклад:

- `http://localhost:3000` для фронтенду;
- `http://localhost:5000` для бекенда.

---

## 4. Файли, що відповідають за контейнеризацію

### `docker-compose.yml`

Базовий orchestration-файл. Він:

- описує сервіси `db`, `backend`, `frontend`;
- передає змінні середовища;
- визначає залежності через `depends_on`;
- налаштовує `healthcheck`;
- підключає volume для PostgreSQL;
- оголошує Docker Secrets;
- містить лише спільну конфігурацію для `dev` і `prod`.

### `docker-compose.dev.yml`

Overlay для локальної розробки. Він:

- публікує порти `db`, `backend`, `frontend`;
- переключає бекенд на `Dockerfile.dev`;
- переключає фронтенд на `Dockerfile.dev`;
- додає bind mounts для коду;
- запускає `npm run dev`.

### `docker-compose.prod.yml`

Файл-надбудова для production-подібного запуску. Він:

- залишає стандартні production Dockerfile;
- публікує назовні лише `frontend` і `backend`, без експонування PostgreSQL;
- не монтує локальний код;
- задає `NODE_ENV=production`.

### `backend/Dockerfile`

Описує збірку образу бекенда.

Основні кроки:

- базовий образ `node:20-bookworm-slim`;
- багатоступенева збірка з окремим етапом для production-залежностей;
- встановлення `openssl`, необхідного Prisma;
- `npm ci --omit=dev` для встановлення лише залежностей середовища виконання;
- `npx prisma generate` на окремому етапі збірки;
- копіювання у фінальний образ лише `node_modules`, `prisma`, `src`, `index.js` та entrypoint;
- запуск контейнера від користувача `node`, а не від `root`;
- запуск через entrypoint-скрипт.

### `backend/Dockerfile.dev`

Dev-образ бекенда. Він:

- встановлює залежності;
- генерує Prisma Client;
- не пакує весь застосунок як production-артефакт;
- розрахований на bind mount вихідного коду з хоста.

### `backend/docker-entrypoint.sh`

Стартовий скрипт бекенда:

```sh
read_secret POSTGRES_PASSWORD
read_secret JWT_SECRET
read_secret OPENAI_API_KEY
npx prisma migrate deploy
exec "$@"
```

Або, якщо команда не передана:

```sh
npx prisma migrate deploy
exec npm start
```

Його роль:

- зчитувати значення секретів із `/run/secrets/...`;
- формувати `DATABASE_URL`, якщо його не передано напряму;
- застосувати всі наявні Prisma-міграції до БД;
- після цього запускати передану команду контейнера або стандартний `npm start`.

### `frontend_NEXT/Dockerfile`

Описує збірку образу фронтенда.

Основні кроки:

- базовий образ `node:20-alpine`;
- передача `NEXT_PUBLIC_API_URL` і `NEXT_PUBLIC_SOCKET_URL` через build args;
- `npm ci`;
- `next build`;
- формування standalone-артефакту для виконання;
- копіювання у фінальний образ лише `public`, `.next/static` і `.next/standalone`;
- запуск контейнера від користувача `node`, а не від `root`;
- запуск production-сервера Next.js на `0.0.0.0:3000`.

### `frontend_NEXT/Dockerfile.dev`

Dev-образ фронтенда. Він:

- встановлює залежності;
- не виконує `next build` під час білду образу;
- запускає `next dev`.

### `backend/src/config.js`

Файл відповідає за конфігурацію дозволених frontend-origin для CORS і Socket.IO.

Він:

- читає `FRONTEND_ORIGIN`;
- дозволяє один або кілька origin через кому;
- формує `corsOptions` для Express;
- використовується також у socket-конфігурації.

### `frontend_NEXT/src/lib/api.js`

Файл інкапсулює логіку побудови URL для API та сокетів.

Він розділяє два сценарії:

- у браузері фронтенд використовує `NEXT_PUBLIC_API_URL`;
- на серверній стороні Next.js використовується `INTERNAL_API_URL`.

Це важливо, тому що контейнеру фронтенда потрібно звертатись до бекенда по імені сервісу `backend`, а браузеру користувача потрібен зовнішній URL на кшталт `http://localhost:5000`.
У production-режимі значення `NEXT_PUBLIC_*` вбудовуються в клієнтський бандл під час `docker build`, тому їх зміна потребує перевидання образу, а не простого перезапуску контейнера.

---

## 5. Змінні середовища

Основний шаблон змінних винесено у файл:

### `.env.example`

```env
POSTGRES_DB=lang_platformdb
POSTGRES_USER=postgres
DB_PORT=5432
BACKEND_PORT=5000
FRONTEND_PORT=3000
POSTGRES_PASSWORD_FILE=./secrets/postgres_password.txt
JWT_SECRET_FILE=./secrets/jwt_secret.txt
OPENAI_API_KEY_FILE=./secrets/openai_api_key.txt

FRONTEND_ORIGIN=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:5000
NEXT_PUBLIC_SOCKET_URL=http://localhost:5000
```

### Пояснення змінних

#### PostgreSQL

- `POSTGRES_DB` - назва бази даних;
- `POSTGRES_USER` - користувач БД;
- `POSTGRES_PASSWORD_FILE` - шлях до файлу Docker Secret з паролем PostgreSQL;
- `DB_PORT` - зовнішній порт, на який публікується PostgreSQL.

#### Backend

- `JWT_SECRET_FILE` - шлях до Docker Secret з JWT-секретом;
- `OPENAI_API_KEY_FILE` - шлях до Docker Secret з ключем OpenAI API;
- `BACKEND_PORT` - зовнішній порт бекенда;
- `FRONTEND_ORIGIN` - origin, дозволений для CORS та Socket.IO.

#### Frontend

- `FRONTEND_PORT` - зовнішній порт фронтенда;
- `NEXT_PUBLIC_API_URL` - URL бекенда, який бачить браузер і який у production вбудовується під час збірки фронтенда;
- `NEXT_PUBLIC_SOCKET_URL` - URL Socket.IO, який бачить браузер і який у production вбудовується під час збірки фронтенда.

### Внутрішні змінні в Compose

У самому `docker-compose.yml` також задається:

- `POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password` для PostgreSQL;
- `JWT_SECRET_FILE=/run/secrets/jwt_secret` для бекенда;
- `OPENAI_API_KEY_FILE=/run/secrets/openai_api_key` для бекенда;
- `INTERNAL_API_URL=http://backend:5000` для фронтенда.

Ці адреси працюють лише всередині Docker-мережі й не повинні використовуватись напряму в браузері.

---

## 5.1. Docker Secrets

У поточній версії конфігурації чутливі значення винесені з `.env` у Docker Secrets.

Виносяться такі секрети:

- пароль PostgreSQL;
- `JWT_SECRET`;
- `OPENAI_API_KEY`.

Фізично вони зберігаються в локальних файлах:

- `secrets/postgres_password.txt`
- `secrets/jwt_secret.txt`
- `secrets/openai_api_key.txt`

У `docker-compose.yml` ці файли оголошуються як Docker Secrets і монтуються в контейнери в директорію `/run/secrets/`.

### Чому це краще за зберігання в `.env`

- секрети не потрапляють у відкриті env-змінні контейнера як звичайний текст;
- їх простіше виключити з Git;
- конфігурація проєкту відокремлюється від чутливих значень;
- можна використовувати одну й ту саму compose-схему в різних середовищах з різними secret-файлами.

### Як це працює в проєкті

Для `db` використовується:

- `POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password`

Для `backend` використовуються:

- `POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password`
- `JWT_SECRET_FILE=/run/secrets/jwt_secret`
- `OPENAI_API_KEY_FILE=/run/secrets/openai_api_key`

У `backend/docker-entrypoint.sh` значення читаються з цих файлів і експортуються в середовище перед запуском Node.js та Prisma.

---

## 6. Чому довелося прибрати жорстко зашитий `localhost`

До контейнеризації в коді фронтенда були прямі звернення на:

- `http://localhost:5000`

а в бекенді були зашиті:

- `http://localhost:3000` для CORS;
- `http://localhost:3000` для Socket.IO origin.

У контейнерному середовищі це проблемно, тому що:

- `localhost` усередині контейнера означає сам контейнер, а не інший сервіс;
- фронтенд у браузері повинен звертатися за зовнішньою адресою хоста;
- фронтенд усередині контейнера для SSR повинен звертатися до `backend`, а не до `localhost`.

Тому конфігурацію було винесено у змінні середовища.

---

## 7. Healthcheck і порядок запуску

### Healthcheck бази

Для `db` використовується:

```yaml
test: ['CMD-SHELL', 'pg_isready -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-lang_platformdb}']
```

Це означає, що Docker Compose не вважатиме базу готовою, поки PostgreSQL реально не почне приймати підключення.

### Healthcheck бекенда

Для `backend` використовується `/health`:

```yaml
fetch('http://127.0.0.1:5000/health')
```

Це дозволяє:

- переконатися, що Express уже стартував;
- відкладати запуск `frontend`, поки API не готове.

### Healthcheck фронтенда

Для `frontend` перевіряється HTTP-відповідь з порту `3000`.

---

## 8. Міграції Prisma

У контейнеризації Prisma інтегрована в старт бекенда.

Логіка така:

- при збірці образу виконується `npx prisma generate`;
- при запуску контейнера виконується `npx prisma migrate deploy`.

### Чому це правильно

`prisma generate`:

- генерує Prisma Client;
- потрібен під час білду образу.

`prisma migrate deploy`:

- застосовує вже існуючі міграції;
- безпечний для production-подібного запуску;
- не створює нові міграції, а тільки розгортає наявні.

---

## 9. Порти та конфлікти портів

За замовчуванням стек використовує:

- `3000` -> frontend;
- `5000` -> backend;
- `5432` -> PostgreSQL.

Але в реальному середовищі ці порти можуть бути вже зайняті іншими контейнерами або локальними сервісами.

Саме тому в проєкті додано:

- `FRONTEND_PORT`
- `BACKEND_PORT`
- `DB_PORT`

### Приклад, якщо стандартні порти вже зайняті

```env
FRONTEND_PORT=3001
BACKEND_PORT=5001
DB_PORT=5433

FRONTEND_ORIGIN=http://localhost:3001
NEXT_PUBLIC_API_URL=http://localhost:5001
NEXT_PUBLIC_SOCKET_URL=http://localhost:5001
```

У такому випадку контейнери всередині Docker усе одно працюватимуть через:

- `backend:5000`
- `db:5432`

але для користувача ззовні стек стане доступним на:

- `http://localhost:3001`
- `http://localhost:5001`

---

## 10. Запуск контейнеризованого стеку

### Крок 1. Створити `.env`

```bash
cp .env.example .env
```

Або в PowerShell:

```powershell
Copy-Item .\.env.example .\.env
```

Або вручну створити `.env` на основі шаблону.

### Крок 2. Створити файли Docker Secrets

```powershell
Copy-Item .\secrets\postgres_password.txt.example .\secrets\postgres_password.txt
Copy-Item .\secrets\jwt_secret.txt.example .\secrets\jwt_secret.txt
Copy-Item .\secrets\openai_api_key.txt.example .\secrets\openai_api_key.txt
```

Після цього потрібно замінити тестові значення на реальні.

### Крок 3. Запустити dev-режим

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build
```

### Крок 4. Запустити production-подібний режим

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
```

### Крок 5. Перевірити статус

```bash
docker compose ps
```

---

## 11. Перевірка працездатності

Після запуску слід перевірити:

### Frontend

Відкрити у браузері:

- `http://localhost:3000`

або інший порт, якщо він змінений.

### Backend health endpoint

- `http://localhost:5000/health`

Очікувана відповідь:

```json
{"status":"ok"}
```

### Контейнери

Команда:

```bash
docker compose ps
```

Очікуваний стан:

- `db` -> `healthy`
- `backend` -> `healthy`
- `frontend` -> `healthy`

---

## 11.1. Практична різниця між `dev` і `prod`

### `dev`

- підходить для щоденної розробки;
- бачить зміни коду без повного перевидання production-образу;
- має bind mounts;
- використовує автоматичне перезавантаження під час змін у коді.

### `prod`

- підходить для демонстрації або production-like запуску;
- стартує з уже зібраних образів;
- не залежить від локальних bind mounts;
- ближчий до реального деплой-сценарію.

---

## 12. Зупинка та очищення

### Зупинка контейнерів

```bash
docker compose down
```

### Зупинка зі збереженням даних у volume

Це стандартна поведінка `down`: база зберігається у `postgres_data`.

### Повне очищення разом із volume

```bash
docker compose down -v
```

Це видалить і контейнери, і дані PostgreSQL.

---

## 13. Практичні переваги поточної реалізації

Поточна контейнеризація має кілька сильних сторін:

- стек запускається як є без ручного встановлення PostgreSQL;
- бекенд стартує лише після готовності БД;
- фронтенд стартує лише після готовності API;
- конфігурація URL не зашита в коді;
- можна легко змінювати зовнішні порти;
- Prisma-міграції автоматизовані;
- є окремі healthcheck для всіх ключових сервісів.

---

## 14. Поточні обмеження

Контейнеризація вже робоча, але варто розуміти її межі:

- Docker Secrets у Compose-режимі все одно базуються на локальних файлах хоста;
- немає окремого reverse proxy на кшталт Nginx або Traefik;
- немає production-налаштувань SSL;
- початкова збірка фронтенда на Alpine може бути відчутно довшою, ніж повторні збірки з кешем;
- у фронтенді залишаються ESLint warning'и, хоча вони не блокують збірку.

---

## 15. Що можна покращити далі

Якщо розвивати контейнеризацію далі, логічні наступні кроки такі:

- додати `nginx` як reverse proxy;
- додати `.env.production` / `.env.development`;
- ще сильніше зменшити backend-образ через distroless або жорсткіше очищення Prisma-середовища виконання;
- додати автоматичну політику перезапуску для production-сценаріїв під хостинг;
- винести спільні налаштування в окрему `docs/` секцію документації.

---

## 16. Підсумок

У проєкті реалізована повноцінна базова контейнеризація всього стеку:

- PostgreSQL у окремому контейнері;
- Express + Prisma у окремому контейнері;
- Next.js у окремому контейнері;
- конфігурація через `.env`;
- healthcheck і правильний порядок запуску;
- автоматичні Prisma-міграції;
- підтримка гнучких зовнішніх портів.

Цього достатньо для локальної розробки, демонстрації проєкту, тестового розгортання й подальшого переходу до більш production-орієнтованої інфраструктури.
