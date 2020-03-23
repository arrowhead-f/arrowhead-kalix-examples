#!/bin/bash

# This script uses the Java `keytool` and the `openssl` command line utilities
# to create PKCS12 key stores and trust stores for both the echo system and the
# echo client in this example. Note how the script also creates key stores for
# a so-called "root" and a "cloud". The "root" certificate is a dummy version
# of the actual root certificate to be provided by the Arrowhead Consortium,
# while the cloud certificate represents the local cloud in which both the
# echo system and client are located. Without being part of the same cloud, the
# system will reject all attempts by the client to connect.

cd "$(dirname "$0")" || exit
source "../../scripts/lib_certs.sh"
cd ..

# Root

create_root_keystore \
  "crypto/root.p12" "arrowhead.eu"

# Cloud

create_cloud_keystore \
  "crypto/root.p12" "arrowhead.eu" \
  "crypto/kalix-example.p12" "kalix-example.ltu.arrowhead.eu"

# Echo system

create_system_keystore \
  "crypto/root.p12" "arrowhead.eu" \
  "crypto/kalix-example.p12" "kalix-example.ltu.arrowhead.eu" \
  "crypto/system-keystore.p12" "echo-system.kalix-example.ltu.arrowhead.eu" \
  "dns:localhost,ip:127.0.0.1"

create_truststore \
  "crypto/system-truststore.p12" \
  "crypto/root.crt" "arrowhead.eu"

# Echo client

create_system_keystore \
  "crypto/root.p12" "arrowhead.eu" \
  "crypto/kalix-example.p12" "kalix-example.ltu.arrowhead.eu" \
  "crypto/client-keystore.p12" "echo-client.kalix-example.ltu.arrowhead.eu" \
  "dns:localhost,ip:127.0.0.1"

create_truststore \
  "crypto/client-truststore.p12" \
  "crypto/root.crt" "arrowhead.eu"
