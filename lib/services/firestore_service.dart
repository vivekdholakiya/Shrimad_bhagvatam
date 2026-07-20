import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/canto_model.dart';
import '../models/chapter_model.dart';
import '../models/verse_model.dart';
import 'cache_service.dart';
import 'network_service.dart';

/// FirestoreService — cache-first, read-only access to Firestore.
///
/// Strategy (stale-while-revalidate):
///   1. Check local cache (SharedPreferences via CacheService).
///   2. Return cached data IMMEDIATELY if present (no network wait).
///   3. If cache exists, kick off a background refresh (fire-and-forget)
///      that updates the cache + notifies [onUpdate] when fresh data lands.
///   4. If cache is empty, fetch from Firestore (this is the only case
///      the caller actually has to wait on network).
///
/// Speed fixes vs the old version:
///   - Chapter/verse counts now use Firestore's `.count().get()`
///     aggregation query instead of downloading full subcollections.
///   - All per-doc subcollection lookups are parallelized with
///     Future.wait instead of awaited one-by-one in a for-loop.
///   - Debug prints gated behind kDebugMode so they don't run in release.
///
/// Explicit refresh: call the method with forceRefresh:true to bypass cache.
class FirestoreService {
  static FirestoreService? _instance;

  FirestoreService._();

  static FirestoreService get instance {
    _instance ??= FirestoreService._();
    return _instance!;
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CacheService _cache = CacheService.instance;

  void _log(String msg) {
    if (kDebugMode) print(msg);
  }

  // ── Cantos ───────────────────────────────────

  /// Returns list of all 12 cantos.
  ///
  /// If cached data exists, it's returned immediately and a background
  /// refresh is triggered; pass [onUpdate] to get notified when the
  /// refreshed data is ready (e.g. to update GetX state).
  Future<List<CantoModel>> getCantos({
    bool forceRefresh = false,
    void Function(List<CantoModel>)? onUpdate,
  }) async {
    final cacheKey = CacheService.cantosKey;

    if (!forceRefresh) {
      final cached = _cache.getString(cacheKey);
      if (cached != null) {
        _log('Using cached cantos');
        // Fire-and-forget background refresh — don't block the caller.
        unawaited(_refreshCantos(cacheKey, onUpdate: onUpdate));
        return CantoModel.decodeList(cached);
      }
    }

    return _fetchCantos(cacheKey);
  }

  Future<void> _refreshCantos(
      String cacheKey, {
        void Function(List<CantoModel>)? onUpdate,
      }) async {
    try {
      final fresh = await _fetchCantos(cacheKey);
      onUpdate?.call(fresh);
    } catch (e) {
      _log('Background canto refresh failed: $e');
    }
  }

  Future<List<CantoModel>> _fetchCantos(String cacheKey) async {
    try {
      final cantos = await NetworkService.instance.run(
            () async {
          final snapshot = await _db.collection('bhagavat').get();

          // Parallelize the chapter-count lookup for every canto instead of
          // awaiting them one-by-one.
          final result = await Future.wait(snapshot.docs.map((doc) async {
            final countSnap =
            await doc.reference.collection('chapters').count().get();

            return CantoModel.fromFirestore(
              doc.data(),
              doc.id,
              chapterCount: countSnap.count ?? 0,
            );
          }));

          result.sort((a, b) => a.cantoNumber.compareTo(b.cantoNumber));
          return result;
        },
        debugLabel: 'getCantos',
      );

      await _cache.setString(cacheKey, CantoModel.encodeList(cantos));

      return cantos;
    } catch (e, s) {
      _log('$e\n$s');

      // Cache fallback: if we have anything stale, prefer showing that
      // over a hard error — especially important for NoConnectionException.
      final cached = _cache.getString(cacheKey);
      if (cached != null) return CantoModel.decodeList(cached);

      rethrow;
    }
  }

  // ── Chapters ──────────────────────────────────

  /// Returns chapters for the given canto.
  Future<List<ChapterModel>> getChapters(
      int cantoNumber, {
        bool forceRefresh = false,
        void Function(List<ChapterModel>)? onUpdate,
      }) async {
    final cacheKey = CacheService.chaptersKey(cantoNumber);

    if (!forceRefresh) {
      final cached = _cache.getString(cacheKey);
      if (cached != null) {
        unawaited(
          _refreshChapters(cantoNumber, cacheKey, onUpdate: onUpdate),
        );
        return ChapterModel.decodeList(cached);
      }
    }

    return _fetchChapters(cantoNumber, cacheKey);
  }

  Future<void> _refreshChapters(
      int cantoNumber,
      String cacheKey, {
        void Function(List<ChapterModel>)? onUpdate,
      }) async {
    try {
      final fresh = await _fetchChapters(cantoNumber, cacheKey);
      onUpdate?.call(fresh);
    } catch (e) {
      _log('Background chapter refresh failed: $e');
    }
  }

  Future<List<ChapterModel>> _fetchChapters(
      int cantoNumber,
      String cacheKey,
      ) async {
    try {
      final chapters = await NetworkService.instance.run(
            () async {
          final cantoDocId = 'canto_$cantoNumber';

          final snapshot = await _db
              .collection('bhagavat')
              .doc(cantoDocId)
              .collection('chapters')
              .get();

          final result = await Future.wait(snapshot.docs.map((doc) async {
            final countSnap =
            await doc.reference.collection('verses').count().get();

            return ChapterModel.fromFirestore(
              doc.data(),
              doc.id,
              cantoNumber,
              verseCount: countSnap.count ?? 0,
            );
          }));

          result.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
          return result;
        },
        debugLabel: 'getChapters($cantoNumber)',
      );

      await _cache.setString(cacheKey, ChapterModel.encodeList(chapters));

      return chapters;
    } catch (e) {
      _log('$e');

      final cached = _cache.getString(cacheKey);
      if (cached != null) return ChapterModel.decodeList(cached);

      rethrow;
    }
  }

  // ── Verses ────────────────────────────────────

  /// Returns all verses for a chapter.
  Future<List<VerseModel>> getVerses(
      int cantoNumber,
      int chapterNumber, {
        bool forceRefresh = false,
        void Function(List<VerseModel>)? onUpdate,
      }) async {
    final cacheKey = CacheService.versesKey(cantoNumber, chapterNumber);

    if (!forceRefresh) {
      final cached = _cache.getString(cacheKey);
      if (cached != null) {
        unawaited(_refreshVerses(
          cantoNumber,
          chapterNumber,
          cacheKey,
          onUpdate: onUpdate,
        ));
        return VerseModel.decodeList(cached);
      }
    }

    return _fetchVerses(cantoNumber, chapterNumber, cacheKey);
  }

  Future<void> _refreshVerses(
      int cantoNumber,
      int chapterNumber,
      String cacheKey, {
        void Function(List<VerseModel>)? onUpdate,
      }) async {
    try {
      final fresh = await _fetchVerses(cantoNumber, chapterNumber, cacheKey);
      onUpdate?.call(fresh);
    } catch (e) {
      _log('Background verse refresh failed: $e');
    }
  }

  Future<List<VerseModel>> _fetchVerses(
      int cantoNumber,
      int chapterNumber,
      String cacheKey,
      ) async {
    try {
      final verses = await NetworkService.instance.run(
            () async {
          final snapshot = await _db
              .collection('bhagavat')
              .doc('canto_$cantoNumber')
              .collection('chapters')
              .doc('chapter_$chapterNumber')
              .collection('verses')
              .get();

          return snapshot.docs.map((doc) {
            return VerseModel.fromFirestore(
              doc.data(),
              doc.id,
              chapterNumber,
              cantoNumber,
            );
          }).toList()
            ..sort((a, b) => a.verseNumber.compareTo(b.verseNumber));
        },
        debugLabel: 'getVerses($cantoNumber,$chapterNumber)',
      );

      await _cache.setString(cacheKey, VerseModel.encodeList(verses));

      return verses;
    } catch (e) {
      _log('$e');

      final cached = _cache.getString(cacheKey);
      if (cached != null) return VerseModel.decodeList(cached);

      rethrow;
    }
  }

  // ── Single Verse ──────────────────────────────

  /// Fetches a single verse. Tries to find in the chapter's cached list first.
  Future<VerseModel?> getVerse(
      int cantoNumber,
      int chapterNumber,
      int verseNumber,
      ) async {
    final cacheKey = CacheService.versesKey(cantoNumber, chapterNumber);
    final cached = _cache.getString(cacheKey);
    if (cached != null) {
      final list = VerseModel.decodeList(cached);
      final found = list.where((v) => v.verseNumber == verseNumber);
      if (found.isNotEmpty) return found.first;
    }

    final verses = await getVerses(cantoNumber, chapterNumber);
    final found = verses.where((v) => v.verseNumber == verseNumber);
    return found.isNotEmpty ? found.first : null;
  }

  // ── Search ────────────────────────────────────

  /// Searches across all cached verses (client-side).
  List<VerseModel> searchCachedVerses(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    final results = <VerseModel>[];

    final prefs = CacheService.instance;
    for (int c = 1; c <= 12; c++) {
      for (int ch = 1; ch <= 50; ch++) {
        final key = CacheService.versesKey(c, ch);
        final cached = prefs.getString(key);
        if (cached == null) continue;
        final verses = VerseModel.decodeList(cached);
        for (final v in verses) {
          if (_verseMatchesQuery(v, q)) {
            results.add(v);
          }
        }
      }
    }
    return results;
  }

  bool _verseMatchesQuery(VerseModel v, String q) {
    return (v.translationEn?.toLowerCase().contains(q) ?? false) ||
        (v.translationHi?.toLowerCase().contains(q) ?? false) ||
        (v.translationGu?.toLowerCase().contains(q) ?? false) ||
        (v.devanagari?.contains(q) ?? false) ||
        (v.transliteration?.toLowerCase().contains(q) ?? false) ||
        (v.purportEn?.toLowerCase().contains(q) ?? false);
  }
}

/// Small helper so fire-and-forget futures don't trigger analyzer warnings
/// and any errors are at least visible in debug mode.
void unawaited(Future<void> future) {
  future.catchError((e) {
    if (kDebugMode) print('Unawaited future error: $e');
  });
}