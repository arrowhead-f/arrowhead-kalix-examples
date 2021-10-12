package se.arkalix.util.config.data;

import se.arkalix.core.plugin.SystemDetailsDto;
import se.arkalix.dto.DtoCodec;
import se.arkalix.dto.DtoReadableAs;
import se.arkalix.dto.DtoToString;

@DtoReadableAs(DtoCodec.JSON)
@DtoToString
public interface CfProvider {
    String address();

    String authenticationInfo();

    int port();

    String systemName();

    default SystemDetailsDto toDetails() {
        return new SystemDetailsDto.Builder()
            .hostname(address())
            .publicKeyBase64(authenticationInfo())
            .port(port())
            .name(systemName())
            .build();
    }
}
