import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="file-upload"
// Handles dynamic file upload fields with "add another file" functionality
export default class extends Controller {
  static targets = ["container", "template"]
  static values = { category: String }

  connect() {
    this.fileCount = 1
  }

  addFile(event) {
    event.preventDefault()
    this.fileCount++

    const newField = document.createElement("div")
    newField.className = "input-group mb-2"
    newField.innerHTML = `
      <input type="file"
             name="application[uploaded_files][]"
             class="form-control"
             data-file-upload-target="input"
             data-category="${this.categoryValue}"
             accept=".pdf,.doc,.docx,.jpg,.jpeg,.png,.gif">
      <button type="button"
              class="btn btn-outline-danger"
              data-action="click->file-upload#removeFile">
        <i class="fas fa-times"></i> Remove
      </button>
    `

    this.containerTarget.appendChild(newField)
  }

  removeFile(event) {
    event.preventDefault()
    const inputGroup = event.target.closest(".input-group")
    if (inputGroup && this.containerTarget.children.length > 1) {
      inputGroup.remove()
    }
  }
}
