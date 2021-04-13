package se.arkalix.util.config.data;

import se.arkalix.dto.DtoReadableAs;

import static se.arkalix.dto.DtoEncoding.JSON;

@DtoReadableAs(JSON)
public interface SrMgmtServiceDefinition {
    String createdAt();

    int id();

    String serviceDefinition();

    String updatedAt();
}