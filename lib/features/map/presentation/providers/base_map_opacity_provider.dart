import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opacity of the base tile layer (0.2–1.0). Lowering it makes weather
/// overlays stand out, Windy-style.
final baseMapOpacityProvider =
    NotifierProvider<BaseMapOpacityNotifier, double>(
        BaseMapOpacityNotifier.new);

class BaseMapOpacityNotifier extends Notifier<double> {
  static const _prefsKey = 'base_map_opacity';

  @override
  double build() {
    _restore();
    return 1.0;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_prefsKey);
    if (saved != null) state = saved.clamp(0.2, 1.0);
  }

  Future<void> set(double value) async {
    state = value.clamp(0.2, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsKey, state);
  }
}
