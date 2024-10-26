
export default class FactoryFakestore {

    generateRandomUserData() {

        const firstNames = ['Alice', 'Bob', 'Charlie', 'Diana'];
        const lastNames = ['Smith', 'Johnson', 'Williams', 'Jones'];

        const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
        const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];

        return {
            email:`${firstName} ${lastName}`,
            username:`${firstName}`,
            password: this.generateRandomPassword(10),
            name:{
                firstname:`${firstName}`,
                lastname:`${lastName}`
            },
            address:{
                city:'kilcoole',
                street:'7835 new road',
                number:3,
                zipcode:'12926-3874',
                geolocation:{
                    lat:'-37.3159',
                    long:'81.1496'
                }
            },
            phone:'1-570-236-7033'
        }
    }

    generateRandomPassword(length) {
        const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()';
        let password = '';
        for (let i = 0; i < length; i++) {
            const randomIndex = Math.floor(Math.random() * charset.length);
            password += charset[randomIndex];
        }
        return password;
    }

    getLoginCredentials() {

        return {
            username: "mor_2314",
            password: "83r5^_"
        }

    }

    getCartProductPayload() {
        return {
            "userId": 1,
            "date": "2020-03-02",
            "products": [{"productId": 1, "quantity": 3}]
        }
    }
}