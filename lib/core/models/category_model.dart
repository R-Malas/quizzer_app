class Category {
  final int id;
  final String name;

  const Category({required this.id, required this.name});

  factory Category.parseJson(Map<String, dynamic> jsonData) {
    return Category(
        id: jsonData['id'] as int, name: jsonData['name'] as String);
  }

  @override
  String toString() {
    return name;
  }
}
