import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'property_details.dart'; // Importa la nueva pantalla

class PropertyCard extends StatefulWidget {
  final dynamic property;

  const PropertyCard({Key? key, required this.property}) : super(key: key);

  @override
  _PropertyCardState createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  final CarouselController _carouselController = CarouselController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls =
        List<String>.from(widget.property['imagenes']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetails(property: widget.property),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 0, // Elimina la sombra
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slider de imágenes
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.2, // Mantiene el aspecto cuadrado
                  child: Container(
                    height: 130.0, // Ajusta la altura de la imagen aquí
                    child: CarouselSlider(
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        height: double.infinity,
                        viewportFraction: 1.0,
                        autoPlay: false, // Desactiva el autoplay
                        enlargeCenterPage: false,
                        enableInfiniteScroll:
                            false, // Desactiva el scroll infinito
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                      items: imageUrls.map((url) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imageUrls.asMap().entries.map((entry) {
                      int index = entry.key;
                      return GestureDetector(
                        onTap: () => _carouselController.jumpToPage(index),
                        child: Container(
                          width: 8.0, // Aumenta el tamaño de los puntos
                          height: 8.0, // Aumenta el tamaño de los puntos
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == _currentIndex
                                ? Colors
                                    .white // Color blanco para el punto activo
                                : Colors.white.withOpacity(
                                    0.5), // Color blanco para los puntos inactivos
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            // Datos debajo de la imagen
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property['nombre'],
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 1), // Reduce el espacio aquí
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.property['departamento'].join(', ')}, ${widget.property['municipio']}',
                        style: TextStyle(fontSize: 12), // Tamaño reducido
                      ),
                      Text(
                        '${widget.property['precio_metro_cuadrado']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
