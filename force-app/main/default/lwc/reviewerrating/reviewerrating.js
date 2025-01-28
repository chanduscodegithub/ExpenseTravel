import { LightningElement,track, api } from 'lwc';
import fontawesome from '@salesforce/resourceUrl/fontawesomecopy';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader'
export default class Reviewerrating extends LightningElement {
 
  

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
    @api defaultRating;
    @api disabledit;
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
    @api noedit;

  


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
        //console.log('this.defaultRating',this.defaultRating);
        this.name = 'name' +this.defaultRating;
        this.rating1 = 'rating1' 
        this.rating2 = 'rating2' 
        this.rating3 = 'rating3' 
        this.rating4 = 'rating4' 
        this.rating5 = 'rating5'
        this.rating6 = 'rating6' 
        this.rating7 = 'rating7'
        this.rating8 = 'rating8'
        this.rating9 = 'rating9' 
        this.rating10 = 'rating10'


        if (this.defaultRating != null && this.defaultRating != '0') {
            //console.log(this.defaultRating);
            //console.log('this.defaultRating',typeof(this.defaultRating));
            if (String(this.defaultRating) === '5') {
                this.check10 = true;
            } else if (String(this.defaultRating) === '4.5') {
                this.check9 = true;
            } else if (String(this.defaultRating) === '4') {
                this.check8 = true;
                //console.log('this.check6',  this.check8);
            } else if (String(this.defaultRating) === '3.5') {
                
                this.check7 = true;
                 //console.log('this.check6', this.check7);
            } else if (String(this.defaultRating) === '3') {
                this.check6 = true;
                //console.log('this.check6', this.check6);
            } else if (String(this.defaultRating) === '2.5') {
                this.check5 = true;
            } else if (String(this.defaultRating)=== '2') {
                this.check4 = true;
            } else if (String(this.defaultRating) === '1.5') {
                this.check3 = true;
            } else if (String(this.defaultRating) === '1') {
                this.check2 = true;
            } else if (String(this.defaultRating) === '0.5') {
                this.check1 = true;
            }
        }
    }

    handleRatingClick(event) {

        if (this.noedit === true) {
            return;
        }
        this.defaultRating = event.target.value;
        const formdata = {
            rating: this.defaultRating,
           
        }
        console.log(formdata);

        const selectedEvent = new CustomEvent(
            'ratingclicks',
            { detail: formdata }
        );
        this.dispatchEvent(selectedEvent);
    }

}