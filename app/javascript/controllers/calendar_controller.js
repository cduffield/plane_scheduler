import { Controller } from "@hotwired/stimulus"
import { Calendar } from "@fullcalendar/core"
import dayGridPlugin from "@fullcalendar/daygrid"
import timeGridPlugin from "@fullcalendar/timegrid"
import interactionPlugin from "@fullcalendar/interaction"
import listPlugin from "@fullcalendar/list"

export default class extends Controller {
  static targets = ["calendar", "aircraftFilter"]

  static values = {
    eventsUrl: String
  }

  connect() {
    this.calendar = new Calendar(this.calendarElement, {
      plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin],
      initialView: "dayGridMonth",
      headerToolbar: {
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth,timeGridWeek,timeGridDay"
      },
      buttonText: {
        today: "Today",
        month: "Month",
        week: "Week",
        day: "Day"
      },
      dayHeaderFormat: {
        weekday: "short",
        month: "short",
        day: "numeric"
      },
      nowIndicator: true,
      navLinks: true,
      selectable: true,
      eventTimeFormat: {
        hour: "2-digit",
        minute: "2-digit",
        meridiem: false
      },
      eventContent: this.renderEventContent.bind(this),
      events: this.fetchEvents.bind(this),
      height: "auto"
    })

    this.calendar.render()
  }

  refetch() {
    this.calendar?.refetchEvents()
  }

  disconnect() {
    if (this.calendar) this.calendar.destroy()
  }

  get calendarElement() {
    return this.hasCalendarTarget ? this.calendarTarget : this.element
  }

  fetchEvents(_fetchInfo, successCallback, failureCallback) {
    const url = new URL(this.eventsUrlValue, window.location.origin)

    if (this.hasAircraftFilterTarget && this.aircraftFilterTarget.value) {
      url.searchParams.set("airplane_id", this.aircraftFilterTarget.value)
    }

    fetch(url)
      .then((response) => {
        if (!response.ok) throw new Error(`Calendar request failed with ${response.status}`)
        return response.json()
      })
      .then(successCallback)
      .catch(failureCallback)
  }

  renderEventContent(eventInfo) {
    const time = document.createElement("span")
    time.className = "sky-calendar-event-time"
    time.textContent = eventInfo.timeText

    const title = document.createElement("span")
    title.className = "sky-calendar-event-title"
    title.textContent = eventInfo.event.title

    const wrapper = document.createElement("span")
    wrapper.className = "sky-calendar-event-block"
    wrapper.style.backgroundColor = eventInfo.event.extendedProps.blockColor || eventInfo.event.backgroundColor || "#0067c9"
    wrapper.append(time, " ", title)

    return { domNodes: [wrapper] }
  }
}
