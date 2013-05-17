library siege_engine_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:siege_engine/siege_engine.dart';

part 'world_test.dart';
part 'entity_test.dart';
part 'component_manager_test.dart';
part 'mock_classes.dart';

void main() {
  world_test();
  entity_test();
  component_manager_test();
}