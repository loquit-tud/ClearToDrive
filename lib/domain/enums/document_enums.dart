enum DocumentType {
  rca,
  itp,
  rovinieta;

  String get storageKey => name;
}

enum DocumentSource {
  scan,
  import,
  manual,
}

enum ReminderStatus {
  scheduled,
  fired,
  cancelled,
}

enum ExpiryStatus {
  valid,
  expiringSoon,
  expired,
}
