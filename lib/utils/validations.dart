class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address.';
    }
    if (!value.contains(RegExp(r'.com'))) {
      return 'Enter a valid email contain .com';
    }
    return null;
  }
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }
  static String? validateName(String? value){
    if( value == null || value.isEmpty){
      return 'Name is required.';
    }
    if(!value.startsWith(RegExp(r'[A-Z]'))&& !value.contains(RegExp(r'[a-z]'))){
      return 'Name should Contain only letters';
    }
    return null;
  }
}