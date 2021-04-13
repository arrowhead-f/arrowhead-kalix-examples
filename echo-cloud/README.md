# Echo Consumer and Provider (Cloud)

In this example, two Arrowhead systems interact while using the service
registration, authorization and orchestration capabilities of the three
Arrowhead core systems with the corresponding names. The first interacting
system provides a service and the other system consumes that service. The
service provider is configured to only grant access to its service if the
system attempting to consume it has a token issued by the same authorization
system of that local cloud.

The example should serve as a good starting point for getting familiar with
how to use Arrowhead Kalix for integration with Arrowhead local clouds. It
should be noted, however, that, at the time this was being written, configuring
local clouds can be tedious and error-prone. This is actively being improved
with future releases of Arrowhead.

## Running

This folder contains a [`docker-compose.yml`](docker-compose.yml) file that
can be used to spin up a local cloud that tests interaction between the two
mentioned systems. To get the local cloud up and running, make sure you have
Docker and Maven installed on your system before entering the following
commands into a POSIX-terminal positioned in this directory.

```sh
$ ./gradlew shadowJar
$ docker-compose up --build
```

The second command might have to be preceded by `sudo` if running on a Linux
system. After seeing the Docker network nodes spin up and write to your
terminal, you will discover that a system we have not yet mentioned is started
before the echo provider and consumer. The started system created the necessary
rules in the service registry, authorization and orchestration systems for the
provider and consumer to be able to communicate.

To look at these rules, import the _system operator key store_
([`crypto/sysop.p12`](crypto/sysop.p12)) to your web browser (the password is
`123456`) and the _system trust store_
([`crypto/truststore.p12`](crypto/truststore.p12)) (same password). Make sure
that the `arrowhead.eu` certificate is trusted to identify websites. Then use
the following addresses to use the Swagger interfaces of the different services
to manually enter or review the required rules.

- Service Registry [`https://localhost:8443`](`https://localhost:8443`)
- Authorization [`https://localhost:8445`](`https://localhost:8445`)
- Orchestrator [`https://localhost:8441`](`https://localhost:8441`)

For more information about how to setup the rules, please consult
[`https://github.com/arrowhead-f/core-java-spring/blob/master/README.md`](https://github.com/arrowhead-f/core-java-spring/blob/master/README.md).

## Help Improve This Example

Can you think of any way this example could be made more comprehensible?
Please don't hesitate to create a new GitHub issue with your idea and then
be ready to make that improvement after discussing it.
