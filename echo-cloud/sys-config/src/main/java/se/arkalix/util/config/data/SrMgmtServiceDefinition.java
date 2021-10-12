package se.arkalix.util.config.data;

import se.arkalix.dto.DtoCodec;
import se.arkalix.dto.DtoReadableAs;

@DtoReadableAs(DtoCodec.JSON)
public interface SrMgmtServiceDefinition {
    String createdAt();

    int id();

    String serviceDefinition();

    String updatedAt();
}