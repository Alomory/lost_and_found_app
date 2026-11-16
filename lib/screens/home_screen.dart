import 'package:flutter/material.dart';
import 'package:lost_and_founds_simple/model/item.dart';
import 'package:lost_and_founds_simple/model/user.dart';
import 'package:lost_and_founds_simple/providers/app_provider.dart';
import 'package:lost_and_founds_simple/screens/add_item.dart';
import 'package:lost_and_founds_simple/screens/auth_screen.dart';
import 'package:lost_and_founds_simple/screens/item_details.dart';
import 'package:lost_and_founds_simple/theme/app_theme.dart';
import 'package:lost_and_founds_simple/util.dart';
import 'package:lost_and_founds_simple/widgets/item_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: Text('Signed in as ${widget.user.username} (${widget.user.email}).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      context.read<AppProvider>().logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  Future<void> _handleSync() async {
    final result = await context.read<AppProvider>().syncWithRemote();
    if (!mounted) return;
    showAppSnackBar(
      context,
      message: result.message,
      isError: !result.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final lostItems = provider.itemsByType(false);
        final foundItems = provider.itemsByType(true);

        return DefaultTabController(
          length: 2,
          initialIndex: 0,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Lost & Found'),
              actions: [
                _SyncStatusChip(
                  isOnline: provider.isOnline,
                  isSyncing: provider.isSyncing,
                  pendingCount: provider.pendingSyncCount,
                  onTap: _handleSync,
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ActionChip(
                    avatar: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        widget.user.firstName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    label: Text(
                      widget.user.firstName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: _confirmLogout,
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(112),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                      child: TextField(
                        controller: _searchController,
                        onChanged: provider.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Search items, locations, or people...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: provider.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.setSearchQuery('');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                      tabs: [
                        Tab(text: 'Lost (${lostItems.length})'),
                        Tab(text: 'Found (${foundItems.length})'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _ItemListTab(
                        items: lostItems,
                        isFoundTab: false,
                        hasSearch: provider.searchQuery.isNotEmpty,
                        user: widget.user,
                        onRefresh: _handleSync,
                      ),
                      _ItemListTab(
                        items: foundItems,
                        isFoundTab: true,
                        hasSearch: provider.searchQuery.isNotEmpty,
                        user: widget.user,
                        onRefresh: _handleSync,
                      ),
                    ],
                  ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => AddItem(user: widget.user),
                  ),
                );
                if (created == true && context.mounted) {
                  showAppSnackBar(
                    context,
                    message: 'Item reported successfully.',
                  );
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Report Item',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SyncStatusChip extends StatelessWidget {
  const _SyncStatusChip({
    required this.isOnline,
    required this.isSyncing,
    required this.pendingCount,
    required this.onTap,
  });

  final bool isOnline;
  final bool isSyncing;
  final int pendingCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppTheme.foundColor : AppTheme.lostColor;
    final bg = isOnline ? AppTheme.foundBg : AppTheme.lostBg;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSyncing)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(
                isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                size: 14,
                color: color,
              ),
            const SizedBox(width: 5),
            Text(
              isSyncing
                  ? 'Syncing'
                  : isOnline
                      ? (pendingCount > 0 ? 'Sync ($pendingCount)' : 'Online')
                      : 'Offline',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemListTab extends StatelessWidget {
  const _ItemListTab({
    required this.items,
    required this.isFoundTab,
    required this.hasSearch,
    required this.user,
    required this.onRefresh,
  });

  final List<Item> items;
  final bool isFoundTab;
  final bool hasSearch;
  final User user;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasSearch
                            ? Icons.search_off_rounded
                            : (isFoundTab
                                ? Icons.inventory_2_outlined
                                : Icons.manage_search_rounded),
                        size: 56,
                        color: AppTheme.textSecondary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        hasSearch
                            ? 'No matching items'
                            : (isFoundTab
                                ? 'No found items yet'
                                : 'No lost items reported'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasSearch
                            ? 'Try a different keyword or clear the search bar.'
                            : 'Tap "Report Item" below to post a listing.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return ItemCard(
            item: item,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ItemDetails(
                    item: item,
                    user: user,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
