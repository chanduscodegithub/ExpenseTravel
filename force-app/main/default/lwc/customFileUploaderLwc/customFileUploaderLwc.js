import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getProjectDetails from '@salesforce/apex/customFileUploader.getProjectDetails';
import createTalentLoading from '@salesforce/apex/customFileUploader.createTalentLoading';
//import uploadFile from '@salesforce/apex/customFileUploader.uploadFile';
import sheetjs from '@salesforce/resourceUrl/sheetjs';

let XLS = {};
export default class CustomFileUploaderLwc extends LightningElement {
    @api recordId;
    @track projectRecord = {};

    @track fileData;
    @api acceptFormat = '.xlsx, .xls';
    @track talendLoadData = [];
    @track isDiabled = true;

    @track talentLoading;
    @track talentLoadingItem;

    connectedCallback() {
        console.log(sheetjs + '/sheetjs/sheetmin.js');

        Promise.all([
            loadScript(this, sheetjs + '/sheetjs/sheetmin.js')
        ]).then(() => {
            XLS = XLSX
            this.callOpportunity();
        }).catch(error => {
            console.log(JSON.stringify(error));
        });



    }

    callOpportunity() {
        getProjectDetails({ recordId: this.recordId })
            .then(result => {
                this.projectRecord = result;
                this.isDiabled = false;
            }).catch(error => {
                console.log('error::' + JSON.stringify(error));
                this.showToast('Error', error.body.message, 'error');
            })
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }


    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
            //console.log('fileData:::' + JSON.stringify(this.fileData));
        }
        reader.readAsDataURL(file)

        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            //this.ExcelToJSON(uploadedFiles[0]);
            this.readExcelFile(uploadedFiles[0]);
        }


    }

    async readExcelFile(file) {
        const reader = new FileReader();

        reader.onload = (e) => {
            const data = new Uint8Array(e.target.result);
            const workbook = XLS.read(data, { type: 'array' });
            const sheetName = workbook.SheetNames[0];
            const sheet = workbook.Sheets[sheetName];

            // Convert sheet data to JSON (with header as first row)
            let jsonData = XLS.utils.sheet_to_json(sheet, { header: 1 });

            if (!jsonData.length) {
                console.error("No data found in sheet");
                return;
            }

            console.log('records::' + JSON.stringify(jsonData[0][0]));

            // Extract headers from first row
            const headers = jsonData[1];
            this.talendLoadData = jsonData.slice(2).map(row => {
                let obj = {};
                headers.forEach((header, index) => {
                    let cellValue = row[index];

                    // Handle date conversion for month columns (if needed)
                    if (typeof header === 'number') {
                        obj[this.excelSerialToDate(header)] = cellValue;
                    } else {
                        obj[header] = cellValue;
                    }
                });
                return obj;
            });

            console.log('records::' + JSON.stringify(this.talendLoadData));

            //this.generateJSONObj();
        };

        reader.readAsArrayBuffer(file);


    }

    excelSerialToDate(serial) {
        let date = new Date((serial - 25569) * 86400000);
        let month = date.toLocaleDateString('en-US', { month: 'short' });
        let year = date.getFullYear().toString().slice(-2);
        return `${month}-${year}`;
    }

    handleClickSave() {
        this.generateJSONObj();
    }

    generateJSONObj() {
        var talentLoadObj = [];
        var talentLoadObjChild = [];

        this.talendLoadData.forEach((item, index) => {
            talentLoadObj.push({
                Role__c: item.Role,
                Location__c: item.Location,
                Version__c: 1,
                StartDate__c: this.projectRecord.StartDate__c,
                EndDate__c: this.projectRecord.EndDate__c,
                Engagement__c: this.projectRecord.Id
            });

            Object.keys(item).forEach(key => {
                if (key !== "Role" && key !== "Location" && key !== "Total") {
                    talentLoadObjChild.push({
                        Role: item.Role,
                        Month: key,
                        Hour: item[key]
                    });
                }
            });
        });

        console.log('talentLoadObj::' + JSON.stringify(talentLoadObj));
        console.log('talentLoadObjChild::' + JSON.stringify(talentLoadObjChild));


        createTalentLoading({ talentLoadObj: JSON.stringify(talentLoadObj), talendLoadChildWrap: JSON.stringify(talentLoadObjChild), base64: this.fileData.base64, filename: this.fileData.filename })
            .then(result => {
                console.log('result::' + JSON.stringify(result));

            }).catch(error => {
                console.log('error::' + JSON.stringify(error));
                return;
            });

        

    }



    handleClear() {
        this.fileData = {};
    }

    toast(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "success"
        })
        this.dispatchEvent(toastEvent)
    }
}