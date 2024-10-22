import { SharedArray } from "k6/data";

const env = __ENV.ENV || "dev";
const strategy = __ENV.STRATEGY || "load";

const data = new SharedArray(`Loading DataDriven ${env.toUpperCase}`, () =>
    JSON.parse(open(`env/${env}.json`))
  );

export default class Strategy {
  static getStrategy() {
    return strategy;
  }

  static getParams() {
    return data[0];
  }

}