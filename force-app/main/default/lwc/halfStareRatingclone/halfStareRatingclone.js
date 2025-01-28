import { LightningElement, track, api } from "lwc";
import fontawesome from '@salesforce/resourceUrl/fontawesomecopy';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HalfStareRatingclone extends LightningElement {
    @api defaultRating;
    @api outerindex;
    @api innerIndex;
    @api noedit;
    @api noeditManager;

    @track selectedRating;
    @track check1;
    @track check1;
    @track check2;
    @track check3;
    @track check4;
    @track check5;
    @track check6;
    @track check7;
    @track check8;
    @track check9;
    @track check10;

    @track rating1;
    @track rating2;
    @track rating3;
    @track rating4;
    @track rating5;
    @track rating6;
    @track rating7;
    @track rating8;
    @track rating9;
    @track rating10;

    @track name;


    renderedCallback() {
        Promise.all([
            loadStyle(this, fontawesome + "/font-awesome-4.7.0/css/font-awesome.css")
            //loadScript(this, fontawesome + 'fontawesome/fontawesome-free-6.0.0-web/js/fontawesome.min.js')
        ]).then(() => {
            //console.log("success" + fontawesome);
        }).catch(error => {
            //console.log("HI");
            // eslint-disable-next-line no-console

            console.log(error);

        });

    }

    connectedCallback() {



        //console.log('validate::' + (this.noeditManager != undefined ? ('' + this.innerIndex) : ''));



        this.name = 'name' + this.outerindex + '' + this.innerIndex + (this.noeditManager != undefined ? ('' + this.innerIndex) : '');

        this.rating1 = 'rating1' + this.outerindex + '' + this.innerIndex + (this.noeditManager != undefined ? ('' + this.innerIndex) : '');
        this.rating2 = 'rating2' + this.outerindex + '' + this.innerIndex + (this.noeditManager != undefined ? ('' + this.innerIndex) : '');
        this.rating3 = 'rating3' + this.outerindex + '' + this.innerIndex + (this.noeditManager != undefined ? ('' + this.innerIndex) : '');
        this.rating4 = 'rating4' + this.outerindex + '' + this.innerIndex + (this.noeditManager != undefined ? ('' + this.innerIndex) : '');
        this.rating5 = 'rating5' + this.outerindex + '' + this.innerIndex + (this.noeditManager != undefined ? ('' + this.innerIndex) : '');
        this.rating6 = 'rating6' + this.outerindex + '' + this.innerIndex + (this.noeditManager != undefined ? ('' + this.innerIndex) : '');
        this.rating7 = 'rating7' + this.outerindex + '' + this.innerIndex + (this.noeditManager != undefined ? ('' + this.innerIndex) : '');
        this.rating8 = 'rating8' + this.outerindex + '' + this.innerIndex + (this.noeditManager != undefined ? ('' + this.innerIndex) : '');
        this.rating9 = 'rating9' + this.outerindex + '' + this.innerIndex + (this.noeditManager != undefined ? ('' + this.innerIndex) : '');
        this.rating10 = 'rating10' + this.outerindex + '' + this.innerIndex + (this.noeditManager != undefined ? ('' + this.innerIndex) : '');

        //console.log('rating::' + this.rating1);
        //console.log('rating::' + this.name);
        //console.log('this.check10' + this.check10);



        if (this.defaultRating != null && this.defaultRating != '0') {
            //console.log('Enter check::'+this.noeditManager);
            if (this.defaultRating === '5') {
                this.check10 = true;
                //console.log('check10::'+this.check10);
            } else if (this.defaultRating === '4.5') {
                this.check9 = true;
            } else if (this.defaultRating === '4') {
                this.check8 = true;
            } else if (this.defaultRating === '3.5') {
                this.check7 = true;
            } else if (this.defaultRating === '3') {
                this.check6 = true;
                //console.log(this.check6);
            } else if (this.defaultRating === '2.5') {
                this.check5 = true;
            } else if (this.defaultRating === '2') {
                this.check4 = true;
            } else if (this.defaultRating === '1.5') {
                this.check3 = true;
            } else if (this.defaultRating === '1') {
                this.check2 = true;
            } else if (this.defaultRating === '0.5') {
                this.check1 = true;
            }
        }
    }

    handleRatingClick(event) {

        if (this.noedit === true) {
            return;
        }
        console.log('Hi:da');
        this.defaultRating = event.target.value;
        const formdata = {
            rating: this.defaultRating,
            outerindex: this.outerindex,
            innerIndex: this.innerIndex
        }
        //console.log(formdata);
        //console.log('@@')
        const selectedEvent = new CustomEvent(
            'ratingclicking',
            { detail: formdata }
        );
        this.dispatchEvent(selectedEvent);
    }
}