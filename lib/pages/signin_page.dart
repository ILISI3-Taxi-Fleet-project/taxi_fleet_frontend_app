import 'package:flutter/material.dart';
import 'package:taxi_fleet_frontend_app/components/app_button.dart';
import 'package:taxi_fleet_frontend_app/components/app_input.dart';
import 'package:taxi_fleet_frontend_app/components/app_text.dart';
import 'package:taxi_fleet_frontend_app/misc/colors.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 100),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          children: [
            //AppText aligned to the left
            Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                text: 'Hey again!',
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50),
            AppInput(
              icon: Icons.email,
              hintText: 'Email',
            ),
            SizedBox(height: 20),
            AppInput(
              icon: Icons.lock,
              hintText: 'Password',
              obscureText: true,
            ),
            SizedBox(height: 20),
            AppButton(
              text: 'Sign in',
              fontSize: 20,
              borderRadius: 75,
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: AppText(
                text: 'Forgot password?',
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 25),
            //a horizontal line with text in the middle
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(width: 10),
                AppText(
                  text: 'Or continue with',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            //an empty container with a border
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textColor),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                text: 'New here?',
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            AppButton(
              text: 'Sign up',
              fontSize: 20,
              borderRadius: 75,
              backgroundColor: AppColors.thirdColor,
            ),
          ],
        ),
      ),
    );
  }
}