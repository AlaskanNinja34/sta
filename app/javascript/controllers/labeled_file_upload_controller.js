import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="labeled-file-upload"
// Handles dynamic file upload fields with labels for document identification
export default class extends Controller {
  static targets = ["container"]
  static values = { category: String }

  connect() {
    this.fileCount = 1
  }

  addFile(event) {
    event.preventDefault()
    this.fileCount++

    const newField = document.createElement("div")
    newField.className = "row mb-3 align-items-end"
    newField.innerHTML = `
      <div class="col-md-4">
        <label class="form-label">Document Label</label>
        <input type="text"
               name="application[file_labels][]"
               class="form-control"
               placeholder="e.g., High School Transcript">
      </div>
      <div class="col-md-7">
        <label class="form-label">File</label>
        <input type="file"
               name="application[uploaded_files][]"
               class="form-control"
               data-category="${this.categoryValue}"
               accept=".pdf,.doc,.docx,.jpg,.jpeg,.png,.gif">
      </div>
      <div class="col-md-1">
        <button type="button"
                class="btn btn-outline-danger btn-sm"
                data-action="click->labeled-file-upload#removeFile"
                title="Remove">
          <i class="fas fa-times"></i>
        </button>
      </div>
    `

    this.containerTarget.appendChild(newField)
  }

  removeFile(event) {
    event.preventDefault()
    const row = event.target.closest(".row")
    if (row && this.containerTarget.children.length > 1) {
      row.remove()
    }
  }
}
