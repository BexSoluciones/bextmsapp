part of '../views/global/login_view.dart';

extension SnackBarWidget on LoginViewState {
  ScaffoldFeatureController buildSnackBar(BuildContext context, String text) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }
}

extension TextFieldWidget on LoginViewState {
  Widget buildTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      validator: validator,
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


extension LoginButton on LoginViewState {
  Widget buildButton(BuildContext context, LoginState state) {
    return DefaultButton(widget: buildChild(state), press: () => buildOnPressed(context));
  }

  Future<void> buildOnPressed(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      context.read<LoginCubit>().onPressedLogin(username, password);
    }
  }

  Widget buildChild(LoginState state) {
    return state is LoginLoading
        ? const CircularProgressIndicator.adaptive()
        : const Icon(Icons.arrow_forward_ios);
  }
}
