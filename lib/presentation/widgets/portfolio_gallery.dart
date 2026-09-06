import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import 'order_sheet.dart';
import 'workshop_media.dart';

class PortfolioGallery extends StatelessWidget {
  const PortfolioGallery({
    required this.workshop,
    required this.title,
    required this.items,
    super.key,
  });

  final Workshop workshop;
  final String title;
  final List<PortfolioItem> items;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CraftImage(
            url: WorkshopMedia.heroFor(workshop),
            height: 150,
            width: double.infinity,
            borderRadius: BorderRadius.circular(18),
            fallbackColor: workshop.color.withValues(alpha: .14),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: primary,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .68,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _showPreview(context, item),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CraftImage(
                          url: item.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          fallbackColor: workshop.color.withValues(alpha: .2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                        child: Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.price,
                              style: const TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );

  void _showPreview(BuildContext context, PortfolioItem item) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CraftImage(url: item.imageUrl, height: 190, borderRadius: BorderRadius.circular(16), fallbackColor: workshop.color.withValues(alpha: .2)),
            const SizedBox(height: 12),
            Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primary)),
            const SizedBox(height: 4),
            Text(item.price, style: const TextStyle(color: accent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                showOrderSheet(context, workshop);
              },
              icon: const Icon(Icons.request_quote_outlined),
              label: const Text('اطلب تصميماً مشابهاً'),
            ),
          ],
        ),
      ),
    );
  }
}

class PortfolioItem {
  const PortfolioItem(this.name, this.price, this.imageUrl);
  final String name;
  final String price;
  final String imageUrl;
}