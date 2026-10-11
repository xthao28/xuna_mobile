import 'dart:async';

abstract class UseCase<Input, Output> {
  const UseCase();

  FutureOr<Output> execute(
    Input input,
  );
}

abstract class NoInputUseCase<Output> {
  const NoInputUseCase();

  FutureOr<Output> execute();
}
