import 'package:flutter/material.dart';
import 'package:fauna/services/navigation.dart'; // 導入 NavigationService
import 'bruno_chat_page.dart'; // 確保導入 BrunoChatPage
import 'package:fauna/views/widgets/navigation_button.dart'; // 導入 NavigationButton

class NSDRPage extends StatelessWidget {
  const NSDRPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NavigationService _navigationService =
        NavigationService(); // 創建 NavigationService 的實例

    return Scaffold(
      appBar: AppBar(title: const Text("NSDR 頁面")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("這是 NSDR 頁面", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            NavigationButton(
              label: "返回 Bruno 頁面", // 按鈕標籤
              onPressed: () {
                // 使用 NavigationService 導航到 BrunoChatPage
                _navigationService.goBruno(); // 導航到 BrunoChatPage
              },
              backgroundColor: Colors.blue, // 可選的背景顏色
            ),
          ],
        ),
      ),
    );
  }
}
