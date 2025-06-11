import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weatherapp/model/weathermodel.dart';

class WeatherService {
  // final String apiKey = "5281de92950ab4608ddad6d0ad6014e7";

  Future<WeatherData?> fetchWeather({
    required double lat,
    required double lon,
  }) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=5281de92950ab4608ddad6d0ad6014e7",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return WeatherData.fromJson(json);
      } else {
        throw Exception("Error in API call: ${response.statusCode}");
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
