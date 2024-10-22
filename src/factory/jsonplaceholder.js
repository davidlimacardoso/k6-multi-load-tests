import { randomIntBetween, randomItem } from "https://jslib.k6.io/k6-utils/1.4.0/index.js";

export default class FactoryJsonplaceholder {

    generateRandomPost() {

        const titles = [
            "The Great Adventure",
            "Whispers in the Wind",
            "A Journey Through Time",
            "Echoes of the Past",
            "The Hidden Treasure"
        ];

        const bodies = [
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
            "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
            "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        ];

        return {
            title: randomItem(titles) ,
            body: randomItem(bodies),
            userId: randomIntBetween(1,5),
          }
    }
}