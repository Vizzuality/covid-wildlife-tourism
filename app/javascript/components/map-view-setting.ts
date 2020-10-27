const EL_SELECTOR = '.js-map-view';
const MAP_VIEW_KEY = 'map-view';
const MAP_VIEW_DEFAULT = 'standard';

export default class MapViewSetting {
  private _mapView; // NOTE: for internal use, use this.mapView instead
  private callback: (mapView: string) => void;
  private el: HTMLSelectElement = document.querySelector(EL_SELECTOR);

  constructor(options?: { onChange: (mapView: string) => void }) {
    this.callback = options?.onChange;

    this.init();
  }

  get mapView() {
    if (this._mapView) {
      return this._mapView;
    }

    this._mapView = MAP_VIEW_DEFAULT;
    try {
      const mapView = sessionStorage.getItem(MAP_VIEW_KEY);
      if (mapView) {
        this._mapView = mapView;
      }
    } catch (e) {
      console.error(`Unable to access "${MAP_VIEW_KEY}" in sessionStorage`);
    }

    return this._mapView;
  }

  set mapView(mapView) {
    this._mapView = mapView;
    if (this.callback) {
      this.callback(mapView);
    }

    try {
      sessionStorage.setItem(MAP_VIEW_KEY, mapView);
    } catch (e) {
      console.error(`Unable to set "${MAP_VIEW_KEY}" in sessionStorage`);
    }
  }

  private init() {
    const selectedOptionIndex =
      Array.from(this.el.querySelectorAll('option')).findIndex(
        (option) => option.value === this.mapView
      ) ?? 0;

    this.el.selectedIndex = selectedOptionIndex;

    this.el.addEventListener('change', ({ target }) => {
      this.mapView = (<HTMLSelectElement>target).selectedOptions[0].value;
    });
  }
}
