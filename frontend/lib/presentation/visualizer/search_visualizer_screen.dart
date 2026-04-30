import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/engines/linear_search_engine.dart';
import '../../domain/engines/binary_search_engine.dart';
import '../../domain/engines/jump_search_engine.dart';
import '../../domain/engines/exponential_search_engine.dart';
import '../../domain/models/search_step_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_panel.dart';
import '../widgets/base_visualizer_control.dart';

// ─── Pseudocode map ───────────────────────────────────────────────────────────
const _pseudoCodeMap = {
  'Linear Search': [
    "1. for i = 0 to n-1",
    "2.   if arr[i] == target",
    "3.     return i  ← found!",
    "4. end for",
    "5. return -1  ← not found",
  ],
  'Binary Search': [
    "1. sort array (pre-condition)",
    "2. mid = (left + right) / 2",
    "3. if arr[mid] == target",
    "4.   return mid  ← found!",
    "5. else if arr[mid] < target",
    "6.   left = mid + 1",
    "7. else right = mid - 1",
    "8. return -1  ← not found",
  ],
  'Jump Search': [
    "1. step = √n",
    "2. jump ahead by step blocks",
    "3. linear search in block",
    "4. if arr[i] == target",
    "5.   return i  ← found!",
    "6. return -1  ← not found",
  ],
  'Exponential Search': [
    "1. double bound until arr[bound] > target",
    "2. range = [bound/2, min(bound, n-1)]",
    "3. binary search in range",
    "4. if arr[mid] == target",
    "5.   return mid  ← found!",
    "6. left = mid + 1 or right = mid - 1",
    "7. return -1  ← not found",
  ],
};

// ─── Array used for all searches ─────────────────────────────────────────────
// Deliberately chosen so binary/jump/exponential (sorted) still contains
// values the user might guess from the unsorted version shown for linear.
const _baseArray = [34, 7, 23, 32, 5, 62, 12, 47];

