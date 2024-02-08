import 'package:bexdeliveries/src/presentation/widgets/icon_svg_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//utils
import '../../../utils/constants/nums.dart';
import '../../../utils/constants/gaps.dart';
import '../../../utils/constants/keys.dart';

//cubits
import '../../cubits/initial/initial_cubit.dart';
import '../../cubits/login/login_cubit.dart';

//bloc
import '../../blocs/network/network_bloc.dart';

//widgets
import '../../widgets/default_button_widget.dart';
import '../../widgets/version_widget.dart';

class InitialView extends StatefulWidget {
  const InitialView({super.key});

  @override
  InitialViewState createState() => InitialViewState();
}

class InitialViewState extends State<InitialView> {
  late InitialCubit initialCubit;
  late LoginCubit loginCubit;
  bool isLoading = false;
  bool showSuffix = true;
  final FocusNode _focus = FocusNode();
  final TextEditingController companyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focus.hasFocus) {
      setState(() {
        showSuffix = false;
      });
    } else {
      showSuffix = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    initialCubit = BlocProvider.of<InitialCubit>(context);
    loginCubit = BlocProvider.of<LoginCubit>(context);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocBuilder<InitialCubit, InitialState>(
            builder: (context, state) => buildBlocConsumer(size)));
  }

  Widget buildBlocConsumer(Size size) {
    return BlocConsumer<InitialCubit, InitialState>(
      listener: buildBlocListener,
      builder: (context, state) {
        return _buildBody(size, state);
      },
    );
  }

  void buildBlocListener(context, state) {
    if (state is InitialSuccess || state is InitialFailed) {
      if (state.error != null) {
      } else {
        initialCubit.goToLogin();
      }
    }
  }

  Widget _buildBody(Size size, InitialState state) {
    return SingleChildScrollView(
        child: SafeArea(
            child: SizedBox(
                height: size.height,
                width: size.width,
                child: BlocBuilder<NetworkBloc, NetworkState>(
                    builder: (context, networkState) {
                  switch (networkState.runtimeType) {
                    case NetworkInitial:
                      return const Center(
                          child: CupertinoActivityIndicator(
                              key: MyInitialKeys.loadingScreen));
                    case NetworkFailure:
                      return _buildNetworkFailed();
                    case NetworkSuccess:
                      return _buildBodyNetworkSuccess(size, state);
                    default:
                      return const SizedBox(
                          key: MyInitialKeys.emptyContainerScreen);
                  }
                }))));
  }

  Widget _buildNetworkFailed() {
    return const SvgWidget(
        key: MyInitialKeys.errorScreen,
        path: 'assets/icons/offline.svg',
        message: 'No tiene conexión o tu conexión es lenta.');
  }

  Widget _buildBodyNetworkSuccess(Size size, InitialState state) {
    return ListView(
      key: MyInitialKeys.initialScreen,
      children: [
        Padding(
            padding: const EdgeInsets.all(60),
            child: Image.asset(
              'assets/images/bex-deliveries-icon.png',
              fit: BoxFit.contain,
            )),
        gapH64,
        Padding(
            padding: const EdgeInsets.only(
                left: kDefaultPadding, right: kDefaultPadding),
            child: buildCompanyField()),
        gapH4,
        if (state.error != null)
          Padding(
              key: MyInitialKeys.errorSnackBar,
              padding: const EdgeInsets.only(
                  left: kDefaultPadding, right: kDefaultPadding),
              child: Text(state.error!, textAlign: TextAlign.center)),
        SizedBox(height: size.height * 0.26),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: kDefaultPadding, right: kDefaultPadding),
              child: DefaultButton(
                  widget: state is InitialLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text('Comenzar'.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal)),
                  press: () async {
                    initialCubit.getEnterprise(
                        companyNameController, loginCubit);
                  }),
            ),
            gapH12,
            const VersionWidget()
          ],
        ),
      ],
    );
  }

  Widget buildCompanyField() {
    return TextField(
      controller: companyNameController,
      focusNode: _focus,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        suffixIcon: SizedBox(
          child: Center(
            widthFactor: 1.1,
            child: Text('@bexsoluciones.com', style: TextStyle(fontSize: 16)),
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
