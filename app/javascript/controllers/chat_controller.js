import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages"]

  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    const messages = document.getElementById('messages'); 
    setTimeout(() => {
        messages.scrollTop = messages.scrollHeight;
    }, 100);

    const inputField = document.getElementById("message_form");
    inputField.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            setTimeout(() => {
                messages.scrollTop = messages.scrollHeight;
            }, 100);
        }
    });
}

  resetForm() {
    // Your custom form reset logic
    document.getElementById("message_form").reset()
  }
}

// Listen for Turbo Streams events
document.addEventListener("turbo:before-stream-render", (event) => {
  const chatController = document.querySelector("[data-controller='chat']")
  if (chatController) {
    const controller = Stimulus.getControllerForElementAndIdentifier(chatController, "chat")
    controller.resetForm() // Call your custom form reset logic
  }
})

document.addEventListener("turbo:after-stream-render", (event) => {
  const chatController = document.querySelector("[data-controller='chat']")
  if (chatController) {
    const controller = Stimulus.getControllerForElementAndIdentifier(chatController, "chat")
    controller.scrollToBottom()
  }
})