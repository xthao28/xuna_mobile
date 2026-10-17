import 'package:xuna_mobile/features/account/data/model/consent_model.dart';
import 'package:xuna_mobile/features/account/domain/entity/consent_settings.dart';
import 'package:xuna_mobile/shared/mappers/mappers_src.dart';

class ConsentMapper extends BaseDataMapper<ConsentModel, ConsentSettings>
    with DataMapperMixin<ConsentModel, ConsentSettings> {
  @override
  ConsentSettings mapToEntity(ConsentModel? data) {
    if (data == null) throw const FormatException('Missing consents');
    return ConsentSettings(
      aggregateMetrics: data.aggregateMetrics,
      experienceEvents: data.experienceEvents,
      conversationText: data.conversationText,
      version: data.version,
    );
  }

  @override
  ConsentModel mapToData(ConsentSettings entity) => ConsentModel(
        aggregateMetrics: entity.aggregateMetrics,
        experienceEvents: entity.experienceEvents,
        conversationText: entity.conversationText,
        version: entity.version,
      );
}
