/*
  Warnings:

  - Added the required column `type` to the `corrections` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "corrections" ADD COLUMN     "type" TEXT NOT NULL;

-- CreateTable
CREATE TABLE "correction_theory" (
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "correction_theory_pkey" PRIMARY KEY ("type")
);
