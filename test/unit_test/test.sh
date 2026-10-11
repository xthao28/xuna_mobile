fvm flutter test --coverage

genhtml coverage/lcov.info -o coverage/html --quiet

open coverage/html/index.html