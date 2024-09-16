import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContactFormModal extends StatefulWidget {
  final String propertyId;

  const ContactFormModal({super.key, required this.propertyId});

  @override
  _ContactFormModalState createState() => _ContactFormModalState();
}

class _ContactFormModalState extends State<ContactFormModal> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phone = '';
  String _message = '';

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      print('Nombre ingresado: $_name'); // Log para depuración

      final formData = {
        'propertyId': widget.propertyId,
        'name': _name,
        'email': _email,
        'phone': _phone,
        'message': _message,
      };

      try {
        final response = await http.post(
          Uri.parse(
              'https://conexion-agraria-default-rtdb.firebaseio.com/Api/Contac.json'),
          body: json.encode(formData),
        );

        if (response.statusCode == 200) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulario enviado exitosamente')),
          );

          // Cerrar el modal después de enviar
          Navigator.of(context).pop();
        } else {
          // Manejar errores si el estado no es 200
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al enviar el formulario')),
          );
        }
      } catch (error) {
        // Manejar errores de conexión
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de conexión')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Esquinas menos redondeadas
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, // Ancho personalizado
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Contáctenos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    onSaved: (value) => _name = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su nombre';
                      }
                      // Expresión regular mejorada para permitir más flexibilidad en nombres compuestos
                      if (!RegExp(r'^[a-zA-ZÀ-ÿ]+(?: [a-zA-ZÀ-ÿ]+)+$')
                          .hasMatch(value)) {
                        return 'Por favor ingrese un nombre y un apellido válidos';
                      }

                      if (value.length < 2 || value.length > 50) {
                        return 'El nombre debe tener entre 2 y 50 caracteres';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Correo electrónico'),
                    onSaved: (value) => _email = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su correo electrónico';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor ingrese un correo electrónico válido';
                      }
                      if (value.length < 5 || value.length > 50) {
                        return 'El correo debe tener entre 5 y 50 caracteres';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    keyboardType: TextInputType.phone,
                    onSaved: (value) => _phone = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su número de teléfono';
                      }
                      if (!RegExp(r'^\d{7,15}$').hasMatch(value)) {
                        return 'El teléfono debe tener entre 7 y 15 dígitos';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Mensaje'),
                    maxLines: 5,
                    onSaved: (value) => _message = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su mensaje';
                      }
                      if (value.length < 10 || value.length > 500) {
                        return 'El mensaje debe tener entre 10 y 500 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
