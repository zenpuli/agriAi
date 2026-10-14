class WeatherModel {
final double temp;
final int humidity;
final String description;


WeatherModel({required this.temp, required this.humidity, required this.description});


factory WeatherModel.fromJson(Map<String, dynamic> json) {
final main = json['main'] ?? {};
final weather = (json['weather'] as List).isNotEmpty ? json['weather'][0] : null;
return WeatherModel(
temp: (main['temp']?.toDouble() ?? 0.0),
humidity: (main['humidity']?.toInt() ?? 0),
description: weather != null ? weather['description'] ?? '' : '',
);
}
}