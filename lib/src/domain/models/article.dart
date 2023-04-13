import 'package:equatable/equatable.dart';

import 'source.dart';

class ArticleFields {
  static final List<String> values = [
    id,
    author,
    title,
    description,
    url,
    urlToImage,
    publishedAt,
    content
  ];

  static const String id = 'id';
  static const String author = 'author';
  static const String title = 'title';
  static const String description = 'description';
  static const String url = 'url';
  static const String urlToImage = 'urlToImage';
  static const String publishedAt = 'publishedAt';
  static const String content = 'content';
}

class Article extends Equatable {
  final int? id;
  final Source? source;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  const Article({
    this.id,
    this.source,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] != null ? map['id'] as int : null,
      source: map['source'] != null
          ? Source.fromMap(map['source'] as Map<String, dynamic>)
          : null,
      author: map['author'] != null ? map['author'] as String : null,
      title: map['title'] != null ? map['title'] as String : null,
      description:
      map['description'] != null ? map['description'] as String : null,
      url: map['url'] != null ? map['url'] as String : null,
      urlToImage:
      map['urlToImage'] != null ? map['urlToImage'] as String : null,
      publishedAt:
      map['publishedAt'] != null ? map['publishedAt'] as String : null,
      content: map['content'] != null ? map['content'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['author'] = author;
    data['title'] = title;
    data['description'] = description;
    data['url'] = url;
    data['urlToImage'] = urlToImage;
    data['publishedAt'] = publishedAt;
    data['content'] = content;
    return data;
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      id,
      source,
      author,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content,
    ];
  }
}