import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../constants/constants.dart';

class NotifyPage extends StatefulWidget {
  const NotifyPage({super.key});

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {
  String formatter = DateFormat('E, MMM d').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(formatter),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const ImageIcon(
              AssetImage("images/fingpticon.png"),
              color: kBlueColor,
              size: 30,
            ), onPressed: () {  },
          ),
          IconButton(
            onPressed: () {
            },
            icon: const Icon(FontAwesomeIcons.bell),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
