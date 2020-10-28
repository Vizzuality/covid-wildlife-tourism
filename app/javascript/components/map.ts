import mapboxgl from 'mapbox-gl';

const EL_SELECTOR = '#map';

export default class Map {
  private el = document.querySelector(EL_SELECTOR);
  private map;
  private userMarker;

  constructor({ mapView }: { mapView: string }) {
    this.init(mapView);
  }

  private getMapStyle(mapView: string): mapboxgl.Style {
    return {
      version: 8,
      sources: {
        'carto-tiles': {
          type: 'raster',
          tiles: ['https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png'],
          tileSize: 256,
        },
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
            'https://tiles.arcgis.com/tiles/zOnyumh63cMmLBBH/arcgis/rest/services/WDPA_VTL/VectorTileServer/tile/{z}/{y}/{x}.pbf',
          ],
        },
      },
      layers: [
        {
          id: 'basemap',
          type: 'raster',
          source: mapView === 'standard' ? 'esri-street' : 'esri-satellite',
          minzoom: 0,
          maxzoom: 22,
        },
        // {
        //   // Sample data coming from Half Earth
        //   id: 'WDPA_africa_0',
        //   type: 'fill',
        //   source: 'protected-areas',
        //   'source-layer': 'WDPA_africa_0',
        //   layout: {},
        //   paint: {
        //     'fill-color': 'rgba(80,132,125,0.6)',
        //     'fill-outline-color': '#FFFFFF',
        //   },
        // },
      ],
    };
  }

  private init(mapView: string) {
    this.map = new mapboxgl.Map({
      container: this.el,
      style: this.getMapStyle(mapView),
      center: [28.3, -13.67],
      zoom: 3,
    });
  }

  setMapView(mapView: string) {
    this.map.setStyle(this.getMapStyle(mapView));
  }

  setUserLocation(coordinates: [number, number]) {
    const lngLat = [...coordinates].reverse();

    if (!this.userMarker) {
      const div = document.createElement('div');
      div.classList.add('marker', 'user-marker')

      this.userMarker = new mapboxgl.Marker({
        element: div
      }).setLngLat(lngLat)
        .addTo(this.map);
    } else {
      this.userMarker.setLngLat(lngLat);
    }

    this.map.setCenter(lngLat);
  }
}
