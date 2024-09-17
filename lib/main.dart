import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Modelo Ticket
class Ticket {
  final String id;
  final String flightNumber;
  final String airline;
  final String passengerInfo;
  final String origin;
  final String destination;
  final String seat;
  final String classType;

  Ticket({
    required this.id,
    required this.flightNumber,
    required this.airline,
    required this.passengerInfo,
    required this.origin,
    required this.destination,
    required this.seat,
    required this.classType,
  });
}

// Provider de Tickets
class TicketProvider with ChangeNotifier {
  List<Ticket> _tickets = [];

  List<Ticket> get tickets => _tickets;

  void addTicket(Ticket ticket) {
    _tickets.add(ticket);
    notifyListeners();
  }

  void updateTicket(Ticket updatedTicket) {
    final index = _tickets.indexWhere((t) => t.id == updatedTicket.id);
    if (index != -1) {
      _tickets[index] = updatedTicket;
      notifyListeners();
    }
  }

  void deleteTicket(String id) {
    _tickets.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}

// Pantalla Principal
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Tickets')),
      body: ListView.builder(
        itemCount: ticketProvider.tickets.length,
        itemBuilder: (context, index) {
          final ticket = ticketProvider.tickets[index];
          return ListTile(
            title: Text(ticket.flightNumber),
            subtitle: Text('${ticket.origin} to ${ticket.destination}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                ticketProvider.deleteTicket(ticket.id);
              },
            ),
            onTap: () => context.go('/ticket/${ticket.id}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/ticket/new'),
        child: Icon(Icons.add),
      ),
    );
  }
}

// Pantalla de Ticket
class TicketScreen extends StatefulWidget {
  final String? id;

  TicketScreen({this.id});

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final _flightNumberController = TextEditingController();
  final _airlineController = TextEditingController();
  final _passengerInfoController = TextEditingController();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _seatController = TextEditingController();
  final _classTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      final ticket = Provider.of<TicketProvider>(context, listen: false)
          .tickets
          .firstWhere((t) => t.id == widget.id);
      _flightNumberController.text = ticket.flightNumber;
      _airlineController.text = ticket.airline;
      _passengerInfoController.text = ticket.passengerInfo;
      _originController.text = ticket.origin;
      _destinationController.text = ticket.destination;
      _seatController.text = ticket.seat;
      _classTypeController.text = ticket.classType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'New Ticket' : 'Edit Ticket'),
        actions: [
          if (widget.id != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                ticketProvider.deleteTicket(widget.id!);
                context.go('/');
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _flightNumberController,
              decoration: InputDecoration(labelText: 'Flight Number'),
            ),
            TextField(
              controller: _airlineController,
              decoration: InputDecoration(labelText: 'Airline'),
            ),
            TextField(
              controller: _passengerInfoController,
              decoration: InputDecoration(labelText: 'Passenger Info'),
            ),
            TextField(
              controller: _originController,
              decoration: InputDecoration(labelText: 'Origin'),
            ),
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(labelText: 'Destination'),
            ),
            TextField(
              controller: _seatController,
              decoration: InputDecoration(labelText: 'Seat'),
            ),
            TextField(
              controller: _classTypeController,
              decoration: InputDecoration(labelText: 'Class'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final ticket = Ticket(
                  id: widget.id ?? DateTime.now().toString(),
                  flightNumber: _flightNumberController.text,
                  airline: _airlineController.text,
                  passengerInfo: _passengerInfoController.text,
                  origin: _originController.text,
                  destination: _destinationController.text,
                  seat: _seatController.text,
                  classType: _classTypeController.text,
                );
                if (widget.id == null) {
                  ticketProvider.addTicket(ticket);
                } else {
                  ticketProvider.updateTicket(ticket);
                }
                context.go('/');
              },
              child: Text(widget.id == null ? 'Add Ticket' : 'Update Ticket'),
            ),
          ],
        ),
      ),
    );
  }
}

// Configuración de Rutas
final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/ticket/:id',
      builder: (context, state) {
        final id = state.params['id'];
        return TicketScreen(id: id);
      },
    ),
    GoRoute(
      path: '/ticket/new',
      builder: (context, state) => TicketScreen(),
    ),
  ],
);

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TicketProvider(),
      child: MaterialApp.router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
      ),
    ),
  );
}
