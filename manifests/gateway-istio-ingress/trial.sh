


http://34.102.157.139/


kubectl run --context=webx-us-west1-a -i --tty --rm loadgen  \
    --image=cyrilbkr/httperf  \
    --restart=Never  \
    -- /bin/sh -c 'httperf  \
    --server=34.102.157.139  \
    --hog --uri="/zone" --port 80  --wsess=100000,1,1 --rate 20'