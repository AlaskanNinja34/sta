import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="required-field"
// Hides the required indicator when field has content or is selected
export default class extends Controller {
  static targets = ["indicator"]

  connect() {
    this.checkField()
  }

  checkField() {
    if (!this.hasIndicatorTarget) return

    let hasValue = false

    // Check for radio buttons first
    const radios = this.element.querySelectorAll('input[type="radio"]')
    if (radios.length > 0) {
      hasValue = Array.from(radios).some(radio => radio.checked)
    } else {
      // Check for regular inputs, selects, and textareas
      const input = this.element.querySelector('input, select, textarea')
      if (input) {
        if (input.type === 'checkbox') {
          hasValue = input.checked
        } else {
          hasValue = input.value && input.value.trim() !== ''
        }
      }
    }

    this.indicatorTarget.style.display = hasValue ? 'none' : 'inline'
  }

  // Called on input/change events
  update() {
    this.checkField()
  }
}
