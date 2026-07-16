import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/home_button.dart';

/// Side-by-side comparison table of up to 3 selected listings.
class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.compareList;

    final body = list.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Karşılaştırma listeniz boş.\n'
                'Keşfet sekmesinden ilan kartlarındaki "Karşılaştır" '
                'butonuyla en fazla 3 ilan ekleyin.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                columns: [
                  const DataColumn(label: Text('Özellik')),
                  for (final p in list)
                    DataColumn(
                      label: Row(
                        children: [
                          Text(p.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            tooltip: 'Listeden çıkar',
                            onPressed: () =>
                                context.read<AppState>().toggleCompare(p.id),
                          ),
                        ],
                      ),
                    ),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('Tür')),
                    for (final p in list) DataCell(TypeBadge(type: p.type)),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Şehir')),
                    for (final p in list) DataCell(Text(p.city)),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Aylık Ücret')),
                    for (final p in list)
                      DataCell(Text(formatPrice(p.monthlyPrice),
                          style:
                              const TextStyle(fontWeight: FontWeight.bold))),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Puan')),
                    for (final p in list)
                      DataCell(RatingStars(rating: p.avgRating, size: 14)),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Yorum Sayısı')),
                    for (final p in list)
                      DataCell(Text('${p.reviews.length}')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Tanıtım Videosu')),
                    for (final p in list)
                      DataCell(Icon(
                        p.videoUrl != null ? Icons.check_circle : Icons.cancel,
                        color: p.videoUrl != null ? Colors.green : Colors.red,
                        size: 18,
                      )),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Özellikler')),
                    for (final p in list)
                      DataCell(SizedBox(
                        width: 200,
                        child: Text(p.features.join(', '),
                            softWrap: true, maxLines: 4),
                      )),
                  ]),
                ],
              ),
            ),
          );

    // Standalone route (pushed from browse) needs its own Scaffold; as a tab
    // inside HomeShell it renders bare.
    final isPushed = ModalRoute.of(context)?.canPop ?? false;
    if (isPushed) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Karşılaştır'),
          actions: const [HomeButton(), SizedBox(width: 8)],
        ),
        body: body,
      );
    }
    return body;
  }
}
