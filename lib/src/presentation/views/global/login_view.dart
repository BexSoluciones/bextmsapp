import 'package:bexdeliveries/src/utils/constants/colors.dart';
import 'package:bexdeliveries/src/utils/extensions/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';

//models
import '../../../domain/models/enterprise.dart';

//cubit
import '../../cubits/login/login_cubit.dart';

//blocs
import '../../blocs/network/network_bloc.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';

//widgets
import '../../widgets/default_button_widget.dart';

part '../../widgets/form_login_widget.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  late LoginCubit loginCubit;

  Enterprise? enterprise;
  bool passwordVisible = true;
  List<String> errors = [];

  final formKey = GlobalKey<FormState>();

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    rememberSession();
    super.initState();
  }

  void rememberSession() {
    var usernameStorage = _storageService.getString('username');
    var passwordStorage = _storageService.getString('password');

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
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    loginCubit = BlocProvider.of<LoginCubit>(context);

    return Scaffold(
      body: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) => buildBlocConsumer(size),
      ),
    );
  }

  Widget _buildBody(Size size,LoginState state) {
    return SafeArea(
      child: SizedBox(
          height: size.height,
          width: size.width,
          child: BlocBuilder<NetworkBloc, NetworkState>(
              builder: (context, networkState) {
                if (networkState is NetworkFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset('assets/animations/1611-online-offline.json',
                            height: 180, width: 180),
                        const Text('No tienes conexión o tu conexión es lenta.')
                      ],
                    ),
                  );
                } else if (networkState is NetworkSuccess) {
                  return Scaffold(
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
                                ]
                            )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(height: 50,),
                            Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, // Forma circular
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
                                      imageUrl: state.enterprise != null && state.enterprise!.logo != null
                                          ? 'https://bexdeliveries.com/${state.enterprise!.logo}'
                                          : '',
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    ),
                                  ),
                                )

                            ),
                            const SizedBox(height: 10,),
                            Container(
                              width: 325,
                              height: 420,
                              decoration:  BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(Radius.circular(35)),
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
                                  const SizedBox(height: 30,),
                                  Text(
                                    state.enterprise != null &&
                                        state.enterprise!.name != null
                                        ? state.enterprise!.name!
                                        : 'demo',
                                    maxLines: 2,
                                    style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    'bexsoluciones.com',
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 30,),
                                  buildForm(context, state),
                                  const SizedBox(height: 30,),
                                ],
                              ),
                            ),
                            const SizedBox(height: 90,),
                            Center(child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    context.read<LoginCubit>().goToCompany();
                                  });
                                },
                                child: Text("Desea cambiar de empresa?", style: TextStyle(color: context.theme.colorScheme.primary,fontWeight: FontWeight.bold,fontSize: 20),)))
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Algo ocurrió mientras cargaba la información'),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: null,
                        )
                      ],
                    ),
                  );
                }
              })),
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
          buildTextField(username,'Correo o código'),
          const SizedBox(height: 10.0),
          buildPasswordFormField(password),
          const SizedBox(height: 50.0),
          buildButton(context, state),
        ],
      ),
    );
  }
}
