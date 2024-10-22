import http from 'k6/http';
import { sleep, check, group } from 'k6';
import Strategy from '../../strategies/strategy.js';
import { randomIntBetween } from "https://jslib.k6.io/k6-utils/1.1.0/index.js";
import FactoryJsonplaceholder from '../../factory/jsonplaceholder.js';


const PARAMS = Strategy.getParams();
const strategy = PARAMS[Strategy.getStrategy()] // Return the strategy inside src/strategies/env/{ENV}.json
const baseUrl = PARAMS.host.jsonplaceholder; // Return the base URL inside src/strategies/env/{ENV}.json

// Options for the load test
export const options = {

    scenarios: {
      jsonplaceholder_simulate_user_post: strategy.jsonplaceholder_simulate_user_post
    },
    thresholds: {
      http_req_failed: ["rate < 0.01"],
      http_req_duration: ["p(99.9) < 1000"],
    }
}

let postId

export default function () {

  // 01. Simulate a posting
  group('Jsonplaceholder - Create post', () => {

    let data = new FactoryJsonplaceholder().generateRandomPost()
    let response = http.post(`${baseUrl}/posts`, data);
    postId = JSON.parse(response.body).id

    check(response, {
        'status is 201': (r) => r.status === 201,
        'post is ok': (r) => r.body.includes('title')
    });

    sleep(1)

  });

  // 02. Simulate a listing of posts and visualize a post id comments
  group('Jsonplaceholder - List posts and comments', () => {

    let responses = http.batch([
      ['GET', `${baseUrl}/posts`],
      ['GET', `${baseUrl}/posts/${postId}/comments`],
      ['GET', `${baseUrl}/posts/${postId}/comments?postId=1`]
    ]);
  
    check(responses[0], {
      'status is 200': (r) => r.status === 200,
      'posts are loaded': (r) => JSON.stringify(r)
    });
  
    sleep(3);

  });

  // 03. Simulate a listing of posts and visualize a post id comments
  group('Jsonplaceholder - Update post', () => {

    postId = randomIntBetween(1, 5)
    let data = new FactoryJsonplaceholder().generateRandomPost()
    let response = http.put(`${baseUrl}/posts/${postId}`, data);

    check(response, {
        'status is 200': (r) => r.status === 200,
        'update is ok': (r) => r.body.includes('title')
    });

    sleep(1)

  });

    // 04. Delete post
    group('Jsonplaceholder - Delete post', () => {

      postId = randomIntBetween(1, 5)
      let response = http.del(`${baseUrl}/posts/${postId}`);
  
      check(response, {
          'status is 200': (r) => r.status === 200,
      });
  
      sleep(2)
  
    });

}