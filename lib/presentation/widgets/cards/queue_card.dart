import 'package:flutter/material.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/widgets/items/queue_item.dart';
import 'package:mostrador_au/presentation/widgets/shared/panel.dart';

class QueueCard extends StatelessWidget {
  final List<Turno> pendientes;
  final String titulo;
  final String textoVacio;
  final int? siguienteAsgCodigo;
  final void Function(Turno turno)? onTapTurno;

  const QueueCard({
    super.key,
    required this.pendientes,
    this.titulo = 'En espera',
    this.textoVacio = 'Sin turnos en espera',
    this.siguienteAsgCodigo,
    this.onTapTurno,
  });

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
                  titulo,
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
                      textoVacio,
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
                      final queueItem = QueueItem(
                        code: item.turno,
                        name: item.nombreCliente.trim().isEmpty
                            ? 'Cliente sin nombre'
                            : item.nombreCliente.trim(),
                        isNext: item.asgCodigo == siguienteAsgCodigo,
                        canal: item.canal,
                        fechaCita: item.fechaCita,
                        fechaLlegada: item.fechaLlegada,
                        fechaOrden: item.fechaOrden,
                      );
                      if (onTapTurno == null) return queueItem;
                      return InkWell(
                        onTap: () => onTapTurno!(item),
                        borderRadius: BorderRadius.circular(12),
                        child: queueItem,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
