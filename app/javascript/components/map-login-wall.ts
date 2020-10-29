import A11yDialog from 'a11y-dialog';

const MAIN_EL = document.getElementById('main');
const DRAWER_EL = document.getElementById('login-wall');

export default class MapLoginWall {
  constructor() {
    // The dialog is only available if the user is not logged in
    if (DRAWER_EL) {
      this.initDrawer();
    }
  }

  private initDrawer() {
    new A11yDialog(DRAWER_EL, MAIN_EL);
  }
}
