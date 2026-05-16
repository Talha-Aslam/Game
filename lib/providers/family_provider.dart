import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_model.dart';

final familyProvider = Provider<FamilyModel?>((ref) {
  return FamilyModel(
    id: 'family_001',
    name: 'Cobra Dynasty',
    tag: '[COBRA]',
    description: 'Strike fast, vanish faster.',
    memberCount: 32,
    maxMembers: 50,
    totalWins: 456,
    seasonPoints: 12500,
    members: const [
      FamilyMember(userId: 'u1', username: 'ShadowKing', role: FamilyRole.boss, isOnline: true, contributedPoints: 3200),
      FamilyMember(userId: 'u2', username: 'NightViper', role: FamilyRole.underboss, isOnline: true, contributedPoints: 2800),
      FamilyMember(userId: 'u3', username: 'IronFist', role: FamilyRole.capo, isOnline: false, contributedPoints: 1900),
      FamilyMember(userId: 'u4', username: 'GhostWalker', role: FamilyRole.capo, isOnline: true, contributedPoints: 1500),
      FamilyMember(userId: 'u5', username: 'RedPhantom', role: FamilyRole.associate, isOnline: false, contributedPoints: 800),
    ],
  );
});
