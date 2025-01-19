import 'package:fauna/services/navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fauna/views/widgets/index.dart';
import 'package:fauna/views/characters.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final List<Map<String, String>> _characters = characters;

  // Handle arrow button press events
  void _onArrowPressed(int direction) {
    int newIndex = _currentIndex + direction;
    if (newIndex >= 0 && newIndex < _characters.length) {
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Update current index when page changes
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Handle character tap events
  void _onCharacterTap() {
    final navigationService =
        Provider.of<NavigationService>(context, listen: false);
    switch (_currentIndex) {
      case 0:
        navigationService.goSparky();
        break;
      case 1:
        navigationService.goBruno();
        break;
      case 2:
        print("bizy");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background and character switching (PageView)
          PageView.builder(
            controller: _pageController,
            itemCount: _characters.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final character = _characters[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  Image.asset(
                    character['background']!,
                    fit: BoxFit.cover,
                  ),
                  // Character information
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Introduction(
                        name: character['name']!,
                        description: character['description']!,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _onCharacterTap,
                        child: Image.asset(
                          character['image']!,
                          height: 200,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          // Fixed foreground buttons
          Positioned(
            left: 16,
            top: MediaQuery.of(context).size.height / 2 - 24,
            child: NavigationArrowButton(
              icon: Icons.arrow_back,
              onPressed: () => _onArrowPressed(-1),
              iconColor: Colors.white,
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height / 2 - 24,
            child: NavigationArrowButton(
              icon: Icons.arrow_forward,
              onPressed: () => _onArrowPressed(1),
              iconColor: Colors.white,
            ),
          ),

          // Fixed bottom buttons
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MenuButton(
                  label: 'Diary',
                  onPressed: () {
                    print("Diary button pressed");
                  },
                ),
                MenuButton(
                  label: 'Map',
                  onPressed: () {
                    print("Map button pressed");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
