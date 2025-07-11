import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]
  static values = { url: String }

  export(event) {
    event.preventDefault()
    const cols = this.checkboxTargets.filter(cb => cb.checked).map(cb => cb.value)
    if (cols.length === 0) { return }
    const query = cols.map(c => `columns[]=${encodeURIComponent(c)}`).join("&")
    window.location = `${this.urlValue}?${query}`
  }
}