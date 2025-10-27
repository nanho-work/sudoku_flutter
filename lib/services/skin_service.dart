import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skin_model.dart';

/// 서버 소스(R/W). Firestore 스키마:
/// - skins_catalog (collection): 각 문서 {id,type,assetPath,defaultUnlocked}
/// - users/{uid}/skins_state/state (document): {selectedCharId, selectedBgId, unlockedIds[], updatedAt}
class SkinService {
  static final _db = FirebaseFirestore.instance;

  /// 서버 카탈로그 조회. 없으면 빈 리스트.
  static Future<List<SkinItem>> fetchCatalog() async {
    final snap = await _db.collection('skins').get(); // ✅ 컬렉션명 수정
    if (snap.docs.isEmpty) return [];
    return snap.docs.map((d) => SkinItem.fromMap(d.data())).toList();
  }

  /// 기본 카탈로그(오프라인/빈 서버 대비)
  static List<SkinItem> fallbackCatalog() => [
    SkinItem(
        id: 'char_koofy_lv1',
        name: '쿠피 (Lv.1)',
        type: 'char',
        imageUrl: 'assets/images/char_koofy_lv1.png',
        bgUrl: 'assets/images/bg_koofy_lv1.png',
        defaultUnlocked: true,
        unlockType: 'default',
        unlockCost: 0,
    ),
    ];

  /// 유저 상태 조회. 없으면 기본 상태 생성 후 반환.
  static Future<SkinState> fetchOrInitUserState(String userId, List<SkinItem> catalog) async {
    final ref = _db.collection('users').doc(userId).collection('skins_state').doc('state');
    final snap = await ref.get();

    if (snap.exists) {
      return SkinState.fromMap(snap.data()!);
    }

    // 초기 해금 세트와 기본 선택값 구성
    final defaults = catalog.where((e) => e.defaultUnlocked).map((e) => e.id).toSet();
    final defaultChar = catalog.firstWhere((e) => e.type == 'char' && e.defaultUnlocked,
        orElse: () => SkinItem(
              id: 'char_koofy_lv1',
              name: '쿠피 (Lv.1)',
              type: 'char',
              imageUrl: 'assets/images/char_koofy_lv1.png',
              bgUrl: 'assets/images/bg_koofy_lv1.png',
              defaultUnlocked: true,
              unlockType: 'default',
              unlockCost: 0,
            ));
    final defaultBg = catalog.firstWhere((e) => e.type == 'bg' && e.defaultUnlocked,
        orElse: () => SkinItem(
              id: 'bg_koofy_lv1',
              name: '쿠피 배경 (Lv.1)',
              type: 'bg',
              imageUrl: 'assets/images/char_koofy_lv1.png',
              bgUrl: 'assets/images/bg_koofy_lv1.png',
              defaultUnlocked: true,
              unlockType: 'default',
              unlockCost: 0,
            ));

    final init = SkinState(
      selectedCharId: defaultChar.id,
      selectedBgId: defaultBg.id,
      unlockedIds: defaults,
      updatedAt: DateTime.now(),
    );

    await ref.set({
      ...init.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 서버 Timestamp 반영 전이라도 즉시 사용
    return init;
  }

  /// 아이템 해금/잠금
  static Future<void> setUnlocked(String userId, String skinId, bool unlocked) async {
    final ref = _db.collection('users').doc(userId).collection('skins_state').doc('state');
    await _db.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final state = snap.exists ? SkinState.fromMap(snap.data()!) : null;
      final set = {...(state?.unlockedIds ?? <String>{})};
      if (unlocked) {
        set.add(skinId);
      } else {
        set.remove(skinId);
      }
      txn.set(ref, {
        'unlockedIds': set.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  /// 선택 변경(캐릭터/배경 중 일부만 변경 가능)
  static Future<void> select(String userId, {String? charId, String? bgId}) async {
    if (charId == null && bgId == null) return;
    final ref = _db.collection('users').doc(userId).collection('skins_state').doc('state');
    final data = <String, dynamic>{
      if (charId != null) 'selectedCharId': charId,
      if (bgId != null) 'selectedBgId': bgId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await ref.set(data, SetOptions(merge: true));
  }

  /// 로컬 상태를 서버에 반영(오프라인 해금 이력 동기화 등)
  static Future<void> syncFromLocal(String userId, SkinState local) async {
    final ref = _db.collection('users').doc(userId).collection('skins_state').doc('state');
    await ref.set({
      'selectedCharId': local.selectedCharId,
      'selectedBgId': local.selectedBgId,
      'unlockedIds': local.unlockedIds.toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}