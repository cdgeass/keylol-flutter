class AllowPerm {
  // TODO
  final String uploadHash;

  AllowPerm.fromJson(Map<String, dynamic> json)
      : uploadHash = json['uploadhash'] ?? '';
}
