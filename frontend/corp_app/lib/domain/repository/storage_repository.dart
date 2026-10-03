// lib/data/storage/database_service.dart
import 'dart:io';

import 'package:corp_app/data/model/audio_model.dart';
import 'package:corp_app/data/model/contract_model.dart';
import 'package:corp_app/data/model/transcription_model.dart';
import 'package:corp_app/data/model/user_model.dart';
import 'package:corp_app/data/storage/database/database.dart';
import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageRepository {
  StorageRepository._();
  static final StorageRepository instance = StorageRepository._();

  Database? _db;
  Database get db {
    final value = _db;
    if (value == null) {
      throw StateError('DatabaseService not initialized. Call init() first.');
    }
    return value;
  }

  bool get isOpen => _db != null;

  Future<void> init() async {
    if (_db != null) return;
    final file = await _resolveFile();
    _db = Database(NativeDatabase(file));
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<File> _resolveFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'corp_app'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return File(p.join(folder.path, 'corp_app.db'));
  }

  // -------------------- USER --------------------

  Future<List<UserModel>> getUsers() => db.select(db.users).get();

  Stream<List<UserModel>> watchUsers() => db.select(db.users).watch();

  Future<UserModel?> getUserById(String id) async {
    return (db.select(
      db.users,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<UserModel?> getUserByLogin(String login) async {
    return (db.select(
      db.users,
    )..where((t) => t.login.equals(login))).getSingleOrNull();
  }

  Future<void> upsertUser(UserModel user) =>
      db.into(db.users).insertOnConflictUpdate(user.toInsertable());

  Future<void> deleteUser(String id) =>
      (db.delete(db.users)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllUsers() => db.delete(db.users).go();

  // -------------------- AUDIO --------------------

  Future<List<AudioModel>> getAudios() => db.select(db.audios).get();

  Stream<List<AudioModel>> watchAudios() => db.select(db.audios).watch();

  Future<AudioModel?> getAudioById(String id) async {
    return (db.select(
      db.audios,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<AudioModel>> getAudiosByCreator(String creatorId) {
    return (db.select(
      db.audios,
    )..where((t) => t.creatorId.equals(creatorId))).get();
  }

  Future<void> upsertAudio(AudioModel audio) =>
      db.into(db.audios).insertOnConflictUpdate(audio.toInsertable());

  Future<void> deleteAudio(String id) =>
      (db.delete(db.audios)..where((t) => t.id.equals(id))).go();

  // -------------------- CONTRACT --------------------

  Future<List<ContractModel>> getContracts() => db.select(db.contracts).get();

  Stream<List<ContractModel>> watchContracts() =>
      db.select(db.contracts).watch();

  Future<ContractModel?> getContractById(String id) async {
    return (db.select(
      db.contracts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<ContractModel>> getContractsByCreator(String creatorId) {
    return (db.select(
      db.contracts,
    )..where((t) => t.creatorId.equals(creatorId))).get();
  }

  Future<void> upsertContract(ContractModel contract) =>
      db.into(db.contracts).insertOnConflictUpdate(contract.toInsertable());

  Future<void> deleteContract(String id) =>
      (db.delete(db.contracts)..where((t) => t.id.equals(id))).go();

  // -------------------- TRANSCRIPTION --------------------

  Future<List<TranscriptionModel>> getTranscriptions() =>
      db.select(db.transcriptions).get();

  Stream<List<TranscriptionModel>> watchTranscriptions() =>
      db.select(db.transcriptions).watch();

  Future<TranscriptionModel?> getTranscriptionById(String id) async {
    return (db.select(
      db.transcriptions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<TranscriptionModel>> getTranscriptionsByCreator(
    String creatorId,
  ) {
    return (db.select(
      db.transcriptions,
    )..where((t) => t.creatorId.equals(creatorId))).get();
  }

  Future<void> upsertTranscription(TranscriptionModel item) =>
      db.into(db.transcriptions).insertOnConflictUpdate(item.toInsertable());

  Future<void> deleteTranscription(String id) =>
      (db.delete(db.transcriptions)..where((t) => t.id.equals(id))).go();

  // -------------------- Общее --------------------

  Future<void> clearAll() async {
    await db.transaction(() async {
      await db.delete(db.transcriptions).go();
      await db.delete(db.contracts).go();
      await db.delete(db.audios).go();
      await db.delete(db.users).go();
    });
  }

  Future<void> runInTransaction(Future<void> Function() action) {
    return db.transaction(action);
  }
}
