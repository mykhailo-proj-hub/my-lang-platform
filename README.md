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

my-lang-platform/
├── frontend/
├── backend/
├── prisma/
├── public/
├── README.md
└── package.json

---

## Installation and Local Setup

### 1. Clone the repository
git clone https://github.com/mykhailo-proj-hub/my-lang-platform.git
cd my-lang-platform

### 2. Configure environment variables

Create a .env file in the backend directory:

PORT=5000
DATABASE_URL=postgresql://postgres:password@db:5432/lang_platformdb
JWT_SECRET=your_jwt_secret
OPENAI_API_KEY=your_openai_api_key

### 3. Build Docker images
docker compose build

### 4. Start the database
docker compose up -d

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
