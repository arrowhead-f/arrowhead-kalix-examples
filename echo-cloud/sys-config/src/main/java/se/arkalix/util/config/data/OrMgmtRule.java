package se.arkalix.util.config.data;

import se.arkalix.dto.DtoWritableAs;

import static se.arkalix.dto.DtoEncoding.JSON;

@DtoWritableAs(JSON)
public interface OrMgmtRule {
    int consumerSystemId();

    int priority();

    OrMgmtProvider providerSystem();

    String serviceDefinitionName();

    String serviceInterfaceName();
}