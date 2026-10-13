import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/data/mapper/device_codes.dart';
import 'package:xuna_mobile/features/device/data/model/memory_episode_model.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/shared/mappers/mappers_src.dart';

class MemoryEpisodeMapper
    extends BaseDataMapper<MemoryEpisodeModel, MemoryEpisode> {
  @override
  MemoryEpisode mapToEntity(MemoryEpisodeModel? data) {
    if (data == null) throw const FormatException('Missing memory episode');
    return MemoryEpisode(
      context: DeviceCodes.contextFromCode(data.contextCode),
      action: DeviceCodes.animationFromCode(data.actionCode),
      approved: data.approved,
      fromText: data.sourceCode == DeviceProtocol.sourceText,
    );
  }
}
