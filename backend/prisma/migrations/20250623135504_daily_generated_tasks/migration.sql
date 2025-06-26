-- CreateTable
CREATE TABLE "daily_generated_tasks" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "question" TEXT NOT NULL,
    "options" TEXT[],
    "correct" TEXT NOT NULL,
    "explanation" TEXT NOT NULL,
    "type" TEXT NOT NULL,

    CONSTRAINT "daily_generated_tasks_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "daily_generated_tasks_userId_date_idx" ON "daily_generated_tasks"("userId", "date");

-- AddForeignKey
ALTER TABLE "daily_generated_tasks" ADD CONSTRAINT "daily_generated_tasks_userId_fkey" FOREIGN KEY ("userId") REFERENCES "app_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
