import 'package:corp_app/data/model/user_model.dart';
import 'package:drift/drift.dart';

@UseRowClass(UserModel, generateInsertable: true)
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get login => text()();
  TextColumn get email => text()();
  TextColumn get password => text()();
  TextColumn get image => text()();
  TextColumn get role => text().withDefault(const Constant('moderation'))();
  TextColumn get createAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
