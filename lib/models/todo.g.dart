// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 1;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      title: fields[0] as String,
      isCompleted: fields[1] as bool,
      createdAt: fields[2] as DateTime,
      details: fields[3] as String?,
      category: fields[4] as String?,
      priority: fields[5] as String?,
      imagePath: fields[6] as String?,
      notificationId: fields[7] as int?,
      repeatFrequency: fields[8] as String?,
      repeatEndDate: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.details)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.imagePath)
      ..writeByte(7)
      ..write(obj.notificationId)
      ..writeByte(8)
      ..write(obj.repeatFrequency)
      ..writeByte(9)
      ..write(obj.repeatEndDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
