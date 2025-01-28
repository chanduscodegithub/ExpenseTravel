import { LightningElement } from 'lwc';
export default class HelpDoc extends LightningElement {

redirectToHelp() {
    window.open('https://scribehow.com/workspace#dashboard');
}
}