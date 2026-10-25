import 'package:yeetrip/core/money.dart';
import '../../test_helper.dart';

class TripSetupValidator {
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Trip name is required';
    }
    return null;
  }

  static String? validateBudget(String? budgetStr) {
    if (budgetStr == null || budgetStr.trim().isEmpty) {
      return 'Budget is required';
    }
    try {
      final paise = Money.decimalStringToPaise(budgetStr);
      if (paise <= 0) {
        return 'Budget must be greater than zero';
      }
    } catch (_) {
      return 'Enter a valid amount';
    }
    return null;
  }

  static String? validateDays(String? daysStr) {
    if (daysStr == null || daysStr.trim().isEmpty) {
      return 'Required';
    }
    final d = int.tryParse(daysStr.trim());
    if (d == null || d < 1) {
      return 'Min 1 day';
    }
    return null;
  }

  static String? validateTravelers(List<String> names) {
    final trimmed = names.map((n) => n.trim()).toList();

    if (trimmed.isEmpty) {
      return 'Add at least one traveler';
    }

    if (trimmed.any((n) => n.isEmpty)) {
      return 'Traveler names cannot be blank';
    }

    final lower = trimmed.map((n) => n.toLowerCase()).toSet();
    if (lower.length < trimmed.length) {
      return 'Traveler names must be unique';
    }

    return null;
  }
}

void main() async {
  group('TripSetupValidator - Name', () {
    test('accepts valid name', () {
      expect(TripSetupValidator.validateName('Goa Trip'), null);
      expect(TripSetupValidator.validateName('  Manali 2026  '), null);
    });

    test('rejects empty or blank name', () {
      expect(TripSetupValidator.validateName(''), 'Trip name is required');
      expect(TripSetupValidator.validateName('   '), 'Trip name is required');
      expect(TripSetupValidator.validateName(null), 'Trip name is required');
    });
  });

  group('TripSetupValidator - Budget', () {
    test('accepts valid rupee strings', () {
      expect(TripSetupValidator.validateBudget('50000'), null);
      expect(TripSetupValidator.validateBudget('1,25,000.50'), null);
      expect(TripSetupValidator.validateBudget('100'), null);
    });

    test('rejects zero or negative budget', () {
      expect(TripSetupValidator.validateBudget('0'), 'Budget must be greater than zero');
      expect(TripSetupValidator.validateBudget('-500'), 'Enter a valid amount');
    });

    test('rejects invalid format or decimals', () {
      expect(TripSetupValidator.validateBudget('abc'), 'Enter a valid amount');
      expect(TripSetupValidator.validateBudget('500.123'), 'Enter a valid amount');
      expect(TripSetupValidator.validateBudget(''), 'Budget is required');
    });
  });

  group('TripSetupValidator - Days', () {
    test('accepts positive integer days', () {
      expect(TripSetupValidator.validateDays('1'), null);
      expect(TripSetupValidator.validateDays('7'), null);
      expect(TripSetupValidator.validateDays('30'), null);
    });

    test('rejects 0, negative, or invalid days', () {
      expect(TripSetupValidator.validateDays('0'), 'Min 1 day');
      expect(TripSetupValidator.validateDays('-1'), 'Min 1 day');
      expect(TripSetupValidator.validateDays('abc'), 'Min 1 day');
      expect(TripSetupValidator.validateDays(''), 'Required');
    });
  });

  group('TripSetupValidator - Travelers', () {
    test('accepts valid unique list of travelers', () {
      expect(TripSetupValidator.validateTravelers(['Aarav', 'Priya', 'Kabir']), null);
      expect(TripSetupValidator.validateTravelers(['OnlyMe']), null);
    });

    test('rejects blank traveler names', () {
      expect(TripSetupValidator.validateTravelers(['Aarav', '  ', 'Priya']), 'Traveler names cannot be blank');
      expect(TripSetupValidator.validateTravelers(['']), 'Traveler names cannot be blank');
    });

    test('rejects duplicate traveler names (case-insensitive)', () {
      expect(TripSetupValidator.validateTravelers(['Aarav', 'aarav']), 'Traveler names must be unique');
      expect(TripSetupValidator.validateTravelers(['Priya', 'Rohan', 'PRIYA']), 'Traveler names must be unique');
    });
  });

  final ok = await runSuite('Trip Setup Validation Tests');
  if (!ok) throw Exception('Trip setup validation tests failed');
}
