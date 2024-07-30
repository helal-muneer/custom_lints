import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/getx_controller_rule.dart';

PluginBase createPlugin() => _GetxControllerLintPlugin();

class _GetxControllerLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) =>
      [const GetxControllerRule()];
}
