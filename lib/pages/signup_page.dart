import 'package:flutter/material.dart';
import 'package:taxi_fleet_frontend_app/components/app_button.dart';
import 'package:taxi_fleet_frontend_app/components/app_input.dart';
import 'package:taxi_fleet_frontend_app/components/app_text.dart';
import 'package:taxi_fleet_frontend_app/config/app_icons.dart';
import 'package:taxi_fleet_frontend_app/styles/colors.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  clientType _clientType = clientType.passenger;
  bool _isObscure = true;
  Client _client = Client(
    name: '',
    birthDate: '',
    phoneNumber: '',
    email: '',
    password: '',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,     
      appBar: AppBar(
        title: Text("Fill your profile"),
        // add margin to the top of the app bar
        toolbarHeight: 80,
      ),
      body: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: MediaQuery.of(context).size.height * 0.04),
          child:Column(
            children: [
              // picture chooser, as a cercle  with a plus sign
              Center(
                child: Container(
                  width: 100, // Adjust the size as needed
                  height: 100, // Adjust the size as needed
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondaryColor, // Background color for unknown picture
                  ),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor
                        ),
                        child:Align(
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
                hintText: 'Full name',
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              AppInput(
                icon: Icons.calendar_today,
                hintText: 'Birth date',
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              AppInput(
                icon: Icons.phone,
                hintText: 'Phone number',
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
                        child: Text("Driver", style: TextStyle(color: _clientType == clientType.driver ? Colors.white : AppColors.textColor),),
                        style: ElevatedButton.styleFrom(
                          primary: _clientType == clientType.driver ? AppColors.primaryColor : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          )
                        ),
                      ),
                    )
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child:SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => {
                          setState(() {
                            _clientType = clientType.passenger;
                          })
                        },
                        child: Text("Passenger", style: TextStyle(color: _clientType == clientType.passenger ? Colors.white : AppColors.textColor),),
                        style: ElevatedButton.styleFrom(
                          primary: _clientType == clientType.passenger ? AppColors.primaryColor : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          )
                        ),
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
              ),
              // password
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              AppInput(
                icon: Icons.lock,
                hintText: 'Password',
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
        )
      ),
      //footer submit button
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: AppButton(
          text: 'Submit',
          fontSize: 20,
          borderRadius: 75,
          backgroundColor: AppColors.primaryColor,
          onPressed: () => {},
        ),
      ),
    );
  }
}


// client type enum
enum clientType { driver, passenger }

// client class
class Client {
  String name;
  String birthDate;
  String phoneNumber;
  String picture;
  clientType type;
  String email;
  String password;

  Client({
    required this.name,
    required this.birthDate,
    required this.phoneNumber,
    this.picture = '',
    this.type = clientType.passenger,
    required this.email,
    required this.password,
  });
}