import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_player_animation/cover_details.dart';
import 'package:music_player_animation/cover_model.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Albuns',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(flex: 3, child: BodyCard()),
              ListCardHorizontal(),
            ],
          ),
        ));
  }
}

class BodyCard extends StatefulWidget {
  @override
  _BodyCardState createState() => _BodyCardState();
}

class _BodyCardState extends State<BodyCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _animationControllerMoviment;
  bool _selectionMode = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.09,
      upperBound: 0.3,
    );
    _animationControllerMoviment = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    super.initState();
  }

  int _selectedIndex = 0;

  Future<void> _onCardSelected(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    _animationControllerMoviment..forward();
    const duration = Duration(milliseconds: 700);

    await Navigator.of(context).push(
      PageRouteBuilder(
        reverseTransitionDuration: duration,
        transitionDuration: duration,
        pageBuilder: (_, anim1, anim2) {
          return FadeTransition(
            opacity: anim1,
            child: CoverDetails(coverModel: listCoverModel[index]),
          );
        },
      ),
    );
    _animationControllerMoviment.reverse(from: 1.0);
  }

  int _getCurrentIndex(int currentIndex) {
    if (currentIndex == _selectedIndex) {
      return 0;
    } else if (currentIndex > _selectedIndex) {
      return -1;
    } else {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              print("outer absorber");
              if (!_selectionMode) {
                _animationController.forward().whenComplete(
                  () {
                    setState(
                      () {
                        _selectionMode = true;
                      },
                    );
                  },
                );
              } else {
                _animationController.reverse().whenComplete(
                  () {
                    setState(
                      () {
                        _selectionMode = false;
                      },
                    );
                  },
                );
              }
            },
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_animationController.value),
              child: AbsorbPointer(
                absorbing: !_selectionMode,
                child: Container(
                  color: Colors.transparent,
                  height: constraints.maxHeight,
                  width: constraints.maxWidth * .5,
                  child: Stack(
                    children: [
                      ...List.generate(
                        listCoverModel.length,
                        (index) => CardMoviment(
                          coverModel: listCoverModel[index],
                          depth: index,
                          animationController: _animationControllerMoviment,
                          percentMoviment: _animationController.value,
                          height: constraints.maxHeight / 2,
                          isAbsorbing: _selectionMode,
                          verticalFactor: _getCurrentIndex(index),
                          onTap: () {
                            _onCardSelected(index);
                          },
                        ),
                      ).reversed,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CardMoviment extends AnimatedWidget {
  final CoverModel coverModel;
  final double percentMoviment;
  final AnimationController animationController;
  final int verticalFactor;
  final double height;
  final int depth;
  final bool isAbsorbing;
  final Function onTap;

  const CardMoviment(
      {required this.coverModel,
      required this.isAbsorbing,
      required this.animationController,
      required this.percentMoviment,
      required this.height,
      required this.depth,
      this.verticalFactor = 0,
      required this.onTap})
      : super(listenable: animationController);

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: height * 0.7 + (-depth * height / 2) * percentMoviment,
      child: Opacity(
        opacity: 1 - _progress.value,
              child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(
              0.0,
              verticalFactor *
                  _progress.value *
                  MediaQuery.of(context).size.height,
              depth * 50,
            ),
          child: InkWell(
            onTap: () {
              onTap();
            },
            child: Hero(
              tag: coverModel.imageUrl,
              flightShuttleBuilder: (
                BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,
              ) {
                final Hero toHero = toHeroContext.widget as Hero;
                return FlipcardTransition(
                  flipAnim: animation,
                  child: toHero,
                );
              },
              child: SizedBox(
                child: CardCover(coverModel),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ListCardHorizontal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) => CardCover(
            listCoverModel[index],
          ),
          itemCount: listCoverModel.length,
        ),
      ),
    );
  }
}

class FlipcardTransition extends AnimatedWidget {
  final Animation<double> flipAnim;
  final Widget child;

  FlipcardTransition({required this.flipAnim, required this.child})
      : super(listenable: flipAnim);

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..rotateX(-pi * 2 * flipAnim.value),
      alignment: FractionalOffset.center,
      child: child,
    );
  }
}

class CardCover extends StatelessWidget {
  final CoverModel coverModel;
  const CardCover(this.coverModel);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: PhysicalModel(
        color: Colors.black,
        elevation: 20,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            child: Image.asset(
              coverModel.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
