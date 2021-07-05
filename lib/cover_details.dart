import 'package:flutter/material.dart';
import 'package:music_player_animation/cover_model.dart';
import 'package:music_player_animation/my_home_page.dart';

class CoverDetails extends StatelessWidget {
  final CoverModel coverModel;

  CoverDetails({required this.coverModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 200,
          width: 200,   
          child: Hero(
            tag: coverModel.imageUrl,
            child: CardCover(coverModel),
          ),
        ),
      ),
    );
  }
}
