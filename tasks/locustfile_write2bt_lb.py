from locust import HttpUser, task, between

import google.auth
import google.auth.transport.requests
import google.oauth2.id_token
import logging
import sys

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

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
    def test_write2bt(self):
        try:
            respone = self.client.post(url="/write2bt", data={"test": "data"})
        except Exception as e:
            logging.error(e)
        logging.info("request header -> {}".format(self.client.headers))
        logging.info("respone header -> {}".format(respone.headers))
        logging.info("response body -> {}".format(respone.content))