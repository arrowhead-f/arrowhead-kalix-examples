package se.arkalix.util.config.data;

import se.arkalix.ServiceInterface;
import se.arkalix.core.plugin.sr.ServiceRegistrationDto;
import se.arkalix.dto.DtoCodec;
import se.arkalix.dto.DtoReadableAs;
import se.arkalix.dto.DtoToString;
import se.arkalix.security.access.AccessPolicyType;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@DtoReadableAs(DtoCodec.JSON)
@DtoToString
public interface CfService {
    String serviceDefinition();

    int providerIndex();

    String serviceUri();

    Optional<AccessPolicyType> secure();

    Map<String, String> metadata();

    Optional<Integer> version();

    List<ServiceInterface> interfaces();

    default ServiceRegistrationDto toRegistrationUsing(final List<CfProvider> providers) {
        return new ServiceRegistrationDto.Builder()
            .name(serviceDefinition())
            .provider(providers.get(providerIndex()).toDetails())
            .uri(serviceUri())
            .security(secure().orElse(null))
            .metadata(metadata())
            .version(version().orElse(null))
            .interfaces(interfaces())
            .build();
    }
}
