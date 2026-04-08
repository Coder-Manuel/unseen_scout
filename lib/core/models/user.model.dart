import 'package:unseen_scout/core/entities/user.entity.dart';

class UserModel extends User {
  UserModel({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.email,
    super.firstName,
    super.lastName,
    super.phone,
    super.role,
    super.userStatus,
    super.fcmToken,
    super.isOnline,
    super.rating,
    super.totalReviews,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) => UserModel(
    id: data['id']?.toString(),
    createdAt: data['created_at']?.toString(),
    updatedAt: data['updated_at']?.toString(),
    email: data['email']?.toString(),
    firstName: data['first_name']?.toString(),
    lastName: data['last_name']?.toString(),
    phone: data['phone']?.toString(),
    role: _parseRole(data['role']?.toString()),
    userStatus: _parseStatus(data['status']?.toString()),
    fcmToken: data['fcm_token']?.toString(),
    isOnline: data['is_online'] as bool?,
    rating: (data['rating'] as num?)?.toDouble(),
    totalReviews: data['total_reviews'] as int?,
  );

  static UserRole? _parseRole(String? value) => switch (value) {
    'client' => UserRole.client,
    'scout' => UserRole.scout,
    _ => null,
  };

  static UserStatus? _parseStatus(String? value) => switch (value) {
    'active' => UserStatus.active,
    'inactive' => UserStatus.inactive,
    'suspended' => UserStatus.suspended,
    _ => null,
  };
}
