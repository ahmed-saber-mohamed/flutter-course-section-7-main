class Anime {
  final String id;

  final String name;

  final String desc;

  final String image;
  final String rating;

  const Anime({
    required this.id,
    required this.name,
    required this.desc,
    required this.image,
    required this.rating,
  });

  factory Anime.fromJson(Map<String, dynamic> data) {
    final id = data["id"];
    final name = data["attributes"]["slug"];
    final desc = data["attributes"]["description"];
    final image = data["attributes"]["posterImage"]["medium"];
    final rating = data["attributes"]["averageRating"];

    return Anime(id: id, name: name, desc: desc, image: image, rating: rating);
  }
}
