class PublicApp {
  final String name;
  final String description;
  final String version;
  final String iconUrl;
  final String downloadUrl;
  final String shortDesc;
  final List<dynamic> images;
  final List<dynamic> changelog;
  final String id;

  PublicApp(
      {this.name,
      this.description,
      this.shortDesc,
      this.version,
      this.iconUrl,
      this.downloadUrl,
      this.images,
      this.changelog,
      this.id});

  PublicApp.fromMap(Map<String, dynamic> data, String id)
      : this(
          name: data['visibleName'],
          description: data['visibleDescription'],
          shortDesc: data['shortDescription'],
          version: data['version'],
          iconUrl: data['iconUrl'],
          downloadUrl: data['downloadUrl'],
          images: data['images'],
          changelog: data['changelog'],
          id: id,
        );
}
