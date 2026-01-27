//contiene la parte sotto la copertina del film in movie detail cioè la descrizione del film che si espande
import 'package:flutter/material.dart';

class MovieDescription extends StatefulWidget {
  final String description;

  const MovieDescription({super.key, required this.description});

  @override
  State<MovieDescription> createState() => _MovieDescriptionState();
}

class _MovieDescriptionState extends State<MovieDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
          child: Text(
            widget.description,
            textAlign: TextAlign.left,
            maxLines: _isExpanded ? null : 4,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
        ),
        if (widget.description.length > 150)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),  //espande la descrizione
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              child: Center(
                child: Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}