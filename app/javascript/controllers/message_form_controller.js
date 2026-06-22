import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]

  connect() {
    this.toggleSubmit()
  }

  toggleSubmit() {
    this.submitTarget.disabled = this.inputTarget.value.trim() === ""
  }
}
