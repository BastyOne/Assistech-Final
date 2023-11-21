import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:assistech/screens/appconfig.dart'; // Asegúrate de que la ruta sea correcta

class MateriaDeletePage extends StatefulWidget {
  @override
  _MateriaDeletePageState createState() => _MateriaDeletePageState();
}

class _MateriaDeletePageState extends State<MateriaDeletePage> {
  List<Map<String, dynamic>> _materias =
      []; // Almacena las materias disponibles
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMaterias();
  }

  Future<void> _fetchMaterias() async {
    final String url = '${AppConfig.baseUrl}/get-materias';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _materias = List<Map<String, dynamic>>.from(json.decode(response.body));
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMateria(String materiaId) async {
    final String url = '${AppConfig.baseUrl}/eliminar-materia/$materiaId';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      _fetchMaterias(); // Recargar materias después de eliminar
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
                'Eliminar Materia',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 30),
              _isLoading ? CircularProgressIndicator() : _buildMateriasTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMateriasTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Acción')),
      ],
      rows: _materias.map((materia) {
        return DataRow(cells: [
          DataCell(Text(materia['nombre'])),
          DataCell(
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteMateria(materia['id'].toString()),
            ),
          ),
        ]);
      }).toList(),
    );
  }
}
