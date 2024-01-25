import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

class CustomErrorWidget extends StatelessWidget {
  final String errorMessage;

  const CustomErrorWidget(
      {super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 50.0,
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Ha ocurrido un error',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Reiniciar app',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0),
                ),
                IconButton(
                    onPressed: () {
                      Restart.restartApp(webOrigin: '/');
                    },
                    icon: const Icon(Icons.refresh, size: 40.0))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
