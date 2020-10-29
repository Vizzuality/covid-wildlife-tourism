import mapboxgl from 'mapbox-gl';

const EL_SELECTOR = '#map';
const VIEW_KEY = 'map';
const VIEW_DEFAULT: { center: [number, number], zoom: number } = { center: [28.3, -13.67], zoom: 3 };

export default class Map {
  private el = document.querySelector(EL_SELECTOR);
  private map;
  private userMarker;

  constructor({ mapView, protectedAreas }: { mapView: string, protectedAreas: boolean }) {
    this.init(mapView, protectedAreas);
  }

  private get view(): { center: [number, number], zoom: number } {
    if (this.map) {
      return {
        center: [
          this.map.getCenter().longitude,
          this.map.getCenter().latitude
        ],
        zoom: this.map.getZoom(),
      };
    }

    let view = VIEW_DEFAULT;
    try {
      const serializedView = sessionStorage.getItem(VIEW_KEY);
      if (serializedView) {
        view = JSON.parse(serializedView);
      }
    } catch (e) {
      console.error(`Unable to access "${VIEW_KEY}" in sessionStorage`);
    }

    return view;
  }

  private set view(view: { center: [number, number], zoom: number }) {
    if (this.map) {
      this.map.setCenter(view.center);
      this.map.setZoom(view.zoom);
    }

    try {
      sessionStorage.setItem(VIEW_KEY, JSON.stringify(view));
    } catch (e) {
      console.error(`Unable to set "${VIEW_KEY}" in sessionStorage`);
    }
  }

  private getMapStyle(): mapboxgl.Style {
    return {
      version: 8,
      glyphs: 'https://tiles.arcgis.com/tiles/zOnyumh63cMmLBBH/arcgis/rest/services/WDPA_africa_labs/VectorTileServer/resources/fonts/{fontstack}/{range}.pbf',
      sources: {
        'esri-satellite': {
          type: 'raster',
          tiles: [
            'https://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          ],
          tileSize: 256,
        },
        'esri-street': {
          type: 'raster',
          tiles: [
            'https://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
          ],
          tileSize: 256,
        },
        'protected-areas': {
          type: 'vector',
          tiles: [
            'https://tiles.arcgis.com/tiles/zOnyumh63cMmLBBH/arcgis/rest/services/WDPA_africa_labs/VectorTileServer/tile/{z}/{y}/{x}.pbf',
          ],
        },
      },
      layers: [],
    };
  }

  private init(mapView: string, protectedAreas: boolean) {
    this.map = new mapboxgl.Map({
      container: this.el,
      style: this.getMapStyle(),
      center: this.view.center,
      zoom: this.view.zoom,
    });

    this.map.dragRotate.disable();
    this.map.touchZoomRotate.disableRotation();

    this.map.on('load', () => {
      // The order here is important: the basemap must be below the protected areas
      this.setMapView(mapView);
      this.toggleProtectedAreas(protectedAreas);
    });

    this.map.on('dragend', () => {
      this.view = {
        center: this.map.getCenter(),
        zoom: this.map.getZoom(),
      };
    });

    this.map.on('zoomend', () => {
      this.view = {
        center: this.map.getCenter(),
        zoom: this.map.getZoom(),
      };
    });
  }

  setMapView(mapView: string) {
    if (mapView === 'standard') {
      if (this.map.getLayer('basemap-satellite')) {
        this.map.removeLayer('basemap-satellite');
      }
    } else {
      if (this.map.getLayer('basemap-standard')) {
        this.map.removeLayer('basemap-standard');
      }
    }

    this.map.addLayer(
      {
        id: `basemap-${mapView}`,
        type: 'raster',
        source: mapView === 'standard' ? 'esri-street' : 'esri-satellite',
        minzoom: 0,
        maxzoom: 22,
      },
      // We make sure to display the basemap below the protected areas
      this.map.getLayer('protected-areas-1') ? 'protected-areas-1' : undefined
    );
  }

  toggleProtectedAreas(active: boolean) {
    if (active) {
      if (!this.map.getLayer('protected-areas-1')) {
        this.map.addLayer({
          id: 'protected-areas-1',
          type: 'fill',
          source: 'protected-areas',
          'source-layer': 'WDPA_africa_0',
          layout: {},
          paint: {
            'fill-color': 'rgba(80,132,125,0.6)',
            'fill-outline-color': '#FFFFFF',
          },
        });
        this.map.addLayer({
          id: 'protected-areas-2',
          type: 'symbol',
          source: 'protected-areas',
          'source-layer': 'WDPA_africa_0/label',
          layout: {
            'text-font': ['Tahoma Regular'],
            'text-size': 13.3333,
            'text-field': '{_name}',
            'text-optional': true
          },
          paint: {
            'text-color': '#000000',
            'text-halo-width': 1,
            'text-halo-blur': 2,
            'text-halo-color': '#FFFFFF',
          }
        });
      }
    } else {
      if (this.map.getLayer('protected-areas-1')) {
        this.map.removeLayer('protected-areas-1');
        this.map.removeLayer('protected-areas-2');
      }
    }
  }

  setUserLocation(coordinates: [number, number]) {
    if (!this.userMarker) {
      const div = document.createElement('div');
      div.classList.add('c-marker', 'user-marker')

      this.userMarker = new mapboxgl.Marker({
        element: div
      }).setLngLat(coordinates)
        .addTo(this.map);
    } else {
      this.userMarker.setLngLat(coordinates);
    }

    this.view = {
      center: coordinates,
      zoom: this.view.zoom,
    };
  }
}
