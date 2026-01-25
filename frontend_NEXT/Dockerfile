# Production build for Next.js
FROM node:18 AS builder

WORKDIR /app

COPY package*.json ./
COPY . .

RUN npm install
RUN npm run build

# Production image
FROM node:18

WORKDIR /app

COPY --from=builder /app ./

# Порт за замовчуванням для Next.js
EXPOSE 3000

CMD ["npm", "start"]
