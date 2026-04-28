import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["container", "input", "submitBtn", "stopBtn", "loaderTemplate"]

  connect() {
    console.log("Chat controller CONNECTED!")
    this.scroll()
    this.setupScrollObserver()

    // Listen for the "streaming is truly done" signal from server
    this.boundReset = this.reset.bind(this)
    document.addEventListener("streaming:done", this.boundReset)

    // Register custom Turbo Stream action (safe to re-register)
    Turbo.StreamActions.streamingDone = () => {
      document.dispatchEvent(new CustomEvent("streaming:done"))
    }
  }

  disconnect() {
    this.observer.disconnect()
    document.removeEventListener("streaming:done", this.boundReset)
  }

  setupScrollObserver() {
    this.observer = new MutationObserver(() => this.scroll())
    this.observer.observe(document.getElementById("messages"), {
      childList: true,
      subtree: true
    })
  }

  submitForm() {
    const message = this.inputTarget.value.trim()
    if (!message) return

    const form = this.inputTarget.form
    form.requestSubmit()
    this.inputTarget.value = ""
    this.inputTarget.disabled = true
    this.submitBtnTarget.classList.add("hidden")
    this.stopBtnTarget.classList.remove("hidden")
    this.scroll()
  }

  handleEnter(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.submitForm()
    }
  }

  stopStreaming() {
    fetch('/stop', {
      method: 'DELETE',
      headers: { 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content }
    })
    this.reset()
  }

  scroll() {
    this.containerTarget.scrollTo({
      top: this.containerTarget.scrollHeight,
      behavior: 'smooth'
    })
  }

  reset() {
    this.inputTarget.disabled = false
    this.inputTarget.focus()
    this.submitBtnTarget.classList.remove("hidden")
    this.stopBtnTarget.classList.add("hidden")
    this.scroll()
  }
}
