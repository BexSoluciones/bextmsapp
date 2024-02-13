import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
//core
import '../../../../core/helpers/index.dart';
//models
import '../../../domain/models/enterprise.dart';
//cubit
import '../../cubits/login/login_cubit.dart';
//blocs
import '../../blocs/network/network_bloc.dart';
//utils
import '../../../utils/constants/colors.dart';
import '../../../utils/extensions/app_theme.dart';
import '../../../utils/constants/keys.dart';

//widgets
import '../../widgets/default_button_widget.dart';
import '../../widgets/icon_svg_widget.dart';
import '../../widgets/upgrader_widget.dart';

part '../../widgets/form_login_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final helperFunctions = HelperFunctions();
  late LoginCubit loginCubit;

  Enterprise? enterprise;
  bool passwordVisible = true;
  List<String> errors = [];
  bool remember = false;

  final formKey = GlobalKey<FormState>();

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    loginCubit = BlocProvider.of<LoginCubit>(context);
    rememberSession();
    super.initState();
  }

  void rememberSession() {
    var usernameStorage = loginCubit.storageService.getString('username');
    var passwordStorage = loginCubit.storageService.getString('password');

    if (usernameStorage != null) {
      setState(() {
        username.text = usernameStorage;
      });
    }

    if (passwordStorage != null) {
      setState(() {
        password.text = passwordStorage;
      });
    }

    if (usernameStorage != null && passwordStorage != null) {
      setState(() {
        remember = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return UpgraderDialog(
      child: Scaffold(body: buildBlocConsumer(size)),
    );
  }

  Widget _buildBody(Size size, LoginState state) {
    return SafeArea(
      child: SizedBox(
          height: size.height,
          width: size.width,
          child: BlocBuilder<NetworkBloc, NetworkState>(
              builder: (context, networkState) {
            if (networkState is NetworkFailure) {
              return const SvgWidget(
                  path: 'assets/icons/offline.svg',
                  messages: ['No tiene conexión o tu conexión es lenta.']);
            } else if (networkState is NetworkSuccess) {
              return Scaffold(
                key: MyLoginKeys.loginScreen,
                body: SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                          Colors.white,
                          Colors.white54,
                        ])),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          height: 50,
                        ),
                        Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: 50,
                                child: CachedNetworkImage(
                                  width: double.infinity,
                                  height: 100.0,
                                  imageUrl: state.enterprise != null &&
                                          state.enterprise!.logo != null
                                      ? 'https://bexdeliveries.com/${state.enterprise!.logo}'
                                      : '',
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 325,
                          height: 460,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(35)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 5,
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              Text(
                                state.enterprise != null &&
                                        state.enterprise!.name != null
                                    ? state.enterprise!.name!
                                    : 'demo',
                                maxLines: 2,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'bexsoluciones.com',
                                maxLines: 2,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              buildForm(context, state),
                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                        Center(
                            child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    loginCubit.goToCompany();
                                  });
                                },
                                child: Text(
                                  "Desea cambiar de empresa?",
                                  style: TextStyle(
                                      color: context.theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                )))
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Center(
                key: MyLoginKeys.emptyContainerScreen,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Algo ocurrió mientras cargaba la información'),
                  ],
                ),
              );
            }
          })),
    );
  }

  SizedBox buildRememberSession() {
    return SizedBox(
      width: 260,
      height: 60,
      child: CheckboxListTile(
          title: const Text('Recuérdame'),
          value: remember,
          onChanged: (val) {
            setState(() {
              remember = val!;
            });
          }),
    );
  }

  Widget buildBlocConsumer(Size size) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: buildBlocListener,
      builder: (context, state) {
        return _buildBody(size, state);
      },
    );
  }

  void buildBlocListener(context, state) {
    if (state is LoginSuccess || state is LoginFailed) {
      if (state.error != null) {
        buildSnackBar(context, state.error!);
      } else {
        loginCubit.goToHome();
      }
    }
  }

  Widget buildForm(BuildContext context, LoginState state) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildTextField(username, 'Correo o código'),
          const SizedBox(height: 10.0),
          buildPasswordFormField(password),
          const SizedBox(height: 10.0),
          buildRememberSession(),
          const SizedBox(height: 20.0),
          buildButton(context, state, remember),
        ],
      ),
    );
  }
}
