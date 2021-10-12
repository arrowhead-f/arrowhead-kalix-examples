package se.arkalix.util.config.data;

import se.arkalix.dto.DtoCodec;
import se.arkalix.dto.DtoReadableAs;

import java.util.List;

@DtoReadableAs(DtoCodec.JSON)
public interface SrMgmtQueryResult {
    int count();

    List<SrMgmtEntry> data();
}