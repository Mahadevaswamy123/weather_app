// ... imports
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp/Service/service.dart';
import 'package:weatherapp/model/weathermodel.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  late WeatherData weatherInfo;
  bool isLoading = false;

  String? selectedState;
  String? selectedCity;
  Map<String, dynamic> indiaStatesCitiesCoords = {};

  List<String> get states => indiaStatesCitiesCoords.keys.toList();

  List<String> get cities {
    if (selectedState == null) return [];
    final citiesMap =
        indiaStatesCitiesCoords[selectedState!] as Map<String, dynamic>?;
    if (citiesMap == null) return [];
    return citiesMap.keys.toList();
  }

  @override
  void initState() {
    super.initState();
    weatherInfo = WeatherData(
      name: '',
      temperature: Temperature(current: 0.0),
      humidity: 0,
      wind: Wind(speed: 0.0),
      maxTemperature: 0,
      minTemperature: 0,
      pressure: 0,
      seaLevel: 0,
      weather: [],
    );
    loadCityStateData();
  }

  Future<void> loadCityStateData() async {
    final jsonString = await rootBundle.loadString(
      'assets/india_states_cities_coordss.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    setState(() {
      isLoading = true;
      indiaStatesCitiesCoords = jsonData;
      selectedState = states.isNotEmpty ? states.first : null;
      selectedCity = cities.isNotEmpty ? cities.first : null;
    });

    if (selectedCity != null) {
      fetchWeatherForSelectedCity();
    }
  }

  void fetchWeatherForSelectedCity() async {
    if (selectedState == null || selectedCity == null) return;

    setState(() => isLoading = true);

    final coordsMap =
        indiaStatesCitiesCoords[selectedState!]![selectedCity!]!
            as Map<String, dynamic>;
    final lat = (coordsMap['lat'] as num).toDouble();
    final lon = (coordsMap['lon'] as num).toDouble();

    WeatherData? data = await WeatherService().fetchWeather(lat: lat, lon: lon);

    if (data != null) {
      setState(() {
        weatherInfo = data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
      'EEEE d, MMMM yyyy',
    ).format(DateTime.now());
    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFF676BD0),
      appBar: AppBar(
        title: const Center(child: Text("Weather App")),
        backgroundColor: Colors.deepPurple[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child:
            indiaStatesCitiesCoords.isEmpty
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedState,
                        dropdownColor: Colors.deepPurple,
                        decoration: _dropdownDecoration('Select State'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        iconEnabledColor: Colors.white,
                        items:
                            states
                                .map(
                                  (state) => DropdownMenuItem(
                                    value: state,
                                    child: Text(state),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedState = value;
                            selectedCity =
                                indiaStatesCitiesCoords[selectedState!]!
                                    .keys
                                    .first;
                            fetchWeatherForSelectedCity();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        value: selectedCity,
                        dropdownColor: Colors.deepPurple,
                        decoration: _dropdownDecoration('Select City'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        iconEnabledColor: Colors.white,
                        items:
                            cities
                                .map(
                                  (city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(city),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCity = value;
                            fetchWeatherForSelectedCity();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Flexible(
                      child:
                          isLoading
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                              : SingleChildScrollView(
                                child: WeatherDetail(
                                  weather: weatherInfo,
                                  formattedDate: formattedDate,
                                  formattedTime: formattedTime,
                                ),
                              ),
                    ),
                  ],
                ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.deepPurple.shade400,
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white70),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    );
  }
}

// The WeatherDetail widget remains unchanged, copy as you have it.

class WeatherDetail extends StatelessWidget {
  final WeatherData weather;
  final String formattedDate;
  final String formattedTime;
  const WeatherDetail({
    super.key,
    required this.weather,
    required this.formattedDate,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          weather.name,
          style: const TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${weather.temperature.current.toStringAsFixed(2)}°C",
          style: const TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (weather.weather.isNotEmpty)
          Text(
            weather.weather[0].main,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 30),
        Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          formattedTime,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        // Container(
        //   height: 150,
        //   width: 100,
        //   alignment: Alignment.center,
        //   child: Icon(Icons.cloud, size: 100, color: Colors.blue),
        // ),
        const SizedBox(height: 30),
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wind_power, color: Colors.white),
                        const SizedBox(height: 5),
                        weatherInfoCard(
                          title: "Wind",
                          value: "${weather.wind.speed} km/h",
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sunny, color: Colors.white),
                        const SizedBox(height: 5),
                        weatherInfoCard(
                          title: "Max",
                          value:
                              "${weather.maxTemperature.toStringAsFixed(2)}°C",
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.ac_unit, color: Colors.white),
                        const SizedBox(height: 5),
                        weatherInfoCard(
                          title: "Min",
                          value:
                              "${weather.minTemperature.toStringAsFixed(2)}°C",
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.water_drop, color: Colors.amber),
                        const SizedBox(height: 5),
                        weatherInfoCard(
                          title: "Humidity",
                          value: "${weather.humidity}%",
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.speed, color: Colors.amber),
                        const SizedBox(height: 5),
                        weatherInfoCard(
                          title: "Pressure",
                          value: "${weather.pressure} hPa",
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.leaderboard, color: Colors.amber),
                        const SizedBox(height: 5),
                        weatherInfoCard(
                          title: "Sea-Level",
                          value: "${weather.seaLevel} m",
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column weatherInfoCard({required String title, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
