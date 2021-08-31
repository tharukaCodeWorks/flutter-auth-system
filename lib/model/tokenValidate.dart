class TokenValidate {
  String timestamp;
  String statusCode;
  String statusMessage;
  ResponseBody responseBody;

  TokenValidate(
      {this.timestamp, this.statusCode, this.statusMessage, this.responseBody});

  TokenValidate.fromJson(Map<String, dynamic> json) {
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
  bool validity;
  String referenceId;

  ResponseBody({this.validity, this.referenceId});

  ResponseBody.fromJson(Map<String, dynamic> json) {
    validity = json['validity'];
    referenceId = json['referenceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['validity'] = this.validity;
    data['referenceId'] = this.referenceId;
    return data;
  }
}
