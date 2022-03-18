from locust import HttpUser, task, between

# import google.auth
# import google.auth.transport.requests
# import google.oauth2.id_token
import logging
import sys

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

class EmulatedUser(HttpUser):
    wait_time = between(0.5, 5)


    def on_start(self):
        self.target_audience = self.client.base_url
        self.url = self.client.base_url
        try:
            # self.auth_req = google.auth.transport.requests.Request()
            # self.id_token = google.oauth2.id_token.fetch_id_token(self.auth_req, self.target_audience)
            # logging.info("token -> {}".format(self.id_token))
            self.client.headers.update({'Authorization': 'Bearer {}'.format('eyJhbGciOiJSUzI1NiIsImtpZCI6IjcyOTE4OTQ1MGQ0OTAyODU3MDQyNTI2NmYwM2U3MzdmNDVhZjI5MzIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIzMjU1NTk0MDU1OS5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImF1ZCI6IjMyNTU1OTQwNTU5LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTA0MTExOTUzNjQzNjE2MjcwMjE1IiwiaGQiOiJjaHVhbmNjLmFsdG9zdHJhdC5jb20iLCJlbWFpbCI6InRlc3RhZG1pbkBjaHVhbmNjLmFsdG9zdHJhdC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6InZET3ozZlpqQ3BNRldwaUp4M1prSVEiLCJpYXQiOjE2NDc2MjA3OTgsImV4cCI6MTY0NzYyNDM5OH0.g4h_bMW5v4mwlDRMYeFNGkW5f8MZE5ZoIS5TgHMn74R35Lo7FSEwmxFdd_zmWe0Rwi0Z-zj597_9ggQK5vvfF6gfvEykALLzmSgv1O_7j-rPX2yV7SsPRDWfauPOfHIgrvaVS8RyFpz6J7SJfEghqElfhhJruccQ5pTnVn68UWwxUJLRXhYc5Lnfu0Eiof3-oaoGb0jmTo9DHcoeeECiYDkffgN8Gq78QXs8uminmMt9pCDXYUMHLd_oZQ-i7xaTfYdLs_WRKLn9TXAczUGBkhsTGauhtXw2r55EN_T0n2iQA2iBDHgq1WmHKhtkicIIPPIO0yF0-S4PaRzCFJ1R6Q')})
        except Exception as e:
            logging.error(e)
        # logging.info(self.id_token)


    # @task
    # def test_bite_cpu(self):
    #     bearer = "Bearer {}".format(self.id_token)
    #     respone = self.client.get(url="/bite/10", headers={"Authorization": bearer})
    #     print(respone)

    @task(80)
    def test_write2bt(self):
        try:
            respone = self.client.post(url="/write2bt", data={"test": "data"})
        except Exception as e:
            logging.error(e)
        logging.info("request header -> {}".format(self.client.headers))
        logging.info("respone header -> {}".format(respone.headers))
        logging.info("response body -> {}".format(respone.content))