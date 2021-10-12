package se.arkalix.util.config.data;

import se.arkalix.dto.DtoCodec;
import se.arkalix.dto.DtoReadableAs;

import java.net.InetSocketAddress;
import java.util.Optional;

@DtoReadableAs(DtoCodec.JSON)
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