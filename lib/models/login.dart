class Login {
  int id;
  String emailAddress;
  String password;

  Login({required this.id, required this.emailAddress, required this.password});

  String get getEmailAdress {
    return emailAddress;
  }

  set setEmailAdress(String emailAddress) {
    this.emailAddress = emailAddress;
  }

  String get getPassword {
    return password;
  }

  set setPassword(String password) {
    this.password = password;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "id": id,
      "emailAddress": emailAddress,
      "password": password
    };
    return map;
  }

  fromMap(Map<String, dynamic> map) {
    id = map['id'];
    emailAddress = map['emailAddress'];
    password = map['password'];
  }
}
