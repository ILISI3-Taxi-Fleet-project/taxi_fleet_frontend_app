import 'package:flutter/material.dart';
import 'package:taxi_fleet_frontend_app/components/app_button.dart';
import 'package:taxi_fleet_frontend_app/components/app_input.dart';
import 'package:taxi_fleet_frontend_app/components/app_text.dart';
import 'package:taxi_fleet_frontend_app/config/app_icons.dart';
import 'package:taxi_fleet_frontend_app/helpers/shared_prefs.dart';
import 'package:taxi_fleet_frontend_app/pages/signup_page.dart';
import 'package:taxi_fleet_frontend_app/services/api_service.dart';
import 'package:taxi_fleet_frontend_app/styles/colors.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  bool isObscure = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _submitForm() async {
      
      String email = emailController.text;
      String password = passwordController.text;

      var response = await ApiService.login(email, password) as Map<String, dynamic>;

      if (response != null && response['access-token'] != null) {
        // Check if roles is a non-empty list
        List<dynamic> roles = response['roles'];
        String userId = response['userId'];

        if (roles.isNotEmpty) {
          // Check for the existence of 'Passenger' or 'Driver' role
          String clientType = roles.firstWhere((role) => (role['authority'] as String).startsWith('clientType.'))['authority'];
          print("clientType: $clientType");
          clientType = clientType.substring(clientType.indexOf('.') + 1).toLowerCase();

          SharedPrefs.setUserData(userId, clientType);

          String routeName = '/${clientType}Home';

          // Use the stored route name to push the route
          Navigator.of(context).pushNamed(routeName);

        } else {
          // Handle the case where roles is an empty list
          // This may indicate an issue with the server response
        }
      }

  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.10),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: MediaQuery.of(context).size.height * 0.06),
          child: Column(
            children: [
              //AppText aligned to the left
              const Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  text: 'Hey again!',
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              AppInput(
                controller: emailController,
                icon: Icons.email,
                hintText: 'Email',
              ),
              const SizedBox(height: 20),
              AppInput(
                controller: passwordController,
                icon: Icons.lock,
                hintText: 'Password',
                obscureText: isObscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.secondaryColor,
                  ),
                  onPressed: () => {
                    setState(() {
                      isObscure = !isObscure;
                    })
                  },
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Sign in',
                fontSize: 20,
                borderRadius: 75,
                backgroundColor: AppColors.primaryColor,
                onPressed: () => {
                  _submitForm()
                }
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.center,
                child: AppText(
                  text: 'Forgot password?',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              //a horizontal line with text in the middle
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const AppText(
                    text: 'Or continue with',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              //an empty container with a border
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                //google logo and onpressed function
                child: IconButton(
                  icon: Image.asset(AppIcons.icGoogle),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  text: 'New here?',
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              AppButton(
                text: 'Sign up',
                fontSize: 20,
                borderRadius: 75,
                backgroundColor: AppColors.thirdColor,
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  )
                }
              ),
            ],
          ),
        )
      ),
      ),
    );
  }
}