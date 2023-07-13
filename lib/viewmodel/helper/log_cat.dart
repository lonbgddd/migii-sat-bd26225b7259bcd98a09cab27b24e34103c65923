class Log {
  static d(String text) {
    print("log_test: $text");
  }

  static all(String text) {
    final size = text.length;
    var index = 0;
    while (index < size - 500) {
      d(text.substring(index, index + 500));
      index += 500;
    }
    d(text.substring(index));
  }
}
