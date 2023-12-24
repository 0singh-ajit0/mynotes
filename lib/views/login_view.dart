import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final closeDialog = _closeDialogHandle;
          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialogHandle = null;
          } else if (state.isLoading && closeDialog == null) {
            _closeDialogHandle = showLoadingDialog(
              context: context,
              text: "Loading...",
            );
          }

          if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, "Invalid email entered");
          } else if (state.exception is InvalidCredentialAuthException ||
              state.exception is WrongPasswordAuthException ||
              state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, "Incorrect email or password");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Authentication error");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
          elevation: 4,
        ),
        body: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "Enter your email",
              ),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: "Enter your password",
              ),
            ),
            FilledButton(
              onPressed: () {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(AuthEventLogin(email, password));
              },
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventShouldRegister());
              },
              child: const Text("Not registered yet? Register here!"),
            ),
          ],
        ),
      ),
    );
  }
}
