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

  // ── Search-mode extensions ──────────────────────────────────────────────────
  /// When non-null, renders a "Target Value" row above the playback controls.
  final int? currentTarget;
  final ValueChanged<int>? onTargetUpdated;

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
    // Search-mode — omit for sorting screens
    this.currentTarget,
    this.onTargetUpdated,
  });

  bool get isSearchMode => currentTarget != null && onTargetUpdated != null;

  @override
  State<BaseVisualizerControl> createState() => _BaseVisualizerControlState();
}

class _BaseVisualizerControlState extends State<BaseVisualizerControl> {
  late TextEditingController _arrayController;
  late TextEditingController _targetController;
  Timer? _arrayDebounce;
  Timer? _targetDebounce;
  int _currentSize = 0;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.currentArray.length;
    _arrayController = TextEditingController(text: widget.currentArray.join(', '));
    _targetController = TextEditingController(
      text: widget.currentTarget?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant BaseVisualizerControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync array if updated externally (but never stomp active cursor)
    if (widget.currentArray.join(', ') != oldWidget.currentArray.join(', ')) {
      final newText = widget.currentArray.join(', ');
      if (_arrayController.text != newText && !FocusScope.of(context).hasFocus) {
        _arrayController.text = newText;
        _currentSize = widget.currentArray.length;
      }
    }
    // Sync target if changed from outside (e.g. a reset)
    if (widget.currentTarget != oldWidget.currentTarget) {
      final newTarget = widget.currentTarget?.toString() ?? '';
      if (_targetController.text != newTarget && !FocusScope.of(context).hasFocus) {
        _targetController.text = newTarget;
      }
    }
  }

  @override
  void dispose() {
    _arrayDebounce?.cancel();
    _targetDebounce?.cancel();
    _arrayController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  // ── Array logic ─────────────────────────────────────────────────────────────
  void _onArrayTextChanged(String value) {
    if (_arrayDebounce?.isActive ?? false) _arrayDebounce!.cancel();
    _arrayDebounce = Timer(const Duration(milliseconds: 500), () {
      _parseAndUpdateArray(value);
    });
  }

  void _parseAndUpdateArray(String value) {
    final matches = RegExp(r'-?\d+').allMatches(value);
    final newArray = matches.map((m) => int.parse(m.group(0)!)).toList();
    if (newArray.isEmpty) return;
    if (newArray.join(',') != widget.currentArray.join(',')) {
      setState(() => _currentSize = newArray.length);
      widget.onArrayUpdated(newArray);
    }
  }

  void _modulateSize(int delta) {
    int newSize = (_currentSize + delta).clamp(2, 25);
    if (newSize == _currentSize) return;

    List<int> newArray = List.from(widget.currentArray);
    if (newSize > _currentSize) {
      final rnd = math.Random();
      for (int i = 0; i < newSize - _currentSize; i++) {
        newArray.add(rnd.nextInt(100) + 1);
      }
    } else {
      newArray = newArray.sublist(0, newSize);
    }

    _arrayController.text = newArray.join(', ');
    setState(() => _currentSize = newSize);
    widget.onArrayUpdated(newArray);
  }

  // ── Target logic ─────────────────────────────────────────────────────────────
  void _onTargetTextChanged(String value) {
    if (_targetDebounce?.isActive ?? false) _targetDebounce!.cancel();
    _targetDebounce = Timer(const Duration(milliseconds: 500), () {
      _parseAndUpdateTarget(value);
    });
  }

  void _parseAndUpdateTarget(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return;
    if (parsed != widget.currentTarget) {
      widget.onTargetUpdated!(parsed);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────
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
            // ── Array Configuration Row ────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _glassInputField(
                    controller: _arrayController,
                    hint: 'Comma separated…',
                    onChanged: _onArrayTextChanged,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    keyboardType: TextInputType.text,
                  ),
                ),
                const SizedBox(width: 10),
                // Size stepper
                _sizeStepperWidget(),
              ],
            ),

            // ── Target Row (search mode only) ─────────────────────────────────
            if (widget.isSearchMode) ...[
              const SizedBox(height: 10),
              _targetRow(),
            ],

            const SizedBox(height: 16),

            // ── Playback Controls ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: widget.onRestart,
                  icon: const Icon(Icons.restart_alt, color: Colors.white70, size: 28),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: widget.canStepBack ? widget.onStepBack : null,
                  icon: Icon(Icons.skip_previous,
                      color: widget.canStepBack ? Colors.white : Colors.white24, size: 32),
                ),
                const SizedBox(width: 12),
                // Play / Pause focal point
                GestureDetector(
                  onTap: widget.onPlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.indigo,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.indigo.withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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

  // ── Sub-widgets ──────────────────────────────────────────────────────────────

  Widget _glassInputField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onSubmitted,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontSize: 14,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30),
          ),
        ),
      ),
    );
  }

  Widget _sizeStepperWidget() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white70, size: 20),
            onPressed: () => _modulateSize(-1),
          ),
          Text(
            '$_currentSize',
            style: const TextStyle(
              color: AppColors.indigoLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white70, size: 20),
            onPressed: () => _modulateSize(1),
          ),
        ],
      ),
    );
  }

  Widget _targetRow() {
    return Row(
      children: [
        // Label chip with orange glow
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.ads_click_rounded, color: AppColors.orange, size: 15),
              const SizedBox(width: 6),
              Text(
                'Target',
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Target input — constrained width so it doesn't overflow
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.orange.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.08),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: TextField(
                controller: _targetController,
                onChanged: _onTargetTextChanged,
                onSubmitted: (v) {
                  _parseAndUpdateTarget(v);
                  FocusScope.of(context).unfocus();
                },
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.numberWithOptions(signed: true),
                style: TextStyle(
                  color: AppColors.orange,
                  fontFamily: 'monospace',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g. 42',
                  hintStyle: TextStyle(color: AppColors.orange.withValues(alpha: 0.35)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
