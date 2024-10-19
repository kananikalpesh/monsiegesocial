class Ticket {
  int idTicket;
  String subject;
  String date;
  bool isSelected;

  Ticket(
      {required this.idTicket,
      required this.subject,
      required this.date,
      required this.isSelected});

  int get getIdticket {
    return idTicket;
  }

  set setIdticket(int idTicket) {
    this.idTicket = idTicket;
  }

  String get getSubject {
    return subject;
  }

  set setSubject(String subject) {
    this.subject = subject;
  }

  String get getDate {
    return date;
  }

  set getDate(String date) {
    this.date = date;
  }
}
