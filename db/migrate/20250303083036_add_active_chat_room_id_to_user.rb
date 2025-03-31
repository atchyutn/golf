class AddActiveChatRoomIdToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :active_chat_room_id, :integer
  end
end
