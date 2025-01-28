import { LightningElement, track, api } from 'lwc';
import fullCalendar from '@salesforce/resourceUrl/FullCalendar';
import fullCalendarCustom from '@salesforce/resourceUrl/fullCalendarCustom';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class CalenderViewParent extends LightningElement {

    @track calendar;
    @track calendarLabel;
    @track initialized = false;
    @track recId;
    @track objRecordId;

    @api allAttendenceRecords;

    viewOptions = [
        {
            label: 'Day',
            viewName: 'timeGridDay',
            checked: false
        },
        {
            label: 'Week',
            viewName: 'timeGridWeek',
            checked: false
        },
        {
            label: 'List Week',
            viewName: 'listWeek',
            checked: false
        },
        {
            label: 'Month',
            viewName: 'dayGridMonth',
            checked: true
        }
    ];

    @api
    get events() {
        return this._events;
    }
    set events(value) {
        this._events = [...value];
    }


    @api
    get eventDataString() {
        return this.events;
    }
    set eventDataString(value) {
        try {
            this.events = eval(value);
        }
        catch{
            this.events = [];
        }
    }

    async renderedCallback() {

        if (this.initialized) {
            return
        }

        this.initialized = true
        try {
            await Promise.all([
                loadScript(this, fullCalendar + "/packages/core/main.js"),
                loadStyle(this, fullCalendar + "/packages/core/main.css")
            ])

            //First Loaded Core NOw Loading grids,list,moment functions 
            await Promise.all([
                loadScript(this, fullCalendar + "/packages/daygrid/main.js"),
                loadStyle(this, fullCalendar + "/packages/daygrid/main.css"),
                loadScript(this, fullCalendar + "/packages/list/main.js"),
                loadStyle(this, fullCalendar + "/packages/list/main.css"),
                loadScript(this, fullCalendar + "/packages/timegrid/main.js"),
                loadStyle(this, fullCalendar + "/packages/timegrid/main.css"),
                loadScript(this, fullCalendar + "/packages/interaction/main.js"),
                loadScript(this, fullCalendar + "/packages/moment/main.js"),
                loadScript(this, fullCalendar + "/packages/moment-timezone/main.js"),
                loadStyle(this, fullCalendarCustom)
            ])
            //create calendar and render
            this.init()

        } catch (error) {

            console.error("error", error)
        }
    }

    calendarActionsHandler(event) {
        const actionName = event.target.value;
        if (actionName === 'previous') {
            this.calendar.prev();
        } else if (actionName === 'next') {
            this.calendar.next();
        } else if (actionName === 'today') {
            this.calendar.today();
        } else if (actionName === 'refresh') {
            this.dispatchEvent(new CustomEvent('refresh', {
                detail: {
                    message: 'refresh'
                }
            }));
        }
        this.calendarLabel = this.calendar.view.title;
    }

    changeViewHandler(event) {
        const viewName = event.detail.value;

        this.calendar.changeView(viewName);
        const viewOptions = [...this.viewOptions];
        for (let viewOption of viewOptions) {
            viewOption.checked = false;
            if (viewOption.viewName === viewName) {
                viewOption.checked = true;
            }
        }
        this.viewOptions = viewOptions;
        this.calendarLabel = this.calendar.view.title;
    }

    @api
    refreshCalender() {
        // Refetch and update events
        this.calendar.removeAllEvents();
        this.calendar.addEventSource(this.events);

        // Redraw the calendar
        this.calendar.refetchEvents();
        this.calendar.rerenderEvents();
        this.calendar.render();

        this.calendarLabel = this.calendar.view.title;
    }

    init() {
        const calendarEl = this.template.querySelector(".calendar")

        this.calendar = new FullCalendar.Calendar(calendarEl, {
            plugins: ["dayGridMonth", "dayGrid", "timeGrid", "list", "interaction", "moment"],
            initialView: 'dayGridMonth',
            initialDate: new Date(),
            navLinks: true,
            editable: true,
            weekNumbers: false,
            headerToolbar: false,
            header: false,
            showNonCurrentDates: true,
            fixedWeekCount: false,
            events: this.events,
            eventStartEditable: false,
            eventClick: info => {
                const selectedEvent = new CustomEvent('eventclicked', { detail: info.event.id });
                this.dispatchEvent(selectedEvent);
            },
            
        });

        this.calendar.setOption('contentHeight', 450)

        this.calendar.render();
        this.calendarLabel = this.calendar.view.title;
    }
}