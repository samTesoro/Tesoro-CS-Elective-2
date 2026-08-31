enum DeviceType {
  mobile,
  tablet,
  desktop,
}

DeviceType getDeviceType(double width) {
  if (width < 600) {
    return DeviceType.mobile;
  } else if (width < 1000) {
    return DeviceType.tablet;
  } else {
    return DeviceType.desktop;
  }
}