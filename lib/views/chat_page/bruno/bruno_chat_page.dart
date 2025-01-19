import 'package:fauna/services/navigation.dart';
import 'package:fauna/view_model/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fauna/view_model/bruno_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:fauna/views/widgets/chat_widgets.dart'; // Import chat-related widgets
import 'package:fauna/views/widgets/navigation_button.dart'; // Import NavigationButton

class BrunoChatPage extends StatefulWidget {
  const BrunoChatPage({super.key});

  @override
  State<BrunoChatPage> createState() => _BrunoChatPageState();
}

class _BrunoChatPageState extends State<BrunoChatPage> {
  late BrunoViewModel brunoViewModel =
      Provider.of<BrunoViewModel>(context, listen: false);
  late AllUsersViewModel userViewModel =
      Provider.of<AllUsersViewModel>(context, listen: false);
  bool isLoading = false;
  bool isGettingResponse = false;
  String output = "...";
  late TextEditingController _textController;

  final NavigationService _navigationService = NavigationService();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
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
    await brunoViewModel.loadData("bruno_01");
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _handleSubmit(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
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

    await brunoViewModel.handleSubmit("bruno_01", text, context);

    setState(() {
      isGettingResponse = false;
    });
  }

  // Function to start meditation
  void startMeditation() {
    _navigationService.goNSDR(); // Navigate to NSDRPage
  }

  // Function to navigate back to the homepage
  void goToHomePage() {
    _navigationService.goHome(); // Navigate to HomePage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const LoadingPage() // Use LoadingPage widget
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/backgrounds/bg_bruno.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Top navigation bar
                    ChatTopBar(
                      title: "Bruno",
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

                    // Speech bubble
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: SpeechBubble(
                              text: isGettingResponse
                                  ? output
                                  : brunoViewModel.brunoOutput,
                              isGettingResponse: isGettingResponse,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          const BrunoImage(
                            imagePath: 'assets/images/bruno/bruno.png',
                            size: 200,
                          ),
                          SizedBox(height: 16.0),
                          // Show start button if action is tutorial
                          if (brunoViewModel.brunoAction == 'tutorial')
                            NavigationButton(
                              label: "開始",
                              onPressed:
                                  startMeditation, // Call startMeditation function
                            ),
                          if (brunoViewModel.brunoAction == 'concern')
                            NavigationButton(
                              label: "返回主頁",
                              onPressed:
                                  goToHomePage, // Call goToHomePage function
                            ),
                        ],
                      ),
                    ),

                    // Chat input
                    if (!isGettingResponse) // Only show input field if not getting response
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
