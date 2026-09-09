class BuildCounter {
  BuildCounter._();

  static int eventTile = 0;
  static int eventSection = 0;
  static int cartBadge = 0;

  static void reset() {
    eventTile = 0;
    eventSection = 0;
    cartBadge = 0;
  }
}
