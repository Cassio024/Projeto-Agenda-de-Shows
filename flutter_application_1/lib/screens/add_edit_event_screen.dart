// lib/screens/add_edit_event_screen.dart
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class AddEditEventScreen extends StatefulWidget {
  final String userId;
  final Event? event;

  const AddEditEventScreen({Key? key, required this.userId, this.event}) : super(key: key);

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController;
  late TextEditingController _venueController;
  late TextEditingController _valueController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  String _selectedStatus = 'Confirmado';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.event != null;
    _eventNameController = TextEditingController(text: isEditing ? widget.event!.eventName : '');
    _venueController = TextEditingController(text: isEditing ? widget.event!.venue : '');
    _valueController = TextEditingController(text: isEditing ? widget.event!.value.toString() : '');
    _descriptionController = TextEditingController(text: isEditing ? widget.event!.description : '');
    _selectedDate = isEditing ? widget.event!.dateTime : DateTime.now();
    _selectedStatus = isEditing ? widget.event!.status : 'Confirmado';
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _venueController.dispose();
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // FUNÇÃO ATUALIZADA: Não pede mais a hora
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        // Guarda a data com a hora definida para o início do dia
        _selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (widget.event == null) {
          await ApiService.createEvent(
            widget.userId,
            _eventNameController.text,
            _venueController.text,
            _selectedDate!,
            double.tryParse(_valueController.text) ?? 0.0,
            _selectedStatus,
            _descriptionController.text,
          );
        } else {
          await ApiService.updateEvent(widget.event!.id, {
            'eventName': _eventNameController.text,
            'venue': _venueController.text,
            'dateTime': _selectedDate!.toIso8601String(),
            'value': double.tryParse(_valueController.text) ?? 0.0,
            'status': _selectedStatus,
            'description': _descriptionController.text,
          });
        }
        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? 'Adicionar Evento' : 'Editar Evento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _eventNameController, decoration: const InputDecoration(labelText: 'Nome do Evento'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _venueController, decoration: const InputDecoration(labelText: 'Local'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _valueController, decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: 'R\$ '), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Confirmado', 'Adiado', 'Cancelado'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                onChanged: (newValue) => setState(() => _selectedStatus = newValue!),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Data do Evento'),
                  child: Text('${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descrição / Itens'), maxLines: 4),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _isLoading ? null : _saveEvent, child: Text(widget.event == null ? 'Salvar Evento' : 'Atualizar Evento')),
            ],
          ),
        ),
      ),
    );
  }
}
