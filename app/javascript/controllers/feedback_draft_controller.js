import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field"]
  static values = { key: String }

  connect() {
    this.restore()
  }

  save() {
    if (!this.hasKeyValue) return

    try {
      this.storage().setItem(this.keyValue, JSON.stringify(this.formData()))
    } catch {
      // Draft persistence is best-effort; feedback submission must keep working.
    }
  }

  restore() {
    if (!this.hasKeyValue) return

    const draft = this.readDraft()
    if (!draft) return

    this.fieldTargets.forEach((field) => {
      if (field.value.length > 0) return

      const value = draft[field.name]
      if (value === undefined) return

      field.value = value
      field.dispatchEvent(new Event("input", { bubbles: true }))
    })
  }

  formData() {
    return this.fieldTargets.reduce((data, field) => {
      data[field.name] = field.value
      return data
    }, {})
  }

  readDraft() {
    let rawDraft

    try {
      rawDraft = this.storage().getItem(this.keyValue)
    } catch {
      return null
    }

    if (!rawDraft) return null

    try {
      return JSON.parse(rawDraft)
    } catch {
      try {
        this.storage().removeItem(this.keyValue)
      } catch {
        // Ignore cleanup errors for the same reason as save errors.
      }
      return null
    }
  }

  storage() {
    return window.sessionStorage
  }
}
