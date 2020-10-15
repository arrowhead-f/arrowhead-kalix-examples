#!/usr/bin/env bash

trap 'pkill -P $$' SIGINT SIGTERM

mvn clean package -U

CP="$(find . -wholename './target/*-jar-with-dependencies.jar' | tr '\n' ':')"

java -cp "${CP}" se.arkalix.examples.EchoProvider \
  ./crypto/system.echo_provider.p12 ./crypto/truststore.p12 &

sleep 5s

java -cp "${CP}" se.arkalix.examples.EchoConsumer \
  ./crypto/system.echo_consumer.p12 ./crypto/truststore.p12 &

wait %1 %2

echo "Done!"
