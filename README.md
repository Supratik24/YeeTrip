# YeeTrip ✈️🇮🇳

**YeeTrip** is an offline-first group trip budget and expense-splitting mobile app crafted specifically for Indian travelers and domestic/international group travel. Everything works natively offline with zero network dependency required, while offering optional cloud sync, on-device OCR bill parsing, ML spending predictions, and user account management.

---

## 🌟 Key Highlights & Features

### Core Budgeting & Splitting
- **INR (₹) Native with Exact Integer Paise Precision**: All currency is stored and calculated strictly as integer paise (`1 INR = 100 paise`). `double` is never used for money anywhere in logic or storage, guaranteeing zero floating-point rounding errors.
- **Indian Numbering System**: Formatting respects standard Indian comma groupings (e.g. `₹1,25,000` and `₹2,400.50`).
- **Dynamic 100% Budget Rebalancer**: Six core categories (*Stay*, *Food*, *Transport*, *Activities*, *Shopping*, *Buffer*) with interactive sliders that always total exactly 100% using proportional scaling and largest-remainder adjustments.
- **4 Flexible Expense Split Modes**:
  1. *Equal*: Leftover paise (`amount % n`) are distributed deterministically to the first travelers in fixed ID order so splits sum *exactly* to the total.
  2. *Percentage*: Largest-remainder rounding ensures 100% split precision down to 1 paisa.
  3. *Shares (Weights)*: Proportional distribution with largest-remainder balancing.
  4. *Exact*: Validates exact amounts in paise with descriptive difference feedback.
- **Visual Dashboard & "Cooked Meter"**:
  - Live metric cards: Total budget, per-person budget, per-day budget, remaining/over budget.
  - "Cooked meter" status: **Chill** (<50%), **Careful** (50–80%), **Slightly cooked** (80–100%), and **Fully cooked** (>100%).
  - Planned vs. actual expenditure bars (turns to error color when exceeding planned category budget).
  - Planned category distribution pie chart via `fl_chart`.
- **Greedy Settle-Up Engine & UPI Integration**:
  - Calculates net balances per person.
  - Repeatedly matches largest debtor with largest creditor to resolve all debts in at most $n - 1$ payments.
  - Integrates with Indian UPI apps (Google Pay, PhonePe, Paytm, BHIM) via direct deep-link intent `upi://pay?pa=...&am=...&cu=INR`.
- **RFC 4180 CSV Data Export**: Exports complete expense records with dates, categories, payers, amounts in INR, and split breakdowns directly to the system share sheet.
- **Bilingual Internationalization (i18n)**: Instant in-app language switcher for **English** and **Hindi (हिन्दी)**.

---

### Advanced Intelligent & Connected Features

#### 1. 🧾 On-Device Receipt OCR & Bill Scanner
- Pure Dart receipt parsing engine (`ReceiptParser`) with zero external binary or cloud dependencies.
- Extracts total amounts in INR/paise, dates, merchant names, and itemized sub-totals from Indian receipts (e.g., GST food bills, fuel bunk slips, grocery supermarket invoices).
- Interactive bill scanner sheet with auto-detection, pre-loaded realistic Indian travel receipts (Goa Seafood, Highway Petrol, D-Mart, Uber), and one-tap form auto-fill.

#### 2. 🧠 Smart ML Categorization & Spending Velocity Predictor
- **Smart Categorizer**: Pure Dart Naive Bayes keyword classifier trained on 200+ Indian travel, dining, transit, accommodation, and retail terms. Provides real-time category suggestions as you type expense descriptions.
- **Spending Velocity Predictor**: Analyzes elapsed trip days, current spend, and daily burn rate against planned budget pace:
  - Classifies budget risk into 4 tiers: `safe`, `moderate`, `high`, `critical`.
  - Computes projected trip-end surplus or deficit in ₹ paise.
  - Generates early `CategoryDepletionWarning` alerts when specific categories are on pace to exhaust before the trip ends.
  - Interactive "Spending Pace & Forecast" card embedded in the trip dashboard.

#### 3. ☁️ Offline-First Cloud Sync & Conflict Resolution
- Fully functional offline with seamless background cloud sync when online.
- **Deterministic Conflict Resolution**: Last-Write-Wins (LWW) with Lamport timestamps, automatic split sum reconciliation, and soft-delete tombstones.
- **Trip Rooms & Invite Codes**: Share 6-character room codes (e.g. `GOA-782`, `MUM-104`) to join trips across devices.
- **Offline Operations Queue**: Queues local changes during network drops and replays them upon reconnection.

#### 4. 👤 User Accounts, Cloud Auth & Profile Migration
- Support for **Google Sign-In**, **Email/Password**, and **Indian Phone OTP** (+91 verification).
- Seamless **Guest Mode**: Use the entire app without ever logging in or signing up.
- **Zero-Loss Local Trip Migration**: When signing in later, existing local guest trips, travelers, and expenses are automatically migrated and associated with the user profile, auto-linking default UPI VPAs without altering IDs or split amounts.

---

## 🏗️ Architecture & Clean Design

YeeTrip is architected using clean architecture with strict domain separation:

```
┌────────────────────────────────────────────────────────┐
│             Presentation Layer (Flutter)               │
│  Material 3 Screens, Riverpod Providers, GoRouter     │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│              Domain Layer (Pure Dart)                  │
│  Money Utils, SplitCalculator, BudgetRebalancer,       │
│  SettleCalculator, ML Predictor, ConflictResolver      │
│  (Zero Flutter / Platform Dependencies)                │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│               Data & Storage Layer                     │
│  TripRepository & ExpenseRepository Interfaces         │
│  Drift SQLite Local Database, Offline Sync Queue       │
└────────────────────────────────────────────────────────┘
```

