import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'calendar_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _events = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await CalendarService.fetchEvents();
    setState(() => _events = events);
  }

  Future<void> _createEvent() async {
    setState(() => _loading = true);
    try {
      final result = await CalendarService.createEvent(_controller.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event created: ${result['title']}")),
      );
      _controller.clear();
      await _loadEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  String formatDate(String dateTime) {
    final date = DateTime.parse(dateTime);
    return DateFormat('EEE, MMM d • h:mm a').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar Scheduler')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'e.g., Schedule design meeting next Tuesday at 2 PM',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loading ? null : _createEvent,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Create Event'),
            ),
            const Divider(height: 30),
            Expanded(
              child: _events.isEmpty
                  ? const Center(child: Text('No events found'))
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final e = _events[index];
                        return Card(
                          child: ListTile(
                            title: Text(e['title'] ?? ''),
                            subtitle: Text(formatDate(e['start'])),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
