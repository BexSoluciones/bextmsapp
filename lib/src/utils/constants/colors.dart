import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFEA5A2B);
const kPrimaryLightColor = Color(0xFFff6330);

const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF5252), Color(0xFFFBC02D)],
);

const kSecondaryColor = Color(0xFF000000);
const kCardColor = Color(0xE6E84118);
const kTextColor = Colors.black;
const kTextDarkColor = Color(0xFF757575);
const kContentColorLightTheme = Color(0xFF1D1D35);
const kContentColorDarkTheme = Color(0xFFF5FCF9);
const kWarningColor = Color(0xFFF3BB1C);
const kErrorColor = Color(0xFFF03738);

// Form Error
final RegExp emailValidatorRegExp =
RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
const String kEmailNullError = 'Por favor ingresa un correo';
const String kInvalidEmailError = 'Porfavor ingresa un correo válido';
const String kPassNullError = 'Porfavor ingresa una contraseña';
const String kShortPassError = 'La contraseña es demasiado corta';
const String kMatchPassError = 'La contraseña no coindice';
const String kNameNullError = 'Porfavor ingresa un nombre';
const String kPhoneNumberNullError = 'Porfavor ingresa tu número de telefono';
const String kAddressNullError = 'Porfavor ingresa tu dirección';