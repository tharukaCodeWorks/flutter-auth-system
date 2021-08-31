class Login {
  String timestamp;
  String statusCode;
  String statusMessage;
  ResponseBody responseBody;

  Login(
      {this.timestamp, this.statusCode, this.statusMessage, this.responseBody});

  Login.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    statusCode = json['statusCode'];
    statusMessage = json['statusMessage'];
    responseBody = json['responseBody'] != null
        ? new ResponseBody.fromJson(json['responseBody'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    data['statusCode'] = this.statusCode;
    data['statusMessage'] = this.statusMessage;
    if (this.responseBody != null) {
      data['responseBody'] = this.responseBody.toJson();
    }
    return data;
  }
}

class ResponseBody {
  String accessToken;
  String expiresIn;
  String refreshExpiresIn;
  String refreshToken;
  String tokenType;
  String sessionState;

  ResponseBody(
      {this.accessToken,
      this.expiresIn,
      this.refreshExpiresIn,
      this.refreshToken,
      this.tokenType,
      this.sessionState});

  ResponseBody.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    expiresIn = json['expires_in'];
    refreshExpiresIn = json['refresh_expires_in'];
    refreshToken = json['refresh_token'];
    tokenType = json['token_type'];
    sessionState = json['session_state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['expires_in'] = this.expiresIn;
    data['refresh_expires_in'] = this.refreshExpiresIn;
    data['refresh_token'] = this.refreshToken;
    data['token_type'] = this.tokenType;
    data['session_state'] = this.sessionState;
    return data;
  }
}
