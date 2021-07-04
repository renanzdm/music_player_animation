import 'package:flutter/material.dart';
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

class _BodyCardState extends State<BodyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _selectionMode = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.09,
      upperBound: 0.3,
    );
    super.initState();
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
                          animationController: _animationController,
                          percentMoviment: _animationController.value,
                          height: constraints.maxHeight / 2,
                          isAbsorbing: _selectionMode,
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
  final double height;
  final int depth;
  final bool isAbsorbing;

  const CardMoviment(
      {required this.coverModel,
    required  this.isAbsorbing ,
      required this.animationController,
      required this.percentMoviment,
      required this.height,
      required this.depth})
      : super(listenable: animationController);

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: height * 0.7 + (-depth * height / 2) * percentMoviment,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..translate(0.0, 0.0, depth * 50),
        child: InkWell(
          onTap: (){
            print("teste");
          },
                  child: SizedBox(
            child: CardCover(coverModel),
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
