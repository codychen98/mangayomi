import 'package:mangayomi/eval/model/m_manga.dart';
import 'package:mangayomi/main.dart';

Set<String> favoriteLinksForSource(int sourceId) {
  return isar.mangas
      .filter()
      .favoriteEqualTo(true)
      .and()
      .sourceIdEqualTo(sourceId)
      .findAllSync()
      .map((m) => m.link)
      .whereType<String>()
      .where((link) => link.isNotEmpty)
      .toSet();
}

List<MManga> filterLibraryItemsFromFeed({
  required List<MManga> mangas,
  required int sourceId,
  required bool hideInLibrary,
}) {
  if (!hideInLibrary) {
    return mangas;
  }

  final libraryLinks = favoriteLinksForSource(sourceId);
  if (libraryLinks.isEmpty) {
    return mangas;
  }

  return mangas
      .where((manga) {
        final link = manga.link;
        return link == null || link.isEmpty || !libraryLinks.contains(link);
      })
      .toList();
}
