import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:fmtc_plus_background_downloading/fmtc_plus_background_downloading.dart';

class BackgroundDownloadBatteryOptimizationsInfo extends StatefulWidget {
  const BackgroundDownloadBatteryOptimizationsInfo({
    super.key,
  });

  @override
  State<BackgroundDownloadBatteryOptimizationsInfo> createState() =>
      _BackgroundDownloadBatteryOptimizationsInfoState();
}

class _BackgroundDownloadBatteryOptimizationsInfoState
    extends State<BackgroundDownloadBatteryOptimizationsInfo> {
  @override
  Widget build(BuildContext context) => FutureBuilder<bool?>(
        future: FMTC
            .instance('')
            .download
            .requestIgnoreBatteryOptimizations(requestIfDenied: false),
        builder: (context, snapshot) => Row(
          children: [
            Icon(
              snapshot.data == null || !snapshot.data!
                  ? Icons.warning_amber
                  : Icons.done,
              color: snapshot.data == null || !snapshot.data!
                  ? Colors.amber
                  : Colors.green,
              size: 36,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Las aplicaciones que admiten la descarga en segundo plano pueden solicitar permisos adicionales para ayudar a evitar que el sistema detenga el proceso en segundo plano. Específicamente, el permiso 'ignorar optimizaciones de batería' es el que más ayuda. La API tiene un método para gestionar este permiso.",
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    snapshot.hasError
                        ? 'Actualmente, esta plataforma no admite esta API: solo es compatible con Android.'
                        : snapshot.data == null
                            ? 'Comprobando si este permiso está actualmente concedido a esta aplicación...'
                            : (!snapshot.data!
                                ? 'Esta aplicación no tiene este permiso otorgado actualmente. Toque el botón a continuación para utilizar el método API para solicitar el permiso.'
                                : 'Esta aplicación actualmente tiene este permiso otorgado.'),
                    textAlign: TextAlign.justify,
                  ),
                  if (!(snapshot.data ?? true))
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await FMTC
                              .instance('')
                              .download
                              .requestIgnoreBatteryOptimizations();
                          setState(() {});
                        },
                        child: const Text('Pedir permiso'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}
