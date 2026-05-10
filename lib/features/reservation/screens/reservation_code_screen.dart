import 'package:cliente_estacionamiento/core/theme/app_theme.dart';
import 'package:cliente_estacionamiento/features/reservation/providers/reservation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReservationCodeScreen extends ConsumerWidget {
  final String reservationId;

  const ReservationCodeScreen({
    super.key,
    required this.reservationId,
  });

  String _formatCode(int code) {
    return code.toString().padLeft(6, '0');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeAsync = ref.watch(reservationCodeProvider(reservationId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.whiteRose,
      appBar: AppBar(
        backgroundColor: AppColors.whiteRose,
        title: const Text('Código de reserva'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: codeAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 42,
                      color: AppColors.darkRaspberry,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error al cargar el código: $error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(reservationCodeProvider(reservationId));
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (code) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.blushRose.withValues(alpha: 0.16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkRaspberry.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.rose100,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.password_rounded,
                          color: AppColors.darkRaspberry,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Código de acceso',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.jetBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Muestra este código para validar tu reserva',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.rose50,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.blushRose.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Text(
                          _formatCode(code),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 10,
                            color: AppColors.darkRaspberry,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Volver a reservas'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}