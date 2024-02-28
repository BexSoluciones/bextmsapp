import 'package:bexdeliveries/core/helpers/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';

//utils
import '../../utils/constants/colors.dart';

//domain
import '../../domain/models/offset.dart';

//services
import '../../locator.dart';
import '../../services/navigation.dart';
import 'default_button_widget.dart';

final NavigationService _navigationService = locator<NavigationService>();

class TouchControl extends StatefulWidget {
  const TouchControl(
      {super.key,
      required this.width,
      required this.height,
      required this.orderNumber,
      this.onChanged,
      this.xPos = 0.0,
      this.yPos = 0.0});

  @override
  TouchControlState createState() => TouchControlState();

  final double xPos;
  final double yPos;
  final double width;
  final double height;
  final ValueChanged<Offset>? onChanged;
  final String orderNumber;
}

List<OffsetDraw?> _points = [];

class TouchControlState extends State<TouchControl> {
  final helperFunctions = HelperFunctions();
  double xPos = 0.0;
  double yPos = 0.0;
  ByteData? imgBytes;

  double margin = 10.0;

  bool isSomethingInTouch = false;

  void onChanged(Offset offset, event) {
    final referenceBox = context.findRenderObject() as RenderBox;
    final position = referenceBox.globalToLocal(offset);

    if (position.dx > 2 &&
        position.dx < (widget.width - (margin * 2)) &&
        position.dy > 2 &&
        position.dy < widget.height) {
      setState(() {
        _points = List.from(_points)..add(OffsetDraw(points: position));
      });
    }
  }

  bool hitTestSelf(Offset position) => true;

  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      // ??
    }
  }

  void _handlePanStart(DragStartDetails details) {
    onChanged(details.globalPosition, 'start');
  }

  void _handlePanDown(DragDownDetails details) {
    onChanged(details.globalPosition, 'down');
  }

  void _handlePanEnd(DragEndDetails details) {
    _points.add(null);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      isSomethingInTouch = true;
    });
    onChanged(details.globalPosition, 'update');
  }

  @override
  void dispose() {
    _points = <OffsetDraw>[];
    imgBytes = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _points = <OffsetDraw>[];
                      imgBytes = null;
                    });
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('LIMPIAR', style: TextStyle(fontSize: 20)),
                      Icon(
                        Icons.edit_off,
                        color: kPrimaryColor,
                      )
                    ],
                  ),
                )
              ],
            ),
            imgBytes != null
                ? Center(
                    child: Image.memory(
                    Uint8List.view(imgBytes!.buffer),
                    width: widget.width,
                    height: widget.height - 220,
                  ))
                : ConstrainedBox(
                    constraints: BoxConstraints.expand(
                        height: widget.height - 220, width: widget.width),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanDown: _handlePanDown,
                      onPanUpdate: _handlePanUpdate,
                      onPanStart: _handlePanStart,
                      onPanEnd: _handlePanEnd,
                      child: CustomPaint(
                        size: Size(xPos, yPos),
                        painter:
                            TouchControlPainter(xPos, yPos, _points, context),
                      ),
                    ),
                  ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DefaultButton(
                    widget: const Text('Confirmar',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    press: saveImageFirm))
          ]),
    );
  }

  Future<void> generateImage() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromPoints(const Offset(0.0, 0.0), Offset(widget.height, widget.width)));

    var offsetPoints = <Offset>[];

    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..strokeWidth = 5.0
      ..strokeJoin = StrokeJoin.bevel;

    for (var i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!.points, _points[i + 1]!.points, paint);
      } else if (_points[i] != null && _points[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(_points[i]!.points);
        offsetPoints.add(
            Offset(_points[i]!.points.dx + 0.1, _points[i]!.points.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(
        widget.width.toInt(), (widget.height - 220).toInt());
    final pngBytes = await img.toByteData(format: ImageByteFormat.png);

    setState(() {
      imgBytes = pngBytes;
    });
  }

  void saveImageFirm() async {
    await generateImage().then((_) {
      if (imgBytes != null) {
        helperFunctions.saveFirm('firm-${widget.orderNumber}', 'firm-${widget.orderNumber}', imgBytes!);
      }
    }).catchError((onError) {
      if (kDebugMode) {
        print(onError);
      }
    });

    _navigationService.goBack();
  }
}

class TouchControlPainter extends CustomPainter {
  TouchControlPainter(this.xPos, this.yPos, this.points, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..strokeWidth = 6.0
      ..strokeJoin = StrokeJoin.bevel;

    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!.points, points[i + 1]!.points, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(points[i]!.points);
        offsetPoints.add(
            Offset(points[i]!.points.dx + 0.1, points[i]!.points.dy + 0.1));

        canvas.drawPoints(PointMode.points, offsetPoints, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  static const markerRadius = 5.0;
  final double xPos;
  final double yPos;
  final List<OffsetDraw?> points;
  final BuildContext context;
  List<Offset> offsetPoints = <Offset>[];
}
