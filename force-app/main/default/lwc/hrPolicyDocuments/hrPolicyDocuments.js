import { LightningElement, track, api } from 'lwc';
import fetchFileNamesAndUrls from '@salesforce/apex/GoogleDriveIntegrationNew.fetchFileNamesAndUrls';
import FLAGS from '@salesforce/resourceUrl/zohoFlags';
import uploadNewVersion from '@salesforce/apex/GoogleDriveIntegrationNew.uploadNewVersion';
import employeeRegion from '@salesforce/apex/HrPolicyDocumentsController.getEmployeeRegionAndProfile';
import saveAcknowledgement from '@salesforce/apex/HrPolicyDocumentsController.saveAcknowledgement';
import getAcknowledgedPolicyFromEmployees from '@salesforce/apex/HrPolicyDocumentsController.getAcknowledgedPolicyFromEmployees';
import uploadNewFile from '@salesforce/apex/HrPolicyDocumentsController.uploadNewFile';
import deleteFileFromDrive from '@salesforce/apex/GoogleDriveIntegrationNew.deleteFileFromDrive';
import logPolicyAction from '@salesforce/apex/HrPolicyDocumentsController.logPolicyAction';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Server Imports
import IMAGES from '@salesforce/resourceUrl/ZohoIcons';
import IMG from '@salesforce/resourceUrl/zohoImages';


export default class HrPolicyDocuments extends LightningElement {
    @track files = [];
    @track isLoading = false;
    @track showTable = false;
    folderId = null; // Initially, no folder selected
    @track isUploading = false; // Tracks upload state
    @track uploadMessage = ''; // Success message
    @track errorMessage = '';  // Error message
    fileIdToDelete;
    empRegion='';
    isFileOpen = false;
    profileName;
    fileIdToPreview='';
    newFileToUpload;
    isModalOpen=false;
    superAdmin=false;
    deleteModal=false;
    uploadNewFileModal=false;
    selectedFileUploadedDate;
    isAdmin=false;
    isEmp=false;
    India=false;Aus=false;Usa=false;
    @track errorMessage1 = '';
    showConfirmationModal=false;


    @track showUploadConfirmationModal = false;

    @track isAcknowledgeDisabled = true;


    @track searchResults = []; // Tracks the filtered results
    @track hasSearched = false; // Tracks if the user has searched
    searchQuery = ''; // Tracks the current query
    files = []; // The list of files available for searching

    indiaImg = FLAGS + '/zohoFlags/India.png';
    ausImg = FLAGS + '/zohoFlags/australia.png';
    usaImage = FLAGS + '/zohoFlags/united-states.png';
    pdfLogo2= IMAGES + '/ZohoIcons/pdf2.png';
    uploadNewImage=IMAGES + '/ZohoIcons/upload2.png';
    uploadImage=IMAGES + '/ZohoIcons/upload.jpg';
    viewImage=IMAGES + '/ZohoIcons/view1.jpg';
    deleteImage=IMAGES + '/ZohoIcons/delete1.png';

    checkImage = IMG + '/zohoImages/check.png';
    crossImage = IMG + '/zohoImages/cross.png';

    searchResults=[];
    // Handle tab clicks
    handleTabClick(event) {
        const tab = event.target.dataset.tab;

        this.files = []; // Clear existing files
        this.showTable = false; // Hide the table initially
        this.folderId = null; // Reset folder ID

        if (tab === 'India') {
            this.fetchFiles('1iVDjbKkTttxDNuZrzB5ZIatZnRekmL99'); // India folder ID
        } else if (tab === 'Australia') {
            this.fetchFiles('1yfx579ZJ_0xlOZ69LbevjYgQlNd-9RkE'); // Australia folder ID
        } else if (tab === 'USA') {
            this.fetchFiles('1e0ypln9Mj89M22z6Ni3JpOiUGeF-Fayx'); // USA folder ID
        } else if (tab === 'ALL') {
            this.fetchFiles('1krhxTSO-gAO5hL24Im4Fj8__ifKWAgTQ'); // All folder ID
        }
    }

    handleUploadConfirm(){
        this.showConfirmationModal=false;
        this.uploadNewFileModal = true; // Show the confirmation modal
    }

    handleUploadFile() {
       this.showConfirmationModal=true;
    }

