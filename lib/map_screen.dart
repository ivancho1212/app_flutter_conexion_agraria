import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(0, 0);
  final Location _location = Location();
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    LocationData locationData;
    try {
      locationData = await _location.getLocation();
      setState(() {
        _initialPosition =
            LatLng(locationData.latitude!, locationData.longitude!);
      });

      // Agregar marcador para la ubicación del usuario
      _markers.add(
        Marker(
          markerId: const MarkerId('userLocation'),
          position: _initialPosition,
          infoWindow: const InfoWindow(title: 'Tu ubicación'),
        ),
      );

      // Aquí puedes agregar los marcadores para las propiedades cercanas
      // _addPropertyMarkers();
    } catch (e) {
      print('Error obteniendo la ubicación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 14,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
