from locust import HttpUser, task, between

import google.auth
import google.auth.transport.requests
import google.oauth2.id_token
import logging
import sys

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

#TODO - Think about refesh identity token if expired

class EmulatedUser(HttpUser):
    wait_time = between(0.5, 5)


    def on_start(self):
        self.url = self.client.base_url
        self.target_audience = self.url
        try:
            creds, project = google.auth.default()
            auth_req = google.auth.transport.requests.Request()
            creds.refresh(auth_req)
            # self.auth_req = google.auth.transport.requests.Request()
            # self.id_token = google.oauth2.id_token.fetch_id_token(self.auth_req, self.target_audience)
            logging.info("token -> {}".format(creds.id_token))
            self.client.headers.update({'Authorization': 'Bearer {}'.format(creds.id_token)})
        except Exception as e:
            logging.error(e)

    @task
    def test_bite_cpu(self):
        respone = self.client.get(url="/bite/10")
        logging.info(respone)

