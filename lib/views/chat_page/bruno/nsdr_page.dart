import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fauna/services/navigation.dart'; // 導入 NavigationService/ 確保導入 BrunoChatPage
import 'package:fauna/views/widgets/navigation_button.dart'; // 導入 NavigationButton

class NSDRPage extends StatelessWidget {
  const NSDRPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationService navigationService =
        NavigationService(); // 創建 NavigationService 的實例

    return Scaffold(
      appBar: AppBar(title: const Text("NSDR 頁面")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text("這是 NSDR 頁面", style: TextStyle(fontSize: 24)),
            NavigationButton(
              label: "返回 Bruno 頁面", // 按鈕標籤
              onPressed: () {
                // 使用 NavigationService 導航到 BrunoChatPage
                navigationService.goBruno(); // 導航到 BrunoChatPage
              },
              backgroundColor: Colors.blue, // 可選的背景顏色
            ),
            const SizedBox(height: 20),
            Expanded(
              child: NSDRAnimation(), // Include the NSDRAnimation widget
            ),
          ],
        ),
      ),
    );
  }
}

class Spotlight extends StatelessWidget {
  final Offset position;

  const Spotlight({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 15,
      top: position.dy - 15,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.yellow.withOpacity(0.7),
          boxShadow: const [
            BoxShadow(
              color: Colors.yellow,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }
}

final List<Offset> positions = [
  const Offset(150, 450), // Feet
  const Offset(150, 375), // Calves
  const Offset(150, 300), // Abdomen
  const Offset(150, 200), // Chest
  const Offset(150, 75), // Head
];

final List<String> messages = [
  "放鬆雙腳", // Message for Feet
  "放鬆小腿", // Message for Calves
  "放鬆腹部", // Message for Abdomen
  "放鬆胸部", // Message for Chest
  "放鬆頭部", // Message for Head
];

class NSDRAnimation extends StatefulWidget {
  const NSDRAnimation({super.key});

  @override
  _NSDRAnimationState createState() => _NSDRAnimationState();
}

class _NSDRAnimationState extends State<NSDRAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 2), () {
            if (_currentIndex < positions.length - 1) {
              setState(() {
                _currentIndex++;
                _animation = Tween<Offset>(
                  begin: positions[_currentIndex - 1],
                  end: positions[_currentIndex],
                ).animate(_controller);
                _controller.forward(from: 0);
              });
            }
          });
        }
      });

    _animation = Tween<Offset>(
      begin: positions[0],
      end: positions[1],
    ).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          'assets/images/bruno/bruno.svg',
          width: 300,
          height: 500,
          fit: BoxFit.cover,
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                Spotlight(position: _animation.value),
                Positioned(
                  left: 20,
                  top: 20,
                  child: Text(
                    messages[
                        _currentIndex], // Show message based on current index
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