    closeConfirmationModal() {
        this.showUploadConfirmationModal = false;
        this.showConfirmationModal=false;
    }

    // Open the modal for uploading a new file
    openUploadNewFileModal() {
        this.showUploadConfirmationModal = false; // Close the confirmation modal
        this.uploadNewFileModal = true; // Open the upload new file modal
    }


    handleFileOpen(event) {
        // Get the file that was double-clicked
        this.fileIdToPreview = event.currentTarget.dataset.fileId;
        let fileUrl = event.currentTarget.dataset.fileUrl;
        this.selectedFileUploadedDate=event.currentTarget.dataset.fileUpdated;
        console.log('selectedFileUploadedDate',this.selectedFileUploadedDate);
        if (fileUrl.includes('/view')) {
            this.selectedFileUrl = fileUrl.replace('/view', '/preview').split('?')[0]; // Remove query parameters
        } else {
            this.selectedFileUrl = fileUrl; // Use the URL as is if no "/view" found
        }
        this.isModalOpen = true;
    }

    connectedCallback() {
        employeeRegion()
            .then((result) => {
                // Assuming `result` is an object containing both region and profile name
                // Example: { Country: "India", ProfileName: "Partner Community Login User_HR" }
                this.empRegion = result.Country;
                this.profileName = result.ProfileName;

                console.log('Result is', result);

                // Set flags based on region
                if (this.empRegion === 'India') {
                    this.India = true; // Set India flag to true
                } else if (this.empRegion === 'Australia') {
                    this.Aus = true; // Set Australia flag to true
                } else if (this.empRegion === 'USA') {
                    this.Usa = true; // Set USA flag to true
                }
                
                // Set all flags to true if the profile matches specific values
                if (
                    this.profileName === 'Partner Community Login User_HR' ||
                    this.profileName === 'Partner Community Login User_HR Manager'
                ) {
                    this.India = true;
                    this.Aus = true;
                    this.Usa = true;
                    this.isAdmin=true;
                }
                else if(this.profileName === 'System Administrator'){
                    this.superAdmin=true;
                    this.India = true;
                    this.Aus = true;
                    this.Usa = true;
                }
                else{
                    this.isEmp=true;
                }
                // Create a simulated event object with the data-tab value corresponding to empRegion
                const simulatedEvent = {
                    target: {
                        dataset: {
                            tab: this.empRegion // Pass the empRegion value directly
                        }
                    }
                };

                console.log('simulatedEvent',simulatedEvent.target.dataset);
                // Call handleTabClick with the simulated event
                this.handleTabClick(simulatedEvent);
            })
            .catch((error) => {
                console.error('Error fetching files:', error);
                this.isLoading = false;
            });

            // Wait for the DOM to render to access the footer element **Added this because it was forcing margin in footer for SF instance by host.**
            setTimeout(() => {
                const footer = this.template.querySelector('.footer');
                if (footer) {
                    footer.style.margin = '0';
                }
            }, 0);
    }

    handleUploadClick() {
        this.template.querySelector('[data-id="uploadNewVersion"]').click();
    }



    // handleUploadFile() {
    //     const fileInput = this.template.querySelector('[data-id="uploadNewFile"]');
    //     if (fileInput) {
    //         fileInput.click();  // Trigger the file input click
    //     } else {
    //         console.error('File input not found');
    //     }
    // }
    
    // Handle changes to the search input field
    handleSearchChange(event) {
        this.searchQuery = event.target.value.trim(); // Get the search query
        this.hasSearched = true; // Mark that a search attempt has been made

        // Filter files based on the search query (case-insensitive)
        if (this.searchQuery) {
            this.performSearch();
        } else {
            this.searchResults = []; // Clear results if search query is empty
            this.hasSearched = false; 
        }

    }

    // Filter the files based on the search query
    performSearch() {
        const query = this.searchQuery.toLowerCase(); // Make the search case-insensitive
        this.searchResults = this.files.filter(file => 
            file.fileName.toLowerCase().includes(query) || 
            file.description.toLowerCase().includes(query) // Optionally, search in the description too
        );
    }
    
