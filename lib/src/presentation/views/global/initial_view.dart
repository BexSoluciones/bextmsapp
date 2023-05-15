
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

//models
import '../../../domain/models/enterprise.dart';

//utils
import '../../../utils/constants/nums.dart';
import '../../../utils/constants/strings.dart';

//cubits
import '../../cubits/initial/initial_cubit.dart';

//bloc
import '../../blocs/network/network_bloc.dart';

//widgets
import '../../widgets/default_button_widget.dart';
import '../../widgets/version_widget.dart';

//service
import '../../../locator.dart';
import '../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class InitialView extends StatefulWidget {
  const InitialView({Key? key}) : super(key: key);

  @override
  InitialViewState createState() => InitialViewState();
}

class InitialViewState extends State<InitialView> {
  late InitialCubit initialCubit;
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

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocBuilder<InitialCubit, InitialState>(
          builder: (context, state) {
            if (state.runtimeType == InitialLoading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (state.runtimeType == InitialSuccess ||
                state.runtimeType == InitialFailed) {
              return _buildBody(size, state.enterprise, state.error);
            } else {
              return const SizedBox();
            }
          },
        ));
  }

  Widget _buildBody(Size size, Enterprise? enterprise, String? error) {
    return BlocListener<InitialCubit, InitialState>(
        listener: (context, state) {
          if (state.enterprise != null) {
            _navigationService.goTo(loginRoute);
          }
        },
        child: SingleChildScrollView(
            child: SafeArea(
                child: SizedBox(
                    height: size.height,
                    width: size.width,
                    child: BlocBuilder<NetworkBloc, NetworkState>(
                        builder: (context, networkState) {
                      switch (networkState.runtimeType) {
                        case NetworkInitial:
                          return const Center(
                              child: CupertinoActivityIndicator());
                        case NetworkFailure:
                          return _buildNetworkFailed();
                        case NetworkSuccess:
                          return _buildBodyNetworkSuccess(size, error);
                        default:
                          return const SizedBox();
                      }
                    })))));
  }

  Widget _buildNetworkFailed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/1611-online-offline.json',
              height: 180, width: 180),
          const Text('No tiene conexión o tu conexión es lenta.')
        ],
      ),
    );
  }

  Widget _buildBodyNetworkSuccess(Size size, String? error) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Padding(
          padding: const EdgeInsets.all(60),
          child: Image.asset(
            'assets/images/bex-deliveries-icon.png',
            fit: BoxFit.contain,
          )),
      Padding(
          padding: const EdgeInsets.only(
              left: kDefaultPadding,
              right: kDefaultPadding,
              bottom: kDefaultPadding),
          child: buildCompanyField()),
      if (error != null) Text(error),
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: kDefaultPadding, right: kDefaultPadding),
            child: DefaultButton(
                widget: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text('Comenzar'.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal)),
                press: () async {
                  initialCubit.getEnterprise(companyNameController);
                }),
          ),
          const VersionWidget()
        ],
      ),
    ]);
  }

  MediaQuery buildCompanyField() {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 0.80 * MediaQuery.textScaleFactorOf(context),
      ),
      child: TextField(
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
      ),
    );
  }
}
