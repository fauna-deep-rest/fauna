import 'package:fauna/services/navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // 資料定義：角色與背景
  final List<Map<String, String>> _characters = [
    {
      'name': 'Sparky',
      'description': 'A friendly guide to provide helpful advice.',
      'background': 'assets/images/backgrounds/bg_sparky.png',
      'image': 'assets/images/sparky/sparky.png',
    },
    {
      'name': 'Bruno',
      'description': 'Meditation master.',
      'background': 'assets/images/backgrounds/bg_bruno.png',
      'image': 'assets/images/bruno/bruno.png',
    },
    {
      'name': 'Bizy',
      'description': 'An expert dealing with procrastination.',
      'background': 'assets/images/backgrounds/bg_bizy.png',
      'image': 'assets/images/bizy/bizy.png',
    },
  ];

  void _onArrowPressed(int direction) {
    // 計算新的頁面索引
    int newIndex = _currentIndex + direction;
    if (newIndex >= 0 && newIndex < _characters.length) {
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景與角色切換（PageView）
          PageView.builder(
            controller: _pageController,
            itemCount: _characters.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final character = _characters[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // 背景圖片
                  Image.asset(
                    character['background']!,
                    fit: BoxFit.cover,
                  ),
                  // 角色信息
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        character['name']!,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        character['description']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          if (_currentIndex == 0) {
                            Provider.of<NavigationService>(context,
                                    listen: false)
                                .goSparky();
                          } else if (_currentIndex == 1) {
                            print("bruno");
                          } else if (_currentIndex == 2) {
                            print("bizy");
                          }
                        },
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

          // 固定的前景按鈕
          Positioned(
            left: 16,
            top: MediaQuery.of(context).size.height / 2 - 24,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 32),
              onPressed: () => _onArrowPressed(-1), // 左滑動
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height / 2 - 24,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward, size: 32),
              onPressed: () => _onArrowPressed(1), // 右滑動
            ),
          ),

          // 固定底部按鈕
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print("Diary button pressed");
                  },
                  child: const Text('Diary'),
                ),
                ElevatedButton(
                  onPressed: () {
                    print("Map button pressed");
                  },
                  child: const Text('Map'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
