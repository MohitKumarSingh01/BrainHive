/*
  Warnings:

  - The values [LIKE] on the enum `NotificationType` will be removed. If these variants are still used in the database, this will fail.
  - You are about to drop the `Like` table. If the table is not empty, all the data it contains will be lost.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "NotificationType_new" AS ENUM ('GOLDEN_BIRD', 'COMMENT', 'FOLLOW');
ALTER TABLE "Notification" ALTER COLUMN "type" TYPE "NotificationType_new" USING ("type"::text::"NotificationType_new");
ALTER TYPE "NotificationType" RENAME TO "NotificationType_old";
ALTER TYPE "NotificationType_new" RENAME TO "NotificationType";
DROP TYPE "NotificationType_old";
COMMIT;

-- DropForeignKey
ALTER TABLE "Like" DROP CONSTRAINT "Like_postId_fkey";

-- DropForeignKey
ALTER TABLE "Like" DROP CONSTRAINT "Like_userId_fkey";

-- DropTable
DROP TABLE "Like";

-- CreateTable
CREATE TABLE "GoldenBird" (
    "id" TEXT NOT NULL,
    "postId" TEXT NOT NULL,
    "giverId" TEXT NOT NULL,
    "receiverId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "GoldenBird_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "GoldenBird_giverId_receiverId_postId_idx" ON "GoldenBird"("giverId", "receiverId", "postId");

-- CreateIndex
CREATE UNIQUE INDEX "GoldenBird_giverId_postId_key" ON "GoldenBird"("giverId", "postId");

-- AddForeignKey
ALTER TABLE "GoldenBird" ADD CONSTRAINT "GoldenBird_giverId_fkey" FOREIGN KEY ("giverId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GoldenBird" ADD CONSTRAINT "GoldenBird_receiverId_fkey" FOREIGN KEY ("receiverId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GoldenBird" ADD CONSTRAINT "GoldenBird_postId_fkey" FOREIGN KEY ("postId") REFERENCES "Post"("id") ON DELETE CASCADE ON UPDATE CASCADE;