List<SearchStepState> _generateSteps(String name, List<int> array, int target) {
  switch (name) {
    case 'Binary Search':
      return BinarySearchEngine().generateSteps(array, target);
    case 'Jump Search':
      return JumpSearchEngine().generateSteps(array, target);
    case 'Exponential Search':
      return ExponentialSearchEngine().generateSteps(array, target);
    case 'Linear Search':
    default:
      return LinearSearchEngine().generateSteps(array, target);
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class SearchVisualizerScreen extends StatefulWidget {
  final String algorithmName;

  const SearchVisualizerScreen({super.key, required this.algorithmName});

  @override
  State<SearchVisualizerScreen> createState() => _SearchVisualizerScreenState();
}

class _SearchVisualizerScreenState extends State<SearchVisualizerScreen> {
  // ─── Colours ────────────────────────────────────────────────────────────────
  static const _bg         = AppColors.background;
  static const _indigo      = AppColors.indigo;
  static const _indigoLight = AppColors.indigoLight;
  static const _orange      = AppColors.orange;
  static const _green       = Colors.greenAccent;
  static const _red         = Colors.redAccent;

  List<SearchStepState>? _steps;
  int _currentStepIndex = 0;
  bool _isPlaying = false;
  int? _targetValue;
  late List<int> _currentArray;

  // ─── Pseudocode auto-scroll ────────────────────────────────────────────────
  final ScrollController _pseudoScrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};
  bool _userIsScrolling = false;
  Timer? _userScrollDebounce;

  List<String> get _pseudoCode =>
      _pseudoCodeMap[widget.algorithmName] ?? _pseudoCodeMap['Linear Search']!;

  // ─── Show target input dialog on first frame ─────────────────────────────
  @override
  void initState() {
    super.initState();
    _currentArray = List.from(_baseArray);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTargetDialog());
  }

  @override
  void dispose() {
    _pseudoScrollController.dispose();
    _userScrollDebounce?.cancel();
    super.dispose();
  }

  void _handleArrayUpdate(List<int> newArray) {
    if (_isPlaying) {
      setState(() => _isPlaying = false);
    }
    setState(() {
      _currentArray = newArray;
      if (_targetValue != null) {
        _steps = _generateSteps(widget.algorithmName, _currentArray, _targetValue!);
        _currentStepIndex = 0;
      }
    });
  }

  void _restart() {
    if (_isPlaying) {
      setState(() => _isPlaying = false);
    }
    setState(() {
      _currentStepIndex = 0;
    });
  }

  Future<void> _showTargetDialog({bool isReset = false}) async {
    if (isReset) setState(() { _steps = null; _currentStepIndex = 0; _isPlaying = false; });
    final controller = TextEditingController();

    // Sort-aware hint: show what values are in the working array
    final displayArray = List<int>.from(_currentArray);
    if (widget.algorithmName != 'Linear Search') displayArray.sort();

    await showDialog(
      context: context,
      barrierDismissible: !isReset && _steps != null ? true : false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Enter Target Value',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Array: ${displayArray.join(', ')}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Pick a value from the array above (or any other number).',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. ${displayArray[displayArray.length ~/ 2]}',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.07),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _indigo, width: 1.5),
                ),
              ),
              onSubmitted: (_) => _submitTarget(ctx, controller.text),
            ),
          ],
        ),
        actions: [
          if (_steps != null)
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
            ),
          TextButton(
            onPressed: () => _submitTarget(ctx, controller.text),
            child: Text('Start', style: TextStyle(color: _indigoLight, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _submitTarget(BuildContext ctx, String text) {
    final value = int.tryParse(text.trim());
    if (value == null) return;
    Navigator.pop(ctx);
    setState(() {
      _targetValue = value;
      _steps = _generateSteps(widget.algorithmName, _currentArray, value);
      _currentStepIndex = 0;
      _isPlaying = false;
    });
  }

  // ─── Auto-scroll to active pseudocode line ──────────────────────────────────
  void _scrollToActiveLine(int activeLine) {
    if (_userIsScrolling) return;
    final key = _lineKeys[activeLine];
    if (key == null || key.currentContext == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _userIsScrolling) return;
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        alignment: 0.5,
      );
    });
  }

  // ─── Playback ────────────────────────────────────────────────────────────
  void _nextStep() {
    if (_currentStepIndex < _steps!.length - 1) {
      setState(() => _currentStepIndex++);
      _scrollToActiveLine(_steps![_currentStepIndex].activeCodeLine);
    } else {
      setState(() => _isPlaying = false);
    }
  }

  void _prevStep() {
    if (_currentStepIndex > 0) {
      setState(() { _currentStepIndex--; _isPlaying = false; });
      _scrollToActiveLine(_steps![_currentStepIndex].activeCodeLine);
    }
  }

  void _togglePlay() async {
    setState(() => _isPlaying = !_isPlaying);
    while (_isPlaying && _currentStepIndex < _steps!.length - 1) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted || !_isPlaying) break;
      _nextStep();
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.algorithmName,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        actions: [
          // Reset / change target
          IconButton(
            onPressed: () => _showTargetDialog(isReset: true),
            icon: Icon(Icons.refresh_rounded, color: Colors.white.withValues(alpha: 0.6)),
            tooltip: 'Change target',
          ),
        ],
      ),
      body: _steps == null
          ? const SizedBox.shrink() // dialog is showing
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final step = _steps![_currentStepIndex];
    final maxVal = step.array.reduce((a, b) => a > b ? a : b).toDouble();
    final isFinished = step.stepType == SearchStepType.found ||
        step.stepType == SearchStepType.notFound;

    return SafeArea(
      child: Stack(
        children: [
        // Ambient glow
        Positioned(
          top: -50, right: -50,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _indigo.withValues(alpha: 0.15),
                Colors.transparent,
              ]),
            ),
          ),
        ),

        Column(
          children: [
            // ── Target Badge ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _StatusBadge(step: step, orange: _orange, green: _green, red: _red, indigo: _indigo),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _orange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ads_click_rounded, color: _orange, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Target: $_targetValue',
                          style: TextStyle(color: _orange, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Pseudocode Panel ──────────────────────────────────────────────
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassPanel(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 16,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is UserScrollNotification) {
                        _userIsScrolling = true;
                        _userScrollDebounce?.cancel();
                        _userScrollDebounce = Timer(const Duration(seconds: 2), () {
                          if (mounted) _userIsScrolling = false;
                        });
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: _pseudoScrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _pseudoCode.asMap().entries.map((entry) {
                          final lineIndex = entry.key;
                          final isActive = lineIndex == step.activeCodeLine;
                          final key = _lineKeys.putIfAbsent(lineIndex, () => GlobalKey());
                          return KeyedSubtree(
                            key: key,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOutCubic,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isActive ? _indigo.withValues(alpha: 0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                entry.value,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: isActive ? _indigoLight : Colors.white54,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Array Canvas ──────────────────────────────────────────────────
            Flexible(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRect(
                  clipBehavior: Clip.hardEdge,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final len = step.array.length;
                      final availableWidth = constraints.maxWidth;
                      double barWidth = (availableWidth / len) * 0.8;
                      if (barWidth > 40) barWidth = 40;
                      if (barWidth < 2) barWidth = 2;
                      final showText = barWidth > 16;
                      final showIndex = barWidth > 20;

                      double textSpace = 0.0;
                      if (showText) textSpace += 22.0;
                      if (showIndex) textSpace += 16.0;
                      double maxBarHeight = (constraints.maxHeight - textSpace - 12.0).clamp(0.0, constraints.maxHeight);

                      return SizedBox(
                        height: constraints.maxHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: step.array.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final val = entry.value;
                            final heightRatio = val / (maxVal > 0 ? maxVal : 1);

                            final isFound = idx == step.foundIndex;
                            final isCurrent = idx == step.currentIndex && !isFound;
                            final isJump = idx == step.jumpIndex && !isCurrent && !isFound;
                            final inRange = step.rangeStart != null &&
                                step.rangeEnd != null &&
                                idx >= step.rangeStart! &&
                                idx <= step.rangeEnd! &&
                                !isCurrent &&
                                !isFound &&
                                !isJump;

                            Color barColor;
                            if (isFound) {
                              barColor = _green;
                            } else if (isCurrent) {
                              barColor = _orange;
                            } else if (isJump) {
                              barColor = _indigo;
                            } else if (inRange) {
                              barColor = _indigoLight.withValues(alpha: 0.5);
                            } else {
                              barColor = Colors.white.withValues(alpha: 0.15);
                            }

                            return SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (showText)
                                    Text(
                                      val.toString(),
                                      style: TextStyle(
                                        color: (isFound || isCurrent || isJump)
                                            ? Colors.white
                                            : Colors.white38,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  if (showText) const SizedBox(height: 6),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    width: barWidth,
                                    height: maxBarHeight * heightRatio,
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                      boxShadow: (isFound || isCurrent || isJump)
                                          ? [BoxShadow(color: barColor.withValues(alpha: 0.5), blurRadius: 12, offset: const Offset(0, -2))]
                                          : [],
                                    ),
                                  ),
                                  if (showIndex) const SizedBox(height: 4),
                                  if (showIndex)
                                    Text(
                                      '[$idx]',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        fontSize: 9,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Result Banner ─────────────────────────────────────────────────
            if (isFinished)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GlassPanel(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  borderRadius: 14,
                  glowColor: step.stepType == SearchStepType.found ? _green : _red,
                  alpha: 0.15,
                  child: Row(
                    children: [
                      Icon(
                        step.stepType == SearchStepType.found
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: step.stepType == SearchStepType.found ? _green : _red,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        step.stepType == SearchStepType.found
                            ? 'Element Found at Index ${step.foundIndex}'
                            : 'Element Not Present',
                        style: TextStyle(
                          color: step.stepType == SearchStepType.found ? _green : _red,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Playback Controls ─────────────────────────────────────────────
            if (_steps != null)
              BaseVisualizerControl(
                isPlaying: _isPlaying,
                canStepBack: _currentStepIndex > 0,
                canStepForward: _currentStepIndex < _steps!.length - 1,
                onPlayPause: _togglePlay,
                onStepBack: _prevStep,
                onStepForward: _nextStep,
                onRestart: _restart,
                currentArray: _currentArray,
                onArrayUpdated: _handleArrayUpdate,
              ),
          ],
        ),
      ],
      ),
    );
  }
}

// ─── Status badge widget ──────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final SearchStepState step;
  final Color orange, green, red, indigo;

  const _StatusBadge({
    required this.step,
    required this.orange,
    required this.green,
    required this.red,
    required this.indigo,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (step.stepType) {
      case SearchStepType.found:
        color = green; icon = Icons.check_circle_rounded; label = 'Found';
        break;
      case SearchStepType.notFound:
        color = red; icon = Icons.cancel_rounded; label = 'Not Found';
        break;
      case SearchStepType.jump:
        color = indigo; icon = Icons.flash_on_rounded; label = 'Jumping';
        break;
      case SearchStepType.rangeCheck:
        color = indigo; icon = Icons.linear_scale_rounded; label = 'Narrowing';
        break;
      case SearchStepType.comparing:
        color = orange; icon = Icons.compare_arrows_rounded; label = 'Comparing';
        break;
      default:
        color = Colors.white54; icon = Icons.hourglass_empty_rounded; label = 'Ready';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}