class Message < ApplicationRecord
  belongs_to :chat_room
  belongs_to :user
  has_many :message_reads, dependent: :destroy

  validates :content, presence: true
  after_create :broadcast_message_and_unread_count

  # Check if a user has read the message
  def read_by?(user)
    message_reads.exists?(user:)
  end

  private

  def broadcast_message_and_unread_count
    chat_room.transaction do
      # Broadcast new message to chat room
      broadcast_append_to "chat_room_#{chat_room.id}",
                          target: 'messages',
                          partial: 'messages/message',
                          locals: { message: self, current_user: user } # Pass the sender as current_user
  
      # Notify all other users in the chat room
      chat_room.match.chat_users&.each do |chat_user|
        next if chat_user == user # Skip the sender
  
        unread_count = chat_room.match.unread_message_count_for(chat_user)
  
        # Broadcast unread count to notifications and message button
        broadcast_replace_to "user_#{chat_user.id}_notifications",
                             target: 'notifications',
                             partial: 'notifications/new_message',
                             locals: { unread_count: unread_count, chat_room: chat_room, message: self, user: chat_user }
  
        broadcast_replace_to "user_#{chat_user.id}_notifications",
                             target: 'message_unread_count', # Match the button target
                             partial: 'chat_rooms/unread_count',
                             locals: { unread_count: unread_count, chat_room: chat_room }
  
        # Email chat notifications (send asynchronously)
        UserNotifierMailer.message_notification(chat_user, self, chat_room).deliver_later unless chat_user.online
      end
    end
  end
end
