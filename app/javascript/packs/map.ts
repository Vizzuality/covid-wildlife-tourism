import MapDrawer from 'components/map-drawer';
import MapLoginWall from 'components/map-login-wall';
import { default as MapViewSettingType } from 'components/map-view-setting';
import { default as MapProtectedAreasToggleType } from 'components/map-protected-areas-toggle';
import { default as MapGeolocationButtonType } from 'components/map-geolocation-button';
import { default as MapType } from 'components/map';

type Pin = {
  id: number;
  name: string;
  latitude: number;
  longitude: number;
  website?: string;
  type: 'Community' | 'Enterprise';
  is_owner: boolean;
};

// NOTE: all non-vital code for the navigation should be dynamically imported to speed up the
// page load time on slow connections

new MapDrawer();
new MapLoginWall();

Promise.all([
  import('../components/map'),
  import('../components/map-view-setting'),
  import('../components/map-protected-areas-toggle'),
  import('../components/map-geolocation-button'),
])
  .then(([
    { default: Map },
    { default: MapViewSetting },
    { default: MapProtectedAreasToggle },
    { default: MapGeolocationButton },
  ]) => {
    let
      map: MapType,
      mapViewSetting: MapViewSettingType,
      mapProtectedAreasToggle: MapProtectedAreasToggleType,
      mapGeolocationButton: MapGeolocationButtonType;

    const onClickMap = (event) => {
      const coords = event.lngLat
        .toArray()
        .map(coord => coord.toFixed(4));
      const searchParams = window.location.search.substr(1);
      const split = searchParams.split('&');
      const nextParam = split.find(param => param.startsWith('next'))?.substr(5);

      if (!nextParam) {
        console.error('Unable to find the “next” param in the URL');
      } else {
        window.location.href = `${decodeURIComponent(nextParam)}&lon=${coords[0]}&lat=${coords[1]}`;
      }
    };

    const onClickMarker = (id, markerData) => {
      map.resetMarkersState();
      map.setMarkerActive(id);
    };

    mapViewSetting = new MapViewSetting({
      onChange: mapView => map.setMapView(mapView)
    });

    mapProtectedAreasToggle = new MapProtectedAreasToggle({
      onChange: active => map.toggleProtectedAreas(active)
    });

    mapGeolocationButton = new MapGeolocationButton({
      onChange: coordinates => map.setUserLocation(coordinates)
    });

    map = new Map({
      mapView: mapViewSetting.mapView,
      protectedAreas: mapProtectedAreasToggle.active,
      onClick: window.location.search.includes('operation=location')
        ? onClickMap
        : undefined,
    });

    fetch('/map.json')
      .then(res => res.json())
      .then(({ data }: { data: Pin[] }) => {
        map.setMarkers(data.map(pin => ({
          coordinates: [pin.longitude, pin.latitude],
          classes: [
            `marker-${pin.type.toLowerCase()}`,
            `marker-${pin.is_owner ? 'blue' : 'yellow'}`,
          ],
          data: pin,
          onClick: onClickMarker,
        })));
      })
      .catch(e => console.error('Unable to get the map pins', e));
  })
  .catch((e) => console.error('Unable to load the map and/or map view setting module', e));
