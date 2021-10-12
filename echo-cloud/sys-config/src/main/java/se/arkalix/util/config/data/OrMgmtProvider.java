package se.arkalix.util.config.data;

import se.arkalix.dto.DtoCodec;
import se.arkalix.dto.DtoWritableAs;

import java.util.Optional;

@DtoWritableAs(DtoCodec.JSON)
public interface OrMgmtProvider {
    String address();

    Optional<String> authenticationInfo();

    int port();

    String systemName();
}