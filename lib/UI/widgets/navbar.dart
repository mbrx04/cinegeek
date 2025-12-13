import 'dart:ui';
import 'package:flutter/material.dart';
import 'circle_button.dart';

typedef PageChanged = void Function(int pageIndex);
typedef SearchChanged = void Function(String text);

class LiquidNavBar extends StatefulWidget {
  final int selectedIndex;
  final PageChanged onPageChanged;
  final SearchChanged? onSearchChanged;

  const LiquidNavBar({
    super.key,
    required this.selectedIndex,
    required this.onPageChanged,
    this.onSearchChanged,
  });

  @override
  State<LiquidNavBar> createState() => LiquidNavBarState();
}

class LiquidNavBarState extends State<LiquidNavBar>
    with SingleTickerProviderStateMixin {
  
  // UI State
  late int _activeIndex;
  Offset? _dragPosition;
  bool _isDragging = false;
  bool _isSearchOpened = false;
  final TextEditingController _searchController = TextEditingController();

  //animazione
  late AnimationController _animController;
  late Animation<double> _widthAnim;
  
  final double _navSize = 70;
  final double _iconSize = 56; //simensione standard per i bottoni circolari

  final List<IconData> icons = [
    Icons.home,
    Icons.reviews,
    Icons.person,
  ];

  //chiude a ricerca se è aperta facendo back con gesture
  void closeSearch() {
    if (_isSearchOpened) {
      setState(() {
        _isSearchOpened = false;
        _searchController.clear(); //pulisce il testo
        FocusScope.of(context).unfocus(); //chiude la tastiera
        _animController.reverse(); //stop animazione
      });
      widget.onSearchChanged?.call(""); 
    }
  }

  bool get isSearchOpen => _isSearchOpened;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.selectedIndex;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _searchController.addListener(() {
      widget.onSearchChanged?.call(_searchController.text);
    });
  }

  @override
  void didUpdateWidget(LiquidNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      setState(() {
        _activeIndex = widget.selectedIndex;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

//navigazione  
  void _onDragUpdate(Offset localPosition, double width) {
    double segmentWidth = width / icons.length;
    int newIndex = (localPosition.dx ~/ segmentWidth).clamp(0, icons.length - 1);
    if (newIndex != _activeIndex) {
      setState(() => _activeIndex = newIndex);
    }
  }

  void _onDragEnd() {
    widget.onPageChanged(_activeIndex);
    setState(() {
      _isDragging = false;
      _dragPosition = null;
    });
  }

  void _onIconTap(int index) {
    setState(() => _activeIndex = index);
    widget.onPageChanged(index);
  }

  //ricerca

  void _toggleSearch() {
    setState(() {
      _isSearchOpened = !_isSearchOpened;
      if (_isSearchOpened) {
        _animController.forward();
      } else {
        _searchController.clear();
        FocusScope.of(context).unfocus(); //chiude la tasteira al primo back
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxSearchWidth = screenWidth - 40; //larghezza massima search bar

    _widthAnim = Tween<double>(
      begin: _navSize,
      end: maxSearchWidth,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    return Stack(
      children: [
        //nav bar
        if (!_isSearchOpened)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20 + _navSize + 10,
            child: GestureDetector(
              onHorizontalDragStart: (details) => setState(() {
                _isDragging = true;
                _dragPosition = details.localPosition;
              }),
              onHorizontalDragUpdate: (details) {
                setState(() => _dragPosition = details.localPosition);
                //calcolo larghezza area drag
                double dragAreaWidth = screenWidth - (50 + _navSize);
                _onDragUpdate(details.localPosition, dragAreaWidth);
              },
              onHorizontalDragEnd: (details) => _onDragEnd(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: _navSize,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(64),
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        //bolla animata
                        if (_isDragging && _dragPosition != null)
                          Positioned(
                            left: (_dragPosition!.dx - 30).clamp(0.0, screenWidth - (50 + _navSize) - 60),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(38),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        //icone
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(icons.length, (i) {
                            final isSelected = _activeIndex == i;
                            return GestureDetector(
                              onTap: () => _onIconTap(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: isSelected ? 70 : 60,
                                height: isSelected ? 70 : 60,
                                decoration: BoxDecoration(
                                  color: (!_isDragging && isSelected)
                                      ? Colors.white.withAlpha(38)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icons[i],
                                  size: 28,
                                  color: isSelected
                                      ? const Color.fromARGB(255, 204, 255, 0)
                                      : Colors.white54,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        //search bar che si estende
        Positioned(
          bottom: 20,
          right: 20,
          child: AnimatedBuilder(
            animation: _widthAnim,
            builder: (context, child) {
              final double currentWidth = _widthAnim.value;
              // 140 = icona (56) + gap (8) + min text field + close
              final bool showContent = currentWidth > 140; 
              //mostra bottone chiudi solo verso la fine dell'apertura
              final bool showCloseBtn = currentWidth > 200; 

              return Container(
                width: currentWidth,
                height: _navSize,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(153),
                  borderRadius: BorderRadius.circular(35), // Sempre circolare ai lati
                  border: Border.all(color: Colors.white.withAlpha(26), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: _isSearchOpened ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    //lente sempre visibile
                    SizedBox(
                      width: _iconSize, // 56px fisso
                      height: _iconSize,
                      child: IconButton(
                        onPressed: _toggleSearch,
                        icon: const Icon(Icons.search, color: Colors.white, size: 24),
                        padding: EdgeInsets.zero, //rimuove padding extra
                      ),
                    ),

                    //campo di testo solo quando c'è spazio
                    if (_isSearchOpened && showContent) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Cerca...",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (text) {
                            print("Cerco: $text");
                            _toggleSearch(); //chiudi se clicchi invio
                          },
                        ),
                      ),
                    ],

                    //bottone X per chiudere che esce solo a fine animaizone
                    if (_isSearchOpened && showCloseBtn) ...[
                      SizedBox(
                        width: _iconSize,
                        height: _iconSize,
                        child: CircleButton(
                          icon: Icons.close, 
                          size: _iconSize,
                          backgroundColor: Colors.transparent,
                          onTap: _toggleSearch,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}