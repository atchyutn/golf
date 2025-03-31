class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_room_#{params[:room_id]}"
  end

  def receive(data)
    message = @chat_room.messages.create!(user: current_user, content: data["content"])
    ChatRoomChannel.broadcast_to(@chat_room, {
      content: message.content,
      user_name: message.user.full_name,
      created_at: message.created_at.strftime("%I:%M %p"),
      user_id: message.user.id
    })
  end
end
