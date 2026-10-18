import 'package:corp_app/data/model/audio_model.dart';
import 'package:corp_app/data/model/contract_model.dart';
import 'package:corp_app/data/model/transcription_model.dart';
import 'package:corp_app/data/model/user_model.dart';
import 'package:corp_app/data/storage/storage_model/audio_storage.dart';
import 'package:corp_app/data/storage/storage_model/contract_storage.dart';
import 'package:corp_app/data/storage/storage_model/transcription_storage.dart';
import 'package:corp_app/data/storage/storage_model/user_storage.dart';
import 'package:drift/drift.dart';

part 'database.g.dart';

//! flutter pub run build_runner build -d

@DriftDatabase(tables: [Users, Audios, Contracts, Transcriptions])
class Database extends _$Database {
  Database(super.e);

  @override
  int get schemaVersion => 1;
}
