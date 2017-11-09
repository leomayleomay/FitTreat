const { AppRegistry, Linking } = require('react-native');
const Elm = require('./elm');

import requestAccess from './requestAccess.ios';

const component = Elm.Main.start((app) => {
  app.ports.requestAccess.subscribe(() => {
    requestAccess(app);
  });

  app.ports.grantAccess.subscribe(() => {
    Linking.openURL('App-Prefs:root=Privacy&path=HEALTH/FitTreat');
  });
});

AppRegistry.registerComponent('FitTreat', () => component);
