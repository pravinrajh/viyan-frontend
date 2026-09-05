/// Time-of-day greeting for the executive dashboard.
/// Role-neutral by design — callers append the signed-in user's name.
String executiveGreeting({DateTime? now}) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
