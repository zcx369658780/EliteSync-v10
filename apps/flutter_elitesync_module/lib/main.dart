import 'package:flutter_elitesync_module/main_demo.dart' as demo;
import 'package:flutter_elitesync_module/main_prod.dart' as prod;

Future<void> main() async {
  if (const bool.fromEnvironment('ELITESYNC_SYNTHETIC_DEMO')) {
    await demo.main();
    return;
  }
  await prod.main();
}
