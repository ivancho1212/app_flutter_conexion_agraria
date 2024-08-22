import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'property_card.dart'; // Importa el archivo de la tarjeta de propiedad
import 'contact_form_modal.dart'; // Importa el archivo del formulario de contacto

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> properties = [];
  bool isLoading = true;
  bool isError = false;
  int _selectedIndex = 0; // Para manejar la selección del BottomNavigationBar

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://us-central1-conexion-agraria.cloudfunctions.net/getCombinedData'),
        headers: {
          'x-secret-key': 'supersecreta123', // Agrega tu clave secreta aquí
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          properties = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      // El índice 2 corresponde a "Contáctanos"
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ContactFormModal(propertyId: ''); // Pasar un propertyId vacío
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/logo.png', height: 30),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : isError
                ? Center(child: Text('Failed to load data.'))
                : ListView.builder(
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      return PropertyCard(property: properties[index]);
                    },
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Muestra el ítem seleccionado
        selectedIconTheme:
            IconThemeData(size: 20), // Tamaño de los íconos seleccionados
        unselectedIconTheme:
            IconThemeData(size: 20), // Tamaño de los íconos no seleccionados
        showSelectedLabels:
            true, // Muestra los textos de los íconos seleccionados
        showUnselectedLabels:
            true, // Muestra los textos de los íconos no seleccionados
        selectedItemColor:
            Colors.green, // Color cuando un ítem está seleccionado
        unselectedItemColor:
            Colors.grey, // Color cuando un ítem no está seleccionado
        onTap: _onItemTapped, // Maneja el tap en el BottomNavigationBar
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explora',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Contáctanos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
