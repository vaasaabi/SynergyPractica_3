/// Модель заметки. Поля соответствуют кейс-задаче №4:
/// заголовок, дата, время, содержание.
class Note {
  final int? id;
  String title;
  String date; // формат yyyy-MM-dd
  String time; // формат HH:mm
  String content;
  int updatedAt; // millisSinceEpoch — для сортировки списка

  Note({
    this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.content,
    int? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'date': date,
        'time': time,
        'content': content,
        'updatedAt': updatedAt,
      };

  factory Note.fromMap(Map<String, dynamic> m) => Note(
        id: m['id'] as int?,
        title: (m['title'] ?? '') as String,
        date: (m['date'] ?? '') as String,
        time: (m['time'] ?? '') as String,
        content: (m['content'] ?? '') as String,
        updatedAt: (m['updatedAt'] ?? 0) as int,
      );

  Note copyWith({
    int? id,
    String? title,
    String? date,
    String? time,
    String? content,
    int? updatedAt,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        time: time ?? this.time,
        content: content ?? this.content,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
