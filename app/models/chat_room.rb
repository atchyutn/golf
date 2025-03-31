class ChatRoom < ApplicationRecord
  belongs_to :match
  has_many :messages, dependent: :destroy
  before_create :add_room_name
  
  def add_room_name
    self.name =  "chat_rooms_#{match.id}"
  end
end
