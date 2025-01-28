import { LightningElement, api } from 'lwc';

const COLUMNS = [
    {
        label: 'Date',
        fieldName: 'Date__c',
        type: 'date',
        typeAttributes: {
            year: '2-digit',
            month: 'short',
            day: '2-digit',
            weekday: 'long'
        }
    },
    {
        label: 'Holiday Name',
        fieldName: 'Name',
        type: 'Date'
    },
    {
        label: 'Holiday Type',
        fieldName: 'Holiday_Type__c',
        type: 'text'
    }
]

export default class HolidayComponent extends LightningElement {
    columns = COLUMNS;
    @api holidays;
}