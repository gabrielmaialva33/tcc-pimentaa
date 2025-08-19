// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      id: UserProfile._objectIdFromJson(json['_id']),
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      crp: json['crp'] as String?,
      specialty: json['specialty'] as String?,
      isProfessionalVerified: json['isProfessionalVerified'] as bool?,
      professionalBio: json['professionalBio'] as String?,
      certifications: (json['certifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      phone: json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      lastLoginIp: json['lastLoginIp'] as String?,
      loginCount: (json['loginCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      '_id': UserProfile._objectIdToJson(instance.id),
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'role': _$UserRoleEnumMap[instance.role]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
      'isEmailVerified': instance.isEmailVerified,
      'crp': instance.crp,
      'specialty': instance.specialty,
      'isProfessionalVerified': instance.isProfessionalVerified,
      'professionalBio': instance.professionalBio,
      'certifications': instance.certifications,
      'phone': instance.phone,
      'profileImageUrl': instance.profileImageUrl,
      'preferences': instance.preferences,
      'metadata': instance.metadata,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'lastLoginIp': instance.lastLoginIp,
      'loginCount': instance.loginCount,
    };

const _$UserRoleEnumMap = {
  UserRole.user: 'user',
  UserRole.analyst: 'analyst',
};
