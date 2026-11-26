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
  static const VerificationMeta _destinationMeta = const VerificationMeta(
    'destination',
  );
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverPhotoPathMeta = const VerificationMeta(
    'coverPhotoPath',
  );
  @override
  late final GeneratedColumn<String> coverPhotoPath = GeneratedColumn<String>(
    'cover_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    totalBudgetPaise,
    days,
    currency,
    createdAt,
    destination,
    coverPhotoPath,
    status,
    startDate,
    endDate,
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
    if (data.containsKey('destination')) {
      context.handle(
        _destinationMeta,
        destination.isAcceptableOrUnknown(
          data['destination']!,
          _destinationMeta,
        ),
      );
    }
    if (data.containsKey('cover_photo_path')) {
      context.handle(
        _coverPhotoPathMeta,
        coverPhotoPath.isAcceptableOrUnknown(
          data['cover_photo_path']!,
          _coverPhotoPathMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
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
      destination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination'],
      ),
      coverPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_photo_path'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
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
  final String? destination;
  final String? coverPhotoPath;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  const Trip({
    required this.id,
    required this.name,
    required this.totalBudgetPaise,
    required this.days,
    required this.currency,
    required this.createdAt,
    this.destination,
    this.coverPhotoPath,
    required this.status,
    this.startDate,
    this.endDate,
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
    if (!nullToAbsent || destination != null) {
      map['destination'] = Variable<String>(destination);
    }
    if (!nullToAbsent || coverPhotoPath != null) {
      map['cover_photo_path'] = Variable<String>(coverPhotoPath);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
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
      destination: destination == null && nullToAbsent
          ? const Value.absent()
          : Value(destination),
      coverPhotoPath: coverPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPhotoPath),
      status: Value(status),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
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
      destination: serializer.fromJson<String?>(json['destination']),
      coverPhotoPath: serializer.fromJson<String?>(json['coverPhotoPath']),
      status: serializer.fromJson<String>(json['status']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
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
      'destination': serializer.toJson<String?>(destination),
      'coverPhotoPath': serializer.toJson<String?>(coverPhotoPath),
      'status': serializer.toJson<String>(status),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
    };
  }

  Trip copyWith({
    String? id,
    String? name,
    int? totalBudgetPaise,
    int? days,
    String? currency,
    DateTime? createdAt,
    Value<String?> destination = const Value.absent(),
    Value<String?> coverPhotoPath = const Value.absent(),
    String? status,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
  }) => Trip(
    id: id ?? this.id,
    name: name ?? this.name,
    totalBudgetPaise: totalBudgetPaise ?? this.totalBudgetPaise,
    days: days ?? this.days,
    currency: currency ?? this.currency,
    createdAt: createdAt ?? this.createdAt,
    destination: destination.present ? destination.value : this.destination,
    coverPhotoPath: coverPhotoPath.present
        ? coverPhotoPath.value
        : this.coverPhotoPath,
    status: status ?? this.status,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
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
      destination: data.destination.present
          ? data.destination.value
          : this.destination,
      coverPhotoPath: data.coverPhotoPath.present
          ? data.coverPhotoPath.value
          : this.coverPhotoPath,
      status: data.status.present ? data.status.value : this.status,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
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
          ..write('createdAt: $createdAt, ')
          ..write('destination: $destination, ')
          ..write('coverPhotoPath: $coverPhotoPath, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    totalBudgetPaise,
    days,
    currency,
    createdAt,
    destination,
    coverPhotoPath,
    status,
    startDate,
    endDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.name == this.name &&
          other.totalBudgetPaise == this.totalBudgetPaise &&
          other.days == this.days &&
          other.currency == this.currency &&
          other.createdAt == this.createdAt &&
          other.destination == this.destination &&
          other.coverPhotoPath == this.coverPhotoPath &&
          other.status == this.status &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> totalBudgetPaise;
  final Value<int> days;
  final Value<String> currency;
  final Value<DateTime> createdAt;
  final Value<String?> destination;
  final Value<String?> coverPhotoPath;
  final Value<String> status;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.totalBudgetPaise = const Value.absent(),
    this.days = const Value.absent(),
    this.currency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.destination = const Value.absent(),
    this.coverPhotoPath = const Value.absent(),
    this.status = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String name,
    required int totalBudgetPaise,
    required int days,
    this.currency = const Value.absent(),
    required DateTime createdAt,
    this.destination = const Value.absent(),
    this.coverPhotoPath = const Value.absent(),
    this.status = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
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
    Expression<String>? destination,
    Expression<String>? coverPhotoPath,
    Expression<String>? status,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (totalBudgetPaise != null) 'total_budget_paise': totalBudgetPaise,
      if (days != null) 'days': days,
      if (currency != null) 'currency': currency,
      if (createdAt != null) 'created_at': createdAt,
      if (destination != null) 'destination': destination,
      if (coverPhotoPath != null) 'cover_photo_path': coverPhotoPath,
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
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
    Value<String?>? destination,
    Value<String?>? coverPhotoPath,
    Value<String>? status,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      totalBudgetPaise: totalBudgetPaise ?? this.totalBudgetPaise,
      days: days ?? this.days,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      destination: destination ?? this.destination,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
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
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (coverPhotoPath.present) {
      map['cover_photo_path'] = Variable<String>(coverPhotoPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
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
          ..write('destination: $destination, ')
          ..write('coverPhotoPath: $coverPhotoPath, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
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
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    name,
    upiVpa,
    avatarPath,
    phone,
  ];
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
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
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
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
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
  final String? avatarPath;
  final String? phone;
  const Traveler({
    required this.id,
    required this.tripId,
    required this.name,
    this.upiVpa,
    this.avatarPath,
    this.phone,
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
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
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
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
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
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      phone: serializer.fromJson<String?>(json['phone']),
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
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'phone': serializer.toJson<String?>(phone),
    };
  }

  Traveler copyWith({
    String? id,
    String? tripId,
    String? name,
    Value<String?> upiVpa = const Value.absent(),
    Value<String?> avatarPath = const Value.absent(),
    Value<String?> phone = const Value.absent(),
  }) => Traveler(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    upiVpa: upiVpa.present ? upiVpa.value : this.upiVpa,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    phone: phone.present ? phone.value : this.phone,
  );
  Traveler copyWithCompanion(TravelersCompanion data) {
    return Traveler(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      name: data.name.present ? data.name.value : this.name,
      upiVpa: data.upiVpa.present ? data.upiVpa.value : this.upiVpa,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      phone: data.phone.present ? data.phone.value : this.phone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Traveler(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('upiVpa: $upiVpa, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('phone: $phone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tripId, name, upiVpa, avatarPath, phone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Traveler &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.name == this.name &&
          other.upiVpa == this.upiVpa &&
          other.avatarPath == this.avatarPath &&
          other.phone == this.phone);
}

class TravelersCompanion extends UpdateCompanion<Traveler> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> name;
  final Value<String?> upiVpa;
  final Value<String?> avatarPath;
  final Value<String?> phone;
  final Value<int> rowid;
  const TravelersCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.name = const Value.absent(),
    this.upiVpa = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.phone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TravelersCompanion.insert({
    required String id,
    required String tripId,
    required String name,
    this.upiVpa = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.phone = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       name = Value(name);
  static Insertable<Traveler> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? name,
    Expression<String>? upiVpa,
    Expression<String>? avatarPath,
    Expression<String>? phone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (name != null) 'name': name,
      if (upiVpa != null) 'upi_vpa': upiVpa,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (phone != null) 'phone': phone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TravelersCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? name,
    Value<String?>? upiVpa,
    Value<String?>? avatarPath,
    Value<String?>? phone,
    Value<int>? rowid,
  }) {
    return TravelersCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      upiVpa: upiVpa ?? this.upiVpa,
      avatarPath: avatarPath ?? this.avatarPath,
      phone: phone ?? this.phone,
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
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
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
          ..write('avatarPath: $avatarPath, ')
          ..write('phone: $phone, ')
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
  static const VerificationMeta _receiptImagePathMeta = const VerificationMeta(
    'receiptImagePath',
  );
  @override
  late final GeneratedColumn<String> receiptImagePath = GeneratedColumn<String>(
    'receipt_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _originalCurrencyMeta = const VerificationMeta(
    'originalCurrency',
  );
  @override
  late final GeneratedColumn<String> originalCurrency = GeneratedColumn<String>(
    'original_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalAmountPaiseMeta =
      const VerificationMeta('originalAmountPaise');
  @override
  late final GeneratedColumn<int> originalAmountPaise = GeneratedColumn<int>(
    'original_amount_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exchangeRateMeta = const VerificationMeta(
    'exchangeRate',
  );
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
    'exchange_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
    receiptImagePath,
    notes,
    tagsJson,
    originalCurrency,
    originalAmountPaise,
    exchangeRate,
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
    if (data.containsKey('receipt_image_path')) {
      context.handle(
        _receiptImagePathMeta,
        receiptImagePath.isAcceptableOrUnknown(
          data['receipt_image_path']!,
          _receiptImagePathMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('original_currency')) {
      context.handle(
        _originalCurrencyMeta,
        originalCurrency.isAcceptableOrUnknown(
          data['original_currency']!,
          _originalCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('original_amount_paise')) {
      context.handle(
        _originalAmountPaiseMeta,
        originalAmountPaise.isAcceptableOrUnknown(
          data['original_amount_paise']!,
          _originalAmountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
        _exchangeRateMeta,
        exchangeRate.isAcceptableOrUnknown(
          data['exchange_rate']!,
          _exchangeRateMeta,
        ),
      );
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
      receiptImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_image_path'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      originalCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_currency'],
      ),
      originalAmountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_amount_paise'],
      ),
      exchangeRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}exchange_rate'],
      ),
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
  final String? receiptImagePath;
  final String? notes;
  final String tagsJson;
  final String? originalCurrency;
  final int? originalAmountPaise;
  final double? exchangeRate;
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
    this.receiptImagePath,
    this.notes,
    required this.tagsJson,
    this.originalCurrency,
    this.originalAmountPaise,
    this.exchangeRate,
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
    if (!nullToAbsent || receiptImagePath != null) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['tags_json'] = Variable<String>(tagsJson);
    if (!nullToAbsent || originalCurrency != null) {
      map['original_currency'] = Variable<String>(originalCurrency);
    }
    if (!nullToAbsent || originalAmountPaise != null) {
      map['original_amount_paise'] = Variable<int>(originalAmountPaise);
    }
    if (!nullToAbsent || exchangeRate != null) {
      map['exchange_rate'] = Variable<double>(exchangeRate);
    }
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
      receiptImagePath: receiptImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptImagePath),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      tagsJson: Value(tagsJson),
      originalCurrency: originalCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(originalCurrency),
      originalAmountPaise: originalAmountPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(originalAmountPaise),
      exchangeRate: exchangeRate == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRate),
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
      receiptImagePath: serializer.fromJson<String?>(json['receiptImagePath']),
      notes: serializer.fromJson<String?>(json['notes']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      originalCurrency: serializer.fromJson<String?>(json['originalCurrency']),
      originalAmountPaise: serializer.fromJson<int?>(
        json['originalAmountPaise'],
      ),
      exchangeRate: serializer.fromJson<double?>(json['exchangeRate']),
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
      'receiptImagePath': serializer.toJson<String?>(receiptImagePath),
      'notes': serializer.toJson<String?>(notes),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'originalCurrency': serializer.toJson<String?>(originalCurrency),
      'originalAmountPaise': serializer.toJson<int?>(originalAmountPaise),
      'exchangeRate': serializer.toJson<double?>(exchangeRate),
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
    Value<String?> receiptImagePath = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? tagsJson,
    Value<String?> originalCurrency = const Value.absent(),
    Value<int?> originalAmountPaise = const Value.absent(),
    Value<double?> exchangeRate = const Value.absent(),
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
    receiptImagePath: receiptImagePath.present
        ? receiptImagePath.value
        : this.receiptImagePath,
    notes: notes.present ? notes.value : this.notes,
    tagsJson: tagsJson ?? this.tagsJson,
    originalCurrency: originalCurrency.present
        ? originalCurrency.value
        : this.originalCurrency,
    originalAmountPaise: originalAmountPaise.present
        ? originalAmountPaise.value
        : this.originalAmountPaise,
    exchangeRate: exchangeRate.present ? exchangeRate.value : this.exchangeRate,
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
      receiptImagePath: data.receiptImagePath.present
          ? data.receiptImagePath.value
          : this.receiptImagePath,
      notes: data.notes.present ? data.notes.value : this.notes,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      originalCurrency: data.originalCurrency.present
          ? data.originalCurrency.value
          : this.originalCurrency,
      originalAmountPaise: data.originalAmountPaise.present
          ? data.originalAmountPaise.value
          : this.originalAmountPaise,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
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
          ..write('createdAt: $createdAt, ')
          ..write('receiptImagePath: $receiptImagePath, ')
          ..write('notes: $notes, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('originalCurrency: $originalCurrency, ')
          ..write('originalAmountPaise: $originalAmountPaise, ')
          ..write('exchangeRate: $exchangeRate')
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
    receiptImagePath,
    notes,
    tagsJson,
    originalCurrency,
    originalAmountPaise,
    exchangeRate,
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
          other.createdAt == this.createdAt &&
          other.receiptImagePath == this.receiptImagePath &&
          other.notes == this.notes &&
          other.tagsJson == this.tagsJson &&
          other.originalCurrency == this.originalCurrency &&
          other.originalAmountPaise == this.originalAmountPaise &&
          other.exchangeRate == this.exchangeRate);
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
  final Value<String?> receiptImagePath;
  final Value<String?> notes;
  final Value<String> tagsJson;
  final Value<String?> originalCurrency;
  final Value<int?> originalAmountPaise;
  final Value<double?> exchangeRate;
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
    this.receiptImagePath = const Value.absent(),
    this.notes = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.originalCurrency = const Value.absent(),
    this.originalAmountPaise = const Value.absent(),
    this.exchangeRate = const Value.absent(),
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
    this.receiptImagePath = const Value.absent(),
    this.notes = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.originalCurrency = const Value.absent(),
    this.originalAmountPaise = const Value.absent(),
    this.exchangeRate = const Value.absent(),
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
    Expression<String>? receiptImagePath,
    Expression<String>? notes,
    Expression<String>? tagsJson,
    Expression<String>? originalCurrency,
    Expression<int>? originalAmountPaise,
    Expression<double>? exchangeRate,
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
      if (receiptImagePath != null) 'receipt_image_path': receiptImagePath,
      if (notes != null) 'notes': notes,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (originalCurrency != null) 'original_currency': originalCurrency,
      if (originalAmountPaise != null)
        'original_amount_paise': originalAmountPaise,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
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
    Value<String?>? receiptImagePath,
    Value<String?>? notes,
    Value<String>? tagsJson,
    Value<String?>? originalCurrency,
    Value<int?>? originalAmountPaise,
    Value<double?>? exchangeRate,
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
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      notes: notes ?? this.notes,
      tagsJson: tagsJson ?? this.tagsJson,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      originalAmountPaise: originalAmountPaise ?? this.originalAmountPaise,
      exchangeRate: exchangeRate ?? this.exchangeRate,
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
    if (receiptImagePath.present) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (originalCurrency.present) {
      map['original_currency'] = Variable<String>(originalCurrency.value);
    }
    if (originalAmountPaise.present) {
      map['original_amount_paise'] = Variable<int>(originalAmountPaise.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
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
          ..write('receiptImagePath: $receiptImagePath, ')
          ..write('notes: $notes, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('originalCurrency: $originalCurrency, ')
          ..write('originalAmountPaise: $originalAmountPaise, ')
          ..write('exchangeRate: $exchangeRate, ')
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

class $ItineraryItemsTable extends ItineraryItems
    with TableInfo<$ItineraryItemsTable, ItineraryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItineraryItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dayNumberMeta = const VerificationMeta(
    'dayNumber',
  );
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
    'day_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeSlotMeta = const VerificationMeta(
    'timeSlot',
  );
  @override
  late final GeneratedColumn<String> timeSlot = GeneratedColumn<String>(
    'time_slot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMinutesMeta = const VerificationMeta(
    'startTimeMinutes',
  );
  @override
  late final GeneratedColumn<int> startTimeMinutes = GeneratedColumn<int>(
    'start_time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: const Constant('Activities'),
  );
  static const VerificationMeta _estimatedCostPaiseMeta =
      const VerificationMeta('estimatedCostPaise');
  @override
  late final GeneratedColumn<int> estimatedCostPaise = GeneratedColumn<int>(
    'estimated_cost_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    dayNumber,
    title,
    location,
    timeSlot,
    startTimeMinutes,
    category,
    estimatedCostPaise,
    notes,
    isCompleted,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'itinerary_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItineraryItem> instance, {
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
    if (data.containsKey('day_number')) {
      context.handle(
        _dayNumberMeta,
        dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_dayNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('time_slot')) {
      context.handle(
        _timeSlotMeta,
        timeSlot.isAcceptableOrUnknown(data['time_slot']!, _timeSlotMeta),
      );
    }
    if (data.containsKey('start_time_minutes')) {
      context.handle(
        _startTimeMinutesMeta,
        startTimeMinutes.isAcceptableOrUnknown(
          data['start_time_minutes']!,
          _startTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('estimated_cost_paise')) {
      context.handle(
        _estimatedCostPaiseMeta,
        estimatedCostPaise.isAcceptableOrUnknown(
          data['estimated_cost_paise']!,
          _estimatedCostPaiseMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
  ItineraryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItineraryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      dayNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_number'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      timeSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_slot'],
      ),
      startTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_minutes'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      estimatedCostPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_cost_paise'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ItineraryItemsTable createAlias(String alias) {
    return $ItineraryItemsTable(attachedDatabase, alias);
  }
}

class ItineraryItem extends DataClass implements Insertable<ItineraryItem> {
  final String id;
  final String tripId;
  final int dayNumber;
  final String title;
  final String? location;
  final String? timeSlot;
  final int? startTimeMinutes;
  final String category;
  final int estimatedCostPaise;
  final String? notes;
  final bool isCompleted;
  final int sortOrder;
  final DateTime createdAt;
  const ItineraryItem({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    required this.title,
    this.location,
    this.timeSlot,
    this.startTimeMinutes,
    required this.category,
    required this.estimatedCostPaise,
    this.notes,
    required this.isCompleted,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['day_number'] = Variable<int>(dayNumber);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || timeSlot != null) {
      map['time_slot'] = Variable<String>(timeSlot);
    }
    if (!nullToAbsent || startTimeMinutes != null) {
      map['start_time_minutes'] = Variable<int>(startTimeMinutes);
    }
    map['category'] = Variable<String>(category);
    map['estimated_cost_paise'] = Variable<int>(estimatedCostPaise);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ItineraryItemsCompanion toCompanion(bool nullToAbsent) {
    return ItineraryItemsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      dayNumber: Value(dayNumber),
      title: Value(title),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      timeSlot: timeSlot == null && nullToAbsent
          ? const Value.absent()
          : Value(timeSlot),
      startTimeMinutes: startTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(startTimeMinutes),
      category: Value(category),
      estimatedCostPaise: Value(estimatedCostPaise),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isCompleted: Value(isCompleted),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory ItineraryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItineraryItem(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      dayNumber: serializer.fromJson<int>(json['dayNumber']),
      title: serializer.fromJson<String>(json['title']),
      location: serializer.fromJson<String?>(json['location']),
      timeSlot: serializer.fromJson<String?>(json['timeSlot']),
      startTimeMinutes: serializer.fromJson<int?>(json['startTimeMinutes']),
      category: serializer.fromJson<String>(json['category']),
      estimatedCostPaise: serializer.fromJson<int>(json['estimatedCostPaise']),
      notes: serializer.fromJson<String?>(json['notes']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'dayNumber': serializer.toJson<int>(dayNumber),
      'title': serializer.toJson<String>(title),
      'location': serializer.toJson<String?>(location),
      'timeSlot': serializer.toJson<String?>(timeSlot),
      'startTimeMinutes': serializer.toJson<int?>(startTimeMinutes),
      'category': serializer.toJson<String>(category),
      'estimatedCostPaise': serializer.toJson<int>(estimatedCostPaise),
      'notes': serializer.toJson<String?>(notes),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ItineraryItem copyWith({
    String? id,
    String? tripId,
    int? dayNumber,
    String? title,
    Value<String?> location = const Value.absent(),
    Value<String?> timeSlot = const Value.absent(),
    Value<int?> startTimeMinutes = const Value.absent(),
    String? category,
    int? estimatedCostPaise,
    Value<String?> notes = const Value.absent(),
    bool? isCompleted,
    int? sortOrder,
    DateTime? createdAt,
  }) => ItineraryItem(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    dayNumber: dayNumber ?? this.dayNumber,
    title: title ?? this.title,
    location: location.present ? location.value : this.location,
    timeSlot: timeSlot.present ? timeSlot.value : this.timeSlot,
    startTimeMinutes: startTimeMinutes.present
        ? startTimeMinutes.value
        : this.startTimeMinutes,
    category: category ?? this.category,
    estimatedCostPaise: estimatedCostPaise ?? this.estimatedCostPaise,
    notes: notes.present ? notes.value : this.notes,
    isCompleted: isCompleted ?? this.isCompleted,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  ItineraryItem copyWithCompanion(ItineraryItemsCompanion data) {
    return ItineraryItem(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      title: data.title.present ? data.title.value : this.title,
      location: data.location.present ? data.location.value : this.location,
      timeSlot: data.timeSlot.present ? data.timeSlot.value : this.timeSlot,
      startTimeMinutes: data.startTimeMinutes.present
          ? data.startTimeMinutes.value
          : this.startTimeMinutes,
      category: data.category.present ? data.category.value : this.category,
      estimatedCostPaise: data.estimatedCostPaise.present
          ? data.estimatedCostPaise.value
          : this.estimatedCostPaise,
      notes: data.notes.present ? data.notes.value : this.notes,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItineraryItem(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('title: $title, ')
          ..write('location: $location, ')
          ..write('timeSlot: $timeSlot, ')
          ..write('startTimeMinutes: $startTimeMinutes, ')
          ..write('category: $category, ')
          ..write('estimatedCostPaise: $estimatedCostPaise, ')
          ..write('notes: $notes, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    dayNumber,
    title,
    location,
    timeSlot,
    startTimeMinutes,
    category,
    estimatedCostPaise,
    notes,
    isCompleted,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItineraryItem &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.dayNumber == this.dayNumber &&
          other.title == this.title &&
          other.location == this.location &&
          other.timeSlot == this.timeSlot &&
          other.startTimeMinutes == this.startTimeMinutes &&
          other.category == this.category &&
          other.estimatedCostPaise == this.estimatedCostPaise &&
          other.notes == this.notes &&
          other.isCompleted == this.isCompleted &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class ItineraryItemsCompanion extends UpdateCompanion<ItineraryItem> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<int> dayNumber;
  final Value<String> title;
  final Value<String?> location;
  final Value<String?> timeSlot;
  final Value<int?> startTimeMinutes;
  final Value<String> category;
  final Value<int> estimatedCostPaise;
  final Value<String?> notes;
  final Value<bool> isCompleted;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ItineraryItemsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.location = const Value.absent(),
    this.timeSlot = const Value.absent(),
    this.startTimeMinutes = const Value.absent(),
    this.category = const Value.absent(),
    this.estimatedCostPaise = const Value.absent(),
    this.notes = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItineraryItemsCompanion.insert({
    required String id,
    required String tripId,
    required int dayNumber,
    required String title,
    this.location = const Value.absent(),
    this.timeSlot = const Value.absent(),
    this.startTimeMinutes = const Value.absent(),
    this.category = const Value.absent(),
    this.estimatedCostPaise = const Value.absent(),
    this.notes = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       dayNumber = Value(dayNumber),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<ItineraryItem> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<int>? dayNumber,
    Expression<String>? title,
    Expression<String>? location,
    Expression<String>? timeSlot,
    Expression<int>? startTimeMinutes,
    Expression<String>? category,
    Expression<int>? estimatedCostPaise,
    Expression<String>? notes,
    Expression<bool>? isCompleted,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (dayNumber != null) 'day_number': dayNumber,
      if (title != null) 'title': title,
      if (location != null) 'location': location,
      if (timeSlot != null) 'time_slot': timeSlot,
      if (startTimeMinutes != null) 'start_time_minutes': startTimeMinutes,
      if (category != null) 'category': category,
      if (estimatedCostPaise != null)
        'estimated_cost_paise': estimatedCostPaise,
      if (notes != null) 'notes': notes,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItineraryItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<int>? dayNumber,
    Value<String>? title,
    Value<String?>? location,
    Value<String?>? timeSlot,
    Value<int?>? startTimeMinutes,
    Value<String>? category,
    Value<int>? estimatedCostPaise,
    Value<String?>? notes,
    Value<bool>? isCompleted,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ItineraryItemsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      location: location ?? this.location,
      timeSlot: timeSlot ?? this.timeSlot,
      startTimeMinutes: startTimeMinutes ?? this.startTimeMinutes,
      category: category ?? this.category,
      estimatedCostPaise: estimatedCostPaise ?? this.estimatedCostPaise,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (dayNumber.present) {
      map['day_number'] = Variable<int>(dayNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (timeSlot.present) {
      map['time_slot'] = Variable<String>(timeSlot.value);
    }
    if (startTimeMinutes.present) {
      map['start_time_minutes'] = Variable<int>(startTimeMinutes.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (estimatedCostPaise.present) {
      map['estimated_cost_paise'] = Variable<int>(estimatedCostPaise.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
    return (StringBuffer('ItineraryItemsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('title: $title, ')
          ..write('location: $location, ')
          ..write('timeSlot: $timeSlot, ')
          ..write('startTimeMinutes: $startTimeMinutes, ')
          ..write('category: $category, ')
          ..write('estimatedCostPaise: $estimatedCostPaise, ')
          ..write('notes: $notes, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseCommentsTable extends ExpenseComments
    with TableInfo<$ExpenseCommentsTable, ExpenseComment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseCommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _authorTravelerIdMeta = const VerificationMeta(
    'authorTravelerId',
  );
  @override
  late final GeneratedColumn<String> authorTravelerId = GeneratedColumn<String>(
    'author_traveler_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDisputeMeta = const VerificationMeta(
    'isDispute',
  );
  @override
  late final GeneratedColumn<bool> isDispute = GeneratedColumn<bool>(
    'is_dispute',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dispute" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isResolvedMeta = const VerificationMeta(
    'isResolved',
  );
  @override
  late final GeneratedColumn<bool> isResolved = GeneratedColumn<bool>(
    'is_resolved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_resolved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    expenseId,
    tripId,
    authorTravelerId,
    authorName,
    body,
    isDispute,
    isResolved,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_comments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseComment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('author_traveler_id')) {
      context.handle(
        _authorTravelerIdMeta,
        authorTravelerId.isAcceptableOrUnknown(
          data['author_traveler_id']!,
          _authorTravelerIdMeta,
        ),
      );
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    } else if (isInserting) {
      context.missing(_authorNameMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('is_dispute')) {
      context.handle(
        _isDisputeMeta,
        isDispute.isAcceptableOrUnknown(data['is_dispute']!, _isDisputeMeta),
      );
    }
    if (data.containsKey('is_resolved')) {
      context.handle(
        _isResolvedMeta,
        isResolved.isAcceptableOrUnknown(data['is_resolved']!, _isResolvedMeta),
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
  ExpenseComment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseComment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      authorTravelerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_traveler_id'],
      ),
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      isDispute: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dispute'],
      )!,
      isResolved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_resolved'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExpenseCommentsTable createAlias(String alias) {
    return $ExpenseCommentsTable(attachedDatabase, alias);
  }
}

class ExpenseComment extends DataClass implements Insertable<ExpenseComment> {
  final String id;
  final String expenseId;
  final String tripId;
  final String? authorTravelerId;
  final String authorName;
  final String body;
  final bool isDispute;
  final bool isResolved;
  final DateTime createdAt;
  const ExpenseComment({
    required this.id,
    required this.expenseId,
    required this.tripId,
    this.authorTravelerId,
    required this.authorName,
    required this.body,
    required this.isDispute,
    required this.isResolved,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['expense_id'] = Variable<String>(expenseId);
    map['trip_id'] = Variable<String>(tripId);
    if (!nullToAbsent || authorTravelerId != null) {
      map['author_traveler_id'] = Variable<String>(authorTravelerId);
    }
    map['author_name'] = Variable<String>(authorName);
    map['body'] = Variable<String>(body);
    map['is_dispute'] = Variable<bool>(isDispute);
    map['is_resolved'] = Variable<bool>(isResolved);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpenseCommentsCompanion toCompanion(bool nullToAbsent) {
    return ExpenseCommentsCompanion(
      id: Value(id),
      expenseId: Value(expenseId),
      tripId: Value(tripId),
      authorTravelerId: authorTravelerId == null && nullToAbsent
          ? const Value.absent()
          : Value(authorTravelerId),
      authorName: Value(authorName),
      body: Value(body),
      isDispute: Value(isDispute),
      isResolved: Value(isResolved),
      createdAt: Value(createdAt),
    );
  }

  factory ExpenseComment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseComment(
      id: serializer.fromJson<String>(json['id']),
      expenseId: serializer.fromJson<String>(json['expenseId']),
      tripId: serializer.fromJson<String>(json['tripId']),
      authorTravelerId: serializer.fromJson<String?>(json['authorTravelerId']),
      authorName: serializer.fromJson<String>(json['authorName']),
      body: serializer.fromJson<String>(json['body']),
      isDispute: serializer.fromJson<bool>(json['isDispute']),
      isResolved: serializer.fromJson<bool>(json['isResolved']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'expenseId': serializer.toJson<String>(expenseId),
      'tripId': serializer.toJson<String>(tripId),
      'authorTravelerId': serializer.toJson<String?>(authorTravelerId),
      'authorName': serializer.toJson<String>(authorName),
      'body': serializer.toJson<String>(body),
      'isDispute': serializer.toJson<bool>(isDispute),
      'isResolved': serializer.toJson<bool>(isResolved),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ExpenseComment copyWith({
    String? id,
    String? expenseId,
    String? tripId,
    Value<String?> authorTravelerId = const Value.absent(),
    String? authorName,
    String? body,
    bool? isDispute,
    bool? isResolved,
    DateTime? createdAt,
  }) => ExpenseComment(
    id: id ?? this.id,
    expenseId: expenseId ?? this.expenseId,
    tripId: tripId ?? this.tripId,
    authorTravelerId: authorTravelerId.present
        ? authorTravelerId.value
        : this.authorTravelerId,
    authorName: authorName ?? this.authorName,
    body: body ?? this.body,
    isDispute: isDispute ?? this.isDispute,
    isResolved: isResolved ?? this.isResolved,
    createdAt: createdAt ?? this.createdAt,
  );
  ExpenseComment copyWithCompanion(ExpenseCommentsCompanion data) {
    return ExpenseComment(
      id: data.id.present ? data.id.value : this.id,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      authorTravelerId: data.authorTravelerId.present
          ? data.authorTravelerId.value
          : this.authorTravelerId,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      body: data.body.present ? data.body.value : this.body,
      isDispute: data.isDispute.present ? data.isDispute.value : this.isDispute,
      isResolved: data.isResolved.present
          ? data.isResolved.value
          : this.isResolved,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseComment(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('tripId: $tripId, ')
          ..write('authorTravelerId: $authorTravelerId, ')
          ..write('authorName: $authorName, ')
          ..write('body: $body, ')
          ..write('isDispute: $isDispute, ')
          ..write('isResolved: $isResolved, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    expenseId,
    tripId,
    authorTravelerId,
    authorName,
    body,
    isDispute,
    isResolved,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseComment &&
          other.id == this.id &&
          other.expenseId == this.expenseId &&
          other.tripId == this.tripId &&
          other.authorTravelerId == this.authorTravelerId &&
          other.authorName == this.authorName &&
          other.body == this.body &&
          other.isDispute == this.isDispute &&
          other.isResolved == this.isResolved &&
          other.createdAt == this.createdAt);
}

class ExpenseCommentsCompanion extends UpdateCompanion<ExpenseComment> {
  final Value<String> id;
  final Value<String> expenseId;
  final Value<String> tripId;
  final Value<String?> authorTravelerId;
  final Value<String> authorName;
  final Value<String> body;
  final Value<bool> isDispute;
  final Value<bool> isResolved;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExpenseCommentsCompanion({
    this.id = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.authorTravelerId = const Value.absent(),
    this.authorName = const Value.absent(),
    this.body = const Value.absent(),
    this.isDispute = const Value.absent(),
    this.isResolved = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseCommentsCompanion.insert({
    required String id,
    required String expenseId,
    required String tripId,
    this.authorTravelerId = const Value.absent(),
    required String authorName,
    required String body,
    this.isDispute = const Value.absent(),
    this.isResolved = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       expenseId = Value(expenseId),
       tripId = Value(tripId),
       authorName = Value(authorName),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<ExpenseComment> custom({
    Expression<String>? id,
    Expression<String>? expenseId,
    Expression<String>? tripId,
    Expression<String>? authorTravelerId,
    Expression<String>? authorName,
    Expression<String>? body,
    Expression<bool>? isDispute,
    Expression<bool>? isResolved,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (expenseId != null) 'expense_id': expenseId,
      if (tripId != null) 'trip_id': tripId,
      if (authorTravelerId != null) 'author_traveler_id': authorTravelerId,
      if (authorName != null) 'author_name': authorName,
      if (body != null) 'body': body,
      if (isDispute != null) 'is_dispute': isDispute,
      if (isResolved != null) 'is_resolved': isResolved,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseCommentsCompanion copyWith({
    Value<String>? id,
    Value<String>? expenseId,
    Value<String>? tripId,
    Value<String?>? authorTravelerId,
    Value<String>? authorName,
    Value<String>? body,
    Value<bool>? isDispute,
    Value<bool>? isResolved,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExpenseCommentsCompanion(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      tripId: tripId ?? this.tripId,
      authorTravelerId: authorTravelerId ?? this.authorTravelerId,
      authorName: authorName ?? this.authorName,
      body: body ?? this.body,
      isDispute: isDispute ?? this.isDispute,
      isResolved: isResolved ?? this.isResolved,
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
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (authorTravelerId.present) {
      map['author_traveler_id'] = Variable<String>(authorTravelerId.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (isDispute.present) {
      map['is_dispute'] = Variable<bool>(isDispute.value);
    }
    if (isResolved.present) {
      map['is_resolved'] = Variable<bool>(isResolved.value);
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
    return (StringBuffer('ExpenseCommentsCompanion(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('tripId: $tripId, ')
          ..write('authorTravelerId: $authorTravelerId, ')
          ..write('authorName: $authorName, ')
          ..write('body: $body, ')
          ..write('isDispute: $isDispute, ')
          ..write('isResolved: $isResolved, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripPhotosTable extends TripPhotos
    with TableInfo<$TripPhotosTable, TripPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripPhotosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayNumberMeta = const VerificationMeta(
    'dayNumber',
  );
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
    'day_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _uploadedByTravelerIdMeta =
      const VerificationMeta('uploadedByTravelerId');
  @override
  late final GeneratedColumn<String> uploadedByTravelerId =
      GeneratedColumn<String>(
        'uploaded_by_traveler_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _uploadedByNameMeta = const VerificationMeta(
    'uploadedByName',
  );
  @override
  late final GeneratedColumn<String> uploadedByName = GeneratedColumn<String>(
    'uploaded_by_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('You'),
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
    imagePath,
    caption,
    dayNumber,
    uploadedByTravelerId,
    uploadedByName,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripPhoto> instance, {
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
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('day_number')) {
      context.handle(
        _dayNumberMeta,
        dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta),
      );
    }
    if (data.containsKey('uploaded_by_traveler_id')) {
      context.handle(
        _uploadedByTravelerIdMeta,
        uploadedByTravelerId.isAcceptableOrUnknown(
          data['uploaded_by_traveler_id']!,
          _uploadedByTravelerIdMeta,
        ),
      );
    }
    if (data.containsKey('uploaded_by_name')) {
      context.handle(
        _uploadedByNameMeta,
        uploadedByName.isAcceptableOrUnknown(
          data['uploaded_by_name']!,
          _uploadedByNameMeta,
        ),
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
  TripPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
      dayNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_number'],
      )!,
      uploadedByTravelerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uploaded_by_traveler_id'],
      ),
      uploadedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uploaded_by_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TripPhotosTable createAlias(String alias) {
    return $TripPhotosTable(attachedDatabase, alias);
  }
}

class TripPhoto extends DataClass implements Insertable<TripPhoto> {
  final String id;
  final String tripId;
  final String imagePath;
  final String? caption;
  final int dayNumber;
  final String? uploadedByTravelerId;
  final String uploadedByName;
  final DateTime createdAt;
  const TripPhoto({
    required this.id,
    required this.tripId,
    required this.imagePath,
    this.caption,
    required this.dayNumber,
    this.uploadedByTravelerId,
    required this.uploadedByName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['image_path'] = Variable<String>(imagePath);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    map['day_number'] = Variable<int>(dayNumber);
    if (!nullToAbsent || uploadedByTravelerId != null) {
      map['uploaded_by_traveler_id'] = Variable<String>(uploadedByTravelerId);
    }
    map['uploaded_by_name'] = Variable<String>(uploadedByName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TripPhotosCompanion toCompanion(bool nullToAbsent) {
    return TripPhotosCompanion(
      id: Value(id),
      tripId: Value(tripId),
      imagePath: Value(imagePath),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      dayNumber: Value(dayNumber),
      uploadedByTravelerId: uploadedByTravelerId == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadedByTravelerId),
      uploadedByName: Value(uploadedByName),
      createdAt: Value(createdAt),
    );
  }

  factory TripPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripPhoto(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      caption: serializer.fromJson<String?>(json['caption']),
      dayNumber: serializer.fromJson<int>(json['dayNumber']),
      uploadedByTravelerId: serializer.fromJson<String?>(
        json['uploadedByTravelerId'],
      ),
      uploadedByName: serializer.fromJson<String>(json['uploadedByName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'imagePath': serializer.toJson<String>(imagePath),
      'caption': serializer.toJson<String?>(caption),
      'dayNumber': serializer.toJson<int>(dayNumber),
      'uploadedByTravelerId': serializer.toJson<String?>(uploadedByTravelerId),
      'uploadedByName': serializer.toJson<String>(uploadedByName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TripPhoto copyWith({
    String? id,
    String? tripId,
    String? imagePath,
    Value<String?> caption = const Value.absent(),
    int? dayNumber,
    Value<String?> uploadedByTravelerId = const Value.absent(),
    String? uploadedByName,
    DateTime? createdAt,
  }) => TripPhoto(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    imagePath: imagePath ?? this.imagePath,
    caption: caption.present ? caption.value : this.caption,
    dayNumber: dayNumber ?? this.dayNumber,
    uploadedByTravelerId: uploadedByTravelerId.present
        ? uploadedByTravelerId.value
        : this.uploadedByTravelerId,
    uploadedByName: uploadedByName ?? this.uploadedByName,
    createdAt: createdAt ?? this.createdAt,
  );
  TripPhoto copyWithCompanion(TripPhotosCompanion data) {
    return TripPhoto(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      caption: data.caption.present ? data.caption.value : this.caption,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      uploadedByTravelerId: data.uploadedByTravelerId.present
          ? data.uploadedByTravelerId.value
          : this.uploadedByTravelerId,
      uploadedByName: data.uploadedByName.present
          ? data.uploadedByName.value
          : this.uploadedByName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripPhoto(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('imagePath: $imagePath, ')
          ..write('caption: $caption, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('uploadedByTravelerId: $uploadedByTravelerId, ')
          ..write('uploadedByName: $uploadedByName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    imagePath,
    caption,
    dayNumber,
    uploadedByTravelerId,
    uploadedByName,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripPhoto &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.imagePath == this.imagePath &&
          other.caption == this.caption &&
          other.dayNumber == this.dayNumber &&
          other.uploadedByTravelerId == this.uploadedByTravelerId &&
          other.uploadedByName == this.uploadedByName &&
          other.createdAt == this.createdAt);
}

class TripPhotosCompanion extends UpdateCompanion<TripPhoto> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> imagePath;
  final Value<String?> caption;
  final Value<int> dayNumber;
  final Value<String?> uploadedByTravelerId;
  final Value<String> uploadedByName;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TripPhotosCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.caption = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.uploadedByTravelerId = const Value.absent(),
    this.uploadedByName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripPhotosCompanion.insert({
    required String id,
    required String tripId,
    required String imagePath,
    this.caption = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.uploadedByTravelerId = const Value.absent(),
    this.uploadedByName = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       imagePath = Value(imagePath),
       createdAt = Value(createdAt);
  static Insertable<TripPhoto> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? imagePath,
    Expression<String>? caption,
    Expression<int>? dayNumber,
    Expression<String>? uploadedByTravelerId,
    Expression<String>? uploadedByName,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (imagePath != null) 'image_path': imagePath,
      if (caption != null) 'caption': caption,
      if (dayNumber != null) 'day_number': dayNumber,
      if (uploadedByTravelerId != null)
        'uploaded_by_traveler_id': uploadedByTravelerId,
      if (uploadedByName != null) 'uploaded_by_name': uploadedByName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? imagePath,
    Value<String?>? caption,
    Value<int>? dayNumber,
    Value<String?>? uploadedByTravelerId,
    Value<String>? uploadedByName,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TripPhotosCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      imagePath: imagePath ?? this.imagePath,
      caption: caption ?? this.caption,
      dayNumber: dayNumber ?? this.dayNumber,
      uploadedByTravelerId: uploadedByTravelerId ?? this.uploadedByTravelerId,
      uploadedByName: uploadedByName ?? this.uploadedByName,
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
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (dayNumber.present) {
      map['day_number'] = Variable<int>(dayNumber.value);
    }
    if (uploadedByTravelerId.present) {
      map['uploaded_by_traveler_id'] = Variable<String>(
        uploadedByTravelerId.value,
      );
    }
    if (uploadedByName.present) {
      map['uploaded_by_name'] = Variable<String>(uploadedByName.value);
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
    return (StringBuffer('TripPhotosCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('imagePath: $imagePath, ')
          ..write('caption: $caption, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('uploadedByTravelerId: $uploadedByTravelerId, ')
          ..write('uploadedByName: $uploadedByName, ')
          ..write('createdAt: $createdAt, ')
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
  late final $ItineraryItemsTable itineraryItems = $ItineraryItemsTable(this);
  late final $ExpenseCommentsTable expenseComments = $ExpenseCommentsTable(
    this,
  );
  late final $TripPhotosTable tripPhotos = $TripPhotosTable(this);
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
    itineraryItems,
    expenseComments,
    tripPhotos,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('itinerary_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'expenses',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expense_comments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expense_comments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('trip_photos', kind: UpdateKind.delete)],
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
  Value<String?> destination,
  Value<String?> coverPhotoPath,
  Value<String> status,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<int> rowid,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> totalBudgetPaise,
  Value<int> days,
  Value<String> currency,
  Value<DateTime> createdAt,
  Value<String?> destination,
  Value<String?> coverPhotoPath,
  Value<String> status,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
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

  static MultiTypedResultKey<$ItineraryItemsTable, List<ItineraryItem>>
  _itineraryItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itineraryItems,
    aliasName: 'trips__id__itinerary_items__trip_id',
  );

  $$ItineraryItemsTableProcessedTableManager get itineraryItemsRefs {
    final manager = $$ItineraryItemsTableTableManager(
      $_db,
      $_db.itineraryItems,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itineraryItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpenseCommentsTable, List<ExpenseComment>>
  _expenseCommentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenseComments,
    aliasName: 'trips__id__expense_comments__trip_id',
  );

  $$ExpenseCommentsTableProcessedTableManager get expenseCommentsRefs {
    final manager = $$ExpenseCommentsTableTableManager(
      $_db,
      $_db.expenseComments,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _expenseCommentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TripPhotosTable, List<TripPhoto>>
  _tripPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripPhotos,
    aliasName: 'trips__id__trip_photos__trip_id',
  );

  $$TripPhotosTableProcessedTableManager get tripPhotosRefs {
    final manager = $$TripPhotosTableTableManager(
      $_db,
      $_db.tripPhotos,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripPhotosRefsTable($_db));
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

  ColumnFilters<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPhotoPath => $composableBuilder(
    column: $table.coverPhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
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

  Expression<bool> itineraryItemsRefs(
    Expression<bool> Function($$ItineraryItemsTableFilterComposer f) f,
  ) {
    final $$ItineraryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itineraryItems,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItineraryItemsTableFilterComposer(
            $db: $db,
            $table: $db.itineraryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expenseCommentsRefs(
    Expression<bool> Function($$ExpenseCommentsTableFilterComposer f) f,
  ) {
    final $$ExpenseCommentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseComments,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCommentsTableFilterComposer(
            $db: $db,
            $table: $db.expenseComments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tripPhotosRefs(
    Expression<bool> Function($$TripPhotosTableFilterComposer f) f,
  ) {
    final $$TripPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripPhotos,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPhotosTableFilterComposer(
            $db: $db,
            $table: $db.tripPhotos,
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

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPhotoPath => $composableBuilder(
    column: $table.coverPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
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

  GeneratedColumn<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPhotoPath => $composableBuilder(
    column: $table.coverPhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

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

  Expression<T> itineraryItemsRefs<T extends Object>(
    Expression<T> Function($$ItineraryItemsTableAnnotationComposer a) f,
  ) {
    final $$ItineraryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itineraryItems,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItineraryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.itineraryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expenseCommentsRefs<T extends Object>(
    Expression<T> Function($$ExpenseCommentsTableAnnotationComposer a) f,
  ) {
    final $$ExpenseCommentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseComments,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCommentsTableAnnotationComposer(
            $db: $db,
            $table: $db.expenseComments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tripPhotosRefs<T extends Object>(
    Expression<T> Function($$TripPhotosTableAnnotationComposer a) f,
  ) {
    final $$TripPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripPhotos,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.tripPhotos,
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
            bool itineraryItemsRefs,
            bool expenseCommentsRefs,
            bool tripPhotosRefs,
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
                Value<String?> destination = const Value.absent(),
                Value<String?> coverPhotoPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                name: name,
                totalBudgetPaise: totalBudgetPaise,
                days: days,
                currency: currency,
                createdAt: createdAt,
                destination: destination,
                coverPhotoPath: coverPhotoPath,
                status: status,
                startDate: startDate,
                endDate: endDate,
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
                Value<String?> destination = const Value.absent(),
                Value<String?> coverPhotoPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                name: name,
                totalBudgetPaise: totalBudgetPaise,
                days: days,
                currency: currency,
                createdAt: createdAt,
                destination: destination,
                coverPhotoPath: coverPhotoPath,
                status: status,
                startDate: startDate,
                endDate: endDate,
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
                itineraryItemsRefs = false,
                expenseCommentsRefs = false,
                tripPhotosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (travelersRefs) db.travelers,
                    if (categoryAllocationsRefs) db.categoryAllocations,
                    if (expensesRefs) db.expenses,
                    if (itineraryItemsRefs) db.itineraryItems,
                    if (expenseCommentsRefs) db.expenseComments,
                    if (tripPhotosRefs) db.tripPhotos,
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
                      if (itineraryItemsRefs)
                        await $_getPrefetchedDataByColumns<
                          Trip,
                          $TripsTable,
                          ItineraryItem,
                          $ItineraryItemsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._itineraryItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).itineraryItemsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'trip_id',
                          typedResults: items,
                        ),
                      if (expenseCommentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Trip,
                          $TripsTable,
                          ExpenseComment,
                          $ExpenseCommentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._expenseCommentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).expenseCommentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'trip_id',
                          typedResults: items,
                        ),
                      if (tripPhotosRefs)
                        await $_getPrefetchedDataByColumns<
                          Trip,
                          $TripsTable,
                          TripPhoto,
                          $TripPhotosTable
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._tripPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripPhotosRefs,
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
        bool itineraryItemsRefs,
        bool expenseCommentsRefs,
        bool tripPhotosRefs,
      })
    >;
typedef $$TravelersTableCreateCompanionBuilder = TravelersCompanion Function({
  required String id,
  required String tripId,
  required String name,
  Value<String?> upiVpa,
  Value<String?> avatarPath,
  Value<String?> phone,
  Value<int> rowid,
});
typedef $$TravelersTableUpdateCompanionBuilder = TravelersCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String> name,
  Value<String?> upiVpa,
  Value<String?> avatarPath,
  Value<String?> phone,
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

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
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

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
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

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

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
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TravelersCompanion(
                id: id,
                tripId: tripId,
                name: name,
                upiVpa: upiVpa,
                avatarPath: avatarPath,
                phone: phone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String name,
                Value<String?> upiVpa = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TravelersCompanion.insert(
                id: id,
                tripId: tripId,
                name: name,
                upiVpa: upiVpa,
                avatarPath: avatarPath,
                phone: phone,
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
  Value<String?> receiptImagePath,
  Value<String?> notes,
  Value<String> tagsJson,
  Value<String?> originalCurrency,
  Value<int?> originalAmountPaise,
  Value<double?> exchangeRate,
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
  Value<String?> receiptImagePath,
  Value<String?> notes,
  Value<String> tagsJson,
  Value<String?> originalCurrency,
  Value<int?> originalAmountPaise,
  Value<double?> exchangeRate,
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

  static MultiTypedResultKey<$ExpenseCommentsTable, List<ExpenseComment>>
  _expenseCommentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenseComments,
    aliasName: 'expenses__id__expense_comments__expense_id',
  );

  $$ExpenseCommentsTableProcessedTableManager get expenseCommentsRefs {
    final manager = $$ExpenseCommentsTableTableManager(
      $_db,
      $_db.expenseComments,
    ).filter((f) => f.expenseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _expenseCommentsRefsTable($_db),
    );
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

  ColumnFilters<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalCurrency => $composableBuilder(
    column: $table.originalCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalAmountPaise => $composableBuilder(
    column: $table.originalAmountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exchangeRate => $composableBuilder(
    column: $table.exchangeRate,
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

  Expression<bool> expenseCommentsRefs(
    Expression<bool> Function($$ExpenseCommentsTableFilterComposer f) f,
  ) {
    final $$ExpenseCommentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseComments,
      getReferencedColumn: (t) => t.expenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCommentsTableFilterComposer(
            $db: $db,
            $table: $db.expenseComments,
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

  ColumnOrderings<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalCurrency => $composableBuilder(
    column: $table.originalCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalAmountPaise => $composableBuilder(
    column: $table.originalAmountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
    column: $table.exchangeRate,
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

  GeneratedColumn<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get originalCurrency => $composableBuilder(
    column: $table.originalCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalAmountPaise => $composableBuilder(
    column: $table.originalAmountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
    column: $table.exchangeRate,
    builder: (column) => column,
  );

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

  Expression<T> expenseCommentsRefs<T extends Object>(
    Expression<T> Function($$ExpenseCommentsTableAnnotationComposer a) f,
  ) {
    final $$ExpenseCommentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseComments,
      getReferencedColumn: (t) => t.expenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCommentsTableAnnotationComposer(
            $db: $db,
            $table: $db.expenseComments,
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
            bool expenseCommentsRefs,
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
                Value<String?> receiptImagePath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String?> originalCurrency = const Value.absent(),
                Value<int?> originalAmountPaise = const Value.absent(),
                Value<double?> exchangeRate = const Value.absent(),
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
                receiptImagePath: receiptImagePath,
                notes: notes,
                tagsJson: tagsJson,
                originalCurrency: originalCurrency,
                originalAmountPaise: originalAmountPaise,
                exchangeRate: exchangeRate,
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
                Value<String?> receiptImagePath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String?> originalCurrency = const Value.absent(),
                Value<int?> originalAmountPaise = const Value.absent(),
                Value<double?> exchangeRate = const Value.absent(),
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
                receiptImagePath: receiptImagePath,
                notes: notes,
                tagsJson: tagsJson,
                originalCurrency: originalCurrency,
                originalAmountPaise: originalAmountPaise,
                exchangeRate: exchangeRate,
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
              ({
                tripId = false,
                paidBy = false,
                expenseSplitsRefs = false,
                expenseCommentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (expenseSplitsRefs) db.expenseSplits,
                    if (expenseCommentsRefs) db.expenseComments,
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
                      if (expenseCommentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Expense,
                          $ExpensesTable,
                          ExpenseComment,
                          $ExpenseCommentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExpensesTableReferences
                              ._expenseCommentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExpensesTableReferences(
                                db,
                                table,
                                p0,
                              ).expenseCommentsRefs,
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
      PrefetchHooks Function({
        bool tripId,
        bool paidBy,
        bool expenseSplitsRefs,
        bool expenseCommentsRefs,
      })
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
typedef $$ItineraryItemsTableCreateCompanionBuilder =
    ItineraryItemsCompanion Function({
      required String id,
      required String tripId,
      required int dayNumber,
      required String title,
      Value<String?> location,
      Value<String?> timeSlot,
      Value<int?> startTimeMinutes,
      Value<String> category,
      Value<int> estimatedCostPaise,
      Value<String?> notes,
      Value<bool> isCompleted,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ItineraryItemsTableUpdateCompanionBuilder =
    ItineraryItemsCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<int> dayNumber,
      Value<String> title,
      Value<String?> location,
      Value<String?> timeSlot,
      Value<int?> startTimeMinutes,
      Value<String> category,
      Value<int> estimatedCostPaise,
      Value<String?> notes,
      Value<bool> isCompleted,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ItineraryItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItineraryItemsTable, ItineraryItem> {
  $$ItineraryItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('itinerary_items__trip_id__trips__id');

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

class $$ItineraryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ItineraryItemsTable> {
  $$ItineraryItemsTableFilterComposer({
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

  ColumnFilters<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeSlot => $composableBuilder(
    column: $table.timeSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTimeMinutes => $composableBuilder(
    column: $table.startTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedCostPaise => $composableBuilder(
    column: $table.estimatedCostPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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
}

class $$ItineraryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItineraryItemsTable> {
  $$ItineraryItemsTableOrderingComposer({
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

  ColumnOrderings<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeSlot => $composableBuilder(
    column: $table.timeSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTimeMinutes => $composableBuilder(
    column: $table.startTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedCostPaise => $composableBuilder(
    column: $table.estimatedCostPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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
}

class $$ItineraryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItineraryItemsTable> {
  $$ItineraryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayNumber =>
      $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get timeSlot =>
      $composableBuilder(column: $table.timeSlot, builder: (column) => column);

  GeneratedColumn<int> get startTimeMinutes => $composableBuilder(
    column: $table.startTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get estimatedCostPaise => $composableBuilder(
    column: $table.estimatedCostPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

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
}

class $$ItineraryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItineraryItemsTable,
          ItineraryItem,
          $$ItineraryItemsTableFilterComposer,
          $$ItineraryItemsTableOrderingComposer,
          $$ItineraryItemsTableAnnotationComposer,
          $$ItineraryItemsTableCreateCompanionBuilder,
          $$ItineraryItemsTableUpdateCompanionBuilder,
          (ItineraryItem, $$ItineraryItemsTableReferences),
          ItineraryItem,
          PrefetchHooks Function({bool tripId})
        > {
  $$ItineraryItemsTableTableManager(
    _$AppDatabase db,
    $ItineraryItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItineraryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItineraryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItineraryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<int> dayNumber = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> timeSlot = const Value.absent(),
                Value<int?> startTimeMinutes = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> estimatedCostPaise = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItineraryItemsCompanion(
                id: id,
                tripId: tripId,
                dayNumber: dayNumber,
                title: title,
                location: location,
                timeSlot: timeSlot,
                startTimeMinutes: startTimeMinutes,
                category: category,
                estimatedCostPaise: estimatedCostPaise,
                notes: notes,
                isCompleted: isCompleted,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required int dayNumber,
                required String title,
                Value<String?> location = const Value.absent(),
                Value<String?> timeSlot = const Value.absent(),
                Value<int?> startTimeMinutes = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> estimatedCostPaise = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ItineraryItemsCompanion.insert(
                id: id,
                tripId: tripId,
                dayNumber: dayNumber,
                title: title,
                location: location,
                timeSlot: timeSlot,
                startTimeMinutes: startTimeMinutes,
                category: category,
                estimatedCostPaise: estimatedCostPaise,
                notes: notes,
                isCompleted: isCompleted,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItineraryItemsTable, ItineraryItem>(table),
                  $$ItineraryItemsTableReferences(db, table, e),
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
                        referencedTable: $$ItineraryItemsTableReferences
                            ._tripIdTable(db),
                        referencedColumn: $$ItineraryItemsTableReferences
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

typedef $$ItineraryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItineraryItemsTable,
      ItineraryItem,
      $$ItineraryItemsTableFilterComposer,
      $$ItineraryItemsTableOrderingComposer,
      $$ItineraryItemsTableAnnotationComposer,
      $$ItineraryItemsTableCreateCompanionBuilder,
      $$ItineraryItemsTableUpdateCompanionBuilder,
      (ItineraryItem, $$ItineraryItemsTableReferences),
      ItineraryItem,
      PrefetchHooks Function({bool tripId})
    >;
typedef $$ExpenseCommentsTableCreateCompanionBuilder =
    ExpenseCommentsCompanion Function({
      required String id,
      required String expenseId,
      required String tripId,
      Value<String?> authorTravelerId,
      required String authorName,
      required String body,
      Value<bool> isDispute,
      Value<bool> isResolved,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ExpenseCommentsTableUpdateCompanionBuilder =
    ExpenseCommentsCompanion Function({
      Value<String> id,
      Value<String> expenseId,
      Value<String> tripId,
      Value<String?> authorTravelerId,
      Value<String> authorName,
      Value<String> body,
      Value<bool> isDispute,
      Value<bool> isResolved,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ExpenseCommentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ExpenseCommentsTable, ExpenseComment> {
  $$ExpenseCommentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExpensesTable _expenseIdTable(_$AppDatabase db) =>
      db.expenses.createAlias('expense_comments__expense_id__expenses__id');

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

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('expense_comments__trip_id__trips__id');

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

class $$ExpenseCommentsTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseCommentsTable> {
  $$ExpenseCommentsTableFilterComposer({
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

  ColumnFilters<String> get authorTravelerId => $composableBuilder(
    column: $table.authorTravelerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDispute => $composableBuilder(
    column: $table.isDispute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isResolved => $composableBuilder(
    column: $table.isResolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$ExpenseCommentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseCommentsTable> {
  $$ExpenseCommentsTableOrderingComposer({
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

  ColumnOrderings<String> get authorTravelerId => $composableBuilder(
    column: $table.authorTravelerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDispute => $composableBuilder(
    column: $table.isDispute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isResolved => $composableBuilder(
    column: $table.isResolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$ExpenseCommentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseCommentsTable> {
  $$ExpenseCommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get authorTravelerId => $composableBuilder(
    column: $table.authorTravelerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get isDispute =>
      $composableBuilder(column: $table.isDispute, builder: (column) => column);

  GeneratedColumn<bool> get isResolved => $composableBuilder(
    column: $table.isResolved,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

class $$ExpenseCommentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseCommentsTable,
          ExpenseComment,
          $$ExpenseCommentsTableFilterComposer,
          $$ExpenseCommentsTableOrderingComposer,
          $$ExpenseCommentsTableAnnotationComposer,
          $$ExpenseCommentsTableCreateCompanionBuilder,
          $$ExpenseCommentsTableUpdateCompanionBuilder,
          (ExpenseComment, $$ExpenseCommentsTableReferences),
          ExpenseComment,
          PrefetchHooks Function({bool expenseId, bool tripId})
        > {
  $$ExpenseCommentsTableTableManager(
    _$AppDatabase db,
    $ExpenseCommentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseCommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseCommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseCommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> expenseId = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String?> authorTravelerId = const Value.absent(),
                Value<String> authorName = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> isDispute = const Value.absent(),
                Value<bool> isResolved = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCommentsCompanion(
                id: id,
                expenseId: expenseId,
                tripId: tripId,
                authorTravelerId: authorTravelerId,
                authorName: authorName,
                body: body,
                isDispute: isDispute,
                isResolved: isResolved,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String expenseId,
                required String tripId,
                Value<String?> authorTravelerId = const Value.absent(),
                required String authorName,
                required String body,
                Value<bool> isDispute = const Value.absent(),
                Value<bool> isResolved = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCommentsCompanion.insert(
                id: id,
                expenseId: expenseId,
                tripId: tripId,
                authorTravelerId: authorTravelerId,
                authorName: authorName,
                body: body,
                isDispute: isDispute,
                isResolved: isResolved,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpenseCommentsTable, ExpenseComment>(table),
                  $$ExpenseCommentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expenseId = false, tripId = false}) {
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
                        referencedTable: $$ExpenseCommentsTableReferences
                            ._expenseIdTable(db),
                        referencedColumn: $$ExpenseCommentsTableReferences
                            ._expenseIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tripId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tripId,
                        referencedTable: $$ExpenseCommentsTableReferences
                            ._tripIdTable(db),
                        referencedColumn: $$ExpenseCommentsTableReferences
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

typedef $$ExpenseCommentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseCommentsTable,
      ExpenseComment,
      $$ExpenseCommentsTableFilterComposer,
      $$ExpenseCommentsTableOrderingComposer,
      $$ExpenseCommentsTableAnnotationComposer,
      $$ExpenseCommentsTableCreateCompanionBuilder,
      $$ExpenseCommentsTableUpdateCompanionBuilder,
      (ExpenseComment, $$ExpenseCommentsTableReferences),
      ExpenseComment,
      PrefetchHooks Function({bool expenseId, bool tripId})
    >;
typedef $$TripPhotosTableCreateCompanionBuilder = TripPhotosCompanion Function({
  required String id,
  required String tripId,
  required String imagePath,
  Value<String?> caption,
  Value<int> dayNumber,
  Value<String?> uploadedByTravelerId,
  Value<String> uploadedByName,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TripPhotosTableUpdateCompanionBuilder = TripPhotosCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String> imagePath,
  Value<String?> caption,
  Value<int> dayNumber,
  Value<String?> uploadedByTravelerId,
  Value<String> uploadedByName,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TripPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $TripPhotosTable, TripPhoto> {
  $$TripPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('trip_photos__trip_id__trips__id');

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

class $$TripPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $TripPhotosTable> {
  $$TripPhotosTableFilterComposer({
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

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadedByTravelerId => $composableBuilder(
    column: $table.uploadedByTravelerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadedByName => $composableBuilder(
    column: $table.uploadedByName,
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
}

class $$TripPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $TripPhotosTable> {
  $$TripPhotosTableOrderingComposer({
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

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadedByTravelerId => $composableBuilder(
    column: $table.uploadedByTravelerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadedByName => $composableBuilder(
    column: $table.uploadedByName,
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
}

class $$TripPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripPhotosTable> {
  $$TripPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<int> get dayNumber =>
      $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumn<String> get uploadedByTravelerId => $composableBuilder(
    column: $table.uploadedByTravelerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uploadedByName => $composableBuilder(
    column: $table.uploadedByName,
    builder: (column) => column,
  );

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
}

class $$TripPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripPhotosTable,
          TripPhoto,
          $$TripPhotosTableFilterComposer,
          $$TripPhotosTableOrderingComposer,
          $$TripPhotosTableAnnotationComposer,
          $$TripPhotosTableCreateCompanionBuilder,
          $$TripPhotosTableUpdateCompanionBuilder,
          (TripPhoto, $$TripPhotosTableReferences),
          TripPhoto,
          PrefetchHooks Function({bool tripId})
        > {
  $$TripPhotosTableTableManager(_$AppDatabase db, $TripPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<int> dayNumber = const Value.absent(),
                Value<String?> uploadedByTravelerId = const Value.absent(),
                Value<String> uploadedByName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripPhotosCompanion(
                id: id,
                tripId: tripId,
                imagePath: imagePath,
                caption: caption,
                dayNumber: dayNumber,
                uploadedByTravelerId: uploadedByTravelerId,
                uploadedByName: uploadedByName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String imagePath,
                Value<String?> caption = const Value.absent(),
                Value<int> dayNumber = const Value.absent(),
                Value<String?> uploadedByTravelerId = const Value.absent(),
                Value<String> uploadedByName = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TripPhotosCompanion.insert(
                id: id,
                tripId: tripId,
                imagePath: imagePath,
                caption: caption,
                dayNumber: dayNumber,
                uploadedByTravelerId: uploadedByTravelerId,
                uploadedByName: uploadedByName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TripPhotosTable, TripPhoto>(table),
                  $$TripPhotosTableReferences(db, table, e),
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
                        referencedTable: $$TripPhotosTableReferences
                            ._tripIdTable(db),
                        referencedColumn: $$TripPhotosTableReferences
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

typedef $$TripPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripPhotosTable,
      TripPhoto,
      $$TripPhotosTableFilterComposer,
      $$TripPhotosTableOrderingComposer,
      $$TripPhotosTableAnnotationComposer,
      $$TripPhotosTableCreateCompanionBuilder,
      $$TripPhotosTableUpdateCompanionBuilder,
      (TripPhoto, $$TripPhotosTableReferences),
      TripPhoto,
      PrefetchHooks Function({bool tripId})
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
  $$ItineraryItemsTableTableManager get itineraryItems =>
      $$ItineraryItemsTableTableManager(_db, _db.itineraryItems);
  $$ExpenseCommentsTableTableManager get expenseComments =>
      $$ExpenseCommentsTableTableManager(_db, _db.expenseComments);
  $$TripPhotosTableTableManager get tripPhotos =>
      $$TripPhotosTableTableManager(_db, _db.tripPhotos);
}
