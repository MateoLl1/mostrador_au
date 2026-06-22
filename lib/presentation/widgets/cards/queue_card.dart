import 'package:flutter/material.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/widgets/items/queue_item.dart';
import 'package:mostrador_au/presentation/widgets/shared/panel.dart';

class QueueCard extends StatelessWidget {
  final List<Turno> pendientes;

  const QueueCard({super.key, required this.pendientes});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Panel(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'En espera',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${pendientes.length} turno(s)',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: pendientes.isEmpty
                ? Center(
                    child: Text(
                      'Sin turnos en espera',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: pendientes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = pendientes[index];
                      return QueueItem(
                        code: item.turno,
                        name: item.nombreCliente.trim().isEmpty
                            ? 'Cliente sin nombre'
                            : item.nombreCliente.trim(),
                        isNext: index == 0,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
