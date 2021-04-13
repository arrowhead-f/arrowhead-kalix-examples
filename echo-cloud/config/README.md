# Configurations

This folder contains the configuration files necessary for the six systems part of this demo to be able to fulfill
their respective roles.

| File/Folder | Description |
|:-------|:------------|
| [crypto/](crypto) | Certificates (.crt), public keys (.pub), private keys (.key) and PKCS#12 stores (.p12) required for the six systems to recognize each others as members of the same local cloud and for the core systems to be recognizable as being core systems by the other three systems. |
| [properties/](properties) | Configuration files required by the three core systems part of this demo, which are the _Service Registry_, _Authorization_ and _Orchestrator_ systems. |
| [sys-config.json](sys-config.json) | Configuration for the sys-config/echo-config system, which allows it to register systems, services, authorization rules and orchestration rules before other systems start. In this demo, the system is used to setup rules for the echo consumer to consume the service of the echo provider system. |