import 'package:shared_preferences/shared_preferences.dart';

final String themeColorKey = "themeColor";
Future<double> getFontSize() async {
//  SharedPreferences prefs = await SharedPreferences.getInstance();
//  return prefs.getDouble(fontSizeKey) ?? 18;
return 18;
}

Future<int> getThemeColor() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(themeColorKey) ?? 0;
}

Future<void> storeThemeColor(int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(themeColorKey, value);
}