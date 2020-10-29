import MapDrawer from 'components/map-drawer';
import MapLoginWall from 'components/map-login-wall';
import { default as MapViewSettingType } from 'components/map-view-setting';
import { default as MapGeolocationButtonType } from 'components/map-geolocation-button';
import { default as MapType } from 'components/map';


// NOTE: all non-vital code for the navigation should be dynamically imported to speed up the
// page load time on slow connections

new MapDrawer();
new MapLoginWall();

Promise.all([
  import('../components/map'),
  import('../components/map-view-setting'),
  import('../components/map-geolocation-button'),
])
  .then(([
    { default: Map },
    { default: MapViewSetting },
    { default: MapGeolocationButton },
  ]) => {
    let
      map: MapType,
      mapViewSetting: MapViewSettingType,
      mapGeolocationButton: MapGeolocationButtonType;

    mapViewSetting = new MapViewSetting({
      onChange: mapView => map.setMapView(mapView)
    });

    mapGeolocationButton = new MapGeolocationButton({
      onChange: coordinates => map.setUserLocation(coordinates)
    });

    map = new Map({ mapView: mapViewSetting.mapView });
  })
  .catch((e) => console.error('Unable to load the map and/or map view setting module', e));
