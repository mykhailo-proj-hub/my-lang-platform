-- CreateTable
CREATE TABLE "archived_practice_tasks" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "question" TEXT NOT NULL,
    "options" TEXT[],
    "correct" TEXT NOT NULL,
    "explanation" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "answer" TEXT,

    CONSTRAINT "archived_practice_tasks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_progress_archive" (
    "id" SERIAL NOT NULL,
    "userProgressId" INTEGER NOT NULL,
    "archivedTaskId" INTEGER NOT NULL,

    CONSTRAINT "user_progress_archive_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "archived_practice_tasks_userId_date_idx" ON "archived_practice_tasks"("userId", "date");

-- CreateIndex
CREATE INDEX "user_progress_archive_userProgressId_idx" ON "user_progress_archive"("userProgressId");

-- CreateIndex
CREATE INDEX "user_progress_archive_archivedTaskId_idx" ON "user_progress_archive"("archivedTaskId");

-- CreateIndex
CREATE UNIQUE INDEX "user_progress_archive_userProgressId_archivedTaskId_key" ON "user_progress_archive"("userProgressId", "archivedTaskId");

-- AddForeignKey
ALTER TABLE "archived_practice_tasks" ADD CONSTRAINT "archived_practice_tasks_userId_fkey" FOREIGN KEY ("userId") REFERENCES "app_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_progress_archive" ADD CONSTRAINT "user_progress_archive_userProgressId_fkey" FOREIGN KEY ("userProgressId") REFERENCES "user_progress"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_progress_archive" ADD CONSTRAINT "user_progress_archive_archivedTaskId_fkey" FOREIGN KEY ("archivedTaskId") REFERENCES "archived_practice_tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
