package se.arkalix.util.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import se.arkalix.io.buf.Buffer;
import se.arkalix.net.http.client.HttpClient;
import se.arkalix.security.identity.OwnedIdentity;
import se.arkalix.security.identity.TrustStore;
import se.arkalix.util.concurrent.Futures;
import se.arkalix.util.concurrent.Schedulers;
import se.arkalix.util.config.data.ConfigDto;

import java.net.ServerSocket;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.logging.Level;

public class Main {
    public static Logger logger = LoggerFactory.getLogger(Main.class);

    public static void main(final String[] args) {
        try {
            final var configPath = "config.json";
            final var bytes = Files.readAllBytes(Path.of(configPath));
            final var reader = Buffer.wrap(bytes).asReader();
            final var config = ConfigDto.decodeJson(reader);

            final var clientBuilder = new HttpClient.Builder();

            if (config.insecureMode().orElse(false)) {
                clientBuilder.insecure();
            }
            else {
                clientBuilder
                    .identity(new OwnedIdentity.Loader()
                        .keyStorePath(config.keyStorePath().orElse(null))
                        .keyStorePassword(config.keyStorePassword().map(String::toCharArray).orElse(null))
                        .keyAlias(config.keyAlias().orElse(null))
                        .keyPassword(config.keyPassword().map(String::toCharArray).orElse(null))
                        .load())
                    .trustStore(TrustStore.read(
                        config.trustStorePath().orElse(null),
                        config.trustStorePassword().map(String::toCharArray).orElse(null)));
            }

            final var client = clientBuilder.build();

            final var srSocketAddress = config.serviceRegistrySocketAddress();

            final var serviceRegistry = new ServiceRegistryMgmt(client, srSocketAddress);

            serviceRegistry.register(config.services(), config.providers())
                .flatMap(ignored -> {
                    final var cache = new ServiceRegistryCache(client, srSocketAddress);
                    return cache.refresh()
                        .pass(cache);
                })
                .flatMap(cache -> {
                    final var auSocketAddress = cache.getProviderByNameOrThrow("authorization").socketAddress();
                    final var orSocketAddress = cache.getProviderByNameOrThrow("orchestrator").socketAddress();

                    final var authorization = new AuthorizationMgmt(client, auSocketAddress, cache);
                    final var orchestrator = new OrchestratorMgmt(client, orSocketAddress, cache);

                    return Futures.serialize(List.of(
                        authorization.register(config.rules()),
                        orchestrator.register(config.rules())));
                })
                .ifSuccess(ignored -> Schedulers.dynamic().submit(() -> {
                    // Allow for other systems to determine if configuration is
                    // done by connecting to port 9999 via TCP.
                    logger.info("Notifying about completion by accepting and closing connections on port 9999");
                    try {
                        final var server = new ServerSocket(9999);
                        while (!Thread.interrupted()) {
                            try {
                                server.accept().close();
                            }
                            catch (final Throwable throwable) {
                                throwable.printStackTrace(System.err);
                            }
                        }
                    }
                    catch (final Throwable throwable) {
                        throwable.printStackTrace(System.err);
                    }
                }))
                .onFailure(Main::panic);
        }
        catch (final Throwable throwable) {
            panic(throwable);
        }
    }

    private static void panic(final Throwable throwable) {
        System.err.println("Failed to start Sysop Configurator; unexpected exception thrown during startup");
        throwable.printStackTrace(System.err);
    }

    static {
        final var logLevel = Level.INFO;
        System.setProperty("java.util.logging.SimpleFormatter.format", "%1$tF %1$tT %4$s %5$s%6$s%n");
        final var root = java.util.logging.Logger.getLogger("");
        root.setLevel(logLevel);
        for (final var handler : root.getHandlers()) {
            handler.setLevel(logLevel);
        }
    }
}
