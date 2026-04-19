# My Language Platform

My Language Platform is a full-stack educational web application for practicing English through real-time communication and AI-assisted feedback.

The project was developed as a learning project to practice modern web technologies, client-server architecture, database interaction, and third-party API integration. It is not intended for production use.

---

## Project Overview

The application allows users to:
- register and authenticate
- communicate in chat rooms
- receive AI-based feedback on English sentences
- practice grammar and writing
- track basic learning progress

The project demonstrates a real-world full-stack architecture in an educational context.

---

## Features

- User registration and authentication
- Protected routes for authorized users
- Real-time chat functionality
- AI-assisted text correction and explanation
- Preview of improved messages before sending
- Daily English practice exercises
- User progress tracking
- Multilingual interface (English / Ukrainian)

---

## Architecture

The project follows a client-server architecture:

- Frontend: Next.js application responsible for UI, routing, and state management
- Backend: Node.js with Express REST API
- Database: PostgreSQL with Prisma ORM
- AI integration: OpenAI API for text analysis and feedback

---

## Tech Stack

### Frontend
- Next.js (React)
- JavaScript (ES6+)
- CSS Modules
- next-intl

### Backend
- Node.js
- Express.js
- REST API
- JWT-based authentication (httpOnly cookies)

### Database
- PostgreSQL
- Prisma ORM

### AI Integration
- OpenAI API

### Tools
- Git, GitHub
- npm
- VS Code

---

## Project Structure (simplified)

Current repository layout for Docker:
- `frontend_NEXT/`
- `backend/`
- `db-init/`
- `docker-compose.yml`
- `docker-compose.dev.yml`
- `docker-compose.prod.yml`

my-lang-platform/
├── frontend_NEXT/
├── backend/
├── db-init/
├── docker-compose.yml
├── README.md
└── package.json

---

## Docker Setup

### 1. Clone the repository
git clone https://github.com/mykhailo-proj-hub/my-lang-platform.git
cd my-lang-platform

### 2. Configure environment variables

Create a root `.env` file from `.env.example`:

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

### 3. Create Docker Secrets files
Copy the templates from `secrets/` and put real values into:
- `secrets/postgres_password.txt`
- `secrets/jwt_secret.txt`
- `secrets/openai_api_key.txt`

### 4. Start development mode
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build

### 5. Start production-style mode
docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d

### 6. Open the app
- Frontend: http://localhost:3000
- Backend healthcheck: http://localhost:5000/health
- PostgreSQL: localhost:5432

### Notes
- `docker-compose.yml` is the shared base config
- `docker-compose.dev.yml` enables bind mounts, `nodemon`, and `next dev`
- `docker-compose.prod.yml` uses production images and does not expose PostgreSQL by default
- `backend` production image uses a multi-stage build, installs only production dependencies, and runs as a non-root user
- `frontend` production image uses Next.js standalone output and a separate lightweight runtime stage
- `backend` runs `prisma migrate deploy` automatically on container start
- in `development`, `NEXT_PUBLIC_API_URL` and `NEXT_PUBLIC_SOCKET_URL` are runtime env variables for `next dev`
- in `production-style`, `NEXT_PUBLIC_*` are build-time values baked into the client bundle during image build; changing them requires rebuild, not just container restart
- `INTERNAL_API_URL` remains a runtime variable for server-side requests inside the frontend container
- secrets are mounted through Docker Secrets from `/run/secrets/...`
- `backend/.env.example` can still be used for non-Docker local development
- if ports `3000`, `5000` or `5432` are already busy, change `FRONTEND_PORT`, `BACKEND_PORT`, `DB_PORT` and matching URL variables in `.env`

## Key Functionality Details

### Authentication
- JWT-based authentication
- Tokens stored in httpOnly cookies
- Protected backend routes

### AI Text Assistance
- User input is sent to the OpenAI API
- The API returns an improved version of the text with explanations
- The user can choose whether to send the original or improved message

### Chat System
- Chat rooms for communication
- Messages stored in PostgreSQL
- Basic real-time interaction

---

## What I Learned

- Building full-stack applications with Next.js and Express
- Designing REST APIs
- Working with PostgreSQL and Prisma ORM
- Implementing authentication using JWT
- Integrating third-party APIs
- Structuring medium-size web projects

---

## Limitations

- Not optimized for high traffic
- Basic security implementation
- UI/UX can be improved
- AI responses depend on external API quality

---

## Possible Improvements

- Role-based access control
- Improved UI/UX
- Better error handling
- Caching AI responses
- Advanced learning analytics

---

## Author

Mykhailo Rekhman  

---

## License

This project is created for educational purposes.
