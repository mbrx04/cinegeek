import 'dart:ui';
import 'package:flutter/material.dart';
import 'circle_button.dart';
import 'dart:async';  //FONDAMENTALE PER NON ESSERE FOTTUTI! serveper non fare chiamate all'API ogni volta che si digita una lettera ma solo dopo un tempo prestabilito

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

  //timer per aspettare prima di fare la ricerca
  Timer? _debounce;

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
      if (_debounce?.isActive ?? false) _debounce!.cancel();
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

    _searchController.addListener(_onSearchInputChanged);
  }

  //----------------IMPORTANTISSIMO SEMPRE PER NON ESSERE FOTTUI E FARE CHIAMATE INUTILI!!!!!!!
  void _onSearchInputChanged() {
    //se c'è un timer attivo e viene scritta una cosa tramite la tastiera, anche una sola lettera lo annulla
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    //ne fa partire uno nuovo sempre di 500 ms
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      //se si smette di scrivere per 1 secondo allora cerca
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
    _debounce?.cancel();
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
    final double maxSearchWidth = screenWidth - 40;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color glassBackground = isDark 
        ? Colors.black.withAlpha(90)  //opacità dark mode
        : Colors.white.withAlpha(90); //opacità light mode

    final Color glassBorder = isDark 
        ? Colors.white.withAlpha(30) 
        : Colors.black.withAlpha(20);

    final Color contentColor = isDark ? Colors.white : Colors.black;
    final Color hintColor = isDark ? Colors.white70 : Colors.black54;

    _widthAnim = Tween<double>(
      begin: _navSize,
      end: maxSearchWidth,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    return Stack(
      children: [
        //nav bar principale
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
                    decoration: BoxDecoration(  //pillola flottante
                      color: isDark ? Colors.black.withAlpha(80) : Colors.white.withAlpha(90),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: glassBorder, width: 1),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        //bolla di selezione
                        if (_isDragging && _dragPosition != null)
                          Positioned(
                            left: (_dragPosition!.dx - 30).clamp(0.0, screenWidth - (50 + _navSize) - 60),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(15),
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
                                      ? (isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(10))
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icons[i],
                                  size: 28,
                                  color: isSelected
                                      ? const Color.fromARGB(255, 204, 255, 0)
                                      : contentColor.withAlpha(128),
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

        //search bar espandibile
        Positioned(
          bottom: 20,
          right: 20,
          child: AnimatedBuilder(
            animation: _widthAnim,
            builder: (context, child) {
              final double currentWidth = _widthAnim.value;
              final bool showContent = currentWidth > 140;
              final bool showCloseBtn = currentWidth > 200;

              return ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: currentWidth,
                    height: _navSize,
                    decoration: BoxDecoration(
                      color: glassBackground,
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: glassBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: _isSearchOpened ? MainAxisAlignment.start : MainAxisAlignment.center,
                      children: [
                        //lente
                        SizedBox(
                          width: _iconSize,
                          height: _iconSize,
                          child: IconButton(
                            onPressed: _toggleSearch,
                            icon: Icon(Icons.search, color: contentColor, size: 24),
                            padding: EdgeInsets.zero,
                          ),
                        ),

                        //campo di testo
                        if (_isSearchOpened && showContent) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: TextStyle(color: contentColor),
                              decoration: InputDecoration(
                                hintText: "Cerca...",
                                hintStyle: TextStyle(color: hintColor),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (text) {
                                _toggleSearch();
                              },
                            ),
                          ),
                        ],

                        //tasto X per chiudere
                        if (_isSearchOpened && showCloseBtn) ...[
                          SizedBox(
                            width: _iconSize,
                            height: _iconSize,
                            child: CircleButton(
                              icon: Icons.close,
                              size: _iconSize,
                              backgroundColor: Colors.transparent,
                              borderColor: Colors.transparent,
                              iconColor: contentColor,
                              onTap: _toggleSearch,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}