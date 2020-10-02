# Echo Consumer and Provider (Standalone)

In this example, only two Arrowhead systems interact: a system providing a
service and another system consuming that service. The service provider is
configured to only grant access to its service if the system attempting to
consume it has a certificate issued by the same cloud certificate as the
provider. As the systems are assumed to know of each other's IP addresses, no
Service Registry or other intermediary is required.

The example should serve as a good starting point for getting familiar with
Arrowhead Kalix and the Arrowhead Framework.

## Running

Make sure you have Java 11 or above and Maven installed on your system before
entering the following command into a POSIX-terminal positioned in this
directory.

```sh
$ ./run.sh
```

You will see some log output of the two systems written to your terminal.

