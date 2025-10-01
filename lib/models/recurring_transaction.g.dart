// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringTransactionAdapter extends TypeAdapter<RecurringTransaction> {
  @override
  final int typeId = 1;

  @override
  RecurringTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringTransaction(
      title: fields[0] as String,
      value: fields[1] as double,
      isExpense: fields[2] as bool,
      totalInstallments: fields[3] as int,
      currentInstallment: fields[4] as int,
      startDate: fields[5] as DateTime?,
      paymentDay: fields[6] as int?,
      nextOccurrenceDate: fields[7] as DateTime?,
      isActive: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringTransaction obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.isExpense)
      ..writeByte(3)
      ..write(obj.totalInstallments)
      ..writeByte(4)
      ..write(obj.currentInstallment)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.paymentDay)
      ..writeByte(7)
      ..write(obj.nextOccurrenceDate)
      ..writeByte(8)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
