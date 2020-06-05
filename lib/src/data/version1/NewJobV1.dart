class NewJobV1 {
  String type;
  String ref_id;
  num ttl;
  dynamic params;

  NewJobV1({String type, String ref_id, num ttl, dynamic params})
      : type = type,
        ref_id = ref_id,
        ttl = ttl,
        params = params;

  void fromJson(Map<String, dynamic> json) {
    type = json['type'];
    ref_id = json['ref_id'];
    ttl = json['ttl'];
    params = json['params'];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'ref_id': ref_id,
      'ttl': ttl,
      'params': params
    };
  }
}
