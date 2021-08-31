const String SERVER_URL =
    'https://dunamis-backend-service-stg.herokuapp.com/dunamis-backend-service/api/v1';
const String API_CLIENT_TOKEN = '88738dcd-ccfb-4dc5-b5f6-f7eaca6adbbf';
const String CLIENT_ID = 'dunamis-mobile-app';

const String LOGIN = SERVER_URL + "/auth";
const String REGISTER = SERVER_URL + "/users";
String forgotPasswordRequest(String name) {
  return SERVER_URL + "/auth/forget/password/" + name;
}

String validateForgotPasswordToken(String token, String refId) {
  return SERVER_URL +
      "/auth/password/rest-token/" +
      refId +
      "/validate/token/" +
      token;
}

const String RESET_PASSWORD = SERVER_URL + "/auth/reset/password";
