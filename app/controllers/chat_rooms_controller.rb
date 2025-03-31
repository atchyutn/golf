class ChatRoomsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:mark_as_read]
  before_action :find_chat_room, except: [:show]
  
  def show
    @match = Match.find(params[:match_id])
    @chat_room = @match.ensure_chat_room
    # @user = current_user
    read_unread
    
    @unread_count = @match.unread_message_count_for(current_user)
  end

  def mark_as_read
    @chat_room = ChatRoom.find_by(id: params[:id])

    if @chat_room
      read_unread
      unread_count = @chat_room.match.unread_message_count_for(current_user)

      render json: { unread_count: unread_count }, status: :ok
    else
      render json: { error: "Chat room not found" }, status: :not_found
    end
  end

  def enter
    current_user.update(active_chat_room_id: @chat_room.id)

    render json: { status: "entered", user_id: current_user.id }
  end

  def leave
    current_user.update(active_chat_room_id: nil)

    render json: { status: "left", user_id: current_user.id }
  end

  private

  def read_unread
    @chat_room&.messages.each do |message|
      read_unread = message.message_reads.find_by(user: current_user)
      if read_unread
        read_unread.update(read: true)
      else
        message.message_reads.find_or_create_by(user: current_user, read: true)
      end
    end
  end

  def find_chat_room
    @chat_room = ChatRoom.find_by_id(params[:id] || params[:chat_room_id])
  end
end