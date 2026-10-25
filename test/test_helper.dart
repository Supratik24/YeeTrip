// ignore_for_file: avoid_print, library_private_types_in_public_api, dangling_library_doc_comments

/// Test helper providing test registration, assertions, and execution
/// compatible with both `flutter test` and standalone `dart run`.

typedef TestBody = dynamic Function();

class TestCase {
  final String name;
  final TestBody body;

  TestCase(this.name, this.body);
}

class TestGroup {
  final String name;
  final List<TestCase> tests = [];

  TestGroup(this.name);
}

final List<TestGroup> _registeredGroups = [];
TestGroup _currentGroup = TestGroup('Default');

void group(String name, void Function() body) {
  final previousGroup = _currentGroup;
  final newGroup = TestGroup(name);
  _registeredGroups.add(newGroup);
  _currentGroup = newGroup;
  try {
    body();
  } finally {
    _currentGroup = previousGroup;
  }
}

void test(String name, TestBody body) {
  if (!_registeredGroups.contains(_currentGroup)) {
    _registeredGroups.add(_currentGroup);
  }
  _currentGroup.tests.add(TestCase(name, body));
}

bool _areEqual(dynamic a, dynamic b) {
  if (identical(a, b)) return true;
  if (a == b) return true;
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_areEqual(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || !_areEqual(a[key], b[key])) return false;
    }
    return true;
  }
  if (a is Set && b is Set) {
    if (a.length != b.length) return false;
    return a.every(b.contains);
  }
  return false;
}

void expect(dynamic actual, dynamic expected, {String? reason}) {
  if (expected is _ThrowsMatcher) {
    bool threw = false;
    dynamic caughtError;
    try {
      if (actual is Function) {
        actual();
      } else {
        throw AssertionError('Expected a callable function for throwsA, got $actual');
      }
    } catch (e) {
      threw = true;
      caughtError = e;
      if (expected.expectedType != null && caughtError.runtimeType != expected.expectedType) {
        throw AssertionError(
          'Expected error of type ${expected.expectedType}, but got ${caughtError.runtimeType}: $caughtError'
          '${reason != null ? " ($reason)" : ""}',
        );
      }
    }
    if (!threw) {
      throw AssertionError(
        'Expected function to throw, but it completed successfully.'
        '${reason != null ? " ($reason)" : ""}',
      );
    }
    return;
  }

  if (expected is _PredicateMatcher) {
    if (!expected.matches(actual)) {
      throw AssertionError(
        'Expected $actual to match predicate "${expected.description}".'
        '${reason != null ? " ($reason)" : ""}',
      );
    }
    return;
  }

  if (!_areEqual(actual, expected)) {
    throw AssertionError(
      'Expected: <$expected>\n  Actual: <$actual>'
      '${reason != null ? "\n  Reason: $reason" : ""}',
    );
  }
}

dynamic equals(dynamic expected) => expected;

class _ThrowsMatcher {
  final Type? expectedType;
  _ThrowsMatcher([this.expectedType]);
}

_ThrowsMatcher throwsA(dynamic matcher) {
  if (matcher is Type) {
    return _ThrowsMatcher(matcher);
  }
  return _ThrowsMatcher();
}

final throwsFormatException = _ThrowsMatcher(FormatException);

class _PredicateMatcher {
  final bool Function(dynamic) predicate;
  final String description;
  _PredicateMatcher(this.predicate, this.description);
  bool matches(dynamic item) => predicate(item);
}

_PredicateMatcher predicate(bool Function(dynamic) fn, [String desc = 'predicate']) =>
    _PredicateMatcher(fn, desc);

_PredicateMatcher isTrue = _PredicateMatcher((v) => v == true, 'isTrue');
_PredicateMatcher isFalse = _PredicateMatcher((v) => v == false, 'isFalse');

int lastSuitePassed = 0;
int lastSuiteFailed = 0;

Future<bool> runSuite(String suiteName) async {
  print('\n=== Running Test Suite: $suiteName ===');
  int passed = 0;
  int failed = 0;

  for (final group in _registeredGroups) {
    if (group.tests.isEmpty) continue;
    print('\n[Group: ${group.name}]');
    for (final t in group.tests) {
      try {
        final res = t.body();
        if (res is Future) {
          await res;
        }
        passed++;
        print('  ✓ ${t.name}');
      } catch (e, stack) {
        failed++;
        print('  ✗ ${t.name}');
        print('    Error: $e');
        print('    $stack');
      }
    }
  }

  _registeredGroups.clear();
  _currentGroup = TestGroup('Default');

  lastSuitePassed = passed;
  lastSuiteFailed = failed;

  print('\nSuite Summary: $passed passed, $failed failed.');
  return failed == 0;
}
