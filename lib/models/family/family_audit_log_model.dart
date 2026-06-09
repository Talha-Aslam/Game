import 'package:flutter/material.dart';

/// Audit log action types
enum AuditAction {
  memberJoined,
  memberLeft,
  memberKicked,
  memberInvited,
  memberPromoted,
  memberDemoted,
  memberMuted,
  memberBanned,
  ownershipTransferred,
  settingsChanged,
  motdUpdated,
  treasuryDonation,
  treasurySpent,
  boostActivated,
  familyCreated;

  String get displayName {
    switch (this) {
      case AuditAction.memberJoined:
        return 'Joined';
      case AuditAction.memberLeft:
        return 'Left';
      case AuditAction.memberKicked:
        return 'Kicked';
      case AuditAction.memberInvited:
        return 'Invited';
      case AuditAction.memberPromoted:
        return 'Promoted';
      case AuditAction.memberDemoted:
        return 'Demoted';
      case AuditAction.memberMuted:
        return 'Muted';
      case AuditAction.memberBanned:
        return 'Banned';
      case AuditAction.ownershipTransferred:
        return 'Ownership Transferred';
      case AuditAction.settingsChanged:
        return 'Settings Changed';
      case AuditAction.motdUpdated:
        return 'MOTD Updated';
      case AuditAction.treasuryDonation:
        return 'Treasury Donation';
      case AuditAction.treasurySpent:
        return 'Treasury Spent';
      case AuditAction.boostActivated:
        return 'Boost Activated';
      case AuditAction.familyCreated:
        return 'Family Created';
    }
  }

  IconData get icon {
    switch (this) {
      case AuditAction.memberJoined:
        return Icons.person_add;
      case AuditAction.memberLeft:
        return Icons.exit_to_app;
      case AuditAction.memberKicked:
        return Icons.person_remove;
      case AuditAction.memberInvited:
        return Icons.mail;
      case AuditAction.memberPromoted:
        return Icons.arrow_upward;
      case AuditAction.memberDemoted:
        return Icons.arrow_downward;
      case AuditAction.memberMuted:
        return Icons.volume_off;
      case AuditAction.memberBanned:
        return Icons.block;
      case AuditAction.ownershipTransferred:
        return Icons.swap_horiz;
      case AuditAction.settingsChanged:
        return Icons.settings;
      case AuditAction.motdUpdated:
        return Icons.campaign;
      case AuditAction.treasuryDonation:
        return Icons.volunteer_activism;
      case AuditAction.treasurySpent:
        return Icons.payments;
      case AuditAction.boostActivated:
        return Icons.bolt;
      case AuditAction.familyCreated:
        return Icons.celebration;
    }
  }

  Color get color {
    switch (this) {
      case AuditAction.memberJoined:
      case AuditAction.memberInvited:
        return const Color(0xFF00E676);
      case AuditAction.memberLeft:
        return const Color(0xFF616161);
      case AuditAction.memberKicked:
      case AuditAction.memberBanned:
        return const Color(0xFFFF1744);
      case AuditAction.memberPromoted:
        return const Color(0xFFFFD700);
      case AuditAction.memberDemoted:
        return const Color(0xFFFF9100);
      case AuditAction.memberMuted:
        return const Color(0xFFFFC107);
      case AuditAction.ownershipTransferred:
        return const Color(0xFF9B59FF);
      case AuditAction.settingsChanged:
      case AuditAction.motdUpdated:
        return const Color(0xFF00E5FF);
      case AuditAction.treasuryDonation:
      case AuditAction.treasurySpent:
      case AuditAction.boostActivated:
        return const Color(0xFFFFD700);
      case AuditAction.familyCreated:
        return const Color(0xFF9B59FF);
    }
  }
}

/// Audit log entry
class FamilyAuditEntry {
  final String id;
  final AuditAction action;
  final String actorId;
  final String actorName;
  final String? targetId;
  final String? targetName;
  final String? details;
  final DateTime timestamp;

  const FamilyAuditEntry({
    required this.id,
    required this.action,
    required this.actorId,
    required this.actorName,
    this.targetId,
    this.targetName,
    this.details,
    required this.timestamp,
  });

  String get description {
    switch (action) {
      case AuditAction.memberJoined:
        return '$actorName joined the family';
      case AuditAction.memberLeft:
        return '$actorName left the family';
      case AuditAction.memberKicked:
        return '$actorName kicked ${targetName ?? "a member"}';
      case AuditAction.memberInvited:
        return '$actorName invited ${targetName ?? "a player"}';
      case AuditAction.memberPromoted:
        return '$actorName promoted ${targetName ?? "a member"}';
      case AuditAction.memberDemoted:
        return '$actorName demoted ${targetName ?? "a member"}';
      case AuditAction.memberMuted:
        return '$actorName muted ${targetName ?? "a member"}';
      case AuditAction.memberBanned:
        return '$actorName banned ${targetName ?? "a member"}';
      case AuditAction.ownershipTransferred:
        return '$actorName transferred ownership to ${targetName ?? "a member"}';
      case AuditAction.settingsChanged:
        return '$actorName updated family settings';
      case AuditAction.motdUpdated:
        return '$actorName updated the MOTD';
      case AuditAction.treasuryDonation:
        return '$actorName donated ${details ?? "points"} to treasury';
      case AuditAction.treasurySpent:
        return '$actorName spent ${details ?? "points"} from treasury';
      case AuditAction.boostActivated:
        return '$actorName activated ${details ?? "a boost"}';
      case AuditAction.familyCreated:
        return '$actorName created the family';
    }
  }
}
