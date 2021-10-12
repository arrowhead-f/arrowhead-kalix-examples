package se.arkalix.util.config.data;

import se.arkalix.dto.DtoCodec;
import se.arkalix.dto.DtoWritableAs;

@DtoWritableAs(DtoCodec.JSON)
public interface OrMgmtRule {
    int consumerSystemId();

    int priority();

    OrMgmtProvider providerSystem();

    String serviceDefinitionName();

    String serviceInterfaceName();
}