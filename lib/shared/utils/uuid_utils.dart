import 'package:uuid/uuid.dart';

const uuid = Uuid();

String get uuidV4 {
  return uuid.v4();
}
