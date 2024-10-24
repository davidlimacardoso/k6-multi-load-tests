# k6 Load Tests

This project contains load tests for various scenarios using k6, a modern load testing tool.

## Project Description

This project is designed to perform load testing on different API endpoints, particularly focusing on a fake store API. It includes scenarios for adding products to cart, creating new users, and user login processes.

## Prerequisites

- Node.js
- k6 (version ^0.53.0)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/davidlimacardoso/k6-multi-load-tests.git
cd k6-multi-load-tests.git
```

2. Navigate to the project directory:
```bash
cd k6-multi-load-tests.git
```
3. Install dependencies:
```bash
npm install
```

## Docker Image
You can to use my image [docker here](https://hub.docker.com/r/davidlimacd/k6-node-alpine) too.

1. Run Docker image
```bash
docker run -it davidlimacd/k6-node-alpine:latest
```

## Available Scripts

The project includes several npm scripts for running different load test scenarios, ex:

- `fakeProductToCart`: Run load test for adding a product to cart
- `fakeAddNewUser`: Run load test for creating a new user
- `fakeUserLogin`: Run load test for user login

To run a script, use the following command structure:
`npm run script-name --env=environment --strategy=strategy --token=token`

For example:


```bash 
npm run fakeProductToCart --env=dev --strategy=ramp --token=$TOKEN
```

## Environment Variables

The load tests use the following environment variables:

- `ENV`: The environment to run the tests against
- `STRATEGY`: The load testing strategy to use
- `TOKEN`: Authentication token (if required)

These are passed as command-line arguments when running the scripts.

## Project Structure
```
k6-load-tests/
├── example
│   └── test_product.js
├── package.json
├── README.md
└── src
    ├── factory
    │   └── fakestore.js
    ├── scenarios
    │   └── fakestore
    │       ├── fakestore_new_user.js
    │       ├── fakestore_product_to_cart.js
    │       └── fakestore_user_login.js
    └── strategies
        ├── env
        │   ├── dev.json
        │   ├── prd.json
        │   └── stg.json
        └── strategy.js
```