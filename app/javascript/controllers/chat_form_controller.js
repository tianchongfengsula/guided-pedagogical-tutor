// app/javascript/controllers/chat_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]
  
  submit(event) {
    this.submitTarget.disabled = true
    this.submitTarget.textContent = "Thinking..."
  }
  
  reset() {
    this.inputTarget.value = ""
    this.inputTarget.style.height = "auto"
    this.submitTarget.disabled = false
    this.submitTarget.textContent = "Send"
    this.inputTarget.focus()
  }
  
  handleKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      event.target.form.requestSubmit()
    }
  }
  
  autoResize(event) {
    event.target.style.height = "auto"
    event.target.style.height = Math.min(event.target.scrollHeight, 200) + "px"
  }
}
