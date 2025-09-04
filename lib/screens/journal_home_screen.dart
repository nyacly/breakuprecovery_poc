import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:breakup_recovery/services/auth_service.dart';
import 'package:breakup_recovery/repositories/breakup_recovery_repository.dart';
import 'package:breakup_recovery/models/journal_entry_model.dart';
import 'package:breakup_recovery/screens/journal_editor_screen.dart';
import 'package:breakup_recovery/widgets/br_components.dart';
import 'package:breakup_recovery/theme.dart';

class JournalHomeScreen extends StatefulWidget {
  const JournalHomeScreen({super.key});

  @override
  State<JournalHomeScreen> createState() => _JournalHomeScreenState();
}

class _JournalHomeScreenState extends State<JournalHomeScreen> {
  final AuthService _authService = AuthService();
  final BreakupRecoveryRepository _repository = BreakupRecoveryRepository();
  final TextEditingController _searchController = TextEditingController();
  
  Mood? _selectedMoodFilter;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BRColors.background,
      body: Column(
        children: [
          BRAppBar(
            title: 'Journal',
            showBack: false,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final user = _authService.currentUser;
    if (user == null) {
      return const Center(child: Text('Not authenticated'));
    }

    return StreamBuilder<List<JournalEntryModel>>(
      stream: _repository.getJournalEntries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final entries = _filteredEntries(snapshot.data!);
        
        return Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => setState(() {}),
                color: BRColors.primary,
                backgroundColor: Colors.white,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BRSpacing.md,
                    vertical: BRSpacing.sm,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, index) => _buildJournalEntryCard(entries[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(BRSpacing.md),
      child: Column(
        children: [
          // Search field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(0, 6),
                  blurRadius: 20,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search entries...',
                hintStyle: TextStyle(color: BRColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: BRColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: BRSpacing.md,
                  vertical: BRSpacing.sm,
                ),
              ),
            ),
          ),
          const SizedBox(height: BRSpacing.sm),
          
          // Mood filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildMoodChip('All', null),
                const SizedBox(width: BRSpacing.xs),
                ...Mood.values.map((mood) => Padding(
                  padding: const EdgeInsets.only(right: BRSpacing.xs),
                  child: _buildMoodChip('${mood.emoji} ${mood.name.toUpperCase()}', mood),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChip(String label, Mood? mood) {
    final isSelected = _selectedMoodFilter == mood;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedMoodFilter = selected ? mood : null);
      },
      backgroundColor: Colors.white,
      selectedColor: BRColors.primary.withValues(alpha: 0.1),
      checkmarkColor: BRColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? BRColors.primary : BRColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? BRColors.primary : Colors.grey.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildJournalEntryCard(JournalEntryModel entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: BRSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 6),
            blurRadius: 20,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToEditor(entry),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(BRSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    entry.mood.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: BRSpacing.sm),
                  Expanded(
                    child: Text(
                      entry.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: BRColors.text,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteEntry(entry);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: BRColors.error, size: 18),
                            const SizedBox(width: BRSpacing.xs),
                            Text('Delete', style: TextStyle(color: BRColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: BRSpacing.sm),
              Text(
                DateFormat('MMMM dd, yyyy').format(entry.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BRColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: BRSpacing.sm),
              Text(
                entry.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: BRColors.text,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BRSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(BRSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 6),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(BRSpacing.lg),
                decoration: BoxDecoration(
                  color: BRColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.book_outlined,
                  size: 48,
                  color: BRColors.primary,
                ),
              ),
              const SizedBox(height: BRSpacing.lg),
              Text(
                'Start Your Journal',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: BRColors.text,
                ),
              ),
              const SizedBox(height: BRSpacing.sm),
              Text(
                'Journaling helps process emotions and track your healing journey. Write your first entry to get started.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: BRColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: BRSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _navigateToEditor(null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BRColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Write First Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: BRSpacing.md),
            itemCount: 5,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.only(bottom: BRSpacing.md),
              child: SkeletonCard(height: 120),
            ),
          ),
        ),
      ],
    );
  }

  List<JournalEntryModel> _filteredEntries(List<JournalEntryModel> entries) {
    var filtered = entries;
    
    if (_selectedMoodFilter != null) {
      filtered = filtered.where((entry) => entry.mood == _selectedMoodFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((entry) => 
        entry.title.toLowerCase().contains(query) ||
        entry.body.toLowerCase().contains(query)
      ).toList();
    }
    
    return filtered;
  }

  void _navigateToEditor(JournalEntryModel? entry) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JournalEditorScreen(entry: entry),
      ),
    );
  }

  void _deleteEntry(JournalEntryModel entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Delete Entry',
          style: TextStyle(color: BRColors.text),
        ),
        content: Text(
          'Are you sure you want to delete "${entry.title}"? This action cannot be undone.',
          style: TextStyle(color: BRColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: BRColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _repository.deleteJournalEntry(entry.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Entry deleted'),
                    backgroundColor: BRColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: BRColors.error),
            ),
          ),
        ],
      ),
    );
  }
}