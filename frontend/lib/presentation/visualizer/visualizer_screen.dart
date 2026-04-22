import 'dart:ui';
import 'package:flutter/material.dart' hide StepState;
import '../../domain/engines/bubble_sort_engine.dart';
import '../../domain/models/step_state.dart';

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

  // ─── Colours (Mapped from home_screen.dart) ───
  static const _bg = Color(0xFF08080F);
  static const _card = Color(0xFF111118);
  static const _indigo = Color(0xFF4A6BFF);
  static const _indigoLight = Color(0xFF8E9BFF);
  static const _orange = Color(0xFFFF9500);

  final List<String> _pseudoCode = [
    "1. for i = 0 to n-1",
    "2.   for j = 0 to n-i-1",
    "3.     if arr[j] > arr[j+1]",
    "4.       swap(arr[j], arr[j+1])",
    "5. Array is sorted",
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with a random array for Iteration 2
    final engine = BubbleSortEngine();
    _steps = engine.generateSteps([45, 20, 85, 12, 60, 35, 90, 25]);
  }

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
          // Ambient Glow
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
              // ── Pseudo-Code Panel ──
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _pseudoCode.asMap().entries.map((entry) {
                    bool isActive = entry.key == currentState.activeCodeLine;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isActive ? _indigo.withValues(alpha: 0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isActive ? _indigoLight : Colors.white54,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Array Canvas ──
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: currentState.arraySnapshot.asMap().entries.map((entry) {
                        int index = entry.key;
                        int value = entry.value;
                        bool isActive = index == currentState.activeIndexA || index == currentState.activeIndexB;
                        
                        Color barColor = Colors.white24;
                        if (isActive) {
                          barColor = currentState.isSwap ? Colors.greenAccent : _orange;
                        }

                        // Calculate relative height
                        double heightRatio = value / maxVal;
                        
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
                              height: 200 * heightRatio, // Max height 200
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                boxShadow: isActive ? [
                                  BoxShadow(
                                    color: barColor.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  )
                                ] : [],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // ── Playback Controls ──
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 40, top: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _currentStepIndex > 0 ? _prevStep : null,
                          icon: Icon(Icons.skip_previous, color: _currentStepIndex > 0 ? Colors.white : Colors.white24, size: 32),
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
                          onPressed: _currentStepIndex < _steps.length - 1 ? _nextStep : null,
                          icon: Icon(Icons.skip_next, color: _currentStepIndex < _steps.length - 1 ? Colors.white : Colors.white24, size: 32),
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