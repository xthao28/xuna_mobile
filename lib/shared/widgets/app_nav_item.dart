/// One destination of [AppBottomNavBar].
class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.iconAsset,
    required this.activeIconAsset,
  });

  final String label;
  final String iconAsset;
  final String activeIconAsset;
}
