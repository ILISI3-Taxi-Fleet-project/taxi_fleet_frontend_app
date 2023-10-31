import 'package:flutter/material.dart';
import 'package:taxi_fleet_frontend_app/components/app_button.dart';
import 'package:taxi_fleet_frontend_app/components/app_input.dart';
import 'package:taxi_fleet_frontend_app/components/app_text.dart';
import 'package:taxi_fleet_frontend_app/config/app_icons.dart';
import 'package:taxi_fleet_frontend_app/pages/main_page.dart';
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
      
      bool response = await ApiService.login(email, password);
      
      if(response){
        // push route '/mainpage'
        Navigator.pushNamed(context, '/mainpage');
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
      resizeToAvoidBottomInset: false,
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.10),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: MediaQuery.of(context).size.height * 0.06),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              AppInput(
                controller: emailController,
                icon: Icons.email,
                hintText: 'Email',
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              AppButton(
                text: 'Sign in',
                fontSize: 20,
                borderRadius: 75,
                backgroundColor: AppColors.primaryColor,
                onPressed: () => {
                  _submitForm()
                }
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
              SizedBox(height: 20),
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
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  text: 'New here?',
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
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
    );
  }
}