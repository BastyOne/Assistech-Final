import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:assistech/screens/appconfig.dart'; // Asegúrate de que la ruta sea correcta

class SalaDeletePage extends StatefulWidget {
  @override
  _SalaDeletePageState createState() => _SalaDeletePageState();
}

class _SalaDeletePageState extends State<SalaDeletePage> {
  List<Map<String, dynamic>> _salas = []; // Almacena las salas disponibles
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSalas();
  }

  Future<void> _fetchSalas() async {
    final String url =
        '${AppConfig.baseUrl}/get-salas'; // Asegúrate de que la URL sea correcta
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _salas = List<Map<String, dynamic>>.from(json.decode(response.body));
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSala(String salaId) async {
    final String url = '${AppConfig.baseUrl}/eliminar-sala/$salaId';
    final response = await http.delete(Uri.parse(url));
    print('Respuesta del servidor: ${response.statusCode}');
    if (response.statusCode == 200) {
      _fetchSalas(); // Recargar salas después de eliminar
    } else {
      print('Error al eliminar la sala: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey,
                      Colors.grey,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assest/icons/logotipo.png',
                        width: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Eliminar Sala',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 30),
              _isLoading ? CircularProgressIndicator() : _buildSalasTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalasTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('Nombre')), // Ajusta según los datos de tu sala
        DataColumn(label: Text('Acción')),
      ],
      rows: _salas.map((sala) {
        return DataRow(cells: [
          DataCell(Text(sala['nombre'])), // Ajusta según los datos de tu sala
          DataCell(
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                print('Eliminando sala con ID: ${sala['id']}');
                _deleteSala(sala['id'].toString());
              },
            ),
          ),
        ]);
      }).toList(),
    );
  }
}
