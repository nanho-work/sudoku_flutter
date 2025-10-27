import 'package:cloud_firestore/cloud_firestore.dart';

/// 캐릭터/배경 공통 아이템
class SkinItem {
  final String id;
  final String name;
  final String type;
  final String imageUrl;
  final String bgUrl;
  final bool defaultUnlocked;
  final String unlockType;
  final int unlockCost;

  SkinItem({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.bgUrl,
    this.defaultUnlocked = false,
    this.unlockType = 'default',
    this.unlockCost = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'imageUrl': imageUrl,
        'bgUrl': bgUrl,
        'defaultUnlocked': defaultUnlocked,
        'unlockType': unlockType,
        'unlockCost': unlockCost,
      };

  factory SkinItem.fromMap(Map<String, dynamic> data) => SkinItem(
        id: data['id'] ?? '',
        name: data['name'] ?? '',
        type: data['type'] ?? 'char',
        imageUrl: data['imageUrl'] ?? '',
        bgUrl: data['bgUrl'] ?? '',
        defaultUnlocked: (data['defaultUnlocked'] ?? false) as bool,
        unlockType: data['unlockType'] ?? 'default',
        unlockCost: (data['unlockCost'] ?? 0) as int,
      );
}

/// 유저의 스킨 상태(해금 목록 + 선택 중인 스킨)
class SkinState {
  final String selectedCharId; // 예: "char_koofy_lv1"
  final String selectedBgId;   // 예: "bg_koofy_lv1"
  final Set<String> unlockedIds;
  final DateTime updatedAt;

  SkinState({
    required this.selectedCharId,
    required this.selectedBgId,
    required this.unlockedIds,
    required this.updatedAt,
  });

  SkinState copyWith({
    String? selectedCharId,
    String? selectedBgId,
    Set<String>? unlockedIds,
    DateTime? updatedAt,
  }) {
    return SkinState(
      selectedCharId: selectedCharId ?? this.selectedCharId,
      selectedBgId: selectedBgId ?? this.selectedBgId,
      unlockedIds: unlockedIds ?? this.unlockedIds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'selectedCharId': selectedCharId,
        'selectedBgId': selectedBgId,
        'unlockedIds': unlockedIds.toList(),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory SkinState.fromMap(Map<String, dynamic> data) => SkinState(
        selectedCharId: data['selectedCharId'] ?? 'char_koofy_lv1',
        selectedBgId: data['selectedBgId'] ?? 'bg_koofy_lv1',
        unlockedIds: Set<String>.from((data['unlockedIds'] as List?) ?? const []),
        updatedAt: (data['updatedAt'] is Timestamp)
            ? (data['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
}