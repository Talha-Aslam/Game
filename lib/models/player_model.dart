/// Game roles
enum GameRole {
  mafia,
  doctor,
  detective,
  civilian;

  String get displayName {
    switch (this) {
      case GameRole.mafia:
        return 'Mafia';
      case GameRole.doctor:
        return 'Doctor';
      case GameRole.detective:
        return 'Detective';
      case GameRole.civilian:
        return 'Civilian';
    }
  }

  String get description {
    switch (this) {
      case GameRole.mafia:
        return 'Eliminate civilians under the cover of night';
      case GameRole.doctor:
        return 'Save one player each night from elimination';
      case GameRole.detective:
        return 'Investigate one player each night';
      case GameRole.civilian:
        return 'Find and vote out the mafia';
    }
  }
}

/// Player alive/dead state
enum PlayerStatus { alive, eliminated }

/// Voice activity state
enum VoiceState { muted, idle, speaking }

/// Player model
class PlayerModel {
  final String id;
  final String name;
  final String avatarUrl;
  final GameRole? role; // null until revealed or assigned
  final PlayerStatus status;
  final VoiceState voiceState;
  final String? familyTag;
  final int rankTier; // 0=Bronze, 1=Silver, 2=Gold, 3=Diamond, 4=Syndicate Boss
  final String? voteTargetId; // player ID they voted for (local only)
  final bool isProtected; // Doctor saved this round
  final bool isInvestigated; // Detective checked this round
  final int avatarIndex; // distinct avatar color/letter combo index
  final bool isEliminating; // triggers shatter animation
  final int commendations; // commendation count
  final Map<String, dynamic> equippedCosmetics;

  const PlayerModel({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.role,
    this.status = PlayerStatus.alive,
    this.voiceState = VoiceState.idle,
    this.familyTag,
    this.rankTier = 0,
    this.voteTargetId,
    this.isProtected = false,
    this.isInvestigated = false,
    this.avatarIndex = 0,
    this.isEliminating = false,
    this.commendations = 0,
    this.equippedCosmetics = const {},
  });

  PlayerModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    GameRole? role,
    PlayerStatus? status,
    VoiceState? voiceState,
    String? familyTag,
    int? rankTier,
    String? voteTargetId,
    bool? isProtected,
    bool? isInvestigated,
    int? avatarIndex,
    bool? isEliminating,
    int? commendations,
    Map<String, dynamic>? equippedCosmetics,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      voiceState: voiceState ?? this.voiceState,
      familyTag: familyTag ?? this.familyTag,
      rankTier: rankTier ?? this.rankTier,
      voteTargetId: voteTargetId ?? this.voteTargetId,
      isProtected: isProtected ?? this.isProtected,
      isInvestigated: isInvestigated ?? this.isInvestigated,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      isEliminating: isEliminating ?? this.isEliminating,
      commendations: commendations ?? this.commendations,
      equippedCosmetics: equippedCosmetics ?? this.equippedCosmetics,
    );
  }

  bool get isAlive => status == PlayerStatus.alive;
  bool get isSpeaking => voiceState == VoiceState.speaking;
  bool get isMafia => role == GameRole.mafia;

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      role: json['role'] != null
          ? GameRole.values.byName(json['role'] as String)
          : null,
      status: PlayerStatus.values.byName(json['status'] as String? ?? 'alive'),
      voiceState:
          VoiceState.values.byName(json['voiceState'] as String? ?? 'idle'),
      familyTag: json['familyTag'] as String?,
      rankTier: json['rankTier'] as int? ?? 0,
      avatarIndex: json['avatarIndex'] as int? ?? 0,
      commendations: json['commendations'] as int? ?? 0,
      equippedCosmetics: json['equippedCosmetics'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role?.name,
      'status': status.name,
      'voiceState': voiceState.name,
      'familyTag': familyTag,
      'rankTier': rankTier,
      'avatarIndex': avatarIndex,
      'commendations': commendations,
      'equippedCosmetics': equippedCosmetics,
    };
  }
}
