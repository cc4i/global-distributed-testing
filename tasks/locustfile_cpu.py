import time
import random
from locust import FastHttpUser, task, between
import google.auth
import google.auth.transport.requests

creds, project = google.auth.default()

class EmulatedUser(FastHttpUser):
    wait_time = between(0.5, 5)
    
    # creds.valid is False, and creds.token is None
    # Need to refresh credentials to populate those
    auth_req = google.auth.transport.requests.Request()
    creds.refresh(auth_req)
    # Now you can use creds.token
    def __init__(self, environment):
        print(creds.token)

    @task
    def test_view_index(self):
        self.client.get(path="/bite/10", headers={"Authorization": "Bearer {}".format(creds.token)})
