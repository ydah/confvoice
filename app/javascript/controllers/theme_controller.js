import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "confvoice-theme"
const ACTIVE_CLASSES = ["bg-zinc-950", "text-white", "shadow-sm", "dark:bg-zinc-50", "dark:text-zinc-950"]
const INACTIVE_CLASSES = ["text-zinc-500", "dark:text-zinc-400"]

export default class extends Controller {
  static targets = ["lightLabel", "darkLabel"]

  connect() {
    this.sync()
  }

  toggle() {
    this.setTheme(this.dark ? "light" : "dark")
  }

  setTheme(theme) {
    try {
      localStorage.setItem(STORAGE_KEY, theme)
    } catch (_) {
      // Ignore storage failures; the current page can still switch themes.
    }

    document.documentElement.classList.toggle("dark", theme === "dark")
    document.documentElement.dataset.theme = theme
    this.sync()
  }

  sync() {
    const dark = this.dark

    this.element.setAttribute("aria-pressed", dark ? "true" : "false")
    this.setLabelState(this.lightLabelTarget, !dark)
    this.setLabelState(this.darkLabelTarget, dark)
  }

  setLabelState(label, active) {
    ACTIVE_CLASSES.forEach((className) => label.classList.toggle(className, active))
    INACTIVE_CLASSES.forEach((className) => label.classList.toggle(className, !active))
  }

  get dark() {
    return document.documentElement.classList.contains("dark")
  }
}
