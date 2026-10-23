import 'package:flutter/material.dart';
import '../config/colors.dart';

class TravelSearchDock extends StatefulWidget {
  final Function(String query, String category)? onSearch;

  const TravelSearchDock({super.key, this.onSearch});

  @override
  State<TravelSearchDock> createState() => _TravelSearchDockState();
}

class _TravelSearchDockState extends State<TravelSearchDock> {
  final TextEditingController _queryController = TextEditingController();
  String _selectedStyle = 'All';

  final List<String> _styles = ['All', 'Beaches', 'Mountains', 'Heritage', 'Adventure'];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.onSearch != null) {
      widget.onSearch!(_queryController.text.trim(), _selectedStyle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.travel_explore_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _queryController,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Where to? (e.g. Goa, Kyoto, Swiss Alps...)',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.search_rounded, size: 16),
                label: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _styles.map((style) {
                final isSelected = _selectedStyle == style;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedStyle = style);
                      _submit();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        style,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
