import 'package:xuna_mobile/features/device/data/mapper/device_codes.dart';
import 'package:xuna_mobile/features/device/data/model/life_summary_model.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/shared/mappers/mappers_src.dart';

class LifeSummaryMapper extends BaseDataMapper<LifeSummaryModel, LifeSummary> {
  @override
  LifeSummary mapToEntity(LifeSummaryModel? data) {
    if (data == null) throw const FormatException('Missing life summary');
    return LifeSummary(
      activeSeconds: data.activeSeconds,
      events: data.events,
      decisionId: data.decisionId,
      context: DeviceCodes.contextFromCode(data.contextCode),
      action: DeviceCodes.animationFromCode(data.actionCode),
      quietChoice: DeviceCodes.animationFromCode(data.quietChoiceCode),
      playChoice: DeviceCodes.animationFromCode(data.playChoiceCode),
      canFeedback: data.canFeedback,
      memories: data.memoryCount,
    );
  }
}