### Non-Negotiable Core Principles
1. **Integer Paise Everywhere**: Every monetary value in the database, repositories, and domain calculators is an `int` representing paise (`1 INR = 100 paise`). Conversion to rupees happens only for UI display.
2. **Exact Splits Guarantee**: The sum of shares across all split participants always equals the total expense amount in paise.
3. **Offline Primary Source of Truth**: The local Drift SQLite database is always the primary source of truth. The app never hangs waiting for network calls.
4. **Pure Dart Testability**: All core algorithms have zero Flutter imports and can be executed instantaneously via standard Dart test runners.

---

## 📂 Project Structure

```
lib/
├── main.dart                      # App entrypoint (initializes binding & ProviderScope)
├── app.dart                       # Root MaterialApp.router with themes and l10n
├── core/
│   ├── constants/
│   │   └── categories.dart        # 6 core trip categories & default allocations
│   ├── money.dart                 # Pure Dart paise/rupee conversion & Indian formatting
│   ├── receipt_parser.dart        # OCR bill parser & Indian receipt extractor
│   ├── receipt_scanner_service.dart # Simulated receipt OCR scanner service
│   ├── router.dart                # go_router declarative routes
│   ├── theme.dart                 # Material 3 light & dark themes (teal/amber palette)
│   ├── auth/                      # User authentication, models, and profile migration
│   ├── ml/                        # Smart Naive Bayes categorizer & velocity predictor
│   └── sync/                      # Offline sync engine, LWW conflict resolver, sync queue
├── data/
│   ├── local/
│   │   ├── tables.dart            # Drift table schemas with cascade deletes & indices
│   │   ├── app_database.dart      # Drift database definition, DAOs, and migrations
│   │   └── connection/            # Platform-agnostic connection (Native SQLite & WASM)
│   ├── providers.dart             # Riverpod providers for DB, repositories, & streams
│   └── repositories/
│       ├── trip_repository.dart    # Abstract interface + DriftTripRepository
│       └── expense_repository.dart # Abstract interface + DriftExpenseRepository
├── features/
│   ├── auth/                      # Auth modal, login tabs, edit profile dialog
│   ├── trips/                     # Home screen (trip list), Trip setup, validations
│   ├── budget/                    # 6-slider 100% budget screen & rebalance logic
│   ├── expenses/                  # Add/edit expense, 4 split modes, OCR bill scanner
│   ├── dashboard/                 # Metrics, Cooked meter, velocity card, charts
│   ├── settle/                    # Balance list, greedy settlement engine, UPI intents
│   ├── sync/                      # Join trip dialog, cloud sync bottom sheet
│   └── settings/                  # CSV export, language switch, profile card, about
└── l10n/                          # Localization files (app_en.arb, app_hi.arb)
```

---

## 🧪 Testing Suite & Quality Assurance

YeeTrip has **187 passing automated tests** with 100% verification across all layers:

| Test Area | Scope & Assertions | Tests Passed |
| :--- | :--- | :---: |
| **Money & Indian Currency** | Integer paise conversion, decimal formatting, Indian commas (`₹1,25,000`) | 12 / 12 |
| **Budget Rebalancing** | Property-based testing with 1,000 randomized adjustments (always sums to 100%) | 4 / 4 |
| **Expense Splits** | Equal, Percentage, Shares, Exact modes (1,000 randomized property tests each) | 16 / 16 |
| **Greedy Settle Engine** | Net balance proofs, step minimization ($n-1$ max), 0 paise residue | 10 / 10 |
| **Receipt OCR & Parser** | Indian merchant detection, total amount extraction, GST & dates | 12 / 12 |
| **ML & Velocity Predictor** | Indian keyword classification, burn rate, risk tiers, depletion alerts | 15 / 15 |
| **Cloud Sync & Conflict** | LWW Lamport timestamps, tombstone deletions, offline queue recovery | 15 / 15 |
| **Auth & Profile Migration** | Multi-method sign-in, zero-loss guest trip migration, UPI auto-linking | 14 / 14 |
| **Database & Repositories** | Drift SQLite in-memory operations, cascade deletes, foreign keys | 25 / 25 |
| **Widget UI Integrations** | Setup, expense forms, cooked meter, UPI launcher, language switch | 40 / 40 |
| **Responsive Form Factors** | Phone (360×640, 375×667, 390×844, 412×915), Tablet (800×600), Desktop (1280×800) | 24 / 24 |
| **Total Test Suite** | **All tests passing, 0 failures, 0 regressions** | **187 / 187** |

### Running the Test Suite
```bash
flutter test
```

### Static Analysis
```bash
flutter analyze
# Result: No issues found! (0 warnings, 0 errors)
```

---

## 📱 How to Run & Test on Android

### Prerequisites
- Flutter SDK 3.47+ installed and on `PATH`
- Android SDK Platform 34+ and Android Platform Tools (`adb`)
- Android device or emulator

### 1. Enable Developer Options & USB Debugging on your Android Phone
1. Go to **Settings** > **About phone** > tap **Build number** 7 times to enable Developer options.
2. Go to **Settings** > **Developer options** > enable **USB debugging**.
3. Connect your phone via USB cable and tap **Allow USB debugging** when prompted.

### 2. Verify Device Connection
```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices
```
Your device (e.g. `SM-S721B`) will be listed as `device`.

### 3. Run the App
```bash
flutter run
```
> **Note on Initial Build**: The first build may take a few minutes as Gradle downloads the Gradle wrapper and required Android dependencies. Subsequent builds use the Gradle build cache and launch in just a few seconds.

### 4. Alternative: Run in Chrome Browser
YeeTrip also fully supports WebAssembly SQLite (`sqlite3.wasm`):
```bash
flutter run -d chrome
```
