import A11yDialog from 'a11y-dialog';

const MAIN_EL = document.getElementById('main');
const DRAWER_EL = document.getElementById('drawer');

export default class MapDrawer {
  constructor() {
    this.initDrawer();
  }

  /**
   * Initialize the menu drawer
   */
  private initDrawer() {
    new A11yDialog(DRAWER_EL, MAIN_EL);
  }
}
