import time
import random
from locust import HttpUser, task, between

import google.auth
import google.auth.transport.requests
import google.oauth2.id_token



class EmulatedUser(HttpUser):
    wait_time = between(0.5, 5)


    def on_start(self):
        self.target_audience = self.client.base_url
        self.url = self.client.base_url
        self.auth_req = google.auth.transport.requests.Request()
        self.id_token = google.oauth2.id_token.fetch_id_token(self.auth_req, self.target_audience)
        print(self.id_token)


    @task
    def test_bite_cpu(self):
        bearer = "Bearer {}".format(self.id_token)
        respone = self.client.get(url="/bite/10", headers={"Authorization": bearer})
        print(respone)
