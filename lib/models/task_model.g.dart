// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskPlanAdapter extends TypeAdapter<TaskPlan> {
  @override
  final int typeId = 0;

  @override
  TaskPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskPlan(
      id: fields[0] as String,
      title: fields[1] as String,
      subtasks: (fields[2] as List).cast<SubTask>(),
      createdAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskPlan obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtasks)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubTaskAdapter extends TypeAdapter<SubTask> {
  @override
  final int typeId = 1;

  @override
  SubTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubTask(
      title: fields[0] as String,
      priority: fields[1] as String,
      steps: (fields[2] as List).cast<String>(),
      completed: fields[3] as bool,
      timeTaken: fields[4] as Duration,
      breakTaken: fields[5] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, SubTask obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.priority)
      ..writeByte(2)
      ..write(obj.steps)
      ..writeByte(3)
      ..write(obj.completed)
      ..writeByte(4)
      ..write(obj.timeTaken)
      ..writeByte(5)
      ..write(obj.breakTaken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
