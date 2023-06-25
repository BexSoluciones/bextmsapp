import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

//models
import '../../../domain/models/enterprise.dart';

//utils
import '../../../utils/constants/nums.dart';
import '../../../utils/constants/strings.dart';
import '../../../utils/constants/gaps.dart';

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
                      return const Center(child: CupertinoActivityIndicator());
                    case NetworkFailure:
                      return _buildNetworkFailed();
                    case NetworkSuccess:
                      return _buildBodyNetworkSuccess(size, state);
                    default:
                      return const SizedBox();
                  }
                }))));
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

  Widget _buildBodyNetworkSuccess(Size size, InitialState state) {
    return ListView(
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
                left: kDefaultPadding,
                right: kDefaultPadding,
                bottom: kDefaultPadding),
            child: buildCompanyField()),
        gapH4,
        if (state.error != null)
          Text(state.error!, textAlign: TextAlign.center),
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
                    initialCubit.getEnterprise(companyNameController);
                  }),
            ),
            gapH12,
            const VersionWidget()
          ],
        ),
      ],
    );
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
