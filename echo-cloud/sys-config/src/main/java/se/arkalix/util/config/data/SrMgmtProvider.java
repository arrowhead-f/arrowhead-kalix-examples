package se.arkalix.util.config.data;

import se.arkalix.dto.DtoReadableAs;

import java.net.InetSocketAddress;
import java.util.Optional;

import static se.arkalix.dto.DtoEncoding.JSON;

@DtoReadableAs(JSON)
public interface SrMgmtProvider {
    String address();

    Optional<String> authenticationInfo();

    String createdAt();

    int id();

    int port();

    String systemName();

    String updatedAt();

    default InetSocketAddress socketAddress() {
        return new InetSocketAddress(address(), port());
    }
}