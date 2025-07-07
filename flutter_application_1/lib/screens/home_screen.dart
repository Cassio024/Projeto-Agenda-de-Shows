// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import 'add_edit_event_screen.dart';
import 'login_screen.dart';
// O import para 'change_password_screen.dart' foi removido.

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  late final ValueNotifier<List<Event>> _selectedEvents;
  Map<DateTime, List<Event>> _eventsByDay = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadAllEvents();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void _loadAllEvents() async {
    setState(() => _isLoading = true);
    try {
      final eventsData = await ApiService.getEvents(widget.user.id);
      final allEvents = eventsData.map((data) => Event.fromJson(data)).toList();

      final Map<DateTime, List<Event>> eventsMap = {};
      for (final event in allEvents) {
        final eventDate = DateTime.utc(event.dateTime.year, event.dateTime.month, event.dateTime.day);
        if (eventsMap[eventDate] == null) {
          eventsMap[eventDate] = [];
        }
        eventsMap[eventDate]!.add(event);
      }

      setState(() {
        _eventsByDay = eventsMap;
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    final dateOnly = DateTime.utc(day.year, day.month, day.day);
    return _eventsByDay[dateOnly] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await ApiService.deleteEvent(eventId);
      _loadAllEvents();
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${widget.user.name}'),
        actions: [
          // ATUALIZAÇÃO: Apenas o botão de sair está presente.
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<Event>(
                  locale: 'pt_BR',
                  firstDay: DateTime.utc(2010, 1, 1),
                  lastDay: DateTime.utc(2040, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: _onDaySelected,
                  eventLoader: _getEventsForDay,
                  calendarStyle: const CalendarStyle(markerDecoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) setState(() => _calendarFormat = format);
                  },
                  onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                ),
                const Divider(),
                Expanded(
                  child: ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      if (value.isEmpty) return const Center(child: Text("Nenhum evento para esta data."));
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          final event = value[index];
                          return Dismissible(
                            key: Key(event.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerRight,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirmar Exclusão"),
                                    content: const Text("Você tem certeza que deseja excluir este evento?"),
                                    actions: <Widget>[
                                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancelar")),
                                      TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Excluir", style: TextStyle(color: Colors.redAccent))),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) => _deleteEvent(event.id),
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                title: Text(event.eventName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(event.venue),
                                trailing: Text('${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddEditEventScreen(userId: widget.user.id)),
          );
          _loadAllEvents();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
