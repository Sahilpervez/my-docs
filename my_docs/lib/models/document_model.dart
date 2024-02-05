// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class DocumentModel {
  final String title;
  final DateTime createdAt;
  final String uid;
  final List content;
  final String id;
  DocumentModel({
    this.title = '',
    required this.createdAt,
    this.uid = '',
    this.content = const [],
    this.id = '',
  });

  DocumentModel copyWith({
    String? title,
    DateTime? createdAt,
    String? uid,
    List? content,
    String? id,
  }) {
    return DocumentModel(
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      uid: uid ?? this.uid,
      content: content ?? this.content,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'uid': uid,
      'content': content,
      '_id': id,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      title: map['title'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      uid: map['uid'] as String,
      content: List.from(
        (map['content'] as List),
      ),
      id: map['_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentModel.fromJson(String source) =>
      DocumentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Document(title: $title, createdAt: $createdAt, uid: $uid, content: $content, id: $id)';
  }

  @override
  bool operator ==(covariant DocumentModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.createdAt == createdAt &&
        other.uid == uid &&
        listEquals(other.content, content) &&
        other.id == id;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        createdAt.hashCode ^
        uid.hashCode ^
        content.hashCode ^
        id.hashCode;
  }
}
