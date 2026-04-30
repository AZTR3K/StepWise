import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_panel.dart';

import 'dart:math' as math;

class BaseVisualizerControl extends StatefulWidget {
  final bool isPlaying;
  final bool canStepBack;
  final bool canStepForward;
  final VoidCallback onPlayPause;
  final VoidCallback onStepBack;
  final VoidCallback onStepForward;
  final VoidCallback onRestart;
  
  final List<int> currentArray;
  final ValueChanged<List<int>> onArrayUpdated;

  const BaseVisualizerControl({
    super.key,
    required this.isPlaying,
    required this.canStepBack,
    required this.canStepForward,
    required this.onPlayPause,
    required this.onStepBack,
    required this.onStepForward,
    required this.onRestart,
    required this.currentArray,
    required this.onArrayUpdated,
  });

  @override
  State<BaseVisualizerControl> createState() => _BaseVisualizerControlState();
}

class _BaseVisualizerControlState extends State<BaseVisualizerControl> {
  late TextEditingController _textController;
  Timer? _debounce;
  int _currentSize = 0;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.currentArray.length;
    _textController = TextEditingController(text: widget.currentArray.join(', '));
  }

  @override
  void didUpdateWidget(covariant BaseVisualizerControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync array if updated externally, but avoid cursor jump
    if (widget.currentArray.length != oldWidget.currentArray.length || 
        widget.currentArray.join(', ') != oldWidget.currentArray.join(', ')) {
      final newText = widget.currentArray.join(', ');
      if (_textController.text != newText && !FocusScope.of(context).hasFocus) {
        _textController.text = newText;
        _currentSize = widget.currentArray.length;
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _parseAndUpdate(value);
    });
  }

  void _parseAndUpdate(String value) {
    final matches = RegExp(r'-?\d+').allMatches(value);
    final newArray = matches.map((m) => int.parse(m.group(0)!)).toList();
    if (newArray.isEmpty) return; // Ignore completely empty arrays

    if (newArray.join(',') != widget.currentArray.join(',')) {
      setState(() => _currentSize = newArray.length);
      widget.onArrayUpdated(newArray);
    }
  }

  void _modulateSize(int delta) {
    int newSize = _currentSize + delta;
    if (newSize < 2) newSize = 2;
    if (newSize > 25) newSize = 25; // Sensible max bound for mobile
    if (newSize == _currentSize) return;

    List<int> newArray = List.from(widget.currentArray);
    if (newSize > _currentSize) {
      // Pad with random values between 1 and 100
      final rnd = math.Random();
      for (int i = 0; i < newSize - _currentSize; i++) {
        newArray.add(rnd.nextInt(100) + 1);
      }
    } else {
      newArray = newArray.sublist(0, newSize);
    }

    _textController.text = newArray.join(', ');
    setState(() => _currentSize = newSize);
    widget.onArrayUpdated(newArray);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        alpha: 0.1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Array Configuration ──
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: TextField(
                        controller: _textController,
                        onChanged: _onTextChanged,
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Comma separated...',
                          hintStyle: TextStyle(color: Colors.white30),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // ── Size Modulation ──
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white70, size: 20),
                        onPressed: () => _modulateSize(-1),
                      ),
                      Text(
                        '$_currentSize',
                        style: const TextStyle(color: AppColors.indigoLight, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white70, size: 20),
                        onPressed: () => _modulateSize(1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ── Playback Controls ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: widget.onRestart,
                  icon: const Icon(Icons.restart_alt, color: Colors.white70, size: 28),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: widget.canStepBack ? widget.onStepBack : null,
                  icon: Icon(Icons.skip_previous,
                      color: widget.canStepBack ? Colors.white : Colors.white24, size: 32),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: widget.onPlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.indigo,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.indigo.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(
                      widget.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: widget.canStepForward ? widget.onStepForward : null,
                  icon: Icon(Icons.skip_next,
                      color: widget.canStepForward ? Colors.white : Colors.white24, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
