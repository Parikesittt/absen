import 'package:flutter/material.dart';

class GenderSelector extends StatefulWidget {
  final String? selected;
  final ValueChanged<String> onChanged;

  const GenderSelector({super.key, this.selected, required this.onChanged});

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  final Map<String, String> genderMap = {'L': 'Laki-laki', 'P': 'Perempuan'};
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _genderButton("L", "Laki-laki", "👨")),
        const SizedBox(width: 12),
        Expanded(child: _genderButton("P", "Perempuan", "👩")),
      ],
    );
  }

  Widget _genderButton(String value, String gender, String emoji) {
    final bool active = widget.selected == value;

    return GestureDetector(
      onTap: () => widget.onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: active ? Colors.blue : Colors.grey.shade200,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji),
            const SizedBox(width: 6),
            Text(
              gender,
              style: TextStyle(color: active ? Colors.white : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
