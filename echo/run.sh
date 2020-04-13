#!/usr/bin/env bash

trap 'pkill -P $$' SIGINT SIGTERM

mvn package

CP="$(find . -wholename './target/*-jar-with-dependencies.jar' | tr '\n' ':')"

java -cp "${CP}" se.arkalix.examples.EchoProvider \
  ./crypto/system-keystore.p12 ./crypto/system-truststore.p12 &

sleep 5s

java -cp "${CP}" se.arkalix.examples.EchoConsumer \
  ./crypto/client-keystore.p12 ./crypto/client-truststore.p12 &

wait %1 %2

echo "Done!"