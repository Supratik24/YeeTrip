# YeeTrip ✈️🇮🇳

**YeeTrip** is an offline-first group trip budget and expense-splitting mobile app crafted specifically for Indian users and domestic/international group travel. Everything works fully offline on a single smartphone with zero network dependency, zero accounts, and zero cloud lock-in.

---

## Key Highlights

- **INR (₹) Native with Exact Integer Paise Precision**: All currency is stored and calculated strictly as integer paise. `double` is never used for money anywhere in logic or storage, guaranteeing zero floating-point rounding errors.
- **Indian Numbering System**: Formatting respects standard Indian comma groupings (e.g. `₹1,25,000` and `₹2,400.50`).
- **Dynamic 100% Budget Rebalancer**: Six core categories (*Stay*, *Food*, *Transport*, *Activities*, *Shopping*, *Buffer*) with interactive sliders that always total exactly 100% using proportional scaling and largest-remainder adjustments.
- **4 Flexible Expense Split Modes**:
  1. *Equal*: Leftover paise (amount % n) are distributed deterministically to the first travelers in fixed ID order so splits sum *exactly* to the total.
  2. *Percentage*: Largest-remainder rounding ensures 100% split precision down to 1 paisa.
  3. *Shares (Weights)*: Proportional distribution with largest-remainder balancing.
  4. *Exact*: Validates exact amounts in paise with descriptive difference feedback.
- **Visual Dashboard & "Cooked Meter"**:
  - Live metric cards: Total budget, per-person budget, per-day budget, remaining/over budget.
  - "Cooked meter" status: **Chill** (<50%), **Careful** (50–80%), **Slightly cooked** (80–100%), and **Fully cooked** (>100%).
  - Planned vs. actual expenditure bars (turns to error color when exceeding planned category budget).
  - Planned category distribution pie chart via `fl_chart`.
- **Greedy Settle-Up Engine**:
  - Calculates net balances per person.
  - Repeatedly matches the largest debtor with the largest creditor to resolve all debts in at most $n - 1$ payments, leaving every single person's balance at exactly 0 paise.
- **RFC 4180 CSV Data Export**: Exports complete expense records with dates, categories, payers, amounts in INR, and split breakdowns directly to the system share sheet.
- **Internationalization (i18n)**: English (`en`) active, structured and ready for Hindi (`hi`) via `.arb` files.

---

## Architecture & Design Patterns

YeeTrip is built following clean architecture and pure domain separation:

```
┌────────────────────────────────────────────────────────┐
│             Presentation Layer (Flutter)               │
│  Material 3 Screens, Riverpod Providers, GoRouter     │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│              Domain Layer (Pure Dart)                  │
│  Money Utils, SplitCalculator, BudgetRebalancer,       │
│  SettleCalculator, CsvGenerator (Zero Flutter Imports) │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│               Data & Storage Layer                     │
│  TripRepository & ExpenseRepository Interfaces         │
│  Drift SQLite Implementation (Foreign Keys, Cascades)  │
└────────────────────────────────────────────────────────┘
```

### Non-Negotiable Core Principles
1. **Integer Paise Everywhere**: Every monetary value in the database, repositories, and domain calculators is an `int` representing paise (`1 INR = 100 paise`). Conversion to rupees happens only for UI display.
2. **Exact Splits Guarantee**: The sum of shares across all split participants always equals the total expense amount in paise.
3. **No Drift in UI**: Presentation widgets interact solely with abstract repository interfaces (`TripRepository`, `ExpenseRepository`) exposed via Riverpod providers.
4. **Pure Dart Testability**: All business calculators (`Money`, `SplitCalculator`, `BudgetRebalancer`, `SettleCalculator`, `CsvGenerator`) have zero Flutter imports and can be executed via any standard Dart test runner.

---

## Folder Structure

