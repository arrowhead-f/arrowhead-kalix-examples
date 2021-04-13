# Common Module

This module contains code used by both the echo provider and consumer. Most
significantly, it provides the Ping class they use to exchange messages. Note
that two classes are generated when this module is built, which are the
`PingBuilder` and `PingDto` classes. Your development environment may complain
about these not existing until you have built the module for the first time.

