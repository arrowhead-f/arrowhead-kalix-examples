package se.arkalix.util.config.data;

import se.arkalix.dto.DtoCodec;
import se.arkalix.dto.DtoReadableAs;

@DtoReadableAs(DtoCodec.JSON)
public interface SrMgmtInterface {
    String createdAt();

    int id();

    String interfaceName();

    String updatedAt();
}