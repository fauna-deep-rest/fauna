import 'package:fauna/services/navigation.dart';
import 'package:fauna/view_model/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fauna/view_model/sparky_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:fauna/views/widgets/chat_widgets.dart';

class SparkyChatPage extends StatefulWidget {
  @override
  _SparkyChatPageState createState() => _SparkyChatPageState();
}

class _SparkyChatPageState extends State<SparkyChatPage> {
  late SparkyViewModel sparkyViewModel =
      Provider.of<SparkyViewModel>(context, listen: false);
  late AllUsersViewModel userViewModel =
      Provider.of<AllUsersViewModel>(context, listen: false);
  bool isLoading = false;
  bool isGettingResponse = false;
  String output = "...";
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    await sparkyViewModel.loadData(
        "sparky_01"); //change this to "sparky_01" to test, userViewModel.currentUser.sparkyId for real situations.
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

    await sparkyViewModel.handleSubmit("sparky_01", text, context);

    setState(() {
      isGettingResponse = false;
    });
  }

  // Function to navigate to Bruno
  void navigateToBruno(BuildContext context) {
    Provider.of<NavigationService>(context, listen: false)
        .goBruno(); // Navigate to Bruno
  }

  // Function to navigate to Bizy
  void navigateToBizy(BuildContext context) {
    Provider.of<NavigationService>(context, listen: false)
        .goBizy(); // Navigate to Bizy
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/backgrounds/bg_sparky.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    ChatTopBar(
                      title: "Sparky",
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

                    // Sparky and speech bubble
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Speech bubble
                          SpeechBubble(
                            text: isGettingResponse
                                ? output
                                : sparkyViewModel.sparkyOutput,
                            isGettingResponse: isGettingResponse,
                          ),

                          SizedBox(height: 16.0),

                          // Sparky image
                          Column(
                            children: [
                              const SparkyImage(
                                imagePath: 'assets/images/sparky/sparky.png',
                                size: 200,
                              ),
                              const SizedBox(height: 16.0),
                              if (sparkyViewModel.showBrunoButton)
                                NavigationButton(
                                  label: 'Talk to Bruno',
                                  onPressed: () => navigateToBruno(context),
                                ),
                              if (sparkyViewModel.showBizyButton)
                                NavigationButton(
                                  label: 'Talk to Bizy',
                                  onPressed: () => navigateToBizy(context),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Chat input
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InputField(
                        controller: _textController,
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
