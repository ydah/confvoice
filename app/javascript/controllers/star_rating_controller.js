import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star"]
  static values = { selected: Number }

  connect() {
    this.paint(this.selectedValue || this.checkedValue())
  }

  select(event) {
    const value = Number(event.params.value)
    this.selectedValue = value
    this.paint(value)
  }

  checkedValue() {
    const checked = this.element.querySelector("input[type='radio']:checked")
    return checked ? Number(checked.value) : 0
  }

  paint(value) {
    this.starTargets.forEach((star, index) => {
      star.classList.toggle("text-yellow-400", index < value)
      star.classList.toggle("text-zinc-300", index >= value)
      star.classList.toggle("dark:text-zinc-700", index >= value)
    })
  }
}
