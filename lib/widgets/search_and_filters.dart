import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/constants.dart';

class BreedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const BreedSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
  });

  @override
  State<BreedSearchBar> createState() => _BreedSearchBarState();
}

class _BreedSearchBarState extends State<BreedSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'Search dog breeds...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClear,
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).cardTheme.color,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class BreedFilterBar extends StatelessWidget {
  final BreedFilter activeFilter;
  final ValueChanged<BreedFilter> onFilterSelected;

  const BreedFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: BreedFilter.values.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = BreedFilter.values[index];
          final selected = filter == activeFilter;

          return FilterChip(
            label: Text('${filter.emoji} ${filter.label}'),
            selected: selected,
            onSelected: (_) => onFilterSelected(filter),
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: selected ? AppColors.primary : null,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          );
        },
      ),
    );
  }
}

class StatsDashboard extends StatelessWidget {
  final int totalBreeds;
  final String averageLifeSpan;
  final String mostPopularGroup;

  const StatsDashboard({
    super.key,
    required this.totalBreeds,
    required this.averageLifeSpan,
    required this.mostPopularGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dog Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatTile(title: 'Total Breeds', value: '$totalBreeds+'),
              _StatTile(title: 'Avg Life Span', value: averageLifeSpan),
              _StatTile(title: 'Top Group', value: mostPopularGroup),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;

  const _StatTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You are offline. Showing saved breeds.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class AdoptionInfoCard extends StatelessWidget {
  const AdoptionInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Responsible Dog Ownership',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          _OwnershipTip(text: 'Understand exercise needs'),
          _OwnershipTip(text: 'Prepare quality food and fresh water'),
          _OwnershipTip(text: 'Provide regular healthcare'),
          _OwnershipTip(text: 'Give enough space and attention'),
        ],
      ),
    );
  }
}

class _OwnershipTip extends StatelessWidget {
  final String text;

  const _OwnershipTip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
