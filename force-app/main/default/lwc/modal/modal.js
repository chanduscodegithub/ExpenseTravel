import { LightningElement, api } from 'lwc';

export default class Modal extends LightningElement {
  _confirmButtonState;
  @api state;
  @api confirmMessage;
  @api cancelMessage;
  @api headerMessage;

  @api set conformButtonVisible(value) {
    this._confirmButtonState = value;
  }
  get conformButtonVisible() {
    return this._confirmButtonState === undefined || this._confirmButtonState == null || this._confirmButtonState === 'visible';
  }

  closeModal() {
    this.dispatchEvent(new CustomEvent('modalevt', {
      detail: { state: this.state, value: false }
    }));
  }
  handleApply() {
    this.dispatchEvent(new CustomEvent('modalevt', {
      detail: { state: this.state, value: true }
    }));
  }
}