import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      appBar: buildAppBar,
      body: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) => buildBlocConsumer(size),
      ),
    );
  }

  AppBar get buildAppBar => AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.read<LoginCubit>().goToCompany(),
        ),
        scrolledUnderElevation: 5.0,
        shadowColor: Theme.of(context).colorScheme.shadow,
        notificationPredicate: (ScrollNotification notification) {
          return notification.depth == 1;
        },
      );

  Widget _buildBody(Size size, state) {
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
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: size.height / 4,
                    width: size.width,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                              ],
                            ),
                            CircleAvatar(
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
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 80.0),
                  buildForm(context, state)
                ],
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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
          buildTextField(username),
          const SizedBox(height: 10.0),
          buildTextField(password),
          const SizedBox(height: 120.0),
          buildButton(context, state),
        ],
      ),
    );
  }
}
