// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalBudgetPaiseMeta = const VerificationMeta(
    'totalBudgetPaise',
  );
  @override
  late final GeneratedColumn<int> totalBudgetPaise = GeneratedColumn<int>(
    'total_budget_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<int> days = GeneratedColumn<int>(
    'days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    totalBudgetPaise,
    days,
    currency,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('total_budget_paise')) {
      context.handle(
        _totalBudgetPaiseMeta,
        totalBudgetPaise.isAcceptableOrUnknown(
          data['total_budget_paise']!,
          _totalBudgetPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalBudgetPaiseMeta);
    }
    if (data.containsKey('days')) {
      context.handle(
        _daysMeta,
        days.isAcceptableOrUnknown(data['days']!, _daysMeta),
      );
    } else if (isInserting) {
      context.missing(_daysMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      totalBudgetPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_budget_paise'],
      )!,
      days: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class Trip extends DataClass implements Insertable<Trip> {
  final String id;
  final String name;
  final int totalBudgetPaise;
  final int days;
  final String currency;
  final DateTime createdAt;
  const Trip({
    required this.id,
    required this.name,
    required this.totalBudgetPaise,
    required this.days,
    required this.currency,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['total_budget_paise'] = Variable<int>(totalBudgetPaise);
    map['days'] = Variable<int>(days);
    map['currency'] = Variable<String>(currency);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      name: Value(name),
      totalBudgetPaise: Value(totalBudgetPaise),
      days: Value(days),
      currency: Value(currency),
      createdAt: Value(createdAt),
    );
  }

  factory Trip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trip(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      totalBudgetPaise: serializer.fromJson<int>(json['totalBudgetPaise']),
      days: serializer.fromJson<int>(json['days']),
      currency: serializer.fromJson<String>(json['currency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'totalBudgetPaise': serializer.toJson<int>(totalBudgetPaise),
      'days': serializer.toJson<int>(days),
      'currency': serializer.toJson<String>(currency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Trip copyWith({
    String? id,
    String? name,
    int? totalBudgetPaise,
    int? days,
    String? currency,
    DateTime? createdAt,
  }) => Trip(
    id: id ?? this.id,
    name: name ?? this.name,
    totalBudgetPaise: totalBudgetPaise ?? this.totalBudgetPaise,
    days: days ?? this.days,
    currency: currency ?? this.currency,
    createdAt: createdAt ?? this.createdAt,
  );
  Trip copyWithCompanion(TripsCompanion data) {
    return Trip(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      totalBudgetPaise: data.totalBudgetPaise.present
          ? data.totalBudgetPaise.value
          : this.totalBudgetPaise,
      days: data.days.present ? data.days.value : this.days,
      currency: data.currency.present ? data.currency.value : this.currency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trip(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('totalBudgetPaise: $totalBudgetPaise, ')
          ..write('days: $days, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, totalBudgetPaise, days, currency, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.name == this.name &&
          other.totalBudgetPaise == this.totalBudgetPaise &&
          other.days == this.days &&
          other.currency == this.currency &&
          other.createdAt == this.createdAt);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> totalBudgetPaise;
  final Value<int> days;
  final Value<String> currency;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.totalBudgetPaise = const Value.absent(),
    this.days = const Value.absent(),
    this.currency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String name,
    required int totalBudgetPaise,
    required int days,
    this.currency = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       totalBudgetPaise = Value(totalBudgetPaise),
       days = Value(days),
       createdAt = Value(createdAt);
  static Insertable<Trip> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? totalBudgetPaise,
    Expression<int>? days,
    Expression<String>? currency,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (totalBudgetPaise != null) 'total_budget_paise': totalBudgetPaise,
      if (days != null) 'days': days,
      if (currency != null) 'currency': currency,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? totalBudgetPaise,
    Value<int>? days,
    Value<String>? currency,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      totalBudgetPaise: totalBudgetPaise ?? this.totalBudgetPaise,
      days: days ?? this.days,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (totalBudgetPaise.present) {
      map['total_budget_paise'] = Variable<int>(totalBudgetPaise.value);
    }
    if (days.present) {
      map['days'] = Variable<int>(days.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('totalBudgetPaise: $totalBudgetPaise, ')
          ..write('days: $days, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TravelersTable extends Travelers
    with TableInfo<$TravelersTable, Traveler> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TravelersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _upiVpaMeta = const VerificationMeta('upiVpa');
  @override
  late final GeneratedColumn<String> upiVpa = GeneratedColumn<String>(
    'upi_vpa',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, tripId, name, upiVpa];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'travelers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Traveler> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('upi_vpa')) {
      context.handle(
        _upiVpaMeta,
        upiVpa.isAcceptableOrUnknown(data['upi_vpa']!, _upiVpaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Traveler map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Traveler(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      upiVpa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upi_vpa'],
      ),
    );
  }

  @override
  $TravelersTable createAlias(String alias) {
    return $TravelersTable(attachedDatabase, alias);
  }
}

class Traveler extends DataClass implements Insertable<Traveler> {
  final String id;
  final String tripId;
  final String name;
  final String? upiVpa;
  const Traveler({
    required this.id,
    required this.tripId,
    required this.name,
    this.upiVpa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || upiVpa != null) {
      map['upi_vpa'] = Variable<String>(upiVpa);
    }
    return map;
  }

  TravelersCompanion toCompanion(bool nullToAbsent) {
    return TravelersCompanion(
      id: Value(id),
      tripId: Value(tripId),
      name: Value(name),
      upiVpa: upiVpa == null && nullToAbsent
          ? const Value.absent()
          : Value(upiVpa),
    );
  }

  factory Traveler.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Traveler(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      name: serializer.fromJson<String>(json['name']),
      upiVpa: serializer.fromJson<String?>(json['upiVpa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'name': serializer.toJson<String>(name),
      'upiVpa': serializer.toJson<String?>(upiVpa),
    };
  }

  Traveler copyWith({
    String? id,
    String? tripId,
    String? name,
    Value<String?> upiVpa = const Value.absent(),
  }) => Traveler(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    upiVpa: upiVpa.present ? upiVpa.value : this.upiVpa,
  );
  Traveler copyWithCompanion(TravelersCompanion data) {
    return Traveler(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      name: data.name.present ? data.name.value : this.name,
      upiVpa: data.upiVpa.present ? data.upiVpa.value : this.upiVpa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Traveler(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('upiVpa: $upiVpa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tripId, name, upiVpa);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Traveler &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.name == this.name &&
          other.upiVpa == this.upiVpa);
}

class TravelersCompanion extends UpdateCompanion<Traveler> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> name;
  final Value<String?> upiVpa;
  final Value<int> rowid;
  const TravelersCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.name = const Value.absent(),
    this.upiVpa = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TravelersCompanion.insert({
    required String id,
    required String tripId,
    required String name,
    this.upiVpa = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       name = Value(name);
  static Insertable<Traveler> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? name,
    Expression<String>? upiVpa,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (name != null) 'name': name,
      if (upiVpa != null) 'upi_vpa': upiVpa,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TravelersCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? name,
    Value<String?>? upiVpa,
    Value<int>? rowid,
  }) {
    return TravelersCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      upiVpa: upiVpa ?? this.upiVpa,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (upiVpa.present) {
      map['upi_vpa'] = Variable<String>(upiVpa.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TravelersCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('upiVpa: $upiVpa, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryAllocationsTable extends CategoryAllocations
    with TableInfo<$CategoryAllocationsTable, CategoryAllocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _percentMeta = const VerificationMeta(
    'percent',
  );
  @override
  late final GeneratedColumn<int> percent = GeneratedColumn<int>(
    'percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [tripId, category, percent];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryAllocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('percent')) {
      context.handle(
        _percentMeta,
        percent.isAcceptableOrUnknown(data['percent']!, _percentMeta),
      );
    } else if (isInserting) {
      context.missing(_percentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tripId, category};
  @override
  CategoryAllocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryAllocation(
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      percent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}percent'],
      )!,
    );
  }

  @override
  $CategoryAllocationsTable createAlias(String alias) {
    return $CategoryAllocationsTable(attachedDatabase, alias);
  }
}

class CategoryAllocation extends DataClass
    implements Insertable<CategoryAllocation> {
  final String tripId;
  final String category;
  final int percent;
  const CategoryAllocation({
    required this.tripId,
    required this.category,
    required this.percent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trip_id'] = Variable<String>(tripId);
    map['category'] = Variable<String>(category);
    map['percent'] = Variable<int>(percent);
    return map;
  }

  CategoryAllocationsCompanion toCompanion(bool nullToAbsent) {
    return CategoryAllocationsCompanion(
      tripId: Value(tripId),
      category: Value(category),
      percent: Value(percent),
    );
  }

  factory CategoryAllocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryAllocation(
      tripId: serializer.fromJson<String>(json['tripId']),
      category: serializer.fromJson<String>(json['category']),
      percent: serializer.fromJson<int>(json['percent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tripId': serializer.toJson<String>(tripId),
      'category': serializer.toJson<String>(category),
      'percent': serializer.toJson<int>(percent),
    };
  }

  CategoryAllocation copyWith({
    String? tripId,
    String? category,
    int? percent,
  }) => CategoryAllocation(
    tripId: tripId ?? this.tripId,
    category: category ?? this.category,
    percent: percent ?? this.percent,
  );
  CategoryAllocation copyWithCompanion(CategoryAllocationsCompanion data) {
    return CategoryAllocation(
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      category: data.category.present ? data.category.value : this.category,
      percent: data.percent.present ? data.percent.value : this.percent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryAllocation(')
          ..write('tripId: $tripId, ')
          ..write('category: $category, ')
          ..write('percent: $percent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tripId, category, percent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryAllocation &&
          other.tripId == this.tripId &&
          other.category == this.category &&
          other.percent == this.percent);
}

class CategoryAllocationsCompanion extends UpdateCompanion<CategoryAllocation> {
  final Value<String> tripId;
  final Value<String> category;
  final Value<int> percent;
  final Value<int> rowid;
  const CategoryAllocationsCompanion({
    this.tripId = const Value.absent(),
    this.category = const Value.absent(),
    this.percent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryAllocationsCompanion.insert({
    required String tripId,
    required String category,
    required int percent,
    this.rowid = const Value.absent(),
  }) : tripId = Value(tripId),
       category = Value(category),
       percent = Value(percent);
  static Insertable<CategoryAllocation> custom({
    Expression<String>? tripId,
    Expression<String>? category,
    Expression<int>? percent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tripId != null) 'trip_id': tripId,
      if (category != null) 'category': category,
      if (percent != null) 'percent': percent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryAllocationsCompanion copyWith({
    Value<String>? tripId,
    Value<String>? category,
    Value<int>? percent,
    Value<int>? rowid,
  }) {
    return CategoryAllocationsCompanion(
      tripId: tripId ?? this.tripId,
      category: category ?? this.category,
      percent: percent ?? this.percent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (percent.present) {
      map['percent'] = Variable<int>(percent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryAllocationsCompanion(')
          ..write('tripId: $tripId, ')
          ..write('category: $category, ')
          ..write('percent: $percent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidByMeta = const VerificationMeta('paidBy');
  @override
  late final GeneratedColumn<String> paidBy = GeneratedColumn<String>(
    'paid_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES travelers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _upiTxnIdMeta = const VerificationMeta(
    'upiTxnId',
  );
  @override
  late final GeneratedColumn<String> upiTxnId = GeneratedColumn<String>(
    'upi_txn_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confirmedMeta = const VerificationMeta(
    'confirmed',
  );
  @override
  late final GeneratedColumn<bool> confirmed = GeneratedColumn<bool>(
    'confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    description,
    amountPaise,
    category,
    paidBy,
    source,
    upiTxnId,
    confirmed,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('paid_by')) {
      context.handle(
        _paidByMeta,
        paidBy.isAcceptableOrUnknown(data['paid_by']!, _paidByMeta),
      );
    } else if (isInserting) {
      context.missing(_paidByMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('upi_txn_id')) {
      context.handle(
        _upiTxnIdMeta,
        upiTxnId.isAcceptableOrUnknown(data['upi_txn_id']!, _upiTxnIdMeta),
      );
    }
    if (data.containsKey('confirmed')) {
      context.handle(
        _confirmedMeta,
        confirmed.isAcceptableOrUnknown(data['confirmed']!, _confirmedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      paidBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_by'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      upiTxnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upi_txn_id'],
      ),
      confirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confirmed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String tripId;
  final String description;
  final int amountPaise;
  final String category;
  final String paidBy;
  final String source;
  final String? upiTxnId;
  final bool confirmed;
  final DateTime createdAt;
  const Expense({
    required this.id,
    required this.tripId,
    required this.description,
    required this.amountPaise,
    required this.category,
    required this.paidBy,
    required this.source,
    this.upiTxnId,
    required this.confirmed,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['description'] = Variable<String>(description);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['category'] = Variable<String>(category);
    map['paid_by'] = Variable<String>(paidBy);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || upiTxnId != null) {
      map['upi_txn_id'] = Variable<String>(upiTxnId);
    }
    map['confirmed'] = Variable<bool>(confirmed);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      tripId: Value(tripId),
      description: Value(description),
      amountPaise: Value(amountPaise),
      category: Value(category),
      paidBy: Value(paidBy),
      source: Value(source),
      upiTxnId: upiTxnId == null && nullToAbsent
          ? const Value.absent()
          : Value(upiTxnId),
      confirmed: Value(confirmed),
      createdAt: Value(createdAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      description: serializer.fromJson<String>(json['description']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      category: serializer.fromJson<String>(json['category']),
      paidBy: serializer.fromJson<String>(json['paidBy']),
      source: serializer.fromJson<String>(json['source']),
      upiTxnId: serializer.fromJson<String?>(json['upiTxnId']),
      confirmed: serializer.fromJson<bool>(json['confirmed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'description': serializer.toJson<String>(description),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'category': serializer.toJson<String>(category),
      'paidBy': serializer.toJson<String>(paidBy),
      'source': serializer.toJson<String>(source),
      'upiTxnId': serializer.toJson<String?>(upiTxnId),
      'confirmed': serializer.toJson<bool>(confirmed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Expense copyWith({
    String? id,
    String? tripId,
    String? description,
    int? amountPaise,
    String? category,
    String? paidBy,
    String? source,
    Value<String?> upiTxnId = const Value.absent(),
    bool? confirmed,
    DateTime? createdAt,
  }) => Expense(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    description: description ?? this.description,
    amountPaise: amountPaise ?? this.amountPaise,
    category: category ?? this.category,
    paidBy: paidBy ?? this.paidBy,
    source: source ?? this.source,
    upiTxnId: upiTxnId.present ? upiTxnId.value : this.upiTxnId,
    confirmed: confirmed ?? this.confirmed,
    createdAt: createdAt ?? this.createdAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      description: data.description.present
          ? data.description.value
          : this.description,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      category: data.category.present ? data.category.value : this.category,
      paidBy: data.paidBy.present ? data.paidBy.value : this.paidBy,
      source: data.source.present ? data.source.value : this.source,
      upiTxnId: data.upiTxnId.present ? data.upiTxnId.value : this.upiTxnId,
      confirmed: data.confirmed.present ? data.confirmed.value : this.confirmed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('description: $description, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('category: $category, ')
          ..write('paidBy: $paidBy, ')
          ..write('source: $source, ')
          ..write('upiTxnId: $upiTxnId, ')
          ..write('confirmed: $confirmed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    description,
    amountPaise,
    category,
    paidBy,
    source,
    upiTxnId,
    confirmed,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.description == this.description &&
          other.amountPaise == this.amountPaise &&
          other.category == this.category &&
          other.paidBy == this.paidBy &&
          other.source == this.source &&
          other.upiTxnId == this.upiTxnId &&
          other.confirmed == this.confirmed &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> description;
  final Value<int> amountPaise;
  final Value<String> category;
  final Value<String> paidBy;
  final Value<String> source;
  final Value<String?> upiTxnId;
  final Value<bool> confirmed;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.description = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.category = const Value.absent(),
    this.paidBy = const Value.absent(),
    this.source = const Value.absent(),
    this.upiTxnId = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String tripId,
    required String description,
    required int amountPaise,
    required String category,
    required String paidBy,
    this.source = const Value.absent(),
    this.upiTxnId = const Value.absent(),
    this.confirmed = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       description = Value(description),
       amountPaise = Value(amountPaise),
       category = Value(category),
       paidBy = Value(paidBy),
       createdAt = Value(createdAt);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? description,
    Expression<int>? amountPaise,
    Expression<String>? category,
    Expression<String>? paidBy,
    Expression<String>? source,
    Expression<String>? upiTxnId,
    Expression<bool>? confirmed,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (description != null) 'description': description,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (category != null) 'category': category,
      if (paidBy != null) 'paid_by': paidBy,
      if (source != null) 'source': source,
      if (upiTxnId != null) 'upi_txn_id': upiTxnId,
      if (confirmed != null) 'confirmed': confirmed,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? description,
    Value<int>? amountPaise,
    Value<String>? category,
    Value<String>? paidBy,
    Value<String>? source,
    Value<String?>? upiTxnId,
    Value<bool>? confirmed,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      description: description ?? this.description,
      amountPaise: amountPaise ?? this.amountPaise,
      category: category ?? this.category,
      paidBy: paidBy ?? this.paidBy,
      source: source ?? this.source,
      upiTxnId: upiTxnId ?? this.upiTxnId,
      confirmed: confirmed ?? this.confirmed,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (paidBy.present) {
      map['paid_by'] = Variable<String>(paidBy.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (upiTxnId.present) {
      map['upi_txn_id'] = Variable<String>(upiTxnId.value);
    }
    if (confirmed.present) {
      map['confirmed'] = Variable<bool>(confirmed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('description: $description, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('category: $category, ')
          ..write('paidBy: $paidBy, ')
          ..write('source: $source, ')
          ..write('upiTxnId: $upiTxnId, ')
          ..write('confirmed: $confirmed, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseSplitsTable extends ExpenseSplits
    with TableInfo<$ExpenseSplitsTable, ExpenseSplit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseSplitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES expenses (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _travelerIdMeta = const VerificationMeta(
    'travelerId',
  );
  @override
  late final GeneratedColumn<String> travelerId = GeneratedColumn<String>(
    'traveler_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES travelers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sharePaiseMeta = const VerificationMeta(
    'sharePaise',
  );
  @override
  late final GeneratedColumn<int> sharePaise = GeneratedColumn<int>(
    'share_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [expenseId, travelerId, sharePaise];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_splits';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseSplit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('traveler_id')) {
      context.handle(
        _travelerIdMeta,
        travelerId.isAcceptableOrUnknown(data['traveler_id']!, _travelerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_travelerIdMeta);
    }
    if (data.containsKey('share_paise')) {
      context.handle(
        _sharePaiseMeta,
        sharePaise.isAcceptableOrUnknown(data['share_paise']!, _sharePaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_sharePaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {expenseId, travelerId};
  @override
  ExpenseSplit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseSplit(
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      )!,
      travelerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}traveler_id'],
      )!,
      sharePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}share_paise'],
      )!,
    );
  }

  @override
  $ExpenseSplitsTable createAlias(String alias) {
    return $ExpenseSplitsTable(attachedDatabase, alias);
  }
}

class ExpenseSplit extends DataClass implements Insertable<ExpenseSplit> {
  final String expenseId;
  final String travelerId;
  final int sharePaise;
  const ExpenseSplit({
    required this.expenseId,
    required this.travelerId,
    required this.sharePaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['expense_id'] = Variable<String>(expenseId);
    map['traveler_id'] = Variable<String>(travelerId);
    map['share_paise'] = Variable<int>(sharePaise);
    return map;
  }

  ExpenseSplitsCompanion toCompanion(bool nullToAbsent) {
    return ExpenseSplitsCompanion(
      expenseId: Value(expenseId),
      travelerId: Value(travelerId),
      sharePaise: Value(sharePaise),
    );
  }

  factory ExpenseSplit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseSplit(
      expenseId: serializer.fromJson<String>(json['expenseId']),
      travelerId: serializer.fromJson<String>(json['travelerId']),
      sharePaise: serializer.fromJson<int>(json['sharePaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'expenseId': serializer.toJson<String>(expenseId),
      'travelerId': serializer.toJson<String>(travelerId),
      'sharePaise': serializer.toJson<int>(sharePaise),
    };
  }

  ExpenseSplit copyWith({
    String? expenseId,
    String? travelerId,
    int? sharePaise,
  }) => ExpenseSplit(
    expenseId: expenseId ?? this.expenseId,
    travelerId: travelerId ?? this.travelerId,
    sharePaise: sharePaise ?? this.sharePaise,
  );
  ExpenseSplit copyWithCompanion(ExpenseSplitsCompanion data) {
    return ExpenseSplit(
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      travelerId: data.travelerId.present
          ? data.travelerId.value
          : this.travelerId,
      sharePaise: data.sharePaise.present
          ? data.sharePaise.value
          : this.sharePaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseSplit(')
          ..write('expenseId: $expenseId, ')
          ..write('travelerId: $travelerId, ')
          ..write('sharePaise: $sharePaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(expenseId, travelerId, sharePaise);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseSplit &&
          other.expenseId == this.expenseId &&
          other.travelerId == this.travelerId &&
          other.sharePaise == this.sharePaise);
}

class ExpenseSplitsCompanion extends UpdateCompanion<ExpenseSplit> {
  final Value<String> expenseId;
  final Value<String> travelerId;
  final Value<int> sharePaise;
  final Value<int> rowid;
  const ExpenseSplitsCompanion({
    this.expenseId = const Value.absent(),
    this.travelerId = const Value.absent(),
    this.sharePaise = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseSplitsCompanion.insert({
    required String expenseId,
    required String travelerId,
    required int sharePaise,
    this.rowid = const Value.absent(),
  }) : expenseId = Value(expenseId),
       travelerId = Value(travelerId),
       sharePaise = Value(sharePaise);
  static Insertable<ExpenseSplit> custom({
    Expression<String>? expenseId,
    Expression<String>? travelerId,
    Expression<int>? sharePaise,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (expenseId != null) 'expense_id': expenseId,
      if (travelerId != null) 'traveler_id': travelerId,
      if (sharePaise != null) 'share_paise': sharePaise,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseSplitsCompanion copyWith({
    Value<String>? expenseId,
    Value<String>? travelerId,
    Value<int>? sharePaise,
    Value<int>? rowid,
  }) {
    return ExpenseSplitsCompanion(
      expenseId: expenseId ?? this.expenseId,
      travelerId: travelerId ?? this.travelerId,
      sharePaise: sharePaise ?? this.sharePaise,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (travelerId.present) {
      map['traveler_id'] = Variable<String>(travelerId.value);
    }
    if (sharePaise.present) {
      map['share_paise'] = Variable<int>(sharePaise.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseSplitsCompanion(')
          ..write('expenseId: $expenseId, ')
          ..write('travelerId: $travelerId, ')
          ..write('sharePaise: $sharePaise, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $TravelersTable travelers = $TravelersTable(this);
  late final $CategoryAllocationsTable categoryAllocations =
      $CategoryAllocationsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $ExpenseSplitsTable expenseSplits = $ExpenseSplitsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trips,
    travelers,
    categoryAllocations,
    expenses,
    expenseSplits,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('travelers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('category_allocations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expenses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'travelers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expenses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'expenses',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expense_splits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'travelers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expense_splits', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  required String id,
  required String name,
  required int totalBudgetPaise,
  required int days,
  Value<String> currency,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> totalBudgetPaise,
  Value<int> days,
  Value<String> currency,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TripsTableReferences
    extends BaseReferences<_$AppDatabase, $TripsTable, Trip> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TravelersTable, List<Traveler>>
  _travelersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.travelers,
    aliasName: 'trips__id__travelers__trip_id',
  );

  $$TravelersTableProcessedTableManager get travelersRefs {
    final manager = $$TravelersTableTableManager(
      $_db,
      $_db.travelers,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_travelersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CategoryAllocationsTable,
    List<CategoryAllocation>
  >
  _categoryAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.categoryAllocations,
        aliasName: 'trips__id__category_allocations__trip_id',
      );

  $$CategoryAllocationsTableProcessedTableManager get categoryAllocationsRefs {
    final manager = $$CategoryAllocationsTableTableManager(
      $_db,
      $_db.categoryAllocations,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _categoryAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'trips__id__expenses__trip_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBudgetPaise => $composableBuilder(
    column: $table.totalBudgetPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> travelersRefs(
    Expression<bool> Function($$TravelersTableFilterComposer f) f,
  ) {
    final $$TravelersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableFilterComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> categoryAllocationsRefs(
    Expression<bool> Function($$CategoryAllocationsTableFilterComposer f) f,
  ) {
    final $$CategoryAllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categoryAllocations,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryAllocationsTableFilterComposer(
            $db: $db,
            $table: $db.categoryAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBudgetPaise => $composableBuilder(
    column: $table.totalBudgetPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get totalBudgetPaise => $composableBuilder(
    column: $table.totalBudgetPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> travelersRefs<T extends Object>(
    Expression<T> Function($$TravelersTableAnnotationComposer a) f,
  ) {
    final $$TravelersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableAnnotationComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> categoryAllocationsRefs<T extends Object>(
    Expression<T> Function($$CategoryAllocationsTableAnnotationComposer a) f,
  ) {
    final $$CategoryAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.categoryAllocations,
          getReferencedColumn: (t) => t.tripId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CategoryAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.categoryAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          Trip,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (Trip, $$TripsTableReferences),
          Trip,
          PrefetchHooks Function({
            bool travelersRefs,
            bool categoryAllocationsRefs,
            bool expensesRefs,
          })
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> totalBudgetPaise = const Value.absent(),
                Value<int> days = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                name: name,
                totalBudgetPaise: totalBudgetPaise,
                days: days,
                currency: currency,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int totalBudgetPaise,
                required int days,
                Value<String> currency = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                name: name,
                totalBudgetPaise: totalBudgetPaise,
                days: days,
                currency: currency,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TripsTable, Trip>(table),
                  $$TripsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                travelersRefs = false,
                categoryAllocationsRefs = false,
                expensesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (travelersRefs) db.travelers,
                    if (categoryAllocationsRefs) db.categoryAllocations,
                    if (expensesRefs) db.expenses,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (travelersRefs)
                        await $_getPrefetchedDataByColumns<
                          Trip,
                          $TripsTable,
                          Traveler,
                          $TravelersTable
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._travelersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).travelersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'trip_id',
                          typedResults: items,
                        ),
                      if (categoryAllocationsRefs)
                        await $_getPrefetchedDataByColumns<
                          Trip,
                          $TripsTable,
                          CategoryAllocation,
                          $CategoryAllocationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._categoryAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).categoryAllocationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'trip_id',
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedDataByColumns<
                          Trip,
                          $TripsTable,
                          Expense,
                          $ExpensesTable
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'trip_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      Trip,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (Trip, $$TripsTableReferences),
      Trip,
      PrefetchHooks Function({
        bool travelersRefs,
        bool categoryAllocationsRefs,
        bool expensesRefs,
      })
    >;
typedef $$TravelersTableCreateCompanionBuilder = TravelersCompanion Function({
  required String id,
  required String tripId,
  required String name,
  Value<String?> upiVpa,
  Value<int> rowid,
});
typedef $$TravelersTableUpdateCompanionBuilder = TravelersCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String> name,
  Value<String?> upiVpa,
  Value<int> rowid,
});

final class $$TravelersTableReferences
    extends BaseReferences<_$AppDatabase, $TravelersTable, Traveler> {
  $$TravelersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('travelers__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'travelers__id__expenses__paid_by',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.paidBy.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpenseSplitsTable, List<ExpenseSplit>>
  _expenseSplitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenseSplits,
    aliasName: 'travelers__id__expense_splits__traveler_id',
  );

  $$ExpenseSplitsTableProcessedTableManager get expenseSplitsRefs {
    final manager = $$ExpenseSplitsTableTableManager(
      $_db,
      $_db.expenseSplits,
    ).filter((f) => f.travelerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expenseSplitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TravelersTableFilterComposer
    extends Composer<_$AppDatabase, $TravelersTable> {
  $$TravelersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upiVpa => $composableBuilder(
    column: $table.upiVpa,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.paidBy,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expenseSplitsRefs(
    Expression<bool> Function($$ExpenseSplitsTableFilterComposer f) f,
  ) {
    final $$ExpenseSplitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseSplits,
      getReferencedColumn: (t) => t.travelerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseSplitsTableFilterComposer(
            $db: $db,
            $table: $db.expenseSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TravelersTableOrderingComposer
    extends Composer<_$AppDatabase, $TravelersTable> {
  $$TravelersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upiVpa => $composableBuilder(
    column: $table.upiVpa,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TravelersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TravelersTable> {
  $$TravelersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get upiVpa =>
      $composableBuilder(column: $table.upiVpa, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.paidBy,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expenseSplitsRefs<T extends Object>(
    Expression<T> Function($$ExpenseSplitsTableAnnotationComposer a) f,
  ) {
    final $$ExpenseSplitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseSplits,
      getReferencedColumn: (t) => t.travelerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseSplitsTableAnnotationComposer(
            $db: $db,
            $table: $db.expenseSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TravelersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TravelersTable,
          Traveler,
          $$TravelersTableFilterComposer,
          $$TravelersTableOrderingComposer,
          $$TravelersTableAnnotationComposer,
          $$TravelersTableCreateCompanionBuilder,
          $$TravelersTableUpdateCompanionBuilder,
          (Traveler, $$TravelersTableReferences),
          Traveler,
          PrefetchHooks Function({
            bool tripId,
            bool expensesRefs,
            bool expenseSplitsRefs,
          })
        > {
  $$TravelersTableTableManager(_$AppDatabase db, $TravelersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TravelersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TravelersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TravelersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> upiVpa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TravelersCompanion(
                id: id,
                tripId: tripId,
                name: name,
                upiVpa: upiVpa,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String name,
                Value<String?> upiVpa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TravelersCompanion.insert(
                id: id,
                tripId: tripId,
                name: name,
                upiVpa: upiVpa,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TravelersTable, Traveler>(table),
                  $$TravelersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tripId = false,
                expensesRefs = false,
                expenseSplitsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (expensesRefs) db.expenses,
                    if (expenseSplitsRefs) db.expenseSplits,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tripId,
                            referencedTable: $$TravelersTableReferences
                                ._tripIdTable(db),
                            referencedColumn: $$TravelersTableReferences
                                ._tripIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (expensesRefs)
                        await $_getPrefetchedDataByColumns<
                          Traveler,
                          $TravelersTable,
                          Expense,
                          $ExpensesTable
                        >(
                          currentTable: table,
                          referencedTable: $$TravelersTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TravelersTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'paid_by',
                          typedResults: items,
                        ),
                      if (expenseSplitsRefs)
                        await $_getPrefetchedDataByColumns<
                          Traveler,
                          $TravelersTable,
                          ExpenseSplit,
                          $ExpenseSplitsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TravelersTableReferences
                              ._expenseSplitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TravelersTableReferences(
                                db,
                                table,
                                p0,
                              ).expenseSplitsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'traveler_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TravelersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TravelersTable,
      Traveler,
      $$TravelersTableFilterComposer,
      $$TravelersTableOrderingComposer,
      $$TravelersTableAnnotationComposer,
      $$TravelersTableCreateCompanionBuilder,
      $$TravelersTableUpdateCompanionBuilder,
      (Traveler, $$TravelersTableReferences),
      Traveler,
      PrefetchHooks Function({
        bool tripId,
        bool expensesRefs,
        bool expenseSplitsRefs,
      })
    >;
typedef $$CategoryAllocationsTableCreateCompanionBuilder =
    CategoryAllocationsCompanion Function({
      required String tripId,
      required String category,
      required int percent,
      Value<int> rowid,
    });
typedef $$CategoryAllocationsTableUpdateCompanionBuilder =
    CategoryAllocationsCompanion Function({
      Value<String> tripId,
      Value<String> category,
      Value<int> percent,
      Value<int> rowid,
    });

final class $$CategoryAllocationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CategoryAllocationsTable,
          CategoryAllocation
        > {
  $$CategoryAllocationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('category_allocations__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CategoryAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryAllocationsTable> {
  $$CategoryAllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryAllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryAllocationsTable> {
  $$CategoryAllocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryAllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryAllocationsTable> {
  $$CategoryAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get percent =>
      $composableBuilder(column: $table.percent, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryAllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryAllocationsTable,
          CategoryAllocation,
          $$CategoryAllocationsTableFilterComposer,
          $$CategoryAllocationsTableOrderingComposer,
          $$CategoryAllocationsTableAnnotationComposer,
          $$CategoryAllocationsTableCreateCompanionBuilder,
          $$CategoryAllocationsTableUpdateCompanionBuilder,
          (CategoryAllocation, $$CategoryAllocationsTableReferences),
          CategoryAllocation,
          PrefetchHooks Function({bool tripId})
        > {
  $$CategoryAllocationsTableTableManager(
    _$AppDatabase db,
    $CategoryAllocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryAllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryAllocationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CategoryAllocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> tripId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> percent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryAllocationsCompanion(
                tripId: tripId,
                category: category,
                percent: percent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tripId,
                required String category,
                required int percent,
                Value<int> rowid = const Value.absent(),
              }) => CategoryAllocationsCompanion.insert(
                tripId: tripId,
                category: category,
                percent: percent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoryAllocationsTable, CategoryAllocation>(
                    table,
                  ),
                  $$CategoryAllocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tripId,
                        referencedTable: $$CategoryAllocationsTableReferences
                            ._tripIdTable(db),
                        referencedColumn: $$CategoryAllocationsTableReferences
                            ._tripIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CategoryAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryAllocationsTable,
      CategoryAllocation,
      $$CategoryAllocationsTableFilterComposer,
      $$CategoryAllocationsTableOrderingComposer,
      $$CategoryAllocationsTableAnnotationComposer,
      $$CategoryAllocationsTableCreateCompanionBuilder,
      $$CategoryAllocationsTableUpdateCompanionBuilder,
      (CategoryAllocation, $$CategoryAllocationsTableReferences),
      CategoryAllocation,
      PrefetchHooks Function({bool tripId})
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  required String tripId,
  required String description,
  required int amountPaise,
  required String category,
  required String paidBy,
  Value<String> source,
  Value<String?> upiTxnId,
  Value<bool> confirmed,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String> description,
  Value<int> amountPaise,
  Value<String> category,
  Value<String> paidBy,
  Value<String> source,
  Value<String?> upiTxnId,
  Value<bool> confirmed,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('expenses__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TravelersTable _paidByTable(_$AppDatabase db) =>
      db.travelers.createAlias('expenses__paid_by__travelers__id');

  $$TravelersTableProcessedTableManager get paidBy {
    final $_column = $_itemColumn<String>('paid_by')!;

    final manager = $$TravelersTableTableManager(
      $_db,
      $_db.travelers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paidByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExpenseSplitsTable, List<ExpenseSplit>>
  _expenseSplitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenseSplits,
    aliasName: 'expenses__id__expense_splits__expense_id',
  );

  $$ExpenseSplitsTableProcessedTableManager get expenseSplitsRefs {
    final manager = $$ExpenseSplitsTableTableManager(
      $_db,
      $_db.expenseSplits,
    ).filter((f) => f.expenseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expenseSplitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upiTxnId => $composableBuilder(
    column: $table.upiTxnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TravelersTableFilterComposer get paidBy {
    final $$TravelersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidBy,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableFilterComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> expenseSplitsRefs(
    Expression<bool> Function($$ExpenseSplitsTableFilterComposer f) f,
  ) {
    final $$ExpenseSplitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseSplits,
      getReferencedColumn: (t) => t.expenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseSplitsTableFilterComposer(
            $db: $db,
            $table: $db.expenseSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upiTxnId => $composableBuilder(
    column: $table.upiTxnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TravelersTableOrderingComposer get paidBy {
    final $$TravelersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidBy,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableOrderingComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get upiTxnId =>
      $composableBuilder(column: $table.upiTxnId, builder: (column) => column);

  GeneratedColumn<bool> get confirmed =>
      $composableBuilder(column: $table.confirmed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TravelersTableAnnotationComposer get paidBy {
    final $$TravelersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidBy,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableAnnotationComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> expenseSplitsRefs<T extends Object>(
    Expression<T> Function($$ExpenseSplitsTableAnnotationComposer a) f,
  ) {
    final $$ExpenseSplitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseSplits,
      getReferencedColumn: (t) => t.expenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseSplitsTableAnnotationComposer(
            $db: $db,
            $table: $db.expenseSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({
            bool tripId,
            bool paidBy,
            bool expenseSplitsRefs,
          })
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> paidBy = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> upiTxnId = const Value.absent(),
                Value<bool> confirmed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                tripId: tripId,
                description: description,
                amountPaise: amountPaise,
                category: category,
                paidBy: paidBy,
                source: source,
                upiTxnId: upiTxnId,
                confirmed: confirmed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String description,
                required int amountPaise,
                required String category,
                required String paidBy,
                Value<String> source = const Value.absent(),
                Value<String?> upiTxnId = const Value.absent(),
                Value<bool> confirmed = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                tripId: tripId,
                description: description,
                amountPaise: amountPaise,
                category: category,
                paidBy: paidBy,
                source: source,
                upiTxnId: upiTxnId,
                confirmed: confirmed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, Expense>(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tripId = false, paidBy = false, expenseSplitsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (expenseSplitsRefs) db.expenseSplits,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tripId,
                            referencedTable: $$ExpensesTableReferences
                                ._tripIdTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._tripIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (paidBy) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.paidBy,
                            referencedTable: $$ExpensesTableReferences
                                ._paidByTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._paidByTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (expenseSplitsRefs)
                        await $_getPrefetchedDataByColumns<
                          Expense,
                          $ExpensesTable,
                          ExpenseSplit,
                          $ExpenseSplitsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExpensesTableReferences
                              ._expenseSplitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExpensesTableReferences(
                                db,
                                table,
                                p0,
                              ).expenseSplitsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'expense_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({bool tripId, bool paidBy, bool expenseSplitsRefs})
    >;
typedef $$ExpenseSplitsTableCreateCompanionBuilder =
    ExpenseSplitsCompanion Function({
      required String expenseId,
      required String travelerId,
      required int sharePaise,
      Value<int> rowid,
    });
typedef $$ExpenseSplitsTableUpdateCompanionBuilder =
    ExpenseSplitsCompanion Function({
      Value<String> expenseId,
      Value<String> travelerId,
      Value<int> sharePaise,
      Value<int> rowid,
    });

final class $$ExpenseSplitsTableReferences
    extends BaseReferences<_$AppDatabase, $ExpenseSplitsTable, ExpenseSplit> {
  $$ExpenseSplitsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExpensesTable _expenseIdTable(_$AppDatabase db) =>
      db.expenses.createAlias('expense_splits__expense_id__expenses__id');

  $$ExpensesTableProcessedTableManager get expenseId {
    final $_column = $_itemColumn<String>('expense_id')!;

    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TravelersTable _travelerIdTable(_$AppDatabase db) =>
      db.travelers.createAlias('expense_splits__traveler_id__travelers__id');

  $$TravelersTableProcessedTableManager get travelerId {
    final $_column = $_itemColumn<String>('traveler_id')!;

    final manager = $$TravelersTableTableManager(
      $_db,
      $_db.travelers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_travelerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpenseSplitsTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseSplitsTable> {
  $$ExpenseSplitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sharePaise => $composableBuilder(
    column: $table.sharePaise,
    builder: (column) => ColumnFilters(column),
  );

  $$ExpensesTableFilterComposer get expenseId {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TravelersTableFilterComposer get travelerId {
    final $$TravelersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.travelerId,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableFilterComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseSplitsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseSplitsTable> {
  $$ExpenseSplitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sharePaise => $composableBuilder(
    column: $table.sharePaise,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExpensesTableOrderingComposer get expenseId {
    final $$ExpensesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableOrderingComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TravelersTableOrderingComposer get travelerId {
    final $$TravelersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.travelerId,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableOrderingComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseSplitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseSplitsTable> {
  $$ExpenseSplitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sharePaise => $composableBuilder(
    column: $table.sharePaise,
    builder: (column) => column,
  );

  $$ExpensesTableAnnotationComposer get expenseId {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TravelersTableAnnotationComposer get travelerId {
    final $$TravelersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.travelerId,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableAnnotationComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseSplitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseSplitsTable,
          ExpenseSplit,
          $$ExpenseSplitsTableFilterComposer,
          $$ExpenseSplitsTableOrderingComposer,
          $$ExpenseSplitsTableAnnotationComposer,
          $$ExpenseSplitsTableCreateCompanionBuilder,
          $$ExpenseSplitsTableUpdateCompanionBuilder,
          (ExpenseSplit, $$ExpenseSplitsTableReferences),
          ExpenseSplit,
          PrefetchHooks Function({bool expenseId, bool travelerId})
        > {
  $$ExpenseSplitsTableTableManager(_$AppDatabase db, $ExpenseSplitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseSplitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseSplitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseSplitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> expenseId = const Value.absent(),
                Value<String> travelerId = const Value.absent(),
                Value<int> sharePaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseSplitsCompanion(
                expenseId: expenseId,
                travelerId: travelerId,
                sharePaise: sharePaise,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String expenseId,
                required String travelerId,
                required int sharePaise,
                Value<int> rowid = const Value.absent(),
              }) => ExpenseSplitsCompanion.insert(
                expenseId: expenseId,
                travelerId: travelerId,
                sharePaise: sharePaise,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpenseSplitsTable, ExpenseSplit>(table),
                  $$ExpenseSplitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expenseId = false, travelerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (expenseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.expenseId,
                        referencedTable: $$ExpenseSplitsTableReferences
                            ._expenseIdTable(db),
                        referencedColumn: $$ExpenseSplitsTableReferences
                            ._expenseIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (travelerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.travelerId,
                        referencedTable: $$ExpenseSplitsTableReferences
                            ._travelerIdTable(db),
                        referencedColumn: $$ExpenseSplitsTableReferences
                            ._travelerIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpenseSplitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseSplitsTable,
      ExpenseSplit,
      $$ExpenseSplitsTableFilterComposer,
      $$ExpenseSplitsTableOrderingComposer,
      $$ExpenseSplitsTableAnnotationComposer,
      $$ExpenseSplitsTableCreateCompanionBuilder,
      $$ExpenseSplitsTableUpdateCompanionBuilder,
      (ExpenseSplit, $$ExpenseSplitsTableReferences),
      ExpenseSplit,
      PrefetchHooks Function({bool expenseId, bool travelerId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$TravelersTableTableManager get travelers =>
      $$TravelersTableTableManager(_db, _db.travelers);
  $$CategoryAllocationsTableTableManager get categoryAllocations =>
      $$CategoryAllocationsTableTableManager(_db, _db.categoryAllocations);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$ExpenseSplitsTableTableManager get expenseSplits =>
      $$ExpenseSplitsTableTableManager(_db, _db.expenseSplits);
}