```
lib/
├── main.dart                      # App entrypoint (initializes binding & ProviderScope)
├── app.dart                       # Root MaterialApp.router with themes and l10n
├── core/
│   ├── constants/
│   │   └── categories.dart        # 6 core trip categories & default allocations
│   ├── money.dart                 # Pure Dart paise/rupee conversion & Indian formatting
│   ├── router.dart                # go_router declarative routes
│   └── theme.dart                 # Material 3 light & dark themes (teal/amber palette)
├── data/
│   ├── local/
│   │   ├── tables.dart            # Drift table schemas with cascade deletes & indices
│   │   ├── app_database.dart      # Drift database definition, DAOs, and migrations
│   │   └── connection/
│   │       └── native.dart        # Native SQLite connection isolates
│   ├── providers.dart             # Riverpod providers for DB, repositories, & streams
│   └── repositories/
│       ├── trip_repository.dart    # Abstract interface + DriftTripRepository
│       └── expense_repository.dart # Abstract interface + DriftExpenseRepository
├── features/
│   ├── trips/                     # Home screen (trip list), Trip setup, validations
│   ├── budget/                    # 6-slider 100% budget screen & rebalance logic
│   ├── expenses/                  # Add/edit expense, 4 split modes, expense list & filters
│   ├── dashboard/                 # Metric cards, Cooked meter, planned vs actual bars, pie chart
│   ├── settle/                    # Balance list, greedy settlement engine, settle screen
│   └── settings/                  # CSV generator & exporter, system share sheet, about screen
└── l10n/                          # Localization templates (app_en.arb, app_hi.arb)
```

---

## Database Model (Drift / SQLite)

- **`trips`**: `id` (UUID PK), `name`, `total_budget_paise`, `days`, `currency` (default 'INR'), `created_at`.
- **`travelers`**: `id` (UUID PK), `trip_id` (FK -> `trips.id` ON DELETE CASCADE), `name`, `upi_vpa` (nullable, extension point).
- **`category_allocations`**: `trip_id` (FK -> `trips.id` ON DELETE CASCADE), `category`, `percent` (integer).
- **`expenses`**: `id` (UUID PK), `trip_id` (FK -> `trips.id` ON DELETE CASCADE), `description`, `amount_paise`, `category`, `paid_by` (FK -> `travelers.id`), `source` (default `'manual'`), `upi_txn_id` (nullable), `confirmed` (bool), `created_at`.
  - *Unique partial index* on `(trip_id, upi_txn_id)` where `upi_txn_id IS NOT NULL`.
- **`expense_splits`**: `expense_id` (FK -> `expenses.id` ON DELETE CASCADE), `traveler_id` (FK -> `travelers.id`), `share_paise`.

---

## Setup & Running

### Prerequisites
- Flutter SDK (stable 3.47+ recommended)
- Dart SDK 3.13+
- Android Studio / VS Code with Flutter extension

### Android Minimum SDK
- **Minimum SDK**: Android `minSdkVersion 21` (Android 5.0 Lollipop).
- No changes to `minSdkVersion` beyond 21 are required; all dependencies (`drift`, `sqlite3_flutter_libs`, `share_plus`, `path_provider`) fully support API level 21+.

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone <repo-url>
   cd YeeTrip
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code (Drift DB & L10n)**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   flutter gen-l10n
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

---

## Running Tests

YeeTrip features 100% passing tests covering money utilities, property-based rebalancer tests (1,000 runs), property-based split tests (1,000 runs each), greedy settlement proofs, in-memory SQLite database operations, widget tests, and end-to-end trip flows.

### 1. Flutter Test Suite
To run all 61 tests across all test suites with the official Flutter test engine:
```bash
flutter test
```

Expected output:
```
00:16 +61: All tests passed!
```

### 2. Static Code Analysis
Run static analysis to verify 0 errors, 0 warnings, and 0 lint issues:
```bash
flutter analyze
```

---

## Future Work

The offline core of YeeTrip has been architected with clear abstraction layers and extension points in the database schema and repository interfaces to facilitate the following future capabilities:

1. **UPI Pay-and-Log Integration**:
   - Utilize existing `upi_vpa` in the `travelers` table and `upi_txn_id` in the `expenses` table.
   - Launch UPI intent URLs (`upi://pay?pa=...&am=...&cu=INR`) directly from the Settle-Up screen.
   - Automatically parse transaction responses to confirm settlements and log them.
2. **Screenshot OCR Import**:
   - On-device Google ML Kit text recognition for payment confirmation screenshots (Google Pay, PhonePe, Paytm).
   - Auto-extract merchant/description, amount in paise, timestamp, and UPI reference IDs into pre-filled expense drafts.
3. **Multi-User Offline & Peer-to-Peer Sync**:
   - Introduce conflict-free replicated data types (CRDTs) or local Wi-Fi / Bluetooth peer-to-peer syncing (via Nearby Connections) to synchronize trip expenses between group members without requiring a centralized cloud backend.
4. **On-Device Machine Learning Features**:
   - Smart predictive category classification based on merchant descriptions.
   - Proactive spend anomaly detection and budget burn-rate projections based on trip duration and remaining category funds.
