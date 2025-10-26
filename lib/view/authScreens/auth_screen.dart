import 'package:flutter/material.dart';
import 'package:sellers_app/view/authScreens/signin_screen.dart';
import 'package:sellers_app/view/authScreens/signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Gram Restaurants',
              style: TextStyle(
                fontSize: 26,
              ),
            ),
            centerTitle: true,
            bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(
                        Icons.lock,
                        color: Colors.black
                    ),
                    text: 'Sign In',
                  ),
                  Tab(
                    icon: Icon(
                        Icons.person,
                        color: Colors.black
                    ),
                    text: 'Sign Up',
                  ),
                ],
                indicatorColor: Colors.amber,
                indicatorWeight: 5,
            ),
          ),
          body: Container(
            color: Colors.white,
            child: const TabBarView(
                children: [
                  SigninScreen(),
                  SignupScreen(),
                ],
            ),
          ),
        ),
    );
  }
}
