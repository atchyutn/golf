class CreateChatRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_rooms do |t|
      t.string :name
      t.references :match, null: false, foreign_key: true

      t.timestamps
    end
  end
end
