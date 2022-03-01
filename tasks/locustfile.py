import time
import random
from locust import HttpUser, task, between


products = [
    '0PUK6V6EV0',
    '1YMWWN1N4O',
    '2ZYFJ3GM2N',
    '66VCHSJNUP',
    '6E92ZMYYFZ',
    '9SIQT8TOJO',
    'L9ECAV7KIM',
    'LS4PSXUNUM',
    'OLJCESPC7Z']


def index(l):
    l.client.get("/")


def setCurrency(l):
    currencies = ['EUR', 'USD', 'JPY', 'CAD']
    l.client.post("/setCurrency",
                  {'currency_code': random.choice(currencies)})


def browseProduct(l):
    l.client.get("/product/" + random.choice(products))


def viewCart(l):
    l.client.get("/cart")


def addToCart(l):
    product = random.choice(products)
    l.client.get("/product/" + product)
    l.client.post("/cart", {
        'product_id': product,
        'quantity': random.choice([1, 2, 3, 4, 5, 10])})


def checkout(l):
    addToCart(l)
    l.client.post("/cart/checkout", {
        'email': 'someone@example.com',
        'street_address': '1600 Amphitheatre Parkway',
        'zip_code': '94043',
        'city': 'Mountain View',
        'state': 'CA',
        'country': 'United States',
        'credit_card_number': '4432-8015-6152-0454',
        'credit_card_expiration_month': '1',
        'credit_card_expiration_year': '2039',
        'credit_card_cvv': '672',
    })


class EmulatedUser(HttpUser):
    wait_time = between(0.5, 5)

    @task(8)
    def test_view_index(self):
        self.client.get("/")

    @task(10)
    def test_view_all_items(self):
        for id in products:
            self.client.get(f"/product/{id}", name="/product")

    @task(6)
    def test_set_currency(self):
        setCurrency(self)

    @task(2)
    def test_view_each_item(self):
        browseProduct(self)

    @task(4)
    def test_add_item_to_cart(self):
        addToCart(self)

    @task(4)
    def test_add_item_to_cart(self):
        addToCart(self)

    @task(2)
    def test_view_card(self):
        viewCart(self)

    @task(4)
    def test_checkout(self):
        checkout(self)
