import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const GeolocationApp(),
    );
  }
}

class GeolocationApp extends StatefulWidget {
  const GeolocationApp({super.key});

  @override
  State<GeolocationApp> createState() => _GelLocationAppState();
}

class _GelLocationAppState extends State<GeolocationApp> {
  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;
  String _currentAddress = "";
  Future<Position> _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print("Service disabled!");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition();
  }

  _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentLocation!.latitude, _currentLocation!.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = "${place.locality},${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  enviarDadosParaServidor(String latitude, String longitude) async {
    var url = 'http://192.168.0.107/receber_dados.php';

    var body = json.encode({
      'latitude': latitude,
      'longitude': longitude,
    });

    var response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 200) {
      // Dados enviados com sucesso
      print('Dados enviados com sucesso!');
    } else {
      // Ocorreu um erro ao enviar os dados
      print(
          'Erro ao enviar os dados. Código de status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pegar localização do usuário"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Coordinates",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
                "Latitude = ${_currentLocation?.latitude};${_currentLocation?.longitude}"),
            const SizedBox(
              height: 30.0,
            ),
            const Text(
              "Localização",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("${_currentAddress}"),
            const SizedBox(
              height: 50.0,
            ),
            ElevatedButton(
                onPressed: () async {
                  _currentLocation = await _getCurrentLocation();
                  print("$_currentLocation");
                  await _getAddressFromCoordinates();
                  await enviarDadosParaServidor("30.0", "80.0");
                  print("$_currentAddress");
                  print("Testando o botão");
                },
                child: const Text("Pegue a localização"))
          ],
        ),
      ),
    );
  }
}
