/*
  Warnings:

  - You are about to drop the column `accuracy` on the `user_progress` table. All the data in the column will be lost.
  - You are about to drop the column `correctedMessages` on the `user_progress` table. All the data in the column will be lost.
  - You are about to drop the column `totalMessages` on the `user_progress` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `user_progress` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[userId,date]` on the table `user_progress` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `score` to the `user_progress` table without a default value. This is not possible if the table is not empty.
  - Added the required column `total` to the `user_progress` table without a default value. This is not possible if the table is not empty.

*/
-- DropIndex
DROP INDEX "user_progress_userId_key";

-- AlterTable
ALTER TABLE "user_progress" DROP COLUMN "accuracy",
DROP COLUMN "correctedMessages",
DROP COLUMN "totalMessages",
DROP COLUMN "updatedAt",
ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "score" INTEGER NOT NULL,
ADD COLUMN     "total" INTEGER NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "user_progress_userId_date_key" ON "user_progress"("userId", "date");
