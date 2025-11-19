import 'dart:ui';
import 'package:flutter/material.dart';

typedef PageChanged = void Function(int pageIndex);

class LiquidNavBar extends StatefulWidget {
  final int selectedIndex;
  final PageChanged onPageChanged;

  const LiquidNavBar({
    super.key,
    required this.selectedIndex,
    required this.onPageChanged,
  });

  @override
  State<LiquidNavBar> createState() => _LiquidNavBarState();
}

class _LiquidNavBarState extends State<LiquidNavBar> {
  late int _activeIndex;
  Offset? _dragPosition;
  bool _isDragging = false;

  final List<IconData> icons = [
    Icons.home,
    Icons.reviews,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.selectedIndex;
  }

  void _onDragUpdate(Offset localPosition, double width) {
    double segmentWidth = width / icons.length;
    int newIndex = (localPosition.dx ~/ segmentWidth).clamp(0, icons.length - 1);
    if (newIndex != _activeIndex) {
      setState(() {
        _activeIndex = newIndex;
      });
    }
  }

  void _onDragEnd() {
    widget.onPageChanged(_activeIndex);
    setState(() {
      _isDragging = false;
      _dragPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Barra principale
        Positioned(
          bottom: 20,
          left: 20,
          right: 80,
          child: GestureDetector(
            onHorizontalDragStart: (details) {
              setState(() {
                _isDragging = true;
                _dragPosition = details.localPosition;
              });
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragPosition = details.localPosition;
              });
              _onDragUpdate(details.localPosition, screenWidth - 100);
            },
            onHorizontalDragEnd: (details) => _onDragEnd(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Bolla liquida che segue il dito
                      if (_isDragging && _dragPosition != null)
                        Positioned(
                          left: (_dragPosition!.dx - 30).clamp(0.0, screenWidth - 100 - 60),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 70, // bolla più grande durante il drag
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                      // Icone centrate
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (int i = 0; i < icons.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _activeIndex == i ? 70 : 60,
                              height: _activeIndex == i ? 70 : 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: (!_isDragging && _activeIndex == i)
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icons[i],
                                size: 28,
                                color: _activeIndex == i
                                    ? const Color.fromARGB(255, 204, 255, 0)
                                    : Colors.white54,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Tasto Cerca circolare
        Positioned(
          bottom: 20,
          right: 20,
          child: SizedBox(
            width: 60,
            height: 70,
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    print("Cerca premuto");
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
