
import 'dart:async';

late StreamController<String> streamController;

class EventHelper {

  static const onLoadAdMod = "on_load_admod";
  static const onShowIntervalAds = "on_show_interval_ads";
  static const onLoginSync = "on_login_sync";
  static const onShowExplain = "on_show_explain";
  static const onHideExplain = "on_hide_explain";
  static const onUpdateHistory = "on_update_history";
  static const onUpdateExam = "on_update_exam";

  push(String event) {
    streamController.sink.add(event);
  }

  StreamSubscription? _subscription;
  listen(Function(String) eventListener) {
    _subscription = streamController.stream.listen((event) {
      eventListener(event);
    });
  }

  cancel() {
    _subscription?.cancel();
  }
}