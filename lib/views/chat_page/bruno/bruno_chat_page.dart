import 'package:fauna/services/navigation.dart';
import 'package:fauna/view_model/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fauna/view_model/bruno_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {},
                          ),
                          Text(
                            "Bruno",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // Sparky and speech bubble
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Speech bubble
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                isGettingResponse
                                    ? output
                                    : brunoViewModel.brunoOutput,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          SizedBox(height: 16.0),

                          // Sparky image
                          Container(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: Image.asset(
                                'assets/images/bruno/bruno.png', // Replace with the correct path to Sparky's image
                                width: 200,
                                height: 200,
                              ),
                            ),
                          ),

                          SizedBox(height: 16.0),
                        ],
                      ),
                    ),

                    // Chat input
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Say something...",
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey[800],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                              controller: _textController,
                              onSubmitted: _handleSubmit,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[800],
                              child: Icon(Icons.send, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
