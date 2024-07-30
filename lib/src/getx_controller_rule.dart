import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class GetxControllerRule extends DartLintRule {
  const GetxControllerRule()
      : super(
          code: _code,
        );

  static const _code = LintCode(
    name: 'getx_controller_rule',
    problemMessage:
        'hey you! GetxController instances should be accessed through .instance or Get.find<T>()',
    correctionMessage:
        'Use YourController.instanse or Get.find<YourController>() or sl<YourController>()',
    errorSeverity: ErrorSeverity.WARNING,
    uniqueName: 'GetXControllerRuleLinter',
    url: 'https://novaGeni.com/packages/novageni_custom_lint_rules',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      // Ignore method calls to super
      if (node.target is SuperExpression) return;

      final methodName = node.methodName.name;

      // Check for usage of Get.find<T>()
      if (methodName == 'find' && _isGetxControllerFindCall(node)) {
        return;
      }

      // Check for usage of static getters (e.g., MyController.instance)
      if (_isStaticGetterForGetxController(node)) {
        return;
      }

      // Check for service locators like sl<T>()
      if (_isServiceLocator(node)) {
        return;
      }

      // Report error if accessing a GetxController instance directly
      if (_isGetxControllerInvocation(node)) {
        reporter.reportErrorForNode(_code, node);
      }
    });
  }

  bool _isGetxControllerFindCall(MethodInvocation node) {
    final argumentList = node.argumentList.arguments;
    if (argumentList.isNotEmpty && argumentList.first is NamedType) {
      final NamedType typeName = argumentList.first as NamedType;
      final DartType? type = typeName.type;
      return type is InterfaceType && _isGetxController(type);
    }
    return false;
  }

  bool _isStaticGetterForGetxController(MethodInvocation node) {
    if (node.methodName.name == 'instance' && node.target is Identifier) {
      final target = node.target as Identifier;
      // Check if the target is a known GetxController static getter
      return _isGetxControllerGetter(target.name);
    }
    return false;
  }

  bool _isServiceLocator(MethodInvocation node) {
    final target = node.target?.staticType;
    if (target is InterfaceType) {
      final targetTypeName = target.getDisplayString(withNullability: false);
      return targetTypeName.startsWith('sl<') && _isGetxController(target);
    }
    return false;
  }

  bool _isGetxControllerInvocation(MethodInvocation node) {
    final targetType = node.target?.staticType;
    if (targetType is InterfaceType) {
      return _isGetxController(targetType);
    }
    return false;
  }

  bool _isGetxController(DartType? type) {
    if (type == null) return false;
    return type is InterfaceType &&
        type.superclass != null &&
        (type.superclass?.getDisplayString(withNullability: false) ==
                'GetxController' ||
            _isGetxController(type.superclass!));
  }

  bool _isGetxControllerGetter(String name) {
    // Define known static getters for GetxController
    return name == 'instance';
  }
}
