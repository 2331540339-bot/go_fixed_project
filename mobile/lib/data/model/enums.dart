// enums.dart
enum UserRole { endUser, mechanic, admin }
extension UserRoleX on UserRole {
  static UserRole from(String? s) {
    switch (s) {
      case 'end_user': return UserRole.endUser;
      case 'mechanic': return UserRole.mechanic;
      case 'admin':    return UserRole.admin;
      default:         return UserRole.endUser;
    }
  }
  String get json => switch (this) {
    UserRole.endUser => 'end_user',
    UserRole.mechanic => 'mechanic',
    UserRole.admin => 'admin',
  };
}

enum ServiceKind { simpleServices, complexServices }
extension ServiceKindX on ServiceKind {
  static ServiceKind from(String? s) {
    switch (s) {
      case 'simple_services': return ServiceKind.simpleServices;
      case 'complex_services': return ServiceKind.complexServices;
      default: return ServiceKind.simpleServices;
    }
  }
  String get json => switch (this) {
    ServiceKind.simpleServices => 'simple_services',
    ServiceKind.complexServices => 'complex_services',
  };
}

enum RescueRequestStatus { pending, accepted, inProgress, completed, cancelled }
extension RescueRequestStatusX on RescueRequestStatus {
  static RescueRequestStatus from(String? s) {
    switch (s) {
      case 'pending':     return RescueRequestStatus.pending;
      case 'accepted':    return RescueRequestStatus.accepted;
      case 'in_progress': return RescueRequestStatus.inProgress;
      case 'completed':   return RescueRequestStatus.completed;
      case 'cancelled':   return RescueRequestStatus.cancelled;
      default:            return RescueRequestStatus.pending;
    }
  }
  String get json => switch (this) {
    RescueRequestStatus.pending => 'pending',
    RescueRequestStatus.accepted => 'accepted',
    RescueRequestStatus.inProgress => 'in_progress',
    RescueRequestStatus.completed => 'completed',
    RescueRequestStatus.cancelled => 'cancelled',
  };
}

enum PaymentStatus { unpaid, paid }
extension PaymentStatusX on PaymentStatus {
  static PaymentStatus from(String? s) {
    switch (s) {
      case 'paid': return PaymentStatus.paid;
      default:     return PaymentStatus.unpaid;
    }
  }
  String get json => this == PaymentStatus.paid ? 'paid' : 'unpaid';
}

enum OrderStatus { pending, confirmed, delivering, completed, cancelled }
extension OrderStatusX on OrderStatus {
  static OrderStatus from(String? s) {
    switch (s) {
      case 'pending':    return OrderStatus.pending;
      case 'confirmed':  return OrderStatus.confirmed;
      case 'delivering': return OrderStatus.delivering;
      case 'completed':  return OrderStatus.completed;
      case 'cancelled':  return OrderStatus.cancelled;
      default:           return OrderStatus.pending;
    }
  }
  String get json => switch (this) {
    OrderStatus.pending => 'pending',
    OrderStatus.confirmed => 'confirmed',
    OrderStatus.delivering => 'delivering',
    OrderStatus.completed => 'completed',
    OrderStatus.cancelled => 'cancelled',
  };
}
