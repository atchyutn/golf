// app/javascript/channels/chat_room_channel.js
import consumer from "./consumer"

document.addEventListener("turbo:load", () => {
  const chatRoomElement = document.getElementById("chat-room");

  if (chatRoomElement) {
    const roomId = chatRoomElement.getAttribute("data-room-id");

    consumer.subscriptions.create({ channel: "ChatRoomChannel", room_id: roomId }, {
      connected() {
        console.log(`Connected to ChatRoom ${roomId}`);
      },

      disconnected() {
        console.log(`Disconnected from ChatRoom ${roomId}`);
      },

      received(data) {
        const messages = document.getElementById("messages");
        messages.insertAdjacentHTML("beforeend", data);
      }
    });
  }
});
