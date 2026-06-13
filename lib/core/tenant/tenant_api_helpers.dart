/// Helper per API tenant / errori XenForo mobile.
class TenantApiHelpers {
  TenantApiHelpers._();

  static bool isMissingEndpoint(String? message) {
    if (message == null || message.isEmpty) return false;
    final lower = message.toLowerCase();
    return lower.contains('requested endpoint') ||
        lower.contains('cannot be found') ||
        lower.contains('endpoint_not_found') ||
        (lower.contains('not found') && lower.contains('endpoint'));
  }
}
