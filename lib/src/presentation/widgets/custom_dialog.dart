
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  CustomDialog(
      {required this.title,
        required this.message,
        required this.elevatedButton1,
        required this.elevatedButton2,
        required this.cancelarButtonText,
        required this.completarButtonText,
        required this.icon,
        required this.colorIcon});
  final String title;
  final String message;
  final Color elevatedButton1;
  final String cancelarButtonText;
  final Color elevatedButton2;
  final String completarButtonText;
  final IconData icon;
  final Color colorIcon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              top: 65,
              right: 20,
              bottom: 20,
            ),
            margin: const EdgeInsets.only(top: 45),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /*ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: elevatedButton1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        cancelarButtonText,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),*/
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: elevatedButton2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        completarButtonText,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 20,
            right: 20,
            child: CircleAvatar(
              backgroundColor: colorIcon,
              radius: 45,
              child: Icon(
                icon,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
