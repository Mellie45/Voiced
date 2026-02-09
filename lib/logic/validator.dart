class Validator {
  static bool validateName(String text) {
    return text.contains(RegExp(r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$"));
  }

  static bool validateNumber(String text) {
    RegExp regex = RegExp(r'^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$');
    return regex.hasMatch(text);
  }

  static bool validateEmail(String text) {
    RegExp regex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    return regex.hasMatch(text);
  }

  static bool validatePassword(String text) {
    // Check for at least 8 characters, one letter, and one number
    RegExp regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return regex.hasMatch(text);
  }
}
