class User {
  int? id;
  String? name;
  String? contact;
  String? description;

  User({this.id, this.name, this.contact, this.description}); // Construtor

  Map<String, dynamic> userMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id; // Não precisa de "?? null"
    mapping['name'] = name!;
    mapping['contact'] = contact!;
    mapping['description'] = description!;
    return mapping;
  }
}
