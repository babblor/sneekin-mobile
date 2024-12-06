import 'package:hive/hive.dart';

part 'app.g.dart'; // For the Hive-generated file

@HiveType(typeId: 2)
class App {
  @HiveField(0)
  final String? accessToken;

  App({
    this.accessToken,
  });

  // Custom fromJson method

  factory App.fromJson(Map<String, dynamic> json) {
    return App(
      accessToken: json['accessToken'] as String?,
    );
  }

  // Custom toJson method

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
    };
  }
}
