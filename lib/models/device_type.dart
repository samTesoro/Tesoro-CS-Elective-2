enum DeviceType {
  compact,
  medium,
  expanded,
  large,
}

DeviceType deviceTypeOf(double width) {
  if (width < 600) {
    return DeviceType.compact;
  }

  if (width < 840) {
    return DeviceType.medium;
  }

  if (width < 1200) {
    return DeviceType.expanded;
  }

  return DeviceType.large;
}