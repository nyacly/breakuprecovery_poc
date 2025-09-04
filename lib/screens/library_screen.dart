import 'package:flutter/material.dart';
import 'package:breakup_recovery/widgets/br_components.dart';
import 'package:breakup_recovery/theme.dart';
import 'package:breakup_recovery/models/resource_model.dart';
import 'package:breakup_recovery/repositories/breakup_recovery_repository.dart';
import 'package:breakup_recovery/screens/paywall_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final BreakupRecoveryRepository _repository = BreakupRecoveryRepository();
  final TextEditingController _searchController = TextEditingController();
  
  List<ResourceModel> _allResources = [];
  List<ResourceModel> _filteredResources = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _isGridView = false;

  final List<String> _filterOptions = ['All', 'Audio', 'Article', 'Exercise', 'Meditation'];

  @override
  void initState() {
    super.initState();
    _loadResources();
    _searchController.addListener(_filterResources);
  }

  Future<void> _loadResources() async {
    try {
      final resources = await _repository.getResources();
      if (resources.isEmpty) {
        // Seed resources if none exist
        await _repository.seedResources();
        final seededResources = await _repository.getResources();
        setState(() {
          _allResources = seededResources;
          _filteredResources = seededResources;
          _isLoading = false;
        });
      } else {
        setState(() {
          _allResources = resources;
          _filteredResources = resources;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading resources: $e')),
        );
      }
    }
  }

  void _filterResources() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredResources = _allResources.where((resource) {
        final matchesSearch = resource.title.toLowerCase().contains(query) ||
            resource.summary.toLowerCase().contains(query);
        final matchesFilter = _selectedFilter == 'All' ||
            resource.type.toLowerCase() == _selectedFilter.toLowerCase();
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _selectFilter(String filter) {
    setState(() => _selectedFilter = filter);
    _filterResources();
  }

  Future<void> _openResource(ResourceModel resource) async {
    // Check if user has premium access for premium content
    final user = await _repository.getCurrentUser();
    if (resource.premium && !(user?.isPremium ?? false)) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PaywallScreen(),
          ),
        );
      }
      return;
    }

    // In a real app, this would open the resource content
    // For now, just show a placeholder
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(resource.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resource.summary),
              const SizedBox(height: 16),
              Text('Type: ${resource.type.toUpperCase()}'),
              Text('Duration: ${resource.duration}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BRColors.background,
      appBar: BRAppBar(
        title: 'Library',
        showBack: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            color: BRColors.text,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and filters
            Container(
              padding: const EdgeInsets.all(BRSpacing.md),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search resources...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                  
                  const SizedBox(height: BRSpacing.md),
                  
                  // Filter chips
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filterOptions.length,
                      separatorBuilder: (context, index) => const SizedBox(width: BRSpacing.xs),
                      itemBuilder: (context, index) {
                        final filter = _filterOptions[index];
                        final isSelected = filter == _selectedFilter;
                        
                        return FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) => _selectFilter(filter),
                          backgroundColor: BRColors.card,
                          selectedColor: BRColors.primary,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : BRColors.text,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          side: BorderSide(
                            color: isSelected ? BRColors.primary : BRColors.border,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Results count
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: BRSpacing.md),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_filteredResources.length} resources found',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            
            const SizedBox(height: BRSpacing.md),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredResources.isEmpty
                      ? _buildEmptyState()
                      : _isGridView
                          ? _buildGridView()
                          : _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: BRColors.textSecondary,
          ),
          const SizedBox(height: BRSpacing.md),
          Text(
            'No resources found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: BRSpacing.xs),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(BRSpacing.md),
      itemCount: _filteredResources.length,
      separatorBuilder: (context, index) => const SizedBox(height: BRSpacing.md),
      itemBuilder: (context, index) {
        final resource = _filteredResources[index];
        return _buildResourceListTile(resource);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(BRSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: BRSpacing.md,
        mainAxisSpacing: BRSpacing.md,
      ),
      itemCount: _filteredResources.length,
      itemBuilder: (context, index) {
        final resource = _filteredResources[index];
        return _buildResourceGridTile(resource);
      },
    );
  }

  Widget _buildResourceListTile(ResourceModel resource) {
    return GestureDetector(
      onTap: () => _openResource(resource),
      child: Container(
        padding: const EdgeInsets.all(BRSpacing.md),
        decoration: BoxDecoration(
          color: BRColors.card,
          borderRadius: BorderRadius.circular(BRRadius.standard),
          boxShadow: BRShadows.card,
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(resource.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(width: BRSpacing.md),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          resource.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (resource.premium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BRSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: BRColors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Premium',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: BRSpacing.xs),
                  
                  Text(
                    resource.summary,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: BRSpacing.xs),
                  
                  Row(
                    children: [
                      _buildTypeChip(resource.type),
                      const SizedBox(width: BRSpacing.xs),
                      Text(
                        '• ${resource.duration}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Icon(
              Icons.chevron_right,
              color: BRColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceGridTile(ResourceModel resource) {
    return GestureDetector(
      onTap: () => _openResource(resource),
      child: Container(
        decoration: BoxDecoration(
          color: BRColors.card,
          borderRadius: BorderRadius.circular(BRRadius.standard),
          boxShadow: BRShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(BRRadius.standard),
                        topRight: Radius.circular(BRRadius.standard),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(resource.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  if (resource.premium)
                    Positioned(
                      top: BRSpacing.xs,
                      right: BRSpacing.xs,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: BRSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: BRColors.warning,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Premium',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(BRSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    Row(
                      children: [
                        _buildTypeChip(resource.type),
                        const Spacer(),
                        Text(
                          resource.duration,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    IconData icon;
    Color color;
    
    switch (type.toLowerCase()) {
      case 'audio':
        icon = Icons.volume_up_outlined;
        color = Colors.blue;
        break;
      case 'article':
        icon = Icons.article_outlined;
        color = Colors.green;
        break;
      case 'exercise':
        icon = Icons.fitness_center_outlined;
        color = Colors.orange;
        break;
      case 'meditation':
        icon = Icons.self_improvement_outlined;
        color = Colors.purple;
        break;
      default:
        icon = Icons.library_books_outlined;
        color = BRColors.primary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BRSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            type.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}