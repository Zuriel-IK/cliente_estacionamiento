import 'package:cliente_estacionamiento/features/models/ticket_model.dart';
import 'package:cliente_estacionamiento/features/ticket/screens/ticket_payment_screen.dart';
import 'package:flutter/material.dart';

class TicketDetailScreen extends StatelessWidget {
  final TicketModel ticket;

  const TicketDetailScreen({
    super.key,
    required this.ticket,
  });

  String _formatDate(DateTime? value) {
    if (value == null) return 'No definido';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Folio: ${ticket.folio}'),
            const SizedBox(height: 8),
            Text('Estado: ${ticket.state.name}'),
            const SizedBox(height: 8),
            Text('Lugar: ${ticket.place}'),
            const SizedBox(height: 8),
            Text('Carro: ${ticket.car}'),
            const SizedBox(height: 8),
            Text('Reserva: ${ticket.reservation}'),
            const SizedBox(height: 8),
            Text('Inicio: ${_formatDate(ticket.timeStart)}'),
            const SizedBox(height: 8),
            Text('Fin: ${_formatDate(ticket.timeEnd)}'),
            const SizedBox(height: 8),
            Text('Código: ${ticket.code?.toString() ?? "Sin código"}'),
            const SizedBox(height: 8),
            Text('Tarifa base: ${ticket.baseFee ?? "No definida"}'),
            const SizedBox(height: 8),
            Text('Tarifa final: ${ticket.finalFee ?? "No definida"}'),
            const SizedBox(height: 24),
            if (ticket.code != null && ticket.state != TicketStateEnum.pagado) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketPaymentScreen(ticket: ticket),
                    ),
                  );
                },
                child: const Text('Pagar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}