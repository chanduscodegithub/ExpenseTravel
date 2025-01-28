export function getWfaColoum() {
    const coloum1 = [{

        label: 'Employee Name',
        fieldName: 'empName',
        type: 'text',
        sortable: "true"
    },
    {
        label: 'Attendence Day',
        fieldName: 'attendenceDay',
        type: 'date',
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        },
        sortable: "true"

    },
    {
        label: 'Check In - Old',
        fieldName: 'checkInOld',
        type: 'date',
        typeAttributes: {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        }
    },
    {
        label: 'Check In - New',
        fieldName: 'checkInNew',
        type: 'date',
        typeAttributes: {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        }
    },
    {
        label: 'Check Out - Old',
        fieldName: 'checkOutOld',
        type: 'date',
        typeAttributes: {
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
            hour12: true
        }
    },
    {
        label: 'Check Out - New',
        fieldName: 'checkOutNew',
        type: 'date',
        typeAttributes: {
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
            hour12: true
        }
    },
    {
        label: 'Duration - Old',
        fieldName: 'durationOld',
        type: 'text'
    },
    {
        label: 'Duration - New',
        fieldName: 'durationNew',
        type: 'text'
    },
    {
        label: 'Reason',
        fieldName: 'Reason',
        type: 'text'
    },
    {
        label: 'Employee Comments',
        fieldName: 'empComment',
        type: 'text'
    }];
    return coloum1;
}

export function getAppdColoum() {
    const coloum2 = [{

        label: 'Employee Name',
        fieldName: 'empName',
        type: 'text'
    },
    {
        label: 'Attendence Day',
        fieldName: 'attendenceDay',
        type: 'date',
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'Check In',
        fieldName: 'checkInOld',
        type: 'date',
        typeAttributes: {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        }
    },
    {
        label: 'Check Out',
        fieldName: 'checkOutOld',
        type: 'date',
        typeAttributes: {
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
            hour12: true
        }
    },
    {
        label: 'Duration - Old',
        fieldName: 'durationOld',
        type: 'text'
    }];
    return coloum2;
}

export function getRejectedColoum() {
    const coloum3 = [{

        label: 'Employee Name',
        fieldName: 'empName',
        type: 'text',
        sortable: "true"
    },
    {
        label: 'Attendence Day',
        fieldName: 'attendenceDay',
        type: 'date',
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        },
        sortable: "true"

    },
    {
        label: 'Check In - Old',
        fieldName: 'checkInOld',
        type: 'date',
        typeAttributes: {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        }
    },
    {
        label: 'Check In - New',
        fieldName: 'checkInNew',
        type: 'date',
        typeAttributes: {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        }
    },
    {
        label: 'Check Out - Old',
        fieldName: 'checkOutOld',
        type: 'date',
        typeAttributes: {
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
            hour12: true
        }
    },
    {
        label: 'Check Out - New',
        fieldName: 'checkOutNew',
        type: 'date',
        typeAttributes: {
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
            hour12: true
        }
    },
    {
        label: 'Duration - Old',
        fieldName: 'durationOld',
        type: 'text'
    },
    {
        label: 'Duration - New',
        fieldName: 'durationNew',
        type: 'text'
    },
    {
        label: 'Reason',
        fieldName: 'Reason',
        type: 'text'
    },
    {
        label: 'Employee Comments',
        fieldName: 'empComment',
        type: 'text'
    },
    {
        label: 'Manager Comments',
        fieldName: 'mangComment',
        type: 'text'
    }];
    return coloum3;
}