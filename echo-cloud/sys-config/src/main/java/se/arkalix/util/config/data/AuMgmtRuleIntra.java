package se.arkalix.util.config.data;

import se.arkalix.dto.DtoCodec;
import se.arkalix.dto.DtoWritableAs;

import java.util.List;

@DtoWritableAs(DtoCodec.JSON)
public interface AuMgmtRuleIntra {
    int consumerId();

    List<Integer> interfaceIds();

    List<Integer> providerIds();

    List<Integer> serviceDefinitionIds();
}