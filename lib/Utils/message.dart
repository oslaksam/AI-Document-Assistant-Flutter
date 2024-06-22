class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});

  // Helper methods to convert between Message objects and Map<String, dynamic>
  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
    );
  }
}
