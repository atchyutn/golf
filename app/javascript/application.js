// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "@hotwired/turbo-rails";
import "controllers";
// import "jquery2";
import "jquery_ujs";
import "popper";
import "bootstrap";
import "jquery.datetimepicker.full";
import "select2.min";
import "home_page";
import "registration";
import "match";
import "teams";
import "custom";
import "./upcoming_matches"; 
// import Rails from "@rails/ujs";
// Rails.start();

document.addEventListener('turbo:before-stream-render', (event) => {
  const notification = document.getElementById("notifications");
  if (notification) {
    notification.classList.add("highlight");
  }
});

document.addEventListener("turbo:load", () => {
  scrollToBottom();
});

function scrollToBottom() {
  const messages = document.getElementById("messages");
  if (messages) {
    messages.scrollTop = messages.scrollHeight; // Scroll to the latest message
  }
}

function addMessageToChat(message) {
  const messagesContainer = document.getElementById('messages');
  const messageDiv = document.createElement('div');
  messageDiv.className = `message-group ${message.user_id === currentUserId ? 'outgoing' : 'incoming'}`;
  messageDiv.innerHTML = `
    <div class="message-with-avatar">
      <img src="<%= asset_path 'profile-pic-1.jpeg' %>" alt="User avatar" class="avatar" />
      <div class="message">
        <p>${message.content}</p>
      </div>
    </div>
    <div class="message-time">
      ${new Date(message.created_at).toLocaleTimeString()}
    </div>
  `;
  messagesContainer.appendChild(messageDiv);
  scrollToBottom();
}

import "controllers"
