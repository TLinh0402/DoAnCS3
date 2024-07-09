class Event {
  String id;
  String title;
  DateTime date;

  Event(this.id, this.title, this.date);

  factory Event.fromMap(Map<String, dynamic> data) {
    return Event(
      data['id'] ?? '', // Tránh lỗi nếu không có id
      data['title'] ?? '', // Tránh lỗi nếu không có title
      data['date'] != null
          ? DateTime.parse(data['date'])
          : DateTime.now(), // Tránh lỗi nếu không có date
    );
  }
}
