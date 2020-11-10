import A11yDialog from 'a11y-dialog';

import { Pin } from 'utils/types';

const MAIN_EL: HTMLElement = document.getElementById('main');
const DIALOG_EL: HTMLElement = document.getElementById('pin-details');
const NAME_EL: HTMLElement = DIALOG_EL.querySelector('.js-name');
const WEBSITE_EL: HTMLElement = DIALOG_EL.querySelector('.js-website');
const EDIT_GROUP_EL: HTMLElement = DIALOG_EL.querySelector('.js-edit-group');
const EDIT_BTN_EL: HTMLElement = DIALOG_EL.querySelector('.js-edit');
const DELETE_BTN_EL: HTMLElement = DIALOG_EL.querySelector('.js-delete');
const REPORT_GROUP_EL: HTMLElement = DIALOG_EL.querySelector('.js-report-error-group');
const REPORT_BTN_EL: HTMLElement = DIALOG_EL.querySelector('.js-report-error');

export default class MapPinDetails {
  private dialog: A11yDialog;

  constructor() {
    this.initDialog();
  }

  private initDialog() {
    this.dialog = new A11yDialog(DIALOG_EL, MAIN_EL);
  }

  show(pin: Pin) {
    NAME_EL.textContent = pin.name;

    if (pin.website) {
      WEBSITE_EL.textContent = pin.website;
      WEBSITE_EL.setAttribute('href', pin.website);
      WEBSITE_EL.removeAttribute('hidden');
    } else {
      WEBSITE_EL.setAttribute('hidden', 'true');
    }

    if (pin.is_owner) {
      EDIT_GROUP_EL.removeAttribute('hidden');
      REPORT_GROUP_EL.setAttribute('hidden', 'true');

      const editLink = `${EDIT_BTN_EL.dataset.href}`.replace(':id', `${pin.id}`);
      EDIT_BTN_EL.setAttribute('href', editLink);

      const deleteLink = `${DELETE_BTN_EL.dataset.href}`.replace(':id', `${pin.id}`);
      DELETE_BTN_EL.setAttribute('href', deleteLink);
    } else {
      EDIT_GROUP_EL.setAttribute('hidden', 'true');
      REPORT_GROUP_EL.removeAttribute('hidden');

      if (REPORT_BTN_EL.dataset.href) {
        const link = `${REPORT_BTN_EL.dataset.href}`.replace(':id', `${pin.id}`);
        REPORT_BTN_EL.setAttribute('href', link);
      }
    }

    this.dialog.show();
  }

  hide() {
    this.dialog.hide();
  }
}
