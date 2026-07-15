import 'package:flutter/material.dart';

import '../models/models.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 18});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            rating >= i
                ? Icons.star
                : (rating >= i - 0.5 ? Icons.star_half : Icons.star_border),
            size: size,
            color: Colors.amber,
          ),
        const SizedBox(width: 4),
        Text(rating == 0 ? 'Henüz puan yok' : rating.toStringAsFixed(1),
            style: TextStyle(fontSize: size * 0.75)),
      ],
    );
  }
}

/// Interactive 1..5 star picker used in the review dialog.
class StarPicker extends StatelessWidget {
  const StarPicker({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            icon: Icon(i <= value ? Icons.star : Icons.star_border,
                color: Colors.amber, size: 32),
            onPressed: () => onChanged(i),
          ),
      ],
    );
  }
}

class NetworkPhoto extends StatelessWidget {
  const NetworkPhoto({super.key, required this.url, this.height, this.width, this.fit = BoxFit.cover});

  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: width,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.school, size: 48, color: Colors.grey),
      ),
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              height: height,
              width: width,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
    );
  }
}

class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});

  final ProviderType type;

  Color _color(ProviderType t) => switch (t) {
        ProviderType.privateSchool => Colors.indigo,
        ProviderType.course => Colors.teal,
        ProviderType.dershane => Colors.deepOrange,
        ProviderType.privateTeacher => Colors.purple,
      };

  @override
  Widget build(BuildContext context) {
    final c = _color(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.5)),
      ),
      child: Text(type.labelTr, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

String formatPrice(double price) {
  final s = price.toStringAsFixed(0);
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '$buf TL';
}

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

String formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
