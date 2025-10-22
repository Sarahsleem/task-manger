class Weather {
  final String cityName;
  final String country;
  final double temperature;
  final String condition;
  final String description;
  final int humidity; // This should be int
  final double windSpeed; // This should be double
  final double feelsLike;
  final double uvIndex; // This should be double

  Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.uvIndex,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['location']['name'],
      country: json['location']['country'],
      temperature: json['current']['temp_c'] is int
          ? (json['current']['temp_c'] as int).toDouble()
          : json['current']['temp_c'].toDouble(),
      condition: json['current']['condition']['text'],
      description: json['current']['condition']['text'],
      humidity: json['current']['humidity'] is double
          ? (json['current']['humidity'] as double).round()
          : json['current']['humidity'],
      windSpeed: json['current']['wind_kph'] is int
          ? (json['current']['wind_kph'] as int).toDouble()
          : json['current']['wind_kph'].toDouble(),
      feelsLike: json['current']['feelslike_c'] is int
          ? (json['current']['feelslike_c'] as int).toDouble()
          : json['current']['feelslike_c'].toDouble(),
      uvIndex: json['current']['uv'] is int
          ? (json['current']['uv'] as int).toDouble()
          : json['current']['uv'].toDouble(),
    );
  }
}