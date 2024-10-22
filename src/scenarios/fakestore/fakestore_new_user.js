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
      fakestore_new_user: strategy.fakestore_new_user
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

  // Global variables
  let userId 

  // 01. Include a new user
  group('Fakestore - Add new user', () => {

    const userData = new FactoryFakestore()
      .generateRandomUserData()

    let data = JSON.stringify(userData)
    let response = http.post(`${baseUrl}/users`, data , headers);
    userId = JSON.parse(response.body).id

    check(response, {
        'status is 200': (r) => r.status === 200,
        'Included user': (r) => r.body.includes(`"id":${userId}`)
    });

    sleep(1);
  });

  // 02. Load user
  group('Fakestore - Get new user', () => {

    let data  = { userId }
    let response = http.get(`${baseUrl}/users/${userId}`, data , headers);

    check(response, {
        'status is 200': (r) => r.status === 200,
    });

    sleep(1);
  });
}