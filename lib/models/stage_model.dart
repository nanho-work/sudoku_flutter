import 'dart:convert';

/// 🧩 스테이지 기본 정보 모델 (정형 + grid 기반)
/// Firestore 또는 로컬 JSON 파일로부터 로드됨
class StageModel {
  final String id;
  final String name;
  final String description;
  final int gridSize;
  final Map<String, dynamic> rewards;      // {"gold":10,"gem":1,"exp":5}
  final Map<String, dynamic>? conditions;  // {"max_hints":1,"max_wrong":2,"time_limit":60}
  final String? unlockCondition;
  final bool fixedPuzzle;
  final int? removeCount;
  final List<List<int>>? puzzle;
  final List<List<int>>? solution;
  final List<int>? shape;                  // [blockRows, blockCols]
  final String? updatedAt;
  final String? thumbnail;

  StageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.gridSize,
    required this.rewards,
    this.conditions,
    this.unlockCondition,
    this.fixedPuzzle = false,
    this.removeCount,
    this.puzzle,
    this.solution,
    this.shape,
    this.updatedAt,
    this.thumbnail,
  });

  factory StageModel.fromJson(Map<String, dynamic> json) {
    List<List<int>>? _parse2DList(dynamic data) {
      if (data == null) return null;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {
          return null;
        }
      }
      if (data is List) {
        return data.map((e) => List<int>.from(e)).toList();
      }
      return null;
    }

    return StageModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      gridSize: json['grid_size'] ?? 9,
      rewards: Map<String, dynamic>.from(json['rewards'] ?? {}),
      conditions: json['conditions'] != null
          ? Map<String, dynamic>.from(json['conditions'])
          : null,
      unlockCondition: json['unlock_condition'],
      fixedPuzzle: json['fixed_puzzle'] ?? false,
      removeCount: json['remove_count'],
      puzzle: _parse2DList(json['puzzle']),
      solution: _parse2DList(json['solution']),
      shape: json['shape'] != null ? List<int>.from(json['shape']) : null,
      updatedAt: json['updated_at'],
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'grid_size': gridSize,
        'rewards': rewards,
        'conditions': conditions,
        'unlock_condition': unlockCondition,
        'fixed_puzzle': fixedPuzzle,
        'remove_count': removeCount,
        'puzzle': puzzle,
        'solution': solution,
        'shape': shape,
        'updated_at': updatedAt,
        'thumbnail': thumbnail,
      };
}