FROM python:3.9-slim

ADD tasks /tasks
RUN pip install -r /tasks/requirements.txt

RUN chmod 755 /tasks/run.sh

EXPOSE 8089 5557
ENTRYPOINT ["/tasks/run.sh", "locustfile_write2bt_lb.py"]

