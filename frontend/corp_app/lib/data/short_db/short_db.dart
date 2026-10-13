import 'package:corp_app/data/model/audio_model.dart';
import 'package:corp_app/data/model/contract_model.dart';
import 'package:corp_app/data/model/transcription_model.dart';
import 'package:corp_app/data/model/user_model.dart';

class ShortDb {
  ShortDb._();
  static final ShortDb instance = ShortDb._();

  UserModel userInSystem = UserModel.empty; //TODO
  List<UserModel> userDB = [];
  List<ContractModel> contractDB = [];
  List<AudioModel> audioDB = [];
  List<TranscriptionModel> transcriptionDB = [];
}
