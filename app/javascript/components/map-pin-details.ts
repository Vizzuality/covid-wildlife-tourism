import A11yDialog from 'a11y-dialog';

const MAIN_EL = document.getElementById('main');
const DIALOG_EL = document.getElementById('pin-details');

export default class MapPinDetails {
  private dialog: A11yDialog;

  constructor() {
    this.initDialog();
  }

  private initDialog() {
    this.dialog = new A11yDialog(DIALOG_EL, MAIN_EL);
  }

  showDialog() {
    this.dialog.show();
  }

  hideDialog() {
    this.dialog.hide();
  }
}
