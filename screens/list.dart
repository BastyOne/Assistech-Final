import 'package:assistech/screens/appconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:assistech/screens/api_service.dart';
import 'package:http/http.dart' as http;

class FiltrarAsistenciaScreen extends StatefulWidget {
  @override
  _FiltrarAsistenciaScreenState createState() =>
      _FiltrarAsistenciaScreenState();
}

class _FiltrarAsistenciaScreenState extends State<FiltrarAsistenciaScreen> {
  final ApiService _apiService = ApiService(AppConfig.baseUrl, http.Client());
  final TextEditingController _materiaController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _salaController = TextEditingController();
  List<Asistencia> _asistencias = [];
  bool _mostrarTabla = false;

  @override
  void dispose() {
    _materiaController.dispose();
    _fechaController.dispose();
    _salaController.dispose();
    super.dispose();
  }

  void _filtrarAsistencia() async {
    String materia = _materiaController.text;
    String fecha = _fechaController.text;
    String sala = _salaController.text;

    try {
      List<Asistencia> resultados =
          await _apiService.filtrarAsistenciaCombinada(
        materia: materia.isNotEmpty ? materia : null,
        fecha: fecha.isNotEmpty ? fecha : null,
        sala: sala.isNotEmpty ? sala : null,
      );
      setState(() {
        _asistencias = resultados;
        _mostrarTabla = true;
      });
    } catch (e) {
      setState(() {
        _mostrarTabla = false; // Oculta la tabla si hay un error
      });

      // Maneja el error aquí, por ejemplo mostrando un snackbar o un dialog
      print('Error al filtrar asistencias: $e');
    }
  }

  Future<void> _showMateriaDialog() async {
    final materias = await _apiService.getMaterias();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Selecciona una materia'),
          children: materias.map((materia) {
            return SimpleDialogOption(
              onPressed: () {
                _materiaController.text = materia.nombre;
                Navigator.pop(context);
              },
              child: Text(materia.nombre),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _showSalaDialog() async {
    final salas = await _apiService.getSalas();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Selecciona una sala'),
          children: salas.map((sala) {
            return SimpleDialogOption(
              onPressed: () {
                _salaController.text = sala
                    .codigo; // Asegúrate de que 'codigo' es el atributo correcto
                Navigator.pop(context);
              },
              child: Text(sala.nombre),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Filtrar Asistencia',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: GestureDetector(
                onTap: _showMateriaDialog,
                child: AbsorbPointer(
                  child: TextField(
                    controller: _materiaController,
                    decoration: InputDecoration(
                      labelText: 'Materia',
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _fechaController,
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: GestureDetector(
                onTap: _showSalaDialog,
                child: AbsorbPointer(
                  child: TextField(
                    controller: _salaController,
                    decoration: InputDecoration(
                      labelText: 'Sala',
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _filtrarAsistencia,
              child: Text('Buscar'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.black, // Color del texto
              ),
            ),
            _mostrarTabla
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nombre Estudiante')),
                        DataColumn(label: Text('Fecha de Entrada')),
                      ],
                      rows: _asistencias
                          .map<DataRow>(
                            (asistencia) => DataRow(
                              cells: [
                                DataCell(Text(asistencia.nombreEstudiante)),
                                DataCell(Text(DateFormat('yyyy-MM-dd – kk:mm')
                                    .format(asistencia.fechaHora))),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
