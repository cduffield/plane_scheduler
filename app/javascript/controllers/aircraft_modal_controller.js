import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  open() {
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.setAttribute("aria-hidden", "false")
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.setAttribute("aria-hidden", "true")
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) this.close()
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.close()
  }
}
