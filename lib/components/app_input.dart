import 'package:flutter/material.dart';
import 'package:taxi_fleet_frontend_app/styles/colors.dart';

class AppInput extends StatelessWidget {
  final IconData? icon;
  final String hintText;
  final bool obscureText;
  final IconButton? suffixIcon;

  const AppInput({
    Key? key,
    this.icon,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.secondaryColor),
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
