import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template"]

  add(event) {
    event.preventDefault()

    const index = Date.now().toString()
    const html = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", index)
    this.listTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    event.preventDefault()

    const item = event.currentTarget.closest("[data-certificate-record]")
    if (!item) return

    const destroyInput = item.querySelector("input[name*='[_destroy]']")
    if (destroyInput) {
      destroyInput.value = "1"
      item.classList.add("hidden")
    } else {
      item.remove()
    }
  }
}
