import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/features/controllers/login_controller.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_welcome/home_page_SignUp.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/toggle_password.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:quan_ly_chi_tieu/theme/theme.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_scaffold.dart';

class HomePageSignin extends StatefulWidget {
  const HomePageSignin({super.key});

  @override
  State<HomePageSignin> createState() => _HomePageSigninState();
}

class _HomePageSigninState extends State<HomePageSignin> {
  String email = "", password = "";
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  bool isSecurePassword = true;
  final formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Quay về màn hình giới thiệu
        Navigator.of(context).popUntil((route) => route.isFirst);
        return false; // Ngăn không cho hành động mặc định
      },
      child: CustomScaffold(
        child: Column(
          children: [
            const Expanded(
              child: SizedBox(
                height: 10,
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formSignInKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                            color: lightColorScheme.primary,
                          ),
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        // Form Email
                        TextFormField(
                          controller: emailcontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('Email'),
                            hintText: 'Enter Email',
                            hintStyle: const TextStyle(
                              color: Colors.black26,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        // Form PassWord
                        TextFormField(
                          controller: passwordcontroller,
                          obscureText: isSecurePassword,
                          // Nhập password ẩn
                          obscuringCharacter: '*',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: TogglePassword(
                              isSecurePassword: isSecurePassword,
                              onPressed: () {
                                setState(() {
                                  isSecurePassword = !isSecurePassword;
                                });
                              },
                            ),
                            label: const Text('Password'),
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(
                              color: Colors.black26,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        // dòng Remember, Forget Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberPassword,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberPassword = value!;
                                    });
                                  },
                                  activeColor: lightColorScheme.primary,
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              child: Text(
                                'Forget password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: lightColorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        // nút Sign In
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formSignInKey.currentState!.validate() &&
                                  rememberPassword) {
                                if (emailcontroller.text != "" &&
                                    passwordcontroller.text != "") {
                                  setState(() {
                                    email = emailcontroller.text;
                                    password = passwordcontroller.text;
                                  });
                                }
                                LoginController.userLogin(
                                  context: context,
                                  email: emailcontroller.text,
                                  password: passwordcontroller.text,
                                );
                              } else if (!rememberPassword) {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.info,
                                  animType: AnimType.rightSlide,
                                  title: 'You need to check the box!!!',
                                  btnOkOnPress: () {},
                                ).show();
                              }
                            },
                            child: const Text('Sign in'),
                          ),
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              // tạo đường kẻ ngang
                              child: Divider(
                                thickness: 0.7,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 10,
                              ),
                              child: Text(
                                'Sign up with',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.7,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        // Các kết nối bên ngoài
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(SimpleIcons.facebook),
                            Icon(SimpleIcons.google),
                            Icon(SimpleIcons.twitter),
                          ],
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        // kết nối đến trang sign up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account? ',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) => const HomePageSignup(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: lightColorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
