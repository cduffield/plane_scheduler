import { Controller } from "@hotwired/stimulus"
import { Calendar } from "@fullcalendar/core"
import dayGridPlugin from "@fullcalendar/daygrid"
import timeGridPlugin from "@fullcalendar/timegrid"
import interactionPlugin from "@fullcalendar/interaction"
import listPlugin from "@fullcalendar/list"

export default class extends Controller {
  static values = {
    eventsUrl: String
  }

  connect() {
    this.calendar = new Calendar(this.element, {
      plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin],
      initialView: "timeGridWeek",
      headerToolbar: {
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth,timeGridWeek,timeGridDay,listWeek"
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
        hour: "numeric",
        minute: "2-digit",
        meridiem: "short"
      },
      events: this.eventsUrlValue,
      height: "auto"
    })

    this.calendar.render()
  }

  disconnect() {
    if (this.calendar) this.calendar.destroy()
  }
}
