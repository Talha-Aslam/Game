class BountyModel {
  final String id;
  final String actionType;
  final String description;
  final String icon;
  final int current;
  final int total;
  final int xp;
  final String status;

  BountyModel({
    required this.id,
    required this.actionType,
    required this.description,
    required this.icon,
    required this.current,
    required this.total,
    required this.xp,
    required this.status,
  });

  factory BountyModel.fromJson(Map<String, dynamic> json) {
    return BountyModel(
      id: json['id'] as String,
      actionType: json['action_type'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      current: json['current'] as int,
      total: json['total'] as int,
      xp: json['xp'] as int,
      status: json['status'] as String,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isClaimed => status == 'claimed';
}
