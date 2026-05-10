import 'package:cliente_estacionamiento/core/notifications/app_notifier.dart';
import 'package:cliente_estacionamiento/core/theme/app_theme.dart';
import 'package:cliente_estacionamiento/features/models/ticket_model.dart';
import 'package:cliente_estacionamiento/features/ticket/providers/ticket_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TicketPaymentScreen extends ConsumerStatefulWidget {
  final TicketModel ticket;

  const TicketPaymentScreen({
    super.key,
    required this.ticket,
  });

  @override
  ConsumerState<TicketPaymentScreen> createState() =>
      _TicketPaymentScreenState();
}

class _TicketPaymentScreenState extends ConsumerState<TicketPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cardNumberController = TextEditingController(
    text: '4242 4242 4242 4242',
  );
  final _holderController = TextEditingController(
    text: 'ARTURO ZURIEL',
  );
  final _expiryController = TextEditingController(
    text: '12/28',
  );
  final _cvvController = TextEditingController(
    text: '123',
  );

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _money(num? value) {
    if (value == null) return 'No definido';
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final paymentState = ref.watch(confirmTicketPaymentActionProvider);
    final isPaying = paymentState.isLoading;

    final finalFeeAsync = ticket.code == null
        ? const AsyncValue<num>.data(0)
        : ref.watch(ticketCalculatedFinalFeeProvider(ticket.code!));

    ref.listen<AsyncValue<void>>(
      confirmTicketPaymentActionProvider,
          (previous, next) {
        if (previous?.isLoading == true && next.hasValue) {
          AppNotifier.success(
            title: 'Éxito',
            message: 'Pago realizado correctamente',
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            }
          });
        }

        if (previous?.isLoading == true && next.hasError) {
          AppNotifier.error(
            title: 'Error',
            message: next.error.toString(),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagar ticket'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.darkRaspberry,
                    AppColors.blushRose,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tarjeta',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _cardNumberController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _holderController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _expiryController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.whiteRose,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.blushRose.withValues(alpha: 0.14),
                ),
              ),
              child: finalFeeAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de pago',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.jetBlack,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Error al calcular monto: $error'),
                  ],
                ),
                data: (calculatedFinalFee) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen de pago',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.jetBlack,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _PaymentRow(
                        label: 'Folio',
                        value: ticket.folio,
                      ),
                      _PaymentRow(
                        label: 'Lugar',
                        value: ticket.place,
                      ),
                      _PaymentRow(
                        label: 'Carro',
                        value: ticket.car,
                      ),
                      _PaymentRow(
                        label: 'Estado',
                        value: ticket.state.name,
                      ),
                      _PaymentRow(
                        label: 'Tarifa base',
                        value: _money(ticket.baseFee),
                      ),
                      _PaymentRow(
                        label: 'Total a pagar',
                        value: _money(calculatedFinalFee),
                        isStrong: true,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.whiteRose,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.blushRose.withValues(alpha: 0.14),
                  ),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Número de tarjeta',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _holderController,
                      decoration: const InputDecoration(
                        labelText: 'Titular',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryController,
                            decoration: const InputDecoration(
                              labelText: 'Vencimiento',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: (ticket.code == null || isPaying)
                  ? null
                  : () async {
                await ref
                    .read(confirmTicketPaymentActionProvider.notifier)
                    .confirmPayment(code: ticket.code!);
              },
              child: isPaying
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Confirmar pago'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStrong;

  const _PaymentRow({
    required this.label,
    required this.value,
    this.isStrong = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 14,
      fontWeight: isStrong ? FontWeight.w800 : FontWeight.w600,
      color: AppColors.jetBlack,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(value, style: style),
        ],
      ),
    );
  }
}