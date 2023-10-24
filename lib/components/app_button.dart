import 'package:flutter/material.dart';
import 'package:taxi_fleet_frontend_app/styles/colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final double borderRadius;
  final double buttonSize;
  final double fontSize;
  final FontWeight fontWeight;
  final double width = double.infinity;

  const AppButton({
    Key? key,
    required this.text,
    this.textColor = AppColors.textColor,
    this.backgroundColor = AppColors.primaryColor,
    this.borderRadius = 10.0,
    this.buttonSize = 48.0,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.bold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonSize,
      width: width,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
