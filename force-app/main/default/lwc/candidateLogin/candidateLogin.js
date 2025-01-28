import { LightningElement, track } from 'lwc';
import requestOtpApex from '@salesforce/apex/CandidateLoginController.requestOtp';
import verifyOtpApex from '@salesforce/apex/CandidateLoginController.verifyOtp';
import uploadOfferLetterApex from '@salesforce/apex/CandidateLoginController.uploadOfferLetter';

export default class CandidateLogin extends LightningElement {
  // @track email = ''; 
  // @track otp = '';
  // @track fullName = '';
  // @track fileData = null;

  // @track isOtpVisible = false;
  // @track isVerified = false;
  // @track isRequestOtpDisabled = false;

  // @track message = '';
  // @track messageClass = '';

  // handleEmailChange(event) {
  //   this.email = event.target.value;
  //   console.log('Email is', this.email);
  // }

  // handleOtpChange(event) {
  //   this.otp = event.target.value;
  // }

  // handleNameChange(event) {
  //   this.fullName = event.target.value;
  // }

  // handleFileUpload(event) {
  //   const file = event.target.files[0];
  //   const reader = new FileReader();
  //   reader.onload = () => {
  //     this.fileData = {
  //       fileName: file.name,
  //       base64: reader.result.split(',')[1],
  //     };
  //   };
  //   reader.readAsDataURL(file);
  // }

  // async requestOtp() {
  //   this.isRequestOtpDisabled = true;
  //   try {
  //     const response = await requestOtpApex({ email: this.email });
  //     this.isOtpVisible = true;
  //     this.message = 'OTP sent to your email.';
  //     this.messageClass = 'success-message';
  //   } catch (error) {
  //     this.message = 'Error requesting OTP: ' + error.body.message;
  //     this.messageClass = 'error-message';
  //   } finally {
  //     this.isRequestOtpDisabled = false;
  //   }
  // }

  // async verifyOtp() {
  //   try {
  //     const isValid = await verifyOtpApex({ email: this.email, otp: this.otp });
  //     if (isValid) {
  //       this.isVerified = true;
  //       this.isOtpVisible = false;
  //       this.message = 'OTP verified successfully!';
  //       this.messageClass = 'success-message';
  //     } else {
  //       this.message = 'Invalid OTP. Please try again.';
  //       this.messageClass = 'error-message';
  //     }
  //   } catch (error) {
  //     this.message = 'Error verifying OTP: ' + error.body.message;
  //     this.messageClass = 'error-message';
  //   }
  // }

  // async handleSubmit() {
  //   if (!this.fullName || !this.fileData) {
  //     this.message = 'Please provide all required details.';
  //     this.messageClass = 'error-message';
  //     return;
  //   }

  //   try {
  //     const response = await uploadOfferLetterApex({
  //       email: this.email,
  //       fullName: this.fullName,
  //       fileName: this.fileData.fileName,
  //       base64Data: this.fileData.base64,
  //     });
  //     this.message = 'Offer letter uploaded successfully!';
  //     this.messageClass = 'success-message';
  //     this.resetForm();
  //   } catch (error) {
  //     this.message = 'Error uploading offer letter: ' + error.body.message;
  //     this.messageClass = 'error-message';
  //   }
  // }

  // resetForm() {
  //   this.email = '';
  //   this.otp = '';
  //   this.fullName = '';
  //   this.fileData = null;
  //   this.isOtpVisible = false;
  //   this.isVerified = false;
  // }
}