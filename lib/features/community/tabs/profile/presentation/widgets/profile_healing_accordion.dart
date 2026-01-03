import 'package:flutter/material.dart';
import 'package:xyz/core/theme/app_colors.dart';
import 'package:xyz/features/community/tabs/profile/data/healing_qa_model.dart';

class ProfileHealingAccordion extends StatefulWidget {
  final bool isMe;
  final List<HealingQAModel> items;

  const ProfileHealingAccordion({
    super.key,
    required this.isMe,
    required this.items,
  });

  @override
  State<ProfileHealingAccordion> createState() =>
      _ProfileHealingAccordionState();
}

class _ProfileHealingAccordionState extends State<ProfileHealingAccordion> {
  bool open = true;

  @override
  Widget build(BuildContext context) {
    final visible = widget.items
        .where((x) => x.answer.trim().isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 2),
            color: Colors.black.withValues(alpha: .05),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.question_mark,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'My Healing Philosophy',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),

              IconButton(
                icon: Icon(open ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => open = !open),
              ),
            ],
          ),

          if (open) ...[
            const Divider(height: 18),

            if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.isMe
                      ? 'Answer a few questions to build your philosophy.'
                      : 'No philosophy yet.',
                  style: TextStyle(color: Colors.black.withValues(alpha: .6)),
                ),
              )
            else
              ...visible.map(
                (qa) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _QA(q: qa.question.question, a: qa.answer),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _QA extends StatelessWidget {
  final String q;
  final String a;
  const _QA({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q: $q',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'A: $a',
          style: TextStyle(
            color: Colors.black.withValues(alpha: .7),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
