const EL_SELECTOR = '.js-map-geolocation';

export default class MapGeolocationButton {
  private callback: (coordinates: [number, number]) => void;
  private el: HTMLSelectElement = document.querySelector(EL_SELECTOR);

  constructor(options?: { onChange: (coordinates: [number, number]) => void }) {
    this.callback = options?.onChange;

    this.init();
  }

  private getUserLocation(): Promise<[number, number]> {
    return new Promise((resolve, reject) => {
      navigator?.geolocation.getCurrentPosition(({ coords: { latitude, longitude } }) => {
        resolve([latitude, longitude]);
      }, reject);
    });
  }

  private init() {
    this.el.addEventListener('click', async () => {
      try {
        const coordinates = await this.getUserLocation();

        if (this.callback) {
          this.callback(coordinates);
        }
      } catch (e) {
        console.error('Unable to get the user location', e);
      }
    });
  }
};
