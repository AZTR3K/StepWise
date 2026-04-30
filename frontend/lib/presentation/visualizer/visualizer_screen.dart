import 'dart:async';
import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/engines/bubble_sort_engine.dart';
import '../../domain/engines/merge_sort_engine.dart';
import '../../domain/engines/quick_sort_engine.dart';
import '../../domain/engines/heap_sort_engine.dart';
import '../../domain/engines/insertion_sort_engine.dart';
import '../../domain/engines/selection_sort_engine.dart';
import '../../domain/models/step_state.dart';
import '../theme/app_colors.dart';
import '../state/visualizer_state.dart';
import '../widgets/glass_panel.dart';
import '../widgets/base_visualizer_control.dart';

// ─── Pseudocode definitions per algorithm ───────────────────────────────────
const _pseudoCodeMap = {
  'Bubble Sort': [
    "function bubbleSort(arr) {",
    "  for (i = 0; i < n-1; i++)",
    "    swapped = false",
    "    for (j = 0; j < n-i-1; j++)",
    "      if arr[j] > arr[j+1]",
    "        swap(arr[j], arr[j+1])",
    "        swapped = true",
    "    if (!swapped) break",
    "}",
  ],
  'Merge Sort': [
    "function mergeSort(arr, l, r) {",
    "  if l >= r return",
    "  mid = (l + r) / 2",
    "  mergeSort(arr, l, mid)",
    "  mergeSort(arr, mid + 1, r)",
    "  merge(arr, l, mid, r)",
    "}",
    "function merge(arr, l, m, r) {",
    "  compare left[i] and right[j]",
    "  place smaller into arr[k]",
    "}",
  ],
  'Quick Sort': [
    "function quickSort(arr, low, high) {",
    "  if low < high",
    "    pivot = arr[high]",
    "    i = low - 1",
    "    if arr[j] <= pivot",
    "      swap arr[i] and arr[j]",
    "    place pivot at i+1",
    "}",
  ],
  'Heap Sort': [
    "function heapSort(arr) {",
    "  build max-heap from array",
    "    heapify: compare children",
    "    swap if child > parent",
    "  swap root with last element",
    "  extract max, reduce heap",
    "  repeat until heap empty",
    "}",
  ],
  'Insertion Sort': [
    "function insertionSort(arr) {",
    "  for i = 1 to arr.length - 1",
    "    key = arr[i]",
    "    compare key with sorted portion",
    "    shift elements right",
    "    insert key at correct position",
    "}",
  ],
  'Selection Sort': [
    "function selectionSort(arr) {",
    "  for i = 0 to arr.length - 2",
    "    assume arr[i] is minimum",
    "    find minimum in unsorted portion",
    "    swap with first unsorted element",
    "    place minimum at position i",
    "}",
  ],
};

List<StepState> _generateSteps(String algorithmName, List<int> array) {
  switch (algorithmName) {
    case 'Merge Sort':
      return MergeSortEngine().generateSteps(array);
    case 'Quick Sort':
      return QuickSortEngine().generateSteps(array);
    case 'Heap Sort':
      return HeapSortEngine().generateSteps(array);
    case 'Insertion Sort':
      return InsertionSortEngine().generateSteps(array);
    case 'Selection Sort':
      return SelectionSortEngine().generateSteps(array);
    case 'Bubble Sort':
    default:
      return BubbleSortEngine().generateSteps(array);
  }
}

class VisualizerScreen extends ConsumerStatefulWidget {
  final String algorithmName;

  const VisualizerScreen({super.key, required this.algorithmName});

  @override
  ConsumerState<VisualizerScreen> createState() => _VisualizerScreenState();
}

class _VisualizerScreenState extends ConsumerState<VisualizerScreen> {
  late List<StepState> _steps;
  int _currentStepIndex = 0;
  bool _isPlaying = false;

  static const _initialArray = [45, 20, 85, 12, 60, 35, 90, 25];
  late List<int> _currentArray;

  static const _bg = AppColors.background;
  static const _indigo = AppColors.indigo;
  static const _indigoLight = AppColors.indigoLight;
  static const _orange = AppColors.orange;

