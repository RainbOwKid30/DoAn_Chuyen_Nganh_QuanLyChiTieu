import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_welcome/home_page_SignIn.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_welcome/home_page_SignUp.dart';
import 'package:quan_ly_chi_tieu/theme/theme.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_scaffold.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_welcome_button.dart';

class HomePageWelcome extends StatelessWidget {
  const HomePageWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                  child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(children: [
                  TextSpan(
                      text: 'Welcome Back\n',
                      style: TextStyle(
                        fontSize: 45.0,
                        fontWeight: FontWeight.w600,
                      )),
                  TextSpan(
                      text: '\n Welcome to our app, now create an account.',
                      style: TextStyle(
                        fontSize: 18,
                        // fontWeight: FontWeight.bold,
                      )),
                ]),
              )),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: CustomWelcomeButton(
                      buttonText: 'Sign in',
                      onTap: const HomePageSignin(),
                      color: Colors.transparent,
                      textColor: lightColorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: CustomWelcomeButton(
                      buttonText: 'Sign up',
                      onTap: const HomePageSignup(),
                      color: Colors.white,
                      textColor: lightColorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
