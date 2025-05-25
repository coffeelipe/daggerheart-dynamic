import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application/core/theme/app_pallete.dart';
import 'package:flutter_application/providers/dice_color_provider.dart';
import 'package:flutter_application/providers/tap_provider.dart';
import 'package:flutter_application/widgets/d_twelve.dart';
import 'package:flutter_application/widgets/stats_bar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();

  bool isInEditMode = false;
  int hopeDieVal = 12;
  int fearDieVal = 12;
  int resultValue = 0;
  bool areLabelsHidden = false;
  bool isRolling = false;
  String characterName = 'Kaeros de Skaldrith';

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diceColorProvider = Provider.of<DiceColorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              child: Icon(
                isInEditMode
                    ? Icons.add_photo_alternate_rounded
                    : Icons.person_rounded,
              ),
            ),
            Expanded(
              child: TextField(
                readOnly: !isInEditMode,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(10),
                  hintText: 'New character',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          isInEditMode ? Pallete.mainColor : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          isInEditMode ? Pallete.mainColor : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                maxLines: 1,
                controller: nameController,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                areLabelsHidden
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
              Switch(
                value: areLabelsHidden,
                activeTrackColor: Pallete.complimentaryColor,
                activeColor: Pallete.mainColor,
                onChanged: (value) {
                  setState(() {
                    areLabelsHidden = value;
                  });
                },
              )
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isInEditMode = !isInEditMode;
            characterName = nameController.text;
          });
        },
        backgroundColor: Pallete.mainColor,
        mini: true,
        tooltip: 'Edit sheet',
        shape: CircleBorder(),
        child: Icon(
          isInEditMode ? Icons.check_rounded : Icons.edit_rounded,
          color: Pallete.primaryOnDark,
        ),
      ),
      body: Consumer<StatTapProvider>(
        builder: (context, tapProvider, child) {
          if (tapProvider.tappedStat != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              rollDice(tapProvider.modifier);
              tapProvider.clear();
            });
          }

          return SingleChildScrollView(
            child: Scrollbar(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  StatsBar(isInEditMode: isInEditMode),
                  SizedBox(height: 200),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLabeledDie(hopeDieVal, 'Hope', true),
                      _buildLabeledDie(fearDieVal, 'Fear', false),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton(
                      onPressed: () {
                        rollDice(0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Pallete.mainColor,
                        foregroundColor: Pallete.primaryOnDark,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        minimumSize: Size(300, 50),
                      ),
                      child: Text(
                        'Roll!',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: Duration(milliseconds: 500),
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hopeDieVal == fearDieVal) ...[
                            Text('CRITICAL SUCCESS!'),
                            Text('You clean 1 stress point and gain 1 hope'),
                          ] else ...[
                            Text(resultValue.toString()),
                            RichText(
                              text: TextSpan(
                                text: 'You rolled with ',
                                children: [
                                  TextSpan(
                                    text: hopeDieVal > fearDieVal
                                        ? 'HOPE'
                                        : 'FEAR',
                                    style: TextStyle(
                                      color: hopeDieVal > fearDieVal
                                          ? diceColorProvider.hopeColor
                                          : diceColorProvider.fearColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Column _buildLabeledDie(int val, String label, bool isHopeDie) {
    return Column(
      children: [
        Text(
          areLabelsHidden ? '' : label,
          style: TextStyle(fontSize: 20),
        ),
        DTwelve(rollValue: val, isHopeDie: isHopeDie),
      ],
    );
  }

  void rollDice(int modifier) {
    final random = Random();

    if (isRolling) return; // prevent overlapping rolls

    isRolling = true;
    int rollDuration = 300; // total duration in ms
    int interval = 50; // time between number changes
    int elapsed = 0;

    Timer.periodic(Duration(milliseconds: interval), (timer) {
      setState(() {
        hopeDieVal = random.nextInt(12) + 1;
        fearDieVal = random.nextInt(12) + 1;
        resultValue = hopeDieVal + fearDieVal + modifier;
      });

      elapsed += interval;
      if (elapsed >= rollDuration) {
        timer.cancel();
        isRolling = false;
      }
    });
  }
}
