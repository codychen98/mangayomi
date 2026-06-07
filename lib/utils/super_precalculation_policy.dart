import 'package:super_sliver_list/super_sliver_list.dart';

class SuperPrecalculationPolicy extends ExtentPrecalculationPolicy {
  @override
  bool shouldPrecalculateExtents(ExtentPrecalculationContext context) {
    return context.numberOfItems < 100;
  }
}
