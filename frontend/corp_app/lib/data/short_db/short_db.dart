import 'package:corp_app/data/model/audio_model.dart';
import 'package:corp_app/data/model/contract_model.dart';
import 'package:corp_app/data/model/transcription_model.dart';
import 'package:corp_app/data/model/user_model.dart';

class ShortDb {
  static UserModel userInSystem = UserModel.empty; //TODO
  static List<UserModel> userDB = [];
  static List<ContractModel> contractDB = [];
  static List<AudioModel> audioDB = [];
  static List<TranscriptionModel> transcriptionDB = [];
}
