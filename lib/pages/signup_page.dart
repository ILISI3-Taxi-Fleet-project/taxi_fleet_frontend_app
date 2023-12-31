import 'package:flutter/material.dart';
import 'package:taxi_fleet_frontend_app/components/app_button.dart';
import 'package:taxi_fleet_frontend_app/components/app_input.dart';
import 'package:taxi_fleet_frontend_app/services/api_service.dart';
import 'package:taxi_fleet_frontend_app/styles/colors.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  clientType _clientType = clientType.passenger;
  bool _isObscure = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _submitForm() async {
      String firstName = firstNameController.text;
      String lastName = lastNameController.text;
      String phoneNumber = phoneNumberController.text;
      String email = emailController.text;
      String password = passwordController.text;

      bool response = await ApiService.signup(firstName, lastName, phoneNumber, _clientType.toString(), email, password);

      if(response){
        // push route '/mainpage'
        Navigator.pushNamed(context, '/signinpage');
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,     
      appBar: AppBar(
        title: const Text("Fill your profile"),
        // add margin to the top of the app bar
        toolbarHeight: 80,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
        //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: MediaQuery.of(context).size.height * 0.04),
        child:Column(
          children: [
            // picture chooser, as a cercle  with a plus sign
            Center(
              child: Container(
                width: 100, // Adjust the size as needed
                height: 100, // Adjust the size as needed
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryColor, // Background color for unknown picture
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor
                      ),
                      child:const Align(
                          alignment: Alignment.center,
                          child:Icon(
                            Icons.add, // Plus sign icon
                            size: 20, // Adjust the size as needed
                            color: Colors.white,
                          )
                      ),
                      
                    )
                  ],
                )
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            AppInput(
              icon: Icons.person,
              hintText: 'First name',
              controller: firstNameController,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            AppInput(
              icon: Icons.calendar_today,
              hintText: 'Last name',
              controller: lastNameController,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            AppInput(
              icon: Icons.phone,
              hintText: 'Phone number',
              controller: phoneNumberController,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            // Client Type
            Row(
              children: [
                Expanded(
                  child:SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => {
                        setState(() {
                          _clientType = clientType.driver;
                        })
                      },
                      style: ElevatedButton.styleFrom(
                        primary: _clientType == clientType.driver ? AppColors.primaryColor : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      ),
                      child: Text("Driver", style: TextStyle(color: _clientType == clientType.driver ? Colors.white : AppColors.textColor),),
                    ),
                  )
                ),
                const SizedBox(width: 20),
                Expanded(
                  child:SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => {
                        setState(() {
                          _clientType = clientType.passenger;
                        })
                      },
                      style: ElevatedButton.styleFrom(
                        primary: _clientType == clientType.passenger ? AppColors.primaryColor : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      ),
                      child: Text("Passenger", style: TextStyle(color: _clientType == clientType.passenger ? Colors.white : AppColors.textColor),),
                    ),
                  )
                ),

              ],
            ),
            // email
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            AppInput(
              icon: Icons.email,
              hintText: 'Email',
              controller: emailController,
            ),
            // password
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            AppInput(
              icon: Icons.lock,
              hintText: 'Password',
              controller: passwordController,
              obscureText: _isObscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.secondaryColor,
                ),
                onPressed: () => {
                  setState(() {
                    _isObscure = !_isObscure;
                  })
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          ],
        )
      ),
      ),
      //footer submit button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: AppButton(
          text: 'Submit',
          fontSize: 20,
          borderRadius: 75,
          backgroundColor: AppColors.primaryColor,
          onPressed: () => {
            _submitForm(),
          },
        ),
      ),
    );
  }
}


// client type enum
enum clientType { driver, passenger }
