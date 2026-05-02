// dp_input_sheet.dart
import 'package:flutter/material.dart';

class DPInputSheet extends StatefulWidget {
  final String algorithmName;
  const DPInputSheet({super.key, required this.algorithmName});

  @override
  State<DPInputSheet> createState() => _DPInputSheetState();
}

class _DPInputSheetState extends State<DPInputSheet> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all possible fields
  final _nController = TextEditingController();
  final _capacityController = TextEditingController();
  final _amountController = TextEditingController();
  final _rodLengthController = TextEditingController();

  final _weightsController = TextEditingController();
  final _valuesController = TextEditingController();
  final _coinsController = TextEditingController();
  final _pricesController = TextEditingController();
  final _dimsController = TextEditingController();
  final _arrayController = TextEditingController();
  final _s1Controller = TextEditingController();
  final _s2Controller = TextEditingController();

  @override
  void dispose() {
    _nController.dispose();
    _capacityController.dispose();
    _amountController.dispose();
    _rodLengthController.dispose();
    _weightsController.dispose();
    _valuesController.dispose();
    _coinsController.dispose();
    _pricesController.dispose();
    _dimsController.dispose();
    _arrayController.dispose();
    _s1Controller.dispose();
    _s2Controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _buildParams());
  }

  Map<String, dynamic> _buildParams() {
    final name = widget.algorithmName;
    switch (name) {
      case 'Fibonacci Sequence':
        return {'n': int.parse(_nController.text)};
      case '0/1 Knapsack':
        return {
          'weights': _parseIntList(_weightsController.text),
          'values': _parseIntList(_valuesController.text),
          'capacity': int.parse(_capacityController.text),
        };
      case 'Longest Common Subsequence':
        return {'s1': _s1Controller.text, 's2': _s2Controller.text};
      case 'Longest Increasing Subsequence':
        return {'array': _parseIntList(_arrayController.text)};
      case 'Coin Change':
        return {
          'coins': _parseIntList(_coinsController.text),
          'amount': int.parse(_amountController.text),
        };
      case 'Edit Distance':
        return {'s1': _s1Controller.text, 's2': _s2Controller.text};
      case 'Rod Cutting':
        return {
          'prices': _parseIntList(_pricesController.text),
          'rodLength': int.parse(_rodLengthController.text),
        };
      case 'Matrix Chain Multiplication':
        return {'dims': _parseIntList(_dimsController.text)};
      case 'Max Subarray Sum':
      case 'Max Subarray Product':
        return {'array': _parseIntList(_arrayController.text)};
      default:
        return {};
    }
  }

  List<int> _parseIntList(String text) {
    return text
        .split(RegExp(r'[, ]+'))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => int.parse(s.trim()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.algorithmName;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Custom Input – $name',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Show different fields based on algorithm
              ..._buildFields(name),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFields(String name) {
    switch (name) {
      case 'Fibonacci Sequence':
        return [
          _buildTextField('n (e.g. 9)', _nController),
        ];
      case '0/1 Knapsack':
        return [
          _buildTextField('Weights (comma separated)', _weightsController),
          _buildTextField('Values (comma separated)', _valuesController),
          _buildTextField('Capacity', _capacityController),
        ];
      case 'Longest Common Subsequence':
        return [
          _buildTextField('String 1', _s1Controller),
          _buildTextField('String 2', _s2Controller),
        ];
      case 'Longest Increasing Subsequence':
      case 'Max Subarray Sum':
      case 'Max Subarray Product':
        return [
          _buildTextField('Array (comma separated)', _arrayController),
        ];
      case 'Coin Change':
        return [
          _buildTextField('Coins (comma separated)', _coinsController),
          _buildTextField('Target Amount', _amountController),
        ];
      case 'Edit Distance':
        return [
          _buildTextField('String 1', _s1Controller),
          _buildTextField('String 2', _s2Controller),
        ];
      case 'Rod Cutting':
        return [
          _buildTextField('Prices per length (comma separated)', _pricesController),
          _buildTextField('Rod Length', _rodLengthController),
        ];
      case 'Matrix Chain Multiplication':
        return [
          _buildTextField('Dimensions (comma separated)', _dimsController,
              hint: 'e.g. 10,30,5,60'),
        ];
      default:
        return [const Text('No custom inputs for this algorithm.')];
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.02)), 
          border: const OutlineInputBorder(),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    );
  }
}