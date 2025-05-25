import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:daggerheart_dynamic/core/theme/app_pallete.dart';
import 'package:daggerheart_dynamic/providers/dice_color_provider.dart';
import 'package:daggerheart_dynamic/providers/tap_provider.dart';
import 'package:daggerheart_dynamic/providers/theme_provider.dart';
import 'package:daggerheart_dynamic/widgets/d_twelve.dart';
import 'package:daggerheart_dynamic/widgets/stats_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();
  final ScrollController historyScrollCOntroller = ScrollController();
  final GlobalKey<StatsBarState> _statsBarKey = GlobalKey<StatsBarState>();

  bool _isLoading = true;
  double _loadingProgress = 0.0;
  String _loadingMessage = 'Loading...';

  bool isInEditMode = false;
  bool areLabelsHidden = false;
  bool hasRolled = false;
  bool isRolling = false;
  File? _profileImage;

  int hopeDieVal = 12;
  int fearDieVal = 12;

  int finalHopeVal = 12;
  int finalFearVal = 12;

  int resultValue = 0;
  String characterName = 'Kaeros de Skaldrith';
  List<String> rollHistory = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final diceColorProvider =
          Provider.of<DiceColorProvider>(context, listen: false);
      _loadPreferences(diceColorProvider);
      _loadProfileImage();
    });
  }

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

    return _isLoading
        ? Scaffold(
            body: Center(
              child: LinearProgressIndicator(
                value: _loadingProgress,
                color: Pallete.mainColor,
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              toolbarHeight: 80,
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (isInEditMode) {
                        _pickAndSaveImage();
                      } else if (_profileImage != null) {
                        showDialog(
                          context: context,
                          builder: (context) => Stack(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: Pallete.primaryOnDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Image(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(
                              isInEditMode
                                  ? Icons.add_photo_alternate_rounded
                                  : Icons.person_rounded,
                            )
                          : SizedBox.shrink(),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      readOnly: !isInEditMode,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                        hintText: 'New character',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isInEditMode
                                ? Pallete.mainColor
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isInEditMode
                                ? Pallete.mainColor
                                : Colors.transparent,
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
                });
                if (!isInEditMode) {
                  _savePreferences(diceColorProvider);
                }
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
                        StatsBar(
                          isInEditMode: isInEditMode,
                          key: _statsBarKey,
                        ),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                  color: themeProvider
                                                          .isDarkModeOn
                                                      ? Pallete.primaryOnDark
                                                      : Pallete.primaryOnLight,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: finalHopeVal >
                                                            finalFearVal
                                                        ? 'HOPE!'
                                                        : 'FEAR!',
                                                    style: TextStyle(
                                                      color: finalHopeVal >
                                                              finalFearVal
                                                          ? diceColorProvider
                                                              .hopeColor
                                                          : diceColorProvider
                                                              .fearColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(finalHopeVal > finalFearVal
                                                ? 'You gain 1 hope'
                                                : 'The GM may add a fear token to the pool.'),
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
                                              controller:
                                                  historyScrollCOntroller,
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
          rollHistory.add(
              'CRITICAL SUCCESS: $finalHopeVal(hope) + $finalFearVal(fear).');
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

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');
    if (path != null && File(path).existsSync()) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final directory = await getApplicationDocumentsDirectory();
      final savedImage =
          await File(picked.path).copy('${directory.path}/profile.png');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', savedImage.path);

      setState(() {
        _profileImage = savedImage;
      });
    }
  }

  Future<void> _savePreferences(DiceColorProvider diceColorProvider) async {
    final stats = _statsBarKey.currentState?.getCurrentStats();
    final prefs = await SharedPreferences.getInstance();

    if (stats != null) {
      await prefs.setString('savedStats', jsonEncode(stats));
      await prefs.setString('charName', nameController.text);
      await prefs.setInt(
          'currentHopeColor', diceColorProvider.hopeColor.toARGB32());
      await prefs.setInt(
          'currentFearColor', diceColorProvider.fearColor.toARGB32());
    }
    print(
        "Stats: ${prefs.getString('savedStats')} | Name: ${prefs.getString('charName')} | Dice Color: ${prefs.getInt('currentHopeColor')} | Dice Color: ${prefs.getInt('currentFearColor')}");
  }

  Future<void> _loadPreferences(DiceColorProvider diceColorProvider) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _loadingProgress = 0.2;
      _loadingMessage = 'Loading character name';
    });

    final int? hopeColorVal = prefs.getInt('currentHopeColor');
    final int? fearColorVal = prefs.getInt('currentFearColor');
    final String? savedStatsJson = prefs.getString('savedStats');

    nameController.text = prefs.getString('charName') ?? '';

    setState(() {
      _loadingProgress = 0.4;
      _loadingMessage = 'Loading dice colors';
    });

    if (hopeColorVal != null && fearColorVal != null) {
      diceColorProvider.setHopeColor(Color(hopeColorVal));
      diceColorProvider.setFearColor(Color(fearColorVal));
    }

    setState(() {
      _loadingProgress = 0.6;
      _loadingMessage = 'Loading stats';
    });

    if (savedStatsJson != null) {
      final decodedStats = jsonDecode(savedStatsJson);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final statsBarState = _statsBarKey.currentState;
        if (statsBarState != null) {
          statsBarState.setStatsFromList(decodedStats);
        } else {
          print('StatsBar state is null — not ready yet.');
        }
      });
    }

    setState(() {
      _loadingProgress = 1.0;
      _loadingMessage = 'Done!';
      _isLoading = false;
    });
  }
}
