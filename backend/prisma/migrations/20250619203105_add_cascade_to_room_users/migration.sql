-- DropForeignKey
ALTER TABLE "room_users" DROP CONSTRAINT "room_users_roomId_fkey";

-- AddForeignKey
ALTER TABLE "room_users" ADD CONSTRAINT "room_users_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES "chat_rooms"("id") ON DELETE CASCADE ON UPDATE CASCADE;
