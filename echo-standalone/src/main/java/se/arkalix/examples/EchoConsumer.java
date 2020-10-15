package se.arkalix.examples;

import se.arkalix.dto.DtoEncoding;
import se.arkalix.net.http.HttpMethod;
import se.arkalix.net.http.client.HttpClient;
import se.arkalix.net.http.client.HttpClientRequest;
import se.arkalix.security.identity.OwnedIdentity;
import se.arkalix.security.identity.TrustStore;
import se.arkalix.util.concurrent.Schedulers;

import java.net.InetSocketAddress;
import java.nio.file.Path;
import java.time.Duration;
import java.util.Arrays;

public class EchoConsumer {
    public static void main(final String[] args) {
        if (args.length != 2) {
            System.err.println("Usage: java -jar example.jar <keyStorePath> <trustStorePath>");
            System.exit(1);
        }
        try {
            System.out.println("Running echo consumer ...");

            // Load owned system identity and truststore.
            final var password = new char[]{'1', '2', '3', '4', '5', '6'};
            final var identity = new OwnedIdentity.Loader()
                .keyPassword(password)
                .keyStorePath(Path.of(args[0]))
                .keyStorePassword(password)
                .load();
            final var trustStore = TrustStore.read(Path.of(args[1]), password);
            Arrays.fill(password, '\0');

            // Create Arrowhead client.
            final var client = new HttpClient.Builder()
                .identity(identity)
                .trustStore(trustStore)
                .build();

            final var echoProviderSocketAddress = new InetSocketAddress("localhost", 28081);

            // HTTP GET request without function composition.
            client.send(echoProviderSocketAddress, new HttpClientRequest()
                .method(HttpMethod.GET)
                .uri("/example/pings/32")
                .header("accept", "application/json"))
                .onResult(result -> {
                    if (result.isSuccess()) {
                        final var response = result.value();
                        if (response.status().isSuccess()) {
                            response
                                .bodyAsString()
                                .onResult(result1 -> {
                                    if (result1.isSuccess()) {
                                        System.err.println("\nGET /example/pings/32 result:");
                                        System.err.println(response.status());
                                        System.err.println(result1.value());
                                    }
                                    else {
                                        System.err.println("\nGET /example/pings/32 failed:");
                                        result1.fault().printStackTrace();
                                    }
                                });
                        }
                        else {
                            System.err.println("\nGET /example/pings/32 failed:");
                            System.err.println(response.status());
                        }
                    }
                    else {
                        System.err.println("\nGET /example/pings/32 failed:");
                        result.fault().printStackTrace();
                    }
                });

            // HTTP POST request with function composition.
            client.send(echoProviderSocketAddress, new HttpClientRequest()
                .method(HttpMethod.POST)
                .uri("/example/pings")
                .body(DtoEncoding.JSON, new PingBuilder()
                    .ping("pong!")
                    .build()))
                .flatMap(response -> response.bodyAsIfSuccess(PingDto.class))
                .ifSuccess(body -> {
                    System.err.println("\nPOST /example/pings result:");
                    System.err.println(body);
                })
                .onFailure(throwable -> {
                    System.err.println("\nPOST /example/pings failure:");
                    throwable.printStackTrace();
                });

            // HTTP DELETE request.
            client.send(echoProviderSocketAddress, new HttpClientRequest()
                .method(HttpMethod.DELETE)
                .uri("/example/runtime"))
                .onResult(result -> {
                    System.err.println("\nDELETE /example/runtime result:");
                    result.ifSuccess(response -> System.err.println(response.status()));
                    result.ifFailure(Throwable::printStackTrace);

                    // Exit in 0.5 seconds.
                    Schedulers.fixed()
                        .schedule(Duration.ofMillis(500), () -> System.exit(0))
                        .onFailure(Throwable::printStackTrace);
                });
        }
        catch (final Throwable e) {
            e.printStackTrace();
        }
    }
}
