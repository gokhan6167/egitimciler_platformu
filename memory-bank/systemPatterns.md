# System Patterns

## Mimari
- `lib/models/` — saf veri modelleri (backend'e taşınabilir).
- `lib/data/mock_data.dart` — seed/demo veri. Gerçek backend gelince repository arayüzüne dönüşecek.
- `lib/state/app_state.dart` — tek `ChangeNotifier` (AppState) + `provider` paketi.
- `lib/screens/` — ekranlar; rol bazlı görünürlük AppState.currentUser.role üzerinden.
- `lib/widgets/` — ortak widget'lar (yıldız, kart, avatar).

## Kurallar
- Kod ve commit mesajları İngilizce, UI metinleri Türkçe.
- Rol görünürlük kontrolleri hem navigasyonda hem ekran içinde yapılır (savunmacı).
- Görseller network URL (picsum placeholder) + errorBuilder fallback.
