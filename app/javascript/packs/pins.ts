// NOTE: all non-vital code for the navigation should be dynamically imported to speed up the
// page load time on slow connections

Promise.all([
  import('../components/pins-enterprise-type-field'),
  import('../components/pins-ownership-field'),
])
  .then(([
    { default: PinsEnterpriseTypeField },
    { default: PinsOwnershipField },
  ]) => {
    new PinsEnterpriseTypeField();
    new PinsOwnershipField();
  })
  .catch((e) => console.error('Unable to load the pins modules', e));
