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
        self.target_audience = self.client.base_url
        self.url = self.client.base_url
        try:
            self.auth_req = google.auth.transport.requests.Request()
            self.id_token = google.oauth2.id_token.fetch_id_token(self.auth_req, self.target_audience)
        except Exception as e:
            logging.error(e)
        logging.info(self.id_token)


    # @task
    # def test_bite_cpu(self):
    #     bearer = "Bearer {}".format(self.id_token)
    #     respone = self.client.get(url="/bite/10", headers={"Authorization": bearer})
    #     print(respone)

    @task(80)
    def test_write2bt(self):
        bearer = "Bearer {}".format(self.id_token)
        logging.info("bearer -> {}".format(bearer))
        try:
            respone = self.client.post(url="/write2bt", headers={"Authorization": bearer}, data={"test": "data"})
        except Exception as e:
            logging.error(e)

        logging.info("request header -> {}".format(self.client.headers))
        logging.info("respone header -> {}".format(respone.headers))
        logging.info("response body -> {}".format(respone.content))