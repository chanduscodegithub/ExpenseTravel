import { LightningElement, api, track } from 'lwc';
import getInterviews from '@salesforce/apex/InterviewLightningController.getInterviews';

const columns = [
    {
        label: 'Interview',
        fieldName: 'InterviewUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Interview' }, 
            target: '_blank' 
        },
        initialWidth: 110
    },
    { label: 'Interviewer Name', fieldName: 'InterviewerName', type: 'text',initialWidth: 150},
    { label: 'Status', fieldName: 'Status', type: 'text',initialWidth: 150,wrapText:true },
    { label: 'Rating', fieldName: 'Rating', type: 'decimal',initialWidth: 85 },
    { label: 'Assessment', fieldName: 'Assessment', type: 'text',initialWidth: 328,wrapText:true }
];

export default class InterviewDataTableComponent extends LightningElement {
    @track interviewData = [];
    @track error;
    columns = columns;
    _recordId;
    @track isDataPresent = false;
    @track CandidateName;
    @track PositionName;
    @track PositionNumber;

    @api
    set recordId(value) {
        this._recordId = value;
        this.loadInterviews();
    }

    get recordId() {
        return this._recordId;
    }

    loadInterviews() {
        console.log('this._recordId>>>', this._recordId);
        getInterviews({ jobApplicationId: this._recordId })
            .then(result => {
                this.interviewData = result.map(interview => {
                    return {
                        ...interview,
                        InterviewUrl: `/lightning/r/${interview.Id}/view`
                    };
                });

                if (this.interviewData.length > 0) {
                    this.isDataPresent = true;
                    this.CandidateName = this.interviewData[0].CandidateName;
                    this.PositionName = this.interviewData[0].PositionName;
                    this.PositionNumber = this.interviewData[0].PositionNumber;
                }
                console.log('this.interviewData>>>', JSON.stringify(this.interviewData));
            })
            .catch(error => {
                this.error = error;
                console.log('error>>>', JSON.stringify(this.error));
            });
    }

    connectedCallback() {
        if (this._recordId) {
            this.loadInterviews();
        }
    }
}