extension CheckExist on Map? {
  bool get isNullOrEmpty {
    return this == null || this!.entries.isEmpty;
  }
}
