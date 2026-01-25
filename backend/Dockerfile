FROM node:20-slim

WORKDIR /app

# Копіюємо package.json і встановлюємо залежності
COPY package*.json ./
RUN npm install

# Копіюємо все інше
COPY . .

# Prisma: генерація клієнта
RUN npx prisma generate

EXPOSE 5000

CMD ["npm", "start"]
