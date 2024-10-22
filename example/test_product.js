import http from 'k6/http';
import { sleep, check, group } from 'k6';

export const options = {
    vus: 5,
    duration: '5s',
    thresholds: {
      http_req_failed: ["rate < 0.01"],
      http_req_duration: ["p(99.9) < 800"],
    },
  };

export default function () {
  const params = {
    'accept' : "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    'accept-encoding': 'gzip, deflate, br, zstd',
    'accept-language': 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
    'user-agent' : "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0"
  };

  // 01. Go to the homepage
  group('Fakestore - Home Page', () => {
 
    let responses = http.batch([
        ['GET', 'https://fakestoreapi.com/', params , { tags: { ctype: 'html' } }],
        ['GET', 'https://fakestoreapi.com/dist/master.min.css', params , { tags: { ctype: 'css' } }],
        ['GET', 'https://fakestoreapi.com/icons/intro.svg', params , { tags: { ctype: 'images' } }],
        ['GET', 'https://fakestoreapi.com/js/polyfill.min.js', params , { tags: { ctype: 'js' } }],
      ]);
    
      check(responses[0], {
        'status is 200': (r) => r.status === 200,
        'Homepage loaded': (r) => JSON.stringify(r)
      });
    
      sleep(4);
  });

  // 02. Load products
  group('Fakestore - Products', () => {
    
    let responses = http.batch([
        ['GET', 'https://fakestoreapi.com/products', params],
        ['GET', 'https://fakestoreapi.com/products/categories', params],
        ['GET', 'https://fakestoreapi.com/products/category/jewelery', params],
        ['GET', 'https://fakestoreapi.com/products/products/1', params],
        ['GET', 'https://fakestoreapi.com/carts?userId=1', params],

    ]);

    check(responses[0], {
        'status is 200': (r) => r.status === 200,
        'Products loaded': (r) => JSON.stringify(r),
    });

    sleep(1);
  });

  // 03. Include product to cart
  group('Fakestore - Include to Cart', () => {

    let data = {
        "userId": 1,
        "date": "2020-03-02",
        "products": [{"productId": 1, "quantity": 3}]
    }

    let responses = http.put('https://fakestoreapi.com/carts/1', data, params);
    
    check(responses, {
        'status is 200': (r) => r.status === 200,
        'Included to cart': (r) => r.body.includes('"id":1')
    });

    sleep(1);
  });
}