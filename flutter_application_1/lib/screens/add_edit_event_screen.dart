// lib/screens/add_edit_event_screen.dart

import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/database_service.dart';

class AddEditEventScreen extends StatefulWidget {
  const AddEditEventScreen({Key? key}) : super(key: key);

  @override
  _AddEditEventScreenState createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController;
  late TextEditingController _venueController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController();
    _venueController = TextEditingController();
    _selectedDate = DateTime.now(); // Inicia com a data atual
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final newEvent = Event(
        eventName: _eventNameController.text,
        venue: _venueController.text,
        dateTime: _selectedDate!,
      );

      await DatabaseService.instance.createEvent(newEvent);

      // Volta para a tela anterior
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Novo Evento'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(labelText: 'Nome do Evento/Artista'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira um nome' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _venueController,
                decoration: InputDecoration(labelText: 'Local do Show'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira um local' : null,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Data e Hora do Evento'),
                subtitle: Text('${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} às ${_selectedDate!.hour.toString().padLeft(2, '0')}:${_selectedDate!.minute.toString().padLeft(2, '0')}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text('Salvar Evento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}