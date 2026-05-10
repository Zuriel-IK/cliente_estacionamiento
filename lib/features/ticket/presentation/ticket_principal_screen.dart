import 'package:cliente_estacionamiento/features/models/ticket_model.dart';
import 'package:cliente_estacionamiento/features/ticket/providers/ticket_provider.dart';
import 'package:cliente_estacionamiento/features/ticket/screens/ticket_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TicketPrincipalScreen extends ConsumerStatefulWidget {
  final bool isActive;
  const TicketPrincipalScreen({
    super.key,
    required this.isActive,
  });

  @override
  ConsumerState<TicketPrincipalScreen> createState() =>
      _TicketPrincipalScreenState();
}

class _TicketPrincipalScreenState extends ConsumerState<TicketPrincipalScreen> {
  ProviderSubscription<AsyncValue<List<TicketModel>>>? _ticketSseSub;

  @override
  void initState() {
    super.initState();

    if (widget.isActive) {
      _startSseListener();
    }

    _ticketSseSub = ref.listenManual<AsyncValue<List<TicketModel>>>(
      ticketUpdatesProvider,
          (previous, next) {
        next.whenData((tickets) {
          ref.read(ticketListProvider.notifier).applyUpdate(tickets);
        });
      },
    );
  }
  @override
  void didUpdateWidget(covariant TicketPrincipalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isActive && widget.isActive) {
      _startSseListener();
    }

    if (oldWidget.isActive && !widget.isActive) {
      _stopSseListener();
    }
  }

  @override
  void dispose() {
    _stopSseListener();
    super.dispose();
  }

  void _startSseListener() {
    if (_ticketSseSub != null) return;

    _ticketSseSub = ref.listenManual<AsyncValue<List<TicketModel>>>(
      ticketUpdatesProvider,
          (previous, next) {
        next.whenData((tickets) {
          ref.read(ticketListProvider.notifier).applyUpdate(tickets);
        });
      },
    );
  }

  void _stopSseListener() {
    _ticketSseSub?.close();
    _ticketSseSub = null;
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'No definida';

    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(ticketListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(ticketListProvider.notifier).refreshTickets(),
        child: ticketsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error al cargar tickets: $error'),
                ),
              ),
            ],
          ),
          data: (tickets) {
            if (tickets.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text('No hay tickets'),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return _TicketCard(
                  ticket: ticket,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketDetailScreen(ticket: ticket),
                      ),
                    );
                  },
                  formatDate: _formatDate,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  final String Function(DateTime?) formatDate;

  const _TicketCard({
    required this.ticket,
    required this.onTap,
    required this.formatDate,
  });

  Color _stateColor(TicketStateEnum state, BuildContext context) {
    switch (state) {
      case TicketStateEnum.pagado:
        return Colors.green;
      case TicketStateEnum.activo:
        return Colors.blue;
      case TicketStateEnum.finalizado:
        return Colors.cyan;
      case TicketStateEnum.pendiente_pago:
        return Colors.deepOrange;
      case TicketStateEnum.desconocido:
        return Theme.of(context).colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _stateColor(ticket.state, context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Folio: ${ticket.folio}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Estado: ${ticket.state.name}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Fecha: ${formatDate(ticket.timeStart)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}