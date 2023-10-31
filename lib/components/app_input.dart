import 'package:flutter/material.dart';
import 'package:taxi_fleet_frontend_app/styles/colors.dart';

/*class AppInput extends StatefulWidget {
  final IconData? icon;
  final String hintText;
  final bool obscureText;
  final IconButton? suffixIcon;
  final Function(String)? updateValue;

  AppInput({
    Key? key,
    this.icon,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.updateValue,
  }) : super(key: key);

  @override
  _AppInputState createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        obscureText: widget.obscureText,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: AppColors.secondaryColor),
          prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
          suffixIcon: widget.suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        controller: controller,
        onChanged: (value) => {
          if (widget.updateValue != null) {
            widget.updateValue!(value),
          }
        }
      ),
    );
  }
}*/


class AppInput extends StatelessWidget {
  final IconData? icon;
  final String hintText;
  final bool obscureText;
  final IconButton? suffixIcon;
  final TextEditingController? controller;

  const AppInput({
    Key? key,
    this.icon,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
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
        controller: controller,
      ),
    );
  }
}
