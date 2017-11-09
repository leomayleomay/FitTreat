import AppleHealthKit from 'rn-apple-healthkit';

export default function(elmApp) {
  let startDate = new Date();
  startDate.setHours(0, 0, 0, 0); // start of day

  let options = {
    startDate: startDate.toISOString()
  };

  AppleHealthKit.getStepCount(options: Object, (err: string, results: Object) => {
    if (err) {
      alert(err.message);

      elmApp.ports.didGetStepCount.send({
        error: err.message
      });

      return;
    }

    elmApp.ports.didGetStepCount.send({
      value: results.value
    });
  });
}
