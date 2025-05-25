import 'package:flutter/material.dart';
import 'package:flutter_application/core/theme/app_pallete.dart';
import 'package:flutter_application/providers/dice_color_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DTwelve extends StatefulWidget {
  final int rollValue;
  final bool isHopeDie;

  const DTwelve({
    super.key,
    this.rollValue = 12,
    required this.isHopeDie,
  });

  @override
  State<DTwelve> createState() => _DTwelveState();
}

class _DTwelveState extends State<DTwelve> {
  Color pickerColor = Pallete.defaultDieColor;
  Color dieValueColor = Pallete.primaryOnDark;
  void changeColor(color) => setState(() {
        pickerColor = color;
      });

  @override
  Widget build(BuildContext context) {
    final diceColorProvider =
        Provider.of<DiceColorProvider>(context, listen: false);

    return GestureDetector(
      onLongPress: () => openColorPicker(diceColorProvider),
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(
            end: widget.isHopeDie
                ? diceColorProvider.hopeColor
                : diceColorProvider.fearColor),
        duration: Duration(milliseconds: 300),
        builder: (context, animatedColor, child) {
          return SizedBox(
            height: 100,
            width: 100,
            child: Stack(
              children: [
                SvgPicture.asset(
                  'assets/images/pentagon.svg',
                  colorFilter: ColorFilter.mode(
                    animatedColor ?? diceColorProvider.hopeColor,
                    BlendMode.srcIn,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.rollValue.toString(),
                      style: TextStyle(
                        color: dieValueColor,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void openColorPicker(DiceColorProvider diceColorProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change die color:'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                widget.isHopeDie
                    ? diceColorProvider.setHopeColor(pickerColor)
                    : diceColorProvider.setFearColor(pickerColor);
                setDieValColor(widget.isHopeDie, diceColorProvider);
              });
            },
            child: const Text(
              'Got it!',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> hexToRgb(String hexCode) {
    if (hexCode.length == 6) {
      final r = int.parse(hexCode.substring(0, 2), radix: 16);
      final g = int.parse(hexCode.substring(2, 4), radix: 16);
      final b = int.parse(hexCode.substring(4, 6), radix: 16);
      return {'r': r, 'g': g, 'b': b};
    } else {
      throw FormatException('Invalid hex color: $hexCode');
    }
  }

  void setDieValColor(bool isHopeDie, DiceColorProvider diceColorProvider) {
    final String currentColorHex =
        (isHopeDie ? diceColorProvider.hopeColor : diceColorProvider.fearColor)
            .toHexString()
            .substring(2);
    final int? r = hexToRgb(currentColorHex)['r'];
    final int? g = hexToRgb(currentColorHex)['g'];
    final int? b = hexToRgb(currentColorHex)['b'];
    final int? avgColorValues;
    final Color colorToSet;

    if (r != null && g != null && b != null) {
      avgColorValues = ((r + g + b) / 3).floor();
      colorToSet = avgColorValues >= 127
          ? Pallete.primaryOnLight
          : Pallete.primaryOnDark;
      dieValueColor = colorToSet;
    } else {
      throw Exception('Color values are not defined');
    }
  }
}
