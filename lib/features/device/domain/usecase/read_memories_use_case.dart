import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

class ReadMemoriesUseCase extends NoInputUseCase<List<MemoryEpisode>> {
  const ReadMemoriesUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<List<MemoryEpisode>> execute() => _repository.readMemories();
}
