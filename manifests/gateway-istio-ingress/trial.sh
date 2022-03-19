


http://34.102.157.139/


kubectl run --context=webx-us-west1-a -i --tty --rm loadgen  \
    --image=cyrilbkr/httperf  \
    --restart=Never  \
    -- /bin/sh -c 'httperf  \
    --server=34.102.157.139  \
    --hog --uri="/zone" --port 80  --wsess=100000,1,1 --rate 20'


kubectl run --context=webx-us-west1-a -n locust -i --tty --rm gcloud  \
    --image=gcr.io/cloud-builders/gcloud  \
    --restart=Never  \
    --command \
    -- bash

curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token" 
