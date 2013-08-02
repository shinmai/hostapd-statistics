#!/bin/bash
while true; do
echo -e "HTTP/1.1 200 OK\n\n $(bash ./web.sh)" | nc -l -p 1500 -q1 > /dev/null
done

