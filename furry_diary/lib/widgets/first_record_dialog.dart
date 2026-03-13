import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

class FirstRecordDialog extends StatelessWidget {
  const FirstRecordDialog({
    super.key,
    required this.petName,
    required this.onFirstTime,
    required this.onNotFirstTime,
  });

  final String petName;
  final VoidCallback onFirstTime;
  final VoidCallback onNotFirstTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Center(
                child: Text(
                  '🌸',
                  style: TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.estrusFirstRecordTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.estrusFirstRecordQuestion(petName),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context: context,
              title: l10n.estrusFirstTimeOption,
              subtitle: l10n.estrusFirstTimeHint,
              icon: Icons.pets,
              isSelected: false,
              onTap: () {
                Navigator.of(context).pop();
                onFirstTime();
              },
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context: context,
              title: l10n.estrusNotFirstTimeOption,
              subtitle: l10n.estrusNotFirstTimeHint,
              icon: Icons.history,
              isSelected: false,
              onTap: () {
                Navigator.of(context).pop();
                onNotFirstTime();
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFFF48FB1) : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFFFCE4EC) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFEC407A),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_off,
              color: isSelected ? const Color(0xFFF48FB1) : colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class KnowledgeDialog extends StatelessWidget {
  const KnowledgeDialog({
    super.key,
    required this.onStartRecording,
  });

  final VoidCallback onStartRecording;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Center(
                child: Text(
                  '📚',
                  style: TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.estrusKnowledgeTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.search, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.estrusHowToIdentify,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint(l10n.estrusSwellingRedness),
                  _buildBulletPoint(l10n.estrusBloodyDischarge),
                  _buildBulletPoint(l10n.estrusBehaviorChangesHint),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 20, color: Color(0xFFEC407A)),
                      const SizedBox(width: 8),
                      Text(
                        l10n.estrusTipsTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFEC407A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint(l10n.estrusRecordDates, const Color(0xFFEC407A)),
                  _buildBulletPoint(l10n.estrusObserveDischarge, const Color(0xFFEC407A)),
                  _buildBulletPoint(l10n.estrusKeepClean, const Color(0xFFEC407A)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.estrusSkip),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onStartRecording();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF48FB1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.estrusStartRecording),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color ?? Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
