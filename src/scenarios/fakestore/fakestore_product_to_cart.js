import http from 'k6/http';
import { sleep, check, group } from 'k6';
import Strategy from '../../strategies/strategy.js';
import FactoryFakestore from '../../factory/fakestore.js';

const PARAMS = Strategy.getParams();
const strategy = PARAMS[Strategy.getStrategy()] // Return the strategy inside src/strategies/env/{ENV}.json
const baseUrl = PARAMS.host.fakestore; // Return the base URL inside src/strategies/env/{ENV}.json
const factoryFakestore = new FactoryFakestore();

// Options for the load test
export const options = {

    scenarios: {
      fakestore_product_to_cart: strategy.fakestore_product_to_cart
    },
    thresholds: {
      http_req_failed: ["rate < 0.1"],
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

  // 01. Go to the homepage
  group('Fakestore - Home Page', () => {
 
    let responses = http.batch([
        ['GET', `${baseUrl}/`, headers , { tags: { ctype: 'html' } }],
        ['GET', `${baseUrl}/dist/master.min.css`, headers , { tags: { ctype: 'css' } }],
        ['GET', `${baseUrl}/icons/intro.svg`, headers , { tags: { ctype: 'images' } }],
        ['GET', `${baseUrl}/js/polyfill.min.js`, headers , { tags: { ctype: 'js' } }],
      ]);
      
      // Loop to see each response api or url
      responses.forEach((response) => {
        check(response, {
            'status is 200': (r) => r.status === 200,
            'Homepage loaded': (r) => r.body.length > 0,
        });
      });
    
      sleep(4);
  });

  // 02. Load products
  group('Fakestore - Products', () => {
    
    let responses = http.batch([
        ['GET', `${baseUrl}/products`, headers],
        ['GET', `${baseUrl}/products/categories`, headers],
        ['GET', `${baseUrl}/products/category/jewelery`, headers],
        ['GET', `${baseUrl}/products/1`, headers],
        ['GET', `${baseUrl}/carts?userId=1`, headers],

    ]);

      // Loop to see each response api or url
      responses.forEach((response) => {
        check(response, {
            'status is 200': (r) => r.status === 200
        });
      });

    sleep(1);
  });

  // 03. Include product to cart
  group('Fakestore - Include Product to Cart', () => {

    let data = factoryFakestore.getCartProductPayload()
    let response = http.put(`${baseUrl}/carts/1`, data, headers);
    
    check(response, {
        'status is 200': (r) => r.status === 200,
        'Included to cart': (r) => r.body.includes('"id":1')
    });

    sleep(1);
  });
}