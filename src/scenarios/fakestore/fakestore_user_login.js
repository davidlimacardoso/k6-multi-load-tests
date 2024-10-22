import http from 'k6/http';
import { sleep, check, group } from 'k6';
import Strategy from '../../strategies/strategy.js';
import FactoryFakestore from '../../factory/fakestore.js';

const PARAMS = Strategy.getParams();
const strategy = PARAMS[Strategy.getStrategy()] // Return the strategy inside src/strategies/env/{ENV}.json
const baseUrl = PARAMS.host.fakestore; // Return the base URL inside src/strategies/env/{ENV}.json

// Options for the load test
export const options = {

    scenarios: {
      fakestore_user_login: strategy.fakestore_user_login
    },
    thresholds: {
      http_req_failed: ["rate < 0.01"],
      http_req_duration: ["p(99.9) < 1000"],
    }
}


export default function () {
  const headers = {
    'accept' : "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    'accept-encoding': 'gzip, deflate, br, zstd',
    'accept-language': 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
    'user-agent' : "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0"
  };

  // 01. Include a new user
  group('Fakestore - Login User', () => {

    const data = new FactoryFakestore()
      .getLoginCredentials()

    let response = http.post(`${baseUrl}/auth/login`, data , headers);

    check(response, {
        'status is 200': (r) => r.status === 200,
        'User token generated': (r) => r.body.includes(`"token"`)
    });

    sleep(1);
  });

}