import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application/core/theme/app_pallete.dart';
import 'package:flutter_application/providers/dice_color_provider.dart';
import 'package:flutter_application/providers/tap_provider.dart';
import 'package:flutter_application/providers/theme_provider.dart';
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
  final ScrollController historyScrollCOntroller = ScrollController();

  bool isInEditMode = false;
  bool areLabelsHidden = false;
  bool hasRolled = false;
  bool isRolling = false;

  int hopeDieVal = 12;
  int fearDieVal = 12;

  int finalHopeVal = 12;
  int finalFearVal = 12;

  int resultValue = 0;
  String characterName = 'Kaeros de Skaldrith';
  List<String> rollHistory = [];

  @override
  void dispose() {
    nameController.dispose();
    historyScrollCOntroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diceColorProvider = Provider.of<DiceColorProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                  SizedBox(height: 150),
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
                    duration: Duration(milliseconds: 300),
                    child: hasRolled
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (finalHopeVal == finalFearVal) ...[
                                      Text('CRITICAL SUCCESS!'),
                                      Text(
                                        'You clean 1 stress point and gain 1 hope.',
                                      ),
                                    ] else ...[
                                      Text(resultValue.toString()),
                                      RichText(
                                        text: TextSpan(
                                          text: 'You rolled with ',
                                          style: TextStyle(
                                            color: themeProvider.isDarkModeOn
                                                ? Pallete.primaryOnDark
                                                : Pallete.primaryOnLight,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: finalHopeVal > finalFearVal
                                                  ? 'HOPE!'
                                                  : 'FEAR!',
                                              style: TextStyle(
                                                color:
                                                    finalHopeVal > finalFearVal
                                                        ? diceColorProvider
                                                            .hopeColor
                                                        : diceColorProvider
                                                            .fearColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        finalHopeVal > finalFearVal ? 'You gain 1 hope' : 'The GM may add a fear token to the pool'
                                      ),
                                    ],
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text('History'),
                                        Icon(Icons.history),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 110,
                                      child: ListView.builder(
                                        controller: historyScrollCOntroller,
                                        itemCount: rollHistory.length,
                                        itemBuilder: (context, index) {
                                          return Text(rollHistory[index]);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
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
    final statTapProvider =
        Provider.of<StatTapProvider>(context, listen: false);
    final tappedStatName = statTapProvider.tappedStat;
    final random = Random();

    if (isRolling) return; // prevent overlapping rolls

    setState(() {
      isRolling = true;
      hasRolled = true;
    });

    int rollDuration = 300; // total duration in ms
    int interval = 50; // time between number changes
    int elapsed = 0;

    Timer.periodic(Duration(milliseconds: interval), (timer) {
      setState(() {
        hopeDieVal = random.nextInt(12) + 1;
        fearDieVal = random.nextInt(12) + 1;
      });

      elapsed += interval;
      if (elapsed >= rollDuration) {
        timer.cancel();
        finalHopeVal = random.nextInt(12) + 1;
        finalFearVal = random.nextInt(12) + 1;

        resultValue = finalHopeVal + finalFearVal + modifier;

        final String hopeOrFear = finalHopeVal > finalFearVal ? 'HOPE' : 'FEAR';

        if (finalHopeVal == finalFearVal) {
          rollHistory
              .add('CRITICAL SUCCESS: $finalHopeVal(hope) + $finalFearVal(fear).');
        } else {
          rollHistory.add(
            modifier > 0
                ? '$resultValue with $hopeOrFear: $finalHopeVal(hope) + $finalFearVal(fear) + $modifier($tappedStatName).'
                : '$resultValue with $hopeOrFear: $finalHopeVal(hope) + $finalFearVal(fear).',
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (historyScrollCOntroller.hasClients) {
            historyScrollCOntroller.animateTo(
              historyScrollCOntroller.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        setState(() {
          hopeDieVal = finalHopeVal;
          fearDieVal = finalFearVal;
          isRolling = false;
        });
      }
    });
  }
}
