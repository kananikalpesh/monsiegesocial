class User {
  int userId;
  String userFirstname;
  String userLastname;
  String userEmail;
  String userToken;

  User(
      {required this.userId,
      required this.userFirstname,
      required this.userLastname,
      required this.userEmail,
      required this.userToken});

  int get getId {
    return userId;
  }

  set setId(int id) {
    userId = id;
  }

  String get getfirstname {
    return userFirstname;
  }

  set setfirstname(String userFirstname) {
    this.userFirstname = userFirstname;
  }

  String get getlastname {
    return userLastname;
  }

  set setlastname(String userLastname) {
    this.userLastname = userLastname;
  }

  String get getemail {
    return userEmail;
  }

  set setemail(String userEmail) {
    this.userEmail = userEmail;
  }

  String get getToken {
    return userToken;
  }

  set setToken(String token) {
    userToken = token;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "userId": userId,
      "userFirstname": userFirstname,
      "userLastname": userLastname,
      "userEmail": userEmail,
      "userToken": userToken,
    };
    return map;
  }
}
