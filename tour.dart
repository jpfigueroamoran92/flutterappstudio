class Tour {
  final int id;
  final String name;
  final String? address; 
  final int viewsCount;
  final String kuulaShareLink;
  final String? imageUrl; 
  final String? description; // Added for tour description

  Tour({
    required this.id,
    required this.name,
    this.address,
    required this.viewsCount,
    required this.kuulaShareLink,
    this.imageUrl,
    this.description, // Added to constructor
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      viewsCount: json['views_count'] as int, 
      kuulaShareLink: json['kuula_share_link'] as String,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?, // Added fromJson mapping
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'views_count': viewsCount,
      'kuula_share_link': kuulaShareLink,
      'image_url': imageUrl,
      'description': description, // Added toJson mapping
    };
  }
}
