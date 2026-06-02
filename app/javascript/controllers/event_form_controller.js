import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startPart", "endPart"]

  syncEndTime() {
    const startTime = this.readDate(this.startPartTargets)
    if (!startTime) return

    const endTime = new Date(startTime.getTime() + (2 * 60 * 60 * 1000))
    this.writeDate(this.endPartTargets, endTime)
  }

  readDate(parts) {
    const year = this.valueFor(parts, "1i")
    const month = this.valueFor(parts, "2i")
    const day = this.valueFor(parts, "3i")
    const hour = this.valueFor(parts, "4i")
    const minute = this.valueFor(parts, "5i")

    if ([year, month, day, hour, minute].some((value) => value === null)) return null

    return new Date(year, month - 1, day, hour, minute)
  }

  writeDate(parts, date) {
    this.assignValue(parts, "1i", date.getFullYear())
    this.assignValue(parts, "2i", date.getMonth() + 1)
    this.assignValue(parts, "3i", date.getDate())
    this.assignValue(parts, "4i", date.getHours())
    this.assignValue(parts, "5i", date.getMinutes())
  }

  valueFor(parts, suffix) {
    const part = parts.find((element) => element.name.endsWith(`[${suffix}]`))
    return part ? Number(part.value) : null
  }

  assignValue(parts, suffix, value) {
    const part = parts.find((element) => element.name.endsWith(`[${suffix}]`))
    if (!part) return

    part.value = String(value)
    part.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
