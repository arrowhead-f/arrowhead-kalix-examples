# Echo Consumer and Provider

In this example, only two Arrowhead systems interact: a system providing a
service and another system consuming that service. The service provider is
configured to only grant access to its service if the system attempting to
consume it has a certificate issued by the same cloud certificate as the
provider. As the systems are assumed to know of each other's IP addresses, no
Service Registry or other intermediary is required.

The example should serve as a good starting point for getting familiar with
Arrowhead Kalix and the Arrowhead Framework.