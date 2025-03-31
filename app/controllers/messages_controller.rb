class MessagesController < ApplicationController
  # app/controllers/messages_controller.rb
  def create
    @chat_room = ChatRoom.find(params[:chat_room_id])
    @message = @chat_room.messages.new(message_params)
    @message.user = current_user
  
    if @message.save
      # Broadcast the message (no need to render again)
      head :ok
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def add_read_unread
    active_users_ids = User.where(active_chat_room_id: @chat_room.id)&.pluck(:id)

    @chat_room.match.chat_users.each do |user|
      if active_users_ids.include?(user.id.to_i)
        user.message_reads.find_or_create_by(message: @message, read: true)
      else
        user.message_reads.find_or_create_by(message: @message)
      end
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
