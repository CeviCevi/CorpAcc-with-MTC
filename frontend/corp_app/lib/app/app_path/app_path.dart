class AppPath {
  static String apiPath =
      "https://64wh7x1w-8080.euw.devtunnels.ms"; //TODO get address

  // ─── users ───
  static String registration = "$apiPath/api/users/registration";
  static String login = "$apiPath/api/users/entrance";
  static String destroyMyAcc = "$apiPath/api/users/destroy";
  static String updateMyAcc = "$apiPath/api/users";
  static String getUserById = "$apiPath/api/users";
  static String getUserByEmail = "$apiPath/api/users/email";
  static String setUserInCorpByEmail = "$apiPath/api/users/addToCorp";
  static String getAllUsersInCorp = "$apiPath/api/users/allUsers";
  static String deleteUserInCorpById = "$apiPath/api/users/delete";

  // ─── transcriptions ───
  static String transcriptionGetById = "$apiPath/api/transcriptions";
  static String transcriptionDestroyById = "$apiPath/api/transcriptions";
  static String transcriptionUpdateMeta = "$apiPath/api/transcriptions";
  static String transcriptionDownload = "$apiPath/api/transcriptions/get";
  static String transcriptionUpload = "$apiPath/api/transcriptions/save";
  static String transcriptionGetAllByUserId =
      "$apiPath/api/transcriptions/user";
  static String transcriptionGetAllByCorpId =
      "$apiPath/api/transcriptions/corp";

  // ─── contracts ───
  static String contractGetById = "$apiPath/api/contracts";
  static String contractDestroyById = "$apiPath/api/contracts";
  static String contractUpdateMeta = "$apiPath/api/contracts/";
  static String contractDownload = "$apiPath/api/contracts/get";
  static String contractUpload = "$apiPath/api/contracts/save";
  static String contractGetAllByUserId = "$apiPath/api/contracts/user";
  static String contractGetAllByCorpId = "$apiPath/api/contracts/corp";

  // ─── audios ───
  static String audioGetById = "$apiPath/api/audios";
  static String audioDestroyById = "$apiPath/api/audios";
  static String audioUpdateMeta = "$apiPath/api/audios";
  static String audioDownload = "$apiPath/api/audios/get";
  static String audioUpload = "$apiPath/api/audios/save";
  static String audioGetAllByUserId = "$apiPath/api/audios/user";
  static String audioGetAllByCorpId = "$apiPath/api/audios/corp";
  static String createAudio = "$apiPath/api/audios";
}
