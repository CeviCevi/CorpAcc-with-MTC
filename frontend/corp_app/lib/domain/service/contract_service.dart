import 'package:corp_app/data/model/contract_model.dart';
import 'package:corp_app/domain/service/web_service.dart';

class ContractService {
  static WebService _ws = WebService();

  //! For All
  static Future<ContractModel> getById({required String audioId}) async {
    //* Contract
    return ContractModel.empty;
  }

  static Future<bool> deleteById({required String audioId}) async {
    //* http 200
    return true;
  }

  static Future<bool> updateMeta({required ContractModel audio}) async {
    //* http 200
    return true;
  }

  static Future<bool> updateById({
    required String audioId,
    required String pathToNewAudio,
  }) async {
    //* http 200
    return true;
  }

  static Future<ContractModel> download({required ContractModel audio}) async {
    //* Contract
    return ContractModel.empty;
  }

  static Future<ContractModel> upload({required ContractModel audio}) async {
    //* Contract
    return ContractModel.empty;
  }

  static Future<List<ContractModel>> getAllByUserId({
    required ContractModel audio,
  }) async {
    //* Contract List
    return [];
  }

  static Future<List<ContractModel>> getAllByCorpId({
    required ContractModel audio,
  }) async {
    //* Contract List
    return [];
  }
}
