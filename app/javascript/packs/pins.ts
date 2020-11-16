// NOTE: all non-vital code for the navigation should be dynamically imported to speed up the
// page load time on slow connections

Promise.all([
  import('../components/pins-enterprise-type-field'),
  import('../components/pins-ownership-field'),
  import('../components/map-field'),
])
  .then(([
    { default: PinsEnterpriseTypeField },
    { default: PinsOwnershipField },
    { default: MapField },
  ]) => {
    new PinsEnterpriseTypeField();
    new PinsOwnershipField();
    new MapField();
  })
  .catch((e) => console.error('Unable to load the pins modules', e));
