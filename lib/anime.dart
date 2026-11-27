class Anime {
  final String id;
  final String name;
  final String desc;
  final String image;
  final String rating;
  final int? episodeCount;

  const Anime({
    required this.id,
    required this.name,
    required this.desc,
    required this.image,
    required this.rating,
    this.episodeCount,
  });

  factory Anime.fromJson(Map<String, dynamic> data) {
    final attributes = data["attributes"] as Map<String, dynamic>? ?? {};
    final posterImage = attributes["posterImage"] as Map<String, dynamic>? ?? {};

    final rawDesc = attributes["description"]?.toString().trim() ?? "";
    final rawName = attributes["canonicalTitle"]?.toString().trim() ?? "";
    final rawRating = attributes["averageRating"]?.toString().trim() ?? "";

    return Anime(
      id: data["id"]?.toString() ?? "",
      name: rawName.isEmpty ? "N/A" : rawName,
      desc: rawDesc.isEmpty ? "No description" : rawDesc,
      image: (posterImage["medium"] ??
              posterImage["small"] ??
              posterImage["original"] ??
              "")
          .toString(),
      rating: rawRating.isEmpty ? "N/A" : rawRating,
      episodeCount: attributes["episodeCount"] is int
          ? attributes["episodeCount"]
          : int.tryParse(attributes["episodeCount"]?.toString() ?? ""),
    );
  }
}