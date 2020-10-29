const EL_SELECTOR = '.js-protected-areas-toggle';
const TOGGLE_KEY = 'protected-areas';
const TOGGLE_DEFAULT = false;

export default class MapProtectedAreasToggle {
  private _active; // NOTE: for internal use, use this.active instead
  private callback: (active: boolean) => void;
  private el: HTMLInputElement = document.querySelector(EL_SELECTOR);

  constructor(options?: { onChange: (active: boolean) => void }) {
    this.callback = options?.onChange;

    this.init();
  }

  get active() {
    if (this._active !== null && this._active !== undefined) {
      return this._active;
    }

    this._active = TOGGLE_DEFAULT;
    try {
      const active = sessionStorage.getItem(TOGGLE_KEY);
      if (active !== null && active !== undefined) {
        this._active = active === 'true';
      }
    } catch (e) {
      console.error(`Unable to access "${TOGGLE_KEY}" in sessionStorage`);
    }

    return this._active;
  }

  set active(active) {
    this._active = active;
    if (this.callback) {
      this.callback(active);
    }

    try {
      sessionStorage.setItem(TOGGLE_KEY, active);
    } catch (e) {
      console.error(`Unable to set "${TOGGLE_KEY}" in sessionStorage`);
    }
  }

  private init() {
    this.el.checked = this.active;

    this.el.addEventListener('change', ({ target }) => {
      this.active = (<HTMLInputElement>target).checked;
    });
  }
}
