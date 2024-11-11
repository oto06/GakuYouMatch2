import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({Key? keyx}) : super(key: keyx); // keyパラメータを追加

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'CHATER*ISE',
        // 'CHATERAISE(嘘)',
        style: TextStyle(color: Colors.brown), // 文字色を白に設定
      ),
      centerTitle: true, // タイトルを中央に配置
      backgroundColor: Colors.white, // 背景色を白に設定
    );
  }
}