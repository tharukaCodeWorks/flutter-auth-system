class ForgotPassword {
  String timestamp;
  String statusCode;
  String statusMessage;
  ResponseBody responseBody;

  ForgotPassword(
      {this.timestamp, this.statusCode, this.statusMessage, this.responseBody});

  ForgotPassword.fromJson(Map<String, dynamic> json) {
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
  String userName;
  String referenceId;
  String requestedTime;
  int validity;

  ResponseBody(
      {this.userName, this.referenceId, this.requestedTime, this.validity});

  ResponseBody.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    referenceId = json['referenceId'];
    requestedTime = json['requestedTime'];
    validity = json['validity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['referenceId'] = this.referenceId;
    data['requestedTime'] = this.requestedTime;
    data['validity'] = this.validity;
    return data;
  }
}
