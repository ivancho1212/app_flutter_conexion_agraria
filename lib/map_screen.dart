import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Para Google Maps
import 'package:location/location.dart'; // Para manejar la ubicación del usuario
import 'dart:convert'; // Para decodificar JSON
import 'package:http/http.dart' as http; // Para realizar solicitudes HTTP
import 'package:permission_handler/permission_handler.dart'
    as perm_handler; // Para manejar permisos
import 'package:page_view_indicators/circle_page_indicator.dart'; // Para los indicadores de página en el slider de imágenes
import 'property_details.dart'; // Importa la nueva pantalla

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
  bool _isLoading = true;
  final List<Map<String, dynamic>> _properties = [];
  int currentPage = 1;
  LatLngBounds? _mapBounds;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _fetchProperties(LatLngBounds bounds) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://us-central1-conexion-agraria.cloudfunctions.net/getCombinedData?page=$currentPage&limit=6'),
        headers: {
          'x-secret-key': 'supersecreta123',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> propertiesData = json.decode(response.body);

        if (propertiesData.isNotEmpty) {
          setState(() {
            _properties.clear();
            for (var property in propertiesData) {
              _properties.add({
                "id": property['id'],
                "name": property['nombre'],
                "lat": property['latitud'],
                "lng": property['longitud'],
                "description": property['descripcion'],
                "price": property['precio_arriendo'],
                "measure": property['medida'],
                "address": property['direccion'],
                "image": property[
                    'imagenes'], // Asegúrate de incluir la URL de la imagen
                "climate": property[
                    'clima'], // Añade el dato del clima si está disponible
                "created_at": property['fecha_creacion'], // Fecha de creación
              });
            }
          });

          _addPropertyMarkers(bounds);
        }
      }
    } catch (e) {
      // Aquí eliminamos el manejo de errores
    }
  }

  void _addPropertyMarkers(LatLngBounds bounds) {
    _markers.clear(); // Limpia los marcadores anteriores
    for (var property in _properties) {
      LatLng propertyLocation = LatLng(property['lat'], property['lng']);
      if (bounds.contains(propertyLocation)) {
        // Solo muestra los predios dentro del área visible del mapa
        _markers.add(
          Marker(
            markerId: MarkerId(property['id']),
            position: propertyLocation,
            infoWindow: InfoWindow(
              title: property['name'],
              onTap: () {
                _onMarkerTapped(property); // Pasas el objeto completo
              },
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  Future<void> _getUserLocation() async {
    perm_handler.PermissionStatus permission =
        await perm_handler.Permission.locationWhenInUse.status;

    if (!permission.isGranted) {
      permission = await perm_handler.Permission.locationWhenInUse.request();
      if (!permission.isGranted) {
        return;
      }
    }

    LocationData locationData = await _location.getLocation();
    LatLng userLocation =
        LatLng(locationData.latitude!, locationData.longitude!);

    setState(() {
      _initialPosition = userLocation;
      _isLoading = false;
    });

    _markers.add(
      Marker(
        markerId: const MarkerId('userLocation'),
        position: _initialPosition,
        infoWindow: const InfoWindow(title: 'Tu ubicación'),
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_initialPosition, 10),
    );

    // Aquí verificamos que _mapBounds no sea null antes de llamar a _fetchProperties
    if (_mapBounds != null) {
      _fetchProperties(_mapBounds!);
    }
  }

void _onMarkerTapped(dynamic property) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    barrierColor: Colors.transparent, // Hace que la pantalla no se oscurezca
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25.0), // Bordes redondeados en la parte superior
      ),
    ),
    builder: (BuildContext context) {
      final List<String> imageUrls = property['image'] != null
          ? List<String>.from(property['image']
              .map((url) => url ?? 'lib/assets/default_image.png'))
          : ['lib/assets/default_image.png']; // Imagen por defecto si es null

      final _currentPageNotifier = ValueNotifier<int>(0);

      return GestureDetector(
        onTap: () {
          // Cierra el modal
          Navigator.pop(context);
          // Redirige a la pantalla PropertyDetails
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => PropertyDetails(property: property),
            ),
          );
        },
        child: FractionallySizedBox(
          heightFactor: 0.34, // Ajusta la altura del modal
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25.0), // Esquinas superiores redondeadas
                    ),
                    child: SizedBox(
                      height: 210, // Puedes ajustar la altura según lo necesario
                      width: double.infinity, // Ocupa todo el ancho
                      child: PageView.builder(
                        itemCount: imageUrls.length,
                        onPageChanged: (index) {
                          _currentPageNotifier.value = index;
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover, // Asegura que la imagen cubra todo
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'lib/assets/default_image.png',
                                fit: BoxFit.cover, // Imagen por defecto que cubre todo
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  property['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Eliminamos el espaciado aquí para que el precio quede más cerca del nombre
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${property['price']} / mes',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 165, 164, 164),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${property['measure']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 165, 164, 164),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/logo.png', height: 30),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 8,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;

                // Verificamos la región visible cuando el mapa está listo
                _mapController?.getVisibleRegion().then((LatLngBounds bounds) {
                  _mapBounds = bounds;
                  _fetchProperties(bounds);
                });
              },
              onCameraIdle: () async {
                LatLngBounds newBounds =
                    await _mapController!.getVisibleRegion();
                if (_mapBounds != newBounds) {
                  _mapBounds = newBounds;
                  _fetchProperties(newBounds);
                }
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
