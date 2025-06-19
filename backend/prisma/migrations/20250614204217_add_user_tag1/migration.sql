/*
  Warnings:

  - Made the column `userTag` on table `app_users` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "app_users" ALTER COLUMN "userTag" SET NOT NULL;
