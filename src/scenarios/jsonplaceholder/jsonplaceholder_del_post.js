import http from 'k6/http';
import { sleep, check, group } from 'k6';
import Strategy from '../../strategies/strategy.js';
import { randomIntBetween } from "https://jslib.k6.io/k6-utils/1.1.0/index.js";


const PARAMS = Strategy.getParams();
const strategy = PARAMS[Strategy.getStrategy()] // Return the strategy inside src/strategies/env/{ENV}.json
const baseUrl = PARAMS.host.jsonplaceholder; // Return the base URL inside src/strategies/env/{ENV}.json

// Options for the load test
export const options = {

    scenarios: {
      jsonplaceholder_del_post: strategy.jsonplaceholder_del_post
    },
    thresholds: {
      http_req_failed: ["rate < 0.01"],
      http_req_duration: ["p(99.9) < 500"],
    }
}


export default function () {

  // 01. Delete posts of a user
  group('Jsonplaceholder - Delete Post', () => {

    let postId = randomIntBetween(1,7)
    let response = http.del(`${baseUrl}/posts/${postId}`);
    
    check(response, {
        'status is 200': (r) => r.status === 200,
    });

    sleep(1)

  });

}