package se.arkalix.util.config.data;

import se.arkalix.dto.DtoCodec;
import se.arkalix.dto.DtoReadableAs;
import se.arkalix.dto.DtoToString;

import java.util.List;

@DtoReadableAs(DtoCodec.JSON)
@DtoToString
public interface CfConsumptionRule {
    String consumer();

    List<String> services();

    List<String> providers();
}
