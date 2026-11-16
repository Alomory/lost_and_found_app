import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_founds_simple/model/item.dart';
import 'package:lost_and_founds_simple/model/user.dart';
import 'package:lost_and_founds_simple/providers/app_provider.dart';
import 'package:lost_and_founds_simple/theme/app_theme.dart';
import 'package:lost_and_founds_simple/util.dart';
import 'package:lost_and_founds_simple/widgets/item_image.dart';
import 'package:provider/provider.dart';

class ItemDetails extends StatefulWidget {
  const ItemDetails({
    super.key,
    required this.item,
    required this.user,
  });

  final User user;
  final Item item;

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _itemNameController;
  late TextEditingController _itemDescriptionController;
  late TextEditingController _locationController;

  late Item _currentItem;
  bool _isEditing = false;
  bool _isSaving = false;

  bool get _isOwner => widget.user.email == _currentItem.user.email;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _itemNameController = TextEditingController(text: _currentItem.itemName);
    _itemDescriptionController =
        TextEditingController(text: _currentItem.itemDescription);
    _locationController = TextEditingController(text: _currentItem.location);
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveEdits() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updated = await context.read<AppProvider>().updateItem(
          existing: _currentItem,
          itemName: _itemNameController.text,
          itemDescription: _itemDescriptionController.text,
          location: _locationController.text,
        );

    if (!mounted) return;
    setState(() {
      _currentItem = updated;
      _isEditing = false;
      _isSaving = false;
    });

    showAppSnackBar(context, message: 'Item updated.');
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this report?'),
        content: Text(
          'Remove "${_currentItem.itemName}" from listings? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              minimumSize: const Size(0, 40),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;
    await context.read<AppProvider>().deleteItem(_currentItem);
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppSnackBar(context, message: 'Item deleted.');
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _itemNameController.text = _currentItem.itemName;
      _itemDescriptionController.text = _currentItem.itemDescription;
      _locationController.text = _currentItem.location;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFound = _currentItem.type;
    final badgeColor = isFound ? AppTheme.foundColor : AppTheme.lostColor;
    final badgeBg = isFound ? AppTheme.foundBg : AppTheme.lostBg;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          if (_isOwner && !_isEditing)
            IconButton(
              tooltip: 'Edit item',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isOwner && !_isEditing)
            IconButton(
              tooltip: 'Delete item',
              icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'item_${_currentItem.id}',
                  child: ItemImage(
                    item: _currentItem,
                    height: 240,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                const Gap(16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentItem.typeLabel.toUpperCase(),
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const Gap(10),
                    Icon(
                      _currentItem.isSynced
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_upload_outlined,
                      size: 16,
                      color: _currentItem.isSynced
                          ? AppTheme.foundColor
                          : AppTheme.lostColor,
                    ),
                    const Gap(4),
                    Text(
                      _currentItem.isSynced ? 'Synced' : 'Local (pending sync)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d, y • HH:mm')
                          .format(_currentItem.dateTime),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Gap(18),
                if (_isEditing) ...[
                  TextFormField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter item name'
                        : null,
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _itemDescriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter description'
                        : null,
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter location'
                        : null,
                  ),
                  const Gap(20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : _cancelEditing,
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isSaving ? null : _saveEdits,
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    _currentItem.itemName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Gap(14),
                  _DetailSection(
                    icon: Icons.notes_rounded,
                    title: 'Description',
                    content: _currentItem.itemDescription,
                  ),
                  const Gap(12),
                  _DetailSection(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    content: _currentItem.location,
                  ),
                ],
                const Gap(16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isOwner ? 'Posted by You' : 'Contact Poster',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Gap(10),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  AppTheme.primaryColor.withValues(alpha: 0.12),
                              child: Text(
                                _currentItem.user.firstName
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentItem.user.username,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  if (_currentItem.user.phoneNo.isNotEmpty)
                                    Text(
                                      _currentItem.user.phoneNo,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
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
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
