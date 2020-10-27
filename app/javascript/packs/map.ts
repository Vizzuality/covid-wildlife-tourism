import MapDrawer from 'components/map-drawer';
import { default as MapViewSettingType } from 'components/map-view-setting';
import { default as MapType } from 'components/map';


// NOTE: all non-vital code for the navigation should be dynamically imported to speed up the
// page load time on slow connections

new MapDrawer();

Promise.all([import('../components/map'), import('../components/map-view-setting')])
  .then(([{ default: Map }, { default: MapViewSetting }]) => {
    let map: MapType, mapViewSetting: MapViewSettingType;

    mapViewSetting = new MapViewSetting({ onChange: mapView => map.setMapView(mapView) });
    map = new Map({ mapView: mapViewSetting.mapView });
  })
  .catch((e) => console.error('Unable to load the map and/or map view setting module', e));

