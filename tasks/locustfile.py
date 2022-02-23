import time
from locust import HttpUser, task, between

class EmulatedUser(HttpUser):
    wait_time = between(0.5, 5)

    @task
    def view_index(self):
	    self.client.get("/")

    @task(3)
    def view_items(self):
        for id in ['OLJCESPC7Z', '66VCHSJNUP', '1YMWWN1N4O', '9SIQT8TOJO']:
            self.client.get(f"/product/{id}", name="/product")
