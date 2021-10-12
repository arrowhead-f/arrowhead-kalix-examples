package se.arkalix.util.config.data;

import se.arkalix.dto.DtoCodec;
import se.arkalix.dto.DtoReadableAs;

import java.net.InetSocketAddress;
import java.util.List;
import java.util.Optional;

@DtoReadableAs(DtoCodec.JSON)
public interface Config {
    Optional<String> keyStorePath();

    Optional<String> keyStorePassword();

    Optional<String> keyAlias();

    Optional<String> keyPassword();

    Optional<String> trustStorePath();

    Optional<String> trustStorePassword();

    Optional<Boolean> insecureMode();

    String serviceRegistryHost();

    default InetSocketAddress serviceRegistrySocketAddress() {
        final var host = serviceRegistryHost();
        final var lastColonIndex = host.lastIndexOf(':');
        final var hostname = host.substring(0, lastColonIndex);
        final var port = Integer.parseInt(host.substring(lastColonIndex + 1));
        return new InetSocketAddress(hostname, port);
    }

    List<CfProvider> providers();

    List<CfService> services();

    List<CfConsumptionRule> rules();
}
