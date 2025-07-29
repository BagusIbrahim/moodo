import 'package:flutter/material.dart';

void showAddTaskDialog(BuildContext context, {required Function(String) onSave, String? initialValue}) {
  final TextEditingController controller = TextEditingController(text: initialValue);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(initialValue == null ? 'Tugas Baru' : 'Edit Tugas'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Masukkan judul tugas...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}