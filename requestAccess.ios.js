const { NativeAppEventEmitter } = require('react-native');

import AppleHealthKit from 'rn-apple-healthkit';

import getStepCount from './getStepCount.ios';

export default function(elmApp) {
  let options = {
    permissions: {
      read: ["StepCount"]
    }
  };

  AppleHealthKit.initHealthKit(options: Object, (err: Object, results: Object) => {
    if (err) {
      elmApp.ports.didRequestAccessWithError.send(err.message);

      return;
    }

    AppleHealthKit.initStepCountObserver({}, () => {});

    // TODO: where to call `this.sub.remove();`
    this.sub = NativeAppEventEmitter.addListener('change:steps', (evt) => {
      getStepCount(elmApp);
    });

    getStepCount(elmApp);
  });
}
