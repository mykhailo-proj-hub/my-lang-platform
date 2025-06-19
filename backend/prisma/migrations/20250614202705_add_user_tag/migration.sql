/*
  Warnings:

  - A unique constraint covering the columns `[userTag]` on the table `app_users` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "app_users" ADD COLUMN     "userTag" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "app_users_userTag_key" ON "app_users"("userTag");
