import 'package:corp_app/data/model/transcription_model.dart';
import 'package:drift/drift.dart';

@UseRowClass(TranscriptionModel, generateInsertable: true)
class Transcriptions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get creatorId => text()();
  TextColumn get link => text()();
  TextColumn get createAt => text()();
  TextColumn get description => text()();

  @override
  Set<Column> get primaryKey => {id};
}
