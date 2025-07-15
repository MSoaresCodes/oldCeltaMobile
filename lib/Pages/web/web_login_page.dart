import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../../api/api.dart';
import '../../components/components.dart';

import '../../utils/utils.dart';

class WebLoginPage extends StatefulWidget {
  const WebLoginPage({super.key});

  @override
  State<WebLoginPage> createState() => _WebLoginPageState();
}

class _WebLoginPageState extends State<WebLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final key = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> login() async {
    bool isValid = key.currentState!.validate();

    if (!isValid) return;

    setState(() {
      isLoading = true;
    });

    await FirebaseHelper.signIn(
      email: emailController.text,
      password: passwordController.text,
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingWidget(false);
          } else if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              Future.delayed(Duration.zero, () {
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(APPROUTES.WEB_HOME);
                }
              });
            });
          }

          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: const Text("Login"),
                  actions: null,
                  leading: const Text(""),
                ),
                body: Form(
                  key: key,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: emailController,
                          decoration: FormFieldDecoration.decoration(
                            context: context,
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return "E-mail inválido";
                            } else if (!RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value!)) {
                              return "E-mail inválido";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          onFieldSubmitted: (_) async {
                            await login();
                          },
                          decoration: FormFieldDecoration.decoration(
                            context: context,
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return "Preencha a senha";
                            } else if (value!.length < 3) {
                              return "Senha curta";
                            }

                            return null;
                          },
                        ),
                        TextButton(
                          onPressed: () async {
                            await login();
                          },
                          child: const Text("Efetuar login"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              loadingWidget(isLoading),
            ],
          );
        });
  }
}
