import 'package:flutter/material.dart';
import 'package:flutter_application/core/theme/app_pallete.dart';
import 'package:flutter_application/providers/tap_provider.dart';
import 'package:flutter_application/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class StatsBar extends StatefulWidget {
  final bool isInEditMode;
  
  const StatsBar({
    super.key,
    required this.isInEditMode,
  });

  @override
  State<StatsBar> createState() => _StatsBarState();
}

class _StatsBarState extends State<StatsBar> {
  final List<Map<String, dynamic>> stats = [
    {'name': 'Agility', 'mod': 0},
    {'name': 'Strength', 'mod': 0},
    {'name': 'Finesse', 'mod': 0},
    {'name': 'Instinct', 'mod': 0},
    {'name': 'Presence', 'mod': 0},
    {'name': 'Knowledge', 'mod': 0},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map(
        (stat) {
          return StatField(
            themeProvider: themeProvider,
            isInEditMode: widget.isInEditMode,
            label: stat['name'],
            statValue: stat['mod'],
            increment: () => setState(() {stat['mod']++;}),
            decrement: () => setState(() {stat['mod']--;}),
          );
        }
      ).toList(),
    );
  }
}

class StatField extends StatelessWidget {
  final ThemeProvider themeProvider;
  final int statValue;
  final String label;
  final bool isInEditMode;
  final VoidCallback increment;
  final VoidCallback decrement;

  const StatField({
    super.key,
    required this.label,
    required this.themeProvider,
    required this.isInEditMode,
    required this.statValue,
    required this.increment,
    required this.decrement,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<StatTapProvider>(context, listen: false).tapStat(label, statValue);
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
            ),
          ),
          buildConditionalWidget(
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Pallete.mainColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: increment,
                icon: Icon(
                  Icons.add_rounded,
                  color: Pallete.primaryOnDark,
                ),
                iconSize: 15,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: themeProvider.isDarkModeOn
                      ? Pallete.primaryOnDark
                      : Pallete.primaryOnLight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  statValue.toString(),
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
          buildConditionalWidget(
            Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                color: Pallete.mainColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: decrement,
                icon: Icon(
                  Icons.remove,
                  color: Pallete.primaryOnDark,
                ),
                iconSize: 15,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildConditionalWidget(Widget widget) =>
      isInEditMode ? widget : SizedBox.shrink();
}