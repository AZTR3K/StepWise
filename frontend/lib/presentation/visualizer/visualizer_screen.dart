import 'dart:ui';
import 'package:flutter/material.dart' hide StepState;
import '../../domain/engines/bubble_sort_engine.dart';
import '../../domain/engines/merge_sort_engine.dart';
import '../../domain/engines/quick_sort_engine.dart';
import '../../domain/engines/heap_sort_engine.dart';
import '../../domain/engines/insertion_sort_engine.dart';
import '../../domain/engines/selection_sort_engine.dart';
import '../../domain/models/step_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_panel.dart';

// ─── Pseudocode definitions per algorithm ───────────────────────────────────
const _pseudoCodeMap = {
  'Bubble Sort': [
    "1. for i = 0 to n-1",
    "2.   for j = 0 to n-i-1",
    "3.     if arr[j] > arr[j+1]",
    "4.       swap(arr[j], arr[j+1])",
    "5. Array is sorted",
  ],
  'Merge Sort': [
    "1. if length <= 1: return",
    "2.   mid = length / 2",
    "3.   mergeSort(left half)",
    "4.     compare left[i] and right[j]",
    "5.     place smaller into result",
    "6.   mergeSort(right half)",
    "7. Array is sorted",
  ],
  'Quick Sort': [
    "1. if low < high",
    "2.   pivot = arr[high]",
    "3.   i = low - 1",
    "4.   if arr[j] <= pivot",
    "5.     swap arr[i] and arr[j]",
    "6.   place pivot at i+1",
    "7. Array is sorted",
  ],
  'Heap Sort': [
    "1. build max-heap from array",
    "2.   heapify: compare children",
    "3.   swap if child > parent",
    "4. swap root with last element",
    "5. extract max, reduce heap",
    "6. repeat until heap empty",
    "7. Array is sorted",
  ],
  'Insertion Sort': [
    "1. for i = 1 to n-1",
    "2.   key = arr[i]",
    "3.   compare key with sorted portion",
    "4.   shift elements right",
    "5.   insert key at correct position",
    "6. Array is sorted",
  ],
  'Selection Sort': [
    "1. for i = 0 to n-2",
    "2.   assume arr[i] is minimum",
    "3.   find minimum in unsorted portion",
    "4.   swap with first unsorted element",
    "5.   place minimum at position i",
    "6. Array is sorted",
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

class VisualizerScreen extends StatefulWidget {
  final String algorithmName;

  const VisualizerScreen({super.key, required this.algorithmName});

  @override
  State<VisualizerScreen> createState() => _VisualizerScreenState();
}

class _VisualizerScreenState extends State<VisualizerScreen> {
  late List<StepState> _steps;
  int _currentStepIndex = 0;
  bool _isPlaying = false;

  static const _initialArray = [45, 20, 85, 12, 60, 35, 90, 25];

  static const _bg = AppColors.background;
  static const _indigo = AppColors.indigo;
  static const _indigoLight = AppColors.indigoLight;
  static const _orange = AppColors.orange;

  @override
  void initState() {
    super.initState();
    _steps = _generateSteps(widget.algorithmName, _initialArray);
  }

  List<String> get _pseudoCode =>
      _pseudoCodeMap[widget.algorithmName] ?? _pseudoCodeMap['Bubble Sort']!;

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() => _currentStepIndex++);
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
    }
  }

  void _togglePlay() async {
    setState(() => _isPlaying = !_isPlaying);
    while (_isPlaying && _currentStepIndex < _steps.length - 1) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted || !_isPlaying) break;
      _nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentState = _steps[_currentStepIndex];
    final maxVal = currentState.arraySnapshot.reduce((a, b) => a > b ? a : b);

    return Scaffold(
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
      body: Stack(
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: GlassPanel(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _pseudoCode.asMap().entries.map((entry) {
                    final isActive = entry.key == currentState.activeCodeLine;
                    return Container(
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
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isActive ? _indigoLight : Colors.white54,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

              // ── Array Canvas ───────────────────────────────────────────────
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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

                        final heightRatio = value / maxVal;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              value.toString(),
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: 24,
                              height: 200 * heightRatio,
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
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // ── Playback Controls ──────────────────────────────────────────
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 40, top: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border(
                          top: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed:
                              _currentStepIndex > 0 ? _prevStep : null,
                          icon: Icon(Icons.skip_previous,
                              color: _currentStepIndex > 0
                                  ? Colors.white
                                  : Colors.white24,
                              size: 32),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _togglePlay,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [_indigoLight, _indigo],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _indigo.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: _currentStepIndex < _steps.length - 1
                              ? _nextStep
                              : null,
                          icon: Icon(Icons.skip_next,
                              color: _currentStepIndex < _steps.length - 1
                                  ? Colors.white
                                  : Colors.white24,
                              size: 32),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}