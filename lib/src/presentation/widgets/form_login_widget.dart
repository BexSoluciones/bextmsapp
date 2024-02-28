part of '../views/global/login_view.dart';

extension SnackBarWidget on LoginViewState {
  ScaffoldFeatureController buildSnackBar(BuildContext context, String text) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        key: MyInitialKeys.errorSnackBar,
        duration: const Duration(seconds: 1),
        content: Text(text)));
  }
}

extension TextFieldWidget on LoginViewState {
  Widget buildTextField(TextEditingController controller, String hintText) {
    return SizedBox(
      width: 260,
      height: 60,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            suffix: Icon(
              Icons.email,
              color: context.theme.colorScheme.primary,
            ),
            hintText: hintText,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            )),
        validator: validator,
      ),
    );
  }

  String? validator(value) {
    if (value == null || value.isEmpty) {
      return 'Enter a value';
    } else {
      return null;
    }
  }
}

extension PasswordWidget on LoginViewState {
  Widget buildPasswordFormField(TextEditingController controller) {
    return SizedBox(
      width: 260,
      height: 60,
      child: TextFormField(
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        obscureText: passwordVisible,
        controller: password,
        onChanged: (value) {
          if (value.isNotEmpty) {
            removeError(error: kPassNullError);
          } else if (value.length >= 8) {
            removeError(error: kShortPassError);
          }
          return;
        },
        validator: (value) {
          if (value!.isEmpty) {
            addError(error: kPassNullError);
            return '';
          }
          return null;
        },
        decoration: InputDecoration(
            hintText: 'Contraseña',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              },
              color: Theme.of(context).colorScheme.primary,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            )),
        autofillHints: const [AutofillHints.password],
      ),
    );
  }

  void removeError({required String error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  void addError({required String error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }
}

extension LoginButton on LoginViewState {
  Future<bool> isGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Widget buildButton(BuildContext context, LoginState state, bool remember) {
    return DefaultButton(
      widget: buildChild(state),
      press: () => buildOnPressed(context, remember),
      login: true,
    );
  }

  Future<void> buildOnPressed(BuildContext context, bool remember) async {
    if (formKey.currentState!.validate()) {
      var isGpsEnabled = await Geolocator.isLocationServiceEnabled();
      if (isGpsEnabled && context.mounted) {
        context.read<LoginCubit>().onPressedLogin(username, password, remember);
      } else {
        if (context.mounted) {
          buildSnackBar(context,
              'El GPS no está activado. Activa el GPS y vuelve a intentarlo.');
        }
      }
    }
  }

  Widget buildChild(LoginState state) {
    return state is LoginLoading
        ? const CircularProgressIndicator.adaptive(
            backgroundColor: Colors.white)
        : const Icon(Icons.arrow_forward_ios, color: Colors.white);
  }
}
