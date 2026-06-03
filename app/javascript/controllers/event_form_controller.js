import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startPart",
    "endPart",
    "startDate",
    "startTime",
    "endDate",
    "endTime",
    "startHidden",
    "endHidden"
  ]

  connect() {
    if (this.hasStartHiddenTarget) this.syncHiddenFields()
  }

  syncEndTime() {
    const startTime = this.readDate(this.startPartTargets)
    if (!startTime) return

    const endTime = new Date(startTime.getTime() + (2 * 60 * 60 * 1000))
    this.writeDate(this.endPartTargets, endTime)
  }

  syncFromSimpleFields() {
    const startDate = this.readSimpleStartDate()
    if (!startDate) return

    const endDate = new Date(startDate.getTime() + (2 * 60 * 60 * 1000))
    this.writeSimpleEndDate(endDate)
    this.syncHiddenFields()
  }

  syncHiddenFields() {
    if (this.hasStartHiddenTarget) {
      this.startHiddenTarget.value = this.combinedSimpleValue(this.startDateTarget, this.startTimeTarget)
    }

    if (this.hasEndHiddenTarget) {
      this.endHiddenTarget.value = this.combinedSimpleValue(this.endDateTarget, this.endTimeTarget)
    }
  }

  prepareSubmit() {
    this.syncHiddenFields()
  }

  openDatePicker(event) {
    const targetName = event.currentTarget.dataset.pickerTarget
    const input = this[`${targetName}Target`]
    if (!input) return

    if (typeof input.showPicker === "function") {
      input.showPicker()
    } else {
      input.focus()
    }
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

  readSimpleStartDate() {
    if (!this.hasStartDateTarget || !this.hasStartTimeTarget) return null
    if (!this.startDateTarget.value || !this.startTimeTarget.value) return null

    return new Date(`${this.startDateTarget.value}T${this.startTimeTarget.value}`)
  }

  writeSimpleEndDate(date) {
    if (!this.hasEndDateTarget || !this.hasEndTimeTarget) return

    this.endDateTarget.value = this.formatDate(date)
    this.endTimeTarget.value = this.formatTime(date)
  }

  combinedSimpleValue(dateTarget, timeTarget) {
    if (!dateTarget.value || !timeTarget.value) return ""

    return `${dateTarget.value} ${timeTarget.value}`
  }

  formatDate(date) {
    return [
      date.getFullYear(),
      String(date.getMonth() + 1).padStart(2, "0"),
      String(date.getDate()).padStart(2, "0")
    ].join("-")
  }

  formatTime(date) {
    return [
      String(date.getHours()).padStart(2, "0"),
      String(date.getMinutes()).padStart(2, "0")
    ].join(":")
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
