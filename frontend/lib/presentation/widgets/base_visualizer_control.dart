import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../state/visualizer_state.dart';
import 'glass_panel.dart';

import 'dart:math' as math;

class BaseVisualizerControl extends ConsumerStatefulWidget {
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
    this.currentTarget,
    this.onTargetUpdated,
  });

  bool get isSearchMode => currentTarget != null && onTargetUpdated != null;

  @override
  ConsumerState<BaseVisualizerControl> createState() => _BaseVisualizerControlState();
}

class _BaseVisualizerControlState extends ConsumerState<BaseVisualizerControl> with TickerProviderStateMixin {
  late TextEditingController _arrayController;
  late TextEditingController _targetController;
  Timer? _arrayDebounce;
  Timer? _targetDebounce;
  int _currentSize = 0;

  // Animation controller for the size transition
  late AnimationController _expansionController;
  late Animation<double> _expansionAnimation;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.currentArray.length;
    _arrayController = TextEditingController(text: widget.currentArray.join(', '));
    _targetController = TextEditingController(
      text: widget.currentTarget?.toString() ?? '',
    );

    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeInOutCubic,
    );

    // Initialize state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(controlsVisibilityProvider)) {
        _expansionController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant BaseVisualizerControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentArray.join(', ') != oldWidget.currentArray.join(', ')) {
      final newText = widget.currentArray.join(', ');
      if (_arrayController.text != newText && !FocusScope.of(context).hasFocus) {
        _arrayController.text = newText;
        _currentSize = widget.currentArray.length;
      }
    }
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
    _expansionController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(controlsVisibilityProvider);
    
    // Sync animation with provider state
    if (isVisible) {
      _expansionController.forward();
    } else {
      _expansionController.reverse();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: GlassPanel(
        padding: const EdgeInsets.all(12), // Reduced from 16 to save space
        borderRadius: 24,
        alpha: 0.1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizeTransition(
              sizeFactor: _expansionAnimation,
              axisAlignment: -1.0,
              child: Visibility(
                visible: isVisible || _expansionController.isAnimating,
                maintainState: true,
                child: Column(
                  children: [
                    // ── Array Configuration Row ──
                    Row(
                      children: [
                        Expanded(
                          child: _glassInputField(
                            controller: _arrayController,
                            hint: 'Array…',
                            onChanged: _onArrayTextChanged,
                            onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _sizeStepperWidget(),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Target Row (search mode) ──
                    if (widget.isSearchMode) ...[
                      _targetRow(),
                      const SizedBox(height: 10),
                    ],

                    // ── Speed Control Row ──
                    _speedControlRow(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Playback Controls ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minimalist Toggle (Chevron with Rotation)
                AnimatedRotation(
                  turns: isVisible ? 0.5 : 0.0, // Rotate 180° when expanded
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  child: _playbackIconButton(
                    icon: Icons.expand_less,
                    onPressed: () => ref.read(controlsVisibilityProvider.notifier).toggle(),
                    color: isVisible ? AppColors.indigoLight : Colors.white54,
                    size: 24,
                  ),
                ),
                const Spacer(),
                _playbackIconButton(
                  icon: Icons.restart_alt,
                  onPressed: widget.onRestart,
                ),
                const SizedBox(width: 8),
                _playbackIconButton(
                  icon: Icons.skip_previous,
                  onPressed: widget.canStepBack ? widget.onStepBack : null,
                  isActive: widget.canStepBack,
                ),
                const SizedBox(width: 8),
                // Play / Pause focal point
                GestureDetector(
                  onTap: widget.onPlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.indigo,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.indigo.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _playbackIconButton(
                  icon: Icons.skip_next,
                  onPressed: widget.canStepForward ? widget.onStepForward : null,
                  isActive: widget.canStepForward,
                ),
                const Spacer(),
                // Symmetrical balance (invisible)
                const SizedBox(width: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-widgets ──────────────────────────────────────────────────────────────

  Widget _playbackIconButton({
    required IconData icon,
    VoidCallback? onPressed,
    bool isActive = true,
    Color? color,
    double size = 24,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color ?? (isActive ? Colors.white70 : Colors.white24),
        size: size,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }

  Widget _glassInputField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onSubmitted,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _sizeStepperWidget() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white60, size: 16),
            onPressed: () => _modulateSize(-1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32),
          ),
          Text(
            '$_currentSize',
            style: const TextStyle(color: AppColors.indigoLight, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white60, size: 16),
            onPressed: () => _modulateSize(1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32),
          ),
        ],
      ),
    );
  }

  Widget _targetRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.ads_click_rounded, color: AppColors.orange, size: 14),
              const SizedBox(width: 4),
              Text(
                'Target',
                style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.orange.withValues(alpha: 0.2)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: TextField(
                controller: _targetController,
                onChanged: _onTargetTextChanged,
                onSubmitted: (v) {
                  _parseAndUpdateTarget(v);
                  FocusScope.of(context).unfocus();
                },
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.orange, fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g. 42',
                  hintStyle: TextStyle(color: AppColors.orange.withValues(alpha: 0.3)),
                  isDense: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _speedControlRow() {
    final speed = ref.watch(playbackSpeedProvider);
    final isNormalSpeed = (speed - 1.0).abs() < 0.01;

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.indigo.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.indigo.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.speed_rounded, color: AppColors.indigoLight, size: 14),
              const SizedBox(width: 4),
              const Text(
                'Speed',
                style: TextStyle(color: AppColors.indigoLight, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Slider
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              activeTrackColor: AppColors.indigoLight,
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.white,
              overlayColor: AppColors.indigo.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: speed,
              min: 0.25,
              max: 4.0,
              divisions: 15,
              onChanged: (val) => ref.read(playbackSpeedProvider.notifier).set(val),
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Speed label (Tap-to-Reset)
        GestureDetector(
          onTap: () {
            ref.read(playbackSpeedProvider.notifier).set(1.0);
            Feedback.forTap(context);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isNormalSpeed ? AppColors.indigo.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              boxShadow: isNormalSpeed ? [
                BoxShadow(color: AppColors.indigo.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: -2)
              ] : [],
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isNormalSpeed ? AppColors.indigoLight : Colors.white70,
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: isNormalSpeed ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text('${speed.toStringAsFixed(2)}x'),
            ),
          ),
        ),
      ],
    );
  }
}
