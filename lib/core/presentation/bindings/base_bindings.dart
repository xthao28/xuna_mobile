import 'package:get/get_instance/src/bindings_interface.dart';

abstract class BaseBindings extends Bindings {
  @override
  void dependencies() {
    bindingsRepository();
    bindingsUseCase();
    bindingsController();
  }

  void bindingsRepository();

  void bindingsUseCase();

  void bindingsController();
}

class BindingsBuilderClean extends BaseBindings {
  final BindingBuilderCallback? bindingsControllerBuilder;
  final BindingBuilderCallback? bindingsRepositoryBuilder;
  final BindingBuilderCallback? bindingsUseCaseBuilder;

  BindingsBuilderClean({
    this.bindingsControllerBuilder,
    this.bindingsRepositoryBuilder,
    this.bindingsUseCaseBuilder,
  });

  @override
  void bindingsController() {
    bindingsControllerBuilder?.call();
  }

  @override
  void bindingsRepository() {
    bindingsRepositoryBuilder?.call();
  }

  @override
  void bindingsUseCase() {
    bindingsUseCaseBuilder?.call();
  }
}