    handleActionClick(event) {
        let fileUrl = event.target.dataset.fileUrl;
        this.selectedFileId = event.target.dataset.fileId;
        this.selectedFileUploadedDate=event.target.dataset.fileUpdated;

        if (fileUrl.includes('/view')) {
            this.selectedFileUrl = fileUrl.replace('/view', '/preview').split('?')[0]; // Remove query parameters
        } else {
            this.selectedFileUrl = fileUrl; // Use the URL as is if no "/view" found
        }
        const selectedFile = this.files.find(file => file.fileId === this.selectedFileId);
        if (selectedFile) {
            this.selectedFileName = selectedFile.fileName;
        }
        this.isModalOpen = true;
    }

    
    handleDelete(event){
        this.fileIdToDelete = event.target.dataset.fileId;
        this.selectedFileName=event.target.dataset.fileName;
        this.deleteModal=true;
        console.log('fileIdToDelete',this.fileIdToDelete,this.deleteModal);
    }

    deleteFile(){
        deleteFileFromDrive({fileId:this.fileIdToDelete})
        .then((result)=>{
            logPolicyAction({actionType:'File Deleted', fileName:this.selectedFileName})
            .then(() => {
            })
            .catch((error) => {
                // Handle any errors from the logPolicyAction method
                console.error('Error logging policy action:', error);
            });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'File deleted successfully!',
                    variant: 'success'
                })
            );
            this.closeModal();
        })
        .catch((error) => {
            console.log('Error is',error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error Deleting File. Please contact admin.',
                    variant: 'error'
                })
            );
        });
    }

    fetchFiles(folderId) {
        if (!folderId) {
            this.files = []; // Ensure no files are displayed if no folder is selected
            return;
        }

        this.isLoading = true;

        // Prepare folderIds array based on the selected tab
        const folderIds = folderId !== '1krhxTSO-gAO5hL24Im4Fj8__ifKWAgTQ'
            ? [folderId, '1krhxTSO-gAO5hL24Im4Fj8__ifKWAgTQ'] // Include "ALL" folder
            : [folderId];

        // Sequentially fetch files
        let fetchedFiles = [];
        const fetchNextFolder = (index) => {
            if (index >= folderIds.length) {
                // All folders processed
                this.files = fetchedFiles;
                this.getAcknowledgedFile();
                this.showTable = this.files.length > 0; // Show table only if there are files
                this.isLoading = false; // Stop loading spinner
                console.log('Fetched files:', this.files);
                return;
            }

            const currentFolderId = folderIds[index];
            fetchFileNamesAndUrls({ folderId: currentFolderId })
                .then((result) => {
                    const files = result.map((file) => ({
                        fileId: file.id,
                        fileName: file.name,
                        updatedOn: file.modifiedTime
                            ? new Date(file.modifiedTime).toLocaleString()
                            : 'N/A',
                        description: file.description || 'No description available',
                        isFolder: file.type === 'application/vnd.google-apps.folder',
                        fileUrl: file.url,
                        acknowledged: false,
                    }));
                    fetchedFiles = fetchedFiles.concat(files); // Add files to the list
                    fetchNextFolder(index + 1); // Fetch next folder
                })
                .catch((error) => {
                    console.error('Error fetching files for folder', currentFolderId, error);
                    fetchNextFolder(index + 1); // Continue to next folder even on error
                });
        };

        fetchNextFolder(0); // Start fetching from the first folder
    }

    getAcknowledgedFile() {
        getAcknowledgedPolicyFromEmployees()
            .then((res) => {
                this.acknowledgedFilesFromEmp = res;
                console.log('New',(res));
                // Compare the files and mark as acknowledged if matched
                this.files = this.files.map((file) => {
                    // Convert file.updatedOn to a comparable date format (removing seconds and milliseconds)
                    const updatedOnFormatted = parseDateNew(file.updatedOn);
                    console.log('updatedOnFormatted',updatedOnFormatted);
                    const isAcknowledged = this.acknowledgedFilesFromEmp.some((ackFile) => {
                        // Compare the dates without considering seconds and milliseconds
                        return (
                            ackFile.Name === file.fileName &&
                            ackFile.Policy_Uploaded_Date__c === updatedOnFormatted
                        );
                    });

                    return {
                        ...file,
                        acknowledged: isAcknowledged, // Update the acknowledged status
                    };
                });

            })
            .catch((err) => {
                console.log('Error Getting Acknowledged Files', err);
            });
    }


    handleAcknowledgeFile() {
        console.log('selectedFileUploadedDate',this.selectedFileUploadedDate);
        const newDate= parseDateNew(this.selectedFileUploadedDate);
        
        console.log('sfUpdateOn',newDate);
        saveAcknowledgement({ 
            name: this.selectedFileName, 
            url: this.selectedFileUrl ,
            updatedOn:newDate
        })
        .then(() => {
            const fileIndex = this.files.findIndex(file => file.fileId === this.selectedFileId);
            if (fileIndex !== -1) {
                this.files[fileIndex].acknowledged = true;
                this.files = [...this.files];
            }

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Acknowledgment saved successfully!',
                    variant: 'success'
                })
            );
            this.closeModal();
        })
        .catch((error) => {
            console.error('Error saving acknowledgment:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedFileUrl = '';
        this.selectedFileId = '';
        this.selectedFileName = '';
        this.fileContent = '';
        this.searchResults = [];
        this.deleteModal=false;
        this.uploadNewFileModal=false;
        this.isAcknowledgeDisabled = true
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        const fileName=file.name;
        let fileId = event.currentTarget.dataset.fileId;
        let existingFileName=event.currentTarget.dataset.fileName;
        console.log('FiledId is',fileId);

        if (file) {
            const reader = new FileReader();

            reader.onload = () => {
                // Convert the file data to Base64
                const base64Data = window.btoa(
                    new Uint8Array(reader.result)
                        .reduce((data, byte) => data + String.fromCharCode(byte), '')
                );

                // Call the Apex method with the Base64 data
                this.uploadFileToApex(base64Data,fileId,existingFileName);
            };

            reader.onerror = () => {
                this.errorMessage = 'Error reading file. Please try again.';
            };

            // Read the file as an ArrayBuffer
            reader.readAsArrayBuffer(file);
        }
    }

    handleUploadFileEvent(event){
        this.newFileToUpload=event.target.files[0]; 
        this.errorMessage1 = '';
        
    }

    handleNewFileChange() {

        const file=this.newFileToUpload;
        if (!file) {
            this.errorMessage1 = 'No file selected. Please choose a file to upload.';
            console.log('Error Message:', this.errorMessage1); 
            return;
        }

        const fileName=file.name;

        const fileAlreadyExists = this.files.some(existingFile => existingFile.fileName === fileName);

        if (fileAlreadyExists) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'File Already Exists',
                    message: `A file named "${fileName}" already exists. Please upload a different file.`,
                    variant: 'error',
                })
            );
            return; // Prevent further processing
        }

        // Proceed with the upload if the file doesn't exist
        const reader = new FileReader();

        reader.onload = () => {
            const base64Data = window.btoa(
                new Uint8Array(reader.result).reduce((data, byte) => data + String.fromCharCode(byte), '')
            );
            const descriptionField = this.template.querySelector('.comment');
            const descriptionValue = descriptionField.value.trim();
            this.uploadNewFileToApex(fileName, base64Data, this.folderId, descriptionValue);
        };

        reader.onerror = () => {
            this.errorMessage = 'Error reading file. Please try again.';
        };

        reader.readAsArrayBuffer(file);




        // if (file) {
        //     const reader = new FileReader();

        //     reader.onload = () => {
        //         // Convert the file data to Base64
        //         const base64Data = window.btoa(
        //             new Uint8Array(reader.result)
        //                 .reduce((data, byte) => data + String.fromCharCode(byte), '')
        //         );
        //         const descriptionField = this.template.querySelector('.comment'); 
        //         const descriptionValue = descriptionField.value.trim();
        //         // Call the Apex method with the Base64 data
        //         this.uploadNewFileToApex(fileName,base64Data,this.folderId,descriptionValue);
        //     };

        //     reader.onerror = () => {
        //         this.errorMessage = 'Error reading file. Please try again.';
        //     };

        //     // Read the file as an ArrayBuffer
        //     reader.readAsArrayBuffer(file);
        // }
    }


    uploadNewFileToApex(fileName,fileContent,parentId,description) {
       
        this.isUploading = true;
        this.uploadMessage = 'Please wait while we are uploading the File';
        this.errorMessage = '';
        console.log('fileName',fileName,'parentId',parentId,'fileContent',fileContent);
        // Call the Apex method and send Blob
        uploadNewFile({
            fileName:fileName,
            fileData: fileContent,
            folderId:parentId,
            description:description
        })
        .then((result) => {
            this.isUploading = false;
            this.uploadNewFileModal=false;
            this.uploadMessage = result;

            // Call the logPolicyAction Apex method
            logPolicyAction({actionType:'New File Uploaded', fileName:fileName})
            .then(() => {
                const successToast = new ShowToastEvent({
                    title: 'Success',
                    message: 'File has been uploaded successfully.',
                    variant: 'success', // success, info, warning, error
                });
                this.dispatchEvent(successToast); // Dispatch the toast event
            })
            .catch((error) => {
                // Handle any errors from the logPolicyAction method
                console.error('Error logging policy action:', error);
            });
        })
        .catch((error) => {
            console.log('Error',error);
            this.isUploading = false;
            this.errorMessage = 'Error uploading file: ' + error.body.message;
            // Error toast
            const errorToast = new ShowToastEvent({
                title: 'Error',
                message: 'Unable to upload file. Please contact admin.',
                variant: 'error', // success, info, warning, error
            });
            this.dispatchEvent(errorToast); // Dispatch the toast event
        });
    }

    uploadFileToApex(fileContent,fileId,fileName) {
        this.isUploading = true;
        this.uploadMessage = '';
        this.errorMessage = '';

        // Call the Apex method and send Blob
        uploadNewVersion({
            fileId: fileId,
            fileContent: fileContent
        })
        .then((result) => {
            // Call the logPolicyAction Apex method
            logPolicyAction({actionType:'Version Updated', fileName:fileName})
            .then(() => {
            })
            .catch((error) => {
                // Handle any errors from the logPolicyAction method
                console.error('Error logging policy action:', error);
            });
            const successToast = new ShowToastEvent({
                title: 'Success',
                message: result,
                variant: 'success', // success, info, warning, error
            });
            this.dispatchEvent(successToast); // Dispatch the toast event
        })
        .catch((error) => {
            console.log('Error',error);
            this.isUploading = false;
            this.errorMessage = 'Error uploading file: ' + error.body.message;
            const errorToast = new ShowToastEvent({
                title: 'Error',
                message: 'Unable to upload file. Please contact admin.',
                variant: 'error', // success, info, warning, error
            });
            this.dispatchEvent(errorToast); // Dispatch the toast event
        });
    }


    handleCheckboxChange(event) {
        // Enable the button when checkbox is checked
        this.isAcknowledgeDisabled = !event.target.checked;
    }


}

    /**
     * Utility function to format date by removing seconds and milliseconds.
     * Converts date string to 'YYYY-MM-DDTHH:MM:00.000Z' format (ignoring seconds and milliseconds).
     */
    function formatDateWithoutSeconds(dateStr) {
        // Parse the date string and extract the year, month, day, hours, and minutes
        const date = new Date(dateStr);
        return date.toISOString().slice(0, 17) + ":00.000Z"; // Format: YYYY-MM-DDTHH:MM:00.000Z
    }

    function parseDate(dateString) {
        console.log('dateString',dateString);
        const [datePart, timePart] = dateString.trim().split(','); // Split the date and time
        const [month, day, year] = datePart.trim().split('/').map(Number); // Split and convert day, month, year

        const [time, meridian] = timePart.trim().split(' '); // Separate time and AM/PM
        const [hour, minute, second] = time.split(':').map(Number); // Split hour, minute, second

        // Convert to 24-hour format
        const adjustedHour =
            meridian === "PM" && hour !== 12 ? hour + 12 : (meridian === "AM" && hour === 12 ? 0 : hour);

        // Create a valid JavaScript Date object
        return new Date(year, month - 1, day, adjustedHour, minute, second); // Months are 0-based in JS
    }

    function parseDateNew(date) {
        const parsedDate = parseDate(date);
        if (isNaN(parsedDate.getTime())) {
            console.error("Invalid date:", date);
            return null; // Return null for invalid dates
        }

        // Format the date without seconds (remove seconds and milliseconds)
        return parsedDate.toISOString();
    }