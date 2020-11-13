import Map from './map';
import MapViewSetting from './map-view-setting';

const MAP_EL: HTMLElement = document.querySelector('.js-map-field');
const TYPE_INPUT_EL: HTMLInputElement = document.querySelector('.js-type-input');
const LATITUDE_INPUT_EL: HTMLInputElement = document.querySelector('.js-latitude-input');
const LONGITUDE_INPUT_EL: HTMLInputElement = document.querySelector('.js-longitude-input');

export default class PinsEnterpriseTypeField {
  private latitude: number;
  private longitude: number;
  private map: Map;

  constructor() {
    if (MAP_EL) {
      this.init();
    }
  }

  private restore() {
    // We get the initial values of the inputs
    this.onChangeLatitude();
    this.onChangeLongitude();
  }

  private onChangeLatitude() {
    const value = +LATITUDE_INPUT_EL.value;
    if (!isNaN(value)) {
      this.latitude = value;
    }

    this.update();
  }

  private onChangeLongitude() {
    const value = +LONGITUDE_INPUT_EL.value;
    if (!isNaN(value)) {
      this.longitude = value;
    }

    this.update();
  }

  private onClickMap(event: mapboxgl.MapLayerMouseEvent) {
    const { lat, lng } = event.lngLat;
    this.latitude = lat;
    this.longitude = lng;

    this.update();
  }

  private update() {
    if (this.latitude !== undefined) {
      LATITUDE_INPUT_EL.value = this.latitude.toFixed(4);
    }

    if (this.longitude !== undefined) {
      LONGITUDE_INPUT_EL.value = this.longitude.toFixed(4);
    }

    if (!this.map || (this.latitude === undefined || this.longitude === undefined)) {
      return;
    }

    this.map.setMarkers([{
      id: '0',
      coordinates: [this.longitude, this.latitude],
      data: {},
      onClick: () => { },
      classes: ['marker-yellow', `marker-${TYPE_INPUT_EL.value.toLowerCase()}`],
    }]);

    this.map.setMarkerActive('0');
  }

  private init() {
    this.map = new Map({
      mapView: new MapViewSetting().mapView,
      protectedAreas: false,
      onClick: this.onClickMap.bind(this),
    });

    this.restore();

    LATITUDE_INPUT_EL.addEventListener('change', this.onChangeLatitude.bind(this));
    LONGITUDE_INPUT_EL.addEventListener('change', this.onChangeLongitude.bind(this));
  }
}
