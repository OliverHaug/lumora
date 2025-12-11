import 'package:flutter/material.dart';

class AppBottomSheetContainer extends StatelessWidget {
  final Widget child;
  const AppBottomSheetContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
