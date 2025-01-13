import 'package:fauna/services/navigation.dart';
import 'package:fauna/view_model/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fauna/view_model/sparky_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';

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
    await sparkyViewModel.loadData(
        "sparky_01"); //change this to "sparky_01" to test, userViewModel.currentUser.sparkyId for real situations.
    setState(() {
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                    // Top navigation bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () {},
                          ),
                          const Text(
                            "Sparky",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
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
                                    : sparkyViewModel.sparkyOutput,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          SizedBox(height: 16.0),

                          // Sparky image
                          Column(
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[800],
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/sparky/sparky.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              if (sparkyViewModel.showBrunoButton)
                                ElevatedButton(
                                  onPressed: () {
                                    Provider.of<NavigationService>(context,
                                            listen: false)
                                        .goBruno();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    'Talk to Bruno',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              if (sparkyViewModel.showBizyButton)
                                ElevatedButton(
                                  onPressed: () {
                                    Provider.of<NavigationService>(context,
                                            listen: false)
                                        .goBizy();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    'Talk to Bizy',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
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
                              onSubmitted: (text) async {
                                print("submitting!");
                                _textController.clear();
                                setState(() {
                                  isGettingResponse = true;
                                });

                                Timer.periodic(Duration(milliseconds: 500),
                                    (timer) {
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

                                await sparkyViewModel.handleSubmit(
                                    "sparky_01", text, context);

                                setState(() {
                                  isGettingResponse = false;
                                });
                              },
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