  // ─── Pseudocode auto-scroll ────────────────────────────────────────────────
  final ScrollController _pseudoScrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};
  bool _userIsScrolling = false;
  Timer? _userScrollDebounce;

  @override
  void initState() {
    super.initState();
    _currentArray = List.from(_initialArray);
    _steps = _generateSteps(widget.algorithmName, _currentArray);
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
      _steps = _generateSteps(widget.algorithmName, _currentArray);
      _currentStepIndex = 0;
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

  List<String> get _pseudoCode =>
      _pseudoCodeMap[widget.algorithmName] ?? _pseudoCodeMap['Bubble Sort']!;

  // ─── Auto-scroll to active pseudocode line ─────────────────────────────────
  void _scrollToActiveLine(int activeLine) {
    if (_userIsScrolling) return;
    final key = _lineKeys[activeLine];
    if (key == null || key.currentContext == null) return;

    // Scale animation duration based on playback speed
    final speed = ref.read(playbackSpeedProvider);
    final durationMs = (300 / speed).round().clamp(50, 600);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _userIsScrolling) return;
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.easeInOutCubic,
        alignment: 0.5, // center the line in the viewport
      );
    });
  }

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() => _currentStepIndex++);
      _scrollToActiveLine(_steps[_currentStepIndex].activeCodeLine);
    } else {
      setState(() => _isPlaying = false);
    }
  }

  void _prevStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _isPlaying = false;
      });
      _scrollToActiveLine(_steps[_currentStepIndex].activeCodeLine);
    }
  }

  void _togglePlay() async {
    setState(() => _isPlaying = !_isPlaying);
    while (_isPlaying && _currentStepIndex < _steps.length - 1) {
      final speed = ref.read(playbackSpeedProvider);
      final delayMs = (600 / speed).round();
      
      await Future.delayed(Duration(milliseconds: delayMs));
      if (!mounted || !_isPlaying) break;
      _nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentState = _steps[_currentStepIndex];
    final maxVal = currentState.arraySnapshot.reduce((a, b) => a > b ? a : b);

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
      ),
      body: SafeArea(
        child: Stack(
          children: [
          // Ambient glow
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
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
              // ── Pseudo-Code Panel ──────────────────────────────────────────
              Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(16),
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
                            final isActive = lineIndex == currentState.activeCodeLine;
                            // Lazily create a GlobalKey per line index
                            final key = _lineKeys.putIfAbsent(lineIndex, () => GlobalKey());
                            return KeyedSubtree(
                              key: key,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOutCubic,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? _indigo.withValues(alpha: 0.2)
                                      : Colors.transparent,
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
                                    fontWeight:
                                        isActive ? FontWeight.bold : FontWeight.normal,
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

              // ── Array Canvas ───────────────────────────────────────────────
              Flexible(
                flex: 4,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRect(
                      clipBehavior: Clip.hardEdge,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final len = currentState.arraySnapshot.length;
                          final availableWidth = constraints.maxWidth;
                          double barWidth = (availableWidth / len) * 0.8;
                          if (barWidth > 40) barWidth = 40;
                          if (barWidth < 2) barWidth = 2;
                          final showText = barWidth > 16;
                          final textSpace = showText ? 24.0 : 0.0;
                          double maxBarHeight = (constraints.maxHeight - textSpace - 12.0).clamp(0.0, constraints.maxHeight);

                          return SizedBox(
                            height: constraints.maxHeight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: currentState.arraySnapshot.asMap().entries.map((entry) {
                                final index = entry.key;
                                final value = entry.value;
                                final isActive = index == currentState.activeIndexA ||
                                    index == currentState.activeIndexB;

                                Color barColor = Colors.white24;
                                if (isActive) {
                                  barColor = currentState.isSwap
                                      ? Colors.greenAccent
                                      : _orange;
                                }

                                final heightRatio = value / (maxVal > 0 ? maxVal : 1);

                                return SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (showText)
                                        Text(
                                          value.toString(),
                                          style: TextStyle(
                                            color: isActive ? Colors.white : Colors.white54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      if (showText) const SizedBox(height: 8),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        width: barWidth,
                                        height: maxBarHeight * heightRatio,
                                        decoration: BoxDecoration(
                                          color: barColor,
                                          borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(6)),
                                          boxShadow: isActive
                                              ? [
                                                  BoxShadow(
                                                    color: barColor.withValues(alpha: 0.5),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, -2),
                                                  )
                                                ]
                                              : [],
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

              // ── Result Banner ──────────────────────────────────────────────
              if (_currentStepIndex == _steps.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  child: GlassPanel(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    borderRadius: 14,
                    glowColor: Colors.greenAccent,
                    alpha: 0.15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Array Sorted',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


              // ── Playback Controls ──────────────────────────────────────────
              BaseVisualizerControl(
                isPlaying: _isPlaying,
                canStepBack: _currentStepIndex > 0,
                canStepForward: _currentStepIndex < _steps.length - 1,
                onPlayPause: _togglePlay,
                onStepBack: _prevStep,
                onStepForward: _nextStep,
                onRestart: _restart,
                currentArray: _currentArray,
                onArrayUpdated: _handleArrayUpdate,
              ),
            ],
          ),  // Column
        ],   // Stack children
        ),   // Stack
      ),     // SafeArea
    );       // Scaffold
  }
}