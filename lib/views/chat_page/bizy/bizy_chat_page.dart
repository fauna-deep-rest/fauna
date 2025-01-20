import 'package:fauna/services/navigation.dart';
import 'package:fauna/view_model/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fauna/view_model/bizy_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:fauna/views/widgets/chat_widgets.dart';

class BizyChatPage extends StatefulWidget {
  @override
  _BizyChatPageState createState() => _BizyChatPageState();
}

class _BizyChatPageState extends State<BizyChatPage> {
  late BizyViewModel bizyViewModel;
  late AllUsersViewModel userViewModel;
  bool isLoading = false;
  bool isGettingResponse = false;
  String output = "...";

  @override
  void initState() {
    super.initState();
    bizyViewModel = Provider.of<BizyViewModel>(context, listen: false);
    userViewModel = Provider.of<AllUsersViewModel>(context, listen: false);
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    await bizyViewModel.loadData("bizy_01");
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _handleSubmit(String text) async {
    print("submitting!");
    setState(() {
      isGettingResponse = true;
    });

    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (output == "...") {
          output = ".";
        } else {
          output += ".";
        }
      });
    });

    await bizyViewModel.handleSubmit(text, "01", context);

    setState(() {
      isGettingResponse = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/backgrounds/bg_bizy.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    ChatTopBar(
                      title: "Bizy",
                      titleColor: Colors.white,
                      iconColor: Colors.white,
                      onBackPressed: () {
                        // Handle back button press
                        print('back pressed');
                      },
                      onHistoryPressed: () {
                        // Handle history button press
                        print('history pressed');
                      },
                    ),

                    // Bizy and speech bubble
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Speech bubble
                          SpeechBubble(
                            text: bizyViewModel.bizyType == 'bizy_main' &&
                                    isGettingResponse
                                ? output
                                : bizyViewModel.bizyOutput,
                            isGettingResponse:
                                bizyViewModel.bizyType == 'bizy_main' &&
                                    isGettingResponse,
                          ),

                          SizedBox(height: 16.0),

                          // Bizy image
                          Column(
                            children: [
                              const BizyImage(
                                imagePath: 'assets/images/bizy/bizy.png',
                                size: 200,
                              ),
                              const SizedBox(height: 16.0),
                              if (bizyViewModel.showSmallBizy) ...[
                                Text(
                                  "Planbee",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SpeechBubble(
                                  text: bizyViewModel.bizyType != 'bizy_main' &&
                                          isGettingResponse
                                      ? output
                                      : bizyViewModel.smallBizyOutput,
                                  isGettingResponse:
                                      bizyViewModel.bizyType != 'bizy_main' &&
                                          isGettingResponse,
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Chat input
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InputField(
                        onSubmitted: _handleSubmit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
