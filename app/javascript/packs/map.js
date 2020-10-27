/**
 * SHELL CODE ONLY
 * Non-vital code must be dynamically imported (see below)
 */

import A11yDialog from 'a11y-dialog';

const main = document.getElementById('main');
const drawerDialog = document.getElementById('drawer');
new A11yDialog(drawerDialog, main);

/**
 * DYNAMICALLY IMPORTED CODE
 * All code that is non-vital for the navigation must be dynamically imported to speed up the page
 * load on slow connections
 */

import('mapbox-gl').then((mapboxgl) => {
  const MAP_STYLE = /** @type {mapboxgl.Style} */ ({
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
        source: 'esri-street',
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
  });

  const map = new mapboxgl.Map({
    container: document.getElementById('map'),
    style: MAP_STYLE,
    center: [28.3, -13.67],
    zoom: 3,
  });
});
