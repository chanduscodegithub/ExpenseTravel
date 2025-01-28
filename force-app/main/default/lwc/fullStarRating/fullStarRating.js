import { LightningElement,api,track } from 'lwc';
import fontawesome from '@salesforce/resourceUrl/fontawesome';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class FullStarRating extends LightningElement {
    @api name;
    @api defaultRating;
    @api outerindex;
    @api innerIndex;
    @api noedit;

    @track check1;
    @track check2;
    @track check3;
    @track check4;
    @track check5;

    @track rating1;
    @track rating2;
    @track rating3;
    @track rating4;
    @track rating5;

    renderedCallback(){
        Promise.all([
            loadStyle(this, fontawesome + "/font-awesome-4.7.0/css/font-awesome.css")
        ]).then(() => {
            //console.log("success" + fontawesome);
        }).catch(error => {
            console.log(error);
        });
    }

    connectedCallback(){

        //this.name = 'name'+ this.outerindex + '' + this.innerIndex;

        this.rating1 = 'rating1' + this.outerindex + '' + this.innerIndex;
        this.rating2 = 'rating2' + this.outerindex + '' + this.innerIndex;
        this.rating3 = 'rating3' + this.outerindex + '' + this.innerIndex;
        this.rating4 = 'rating4' + this.outerindex + '' + this.innerIndex;
        this.rating5 = 'rating5' + this.outerindex + '' + this.innerIndex;

        if (this.defaultRating != null && this.defaultRating != '0') {
            if (this.defaultRating === '5') {
                this.check5 = true;
            } else if (this.defaultRating === '4') {
                this.check4 = true;
            } else if (this.defaultRating === '3') {
                this.check3 = true;
            } else if (this.defaultRating === '2') {
                this.check2 = true;
            }  else if (this.defaultRating === '1') {
                this.check1 = true;
            } 
        }
    }

    rating(event){
        if (this.noedit === true){
            return;
        }
        console.log(event.target.value);

        this.defaultRating = event.target.value;
        const formdata = { rating: this.defaultRating, outerindex: this.outerindex, innerIndex: this.innerIndex, questionName : this.name }

        const sendSelectedStar = new CustomEvent('ratingclick', { 
            detail: formdata 
        });
        this.dispatchEvent(sendSelectedStar);
      }
}