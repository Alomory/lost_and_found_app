import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_founds_simple/model/user.dart';
import 'package:lost_and_founds_simple/providers/app_provider.dart';
import 'package:lost_and_founds_simple/theme/app_theme.dart';
import 'package:lost_and_founds_simple/util.dart';
import 'package:provider/provider.dart';

class AddItem extends StatefulWidget {
  final User user;
  const AddItem({super.key, required this.user});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemDescController = TextEditingController();
  final _itemLocController = TextEditingController();

  bool _isFoundSelected = false;
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescController.dispose();
    _itemLocController.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _recoverLostImage();
  }

  Future<void> _recoverLostImage() async {
    try {
      final response = await _picker.retrieveLostData();
      if (!mounted || response.isEmpty || response.file == null) return;
      setState(() {
        _selectedImage = File(response.file!.path);
      });
    } catch (_) {
      // Ignore lost-data retrieval issues and allow normal picking flow.
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (!mounted) return;
      if (pickedImage == null) {
        // Camera apps can return null on first attempt in some cases; try recovering lost data.
        await _recoverLostImage();
        return;
      }
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: 'Could not open ${source == ImageSource.camera ? 'camera' : 'gallery'}. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _showImageSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;
    // Let the bottom sheet fully dismiss before launching the picker to avoid
    // activity/result conflicts that can require a second tap on some devices.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    await _pickImage(source);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      showAppSnackBar(
        context,
        message: 'Please attach a photo of the item.',
        isError: true,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Post ${_isFoundSelected ? 'Found' : 'Lost'} Item?'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    height: 120,
                    width: 360,
                    fit: BoxFit.cover,
                  ),
                ),
                const Gap(12),
                Text(
                  _itemNameController.text.trim(),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const Gap(4),
                Text(
                  _itemLocController.text.trim(),
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Edit'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
            ),
            child: const Text('Publish'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await context.read<AppProvider>().addItem(
            pickedImage: _selectedImage!,
            itemName: _itemNameController.text,
            itemDescription: _itemDescController.text,
            location: _itemLocController.text,
            isFound: _isFoundSelected,
            user: widget.user,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showAppSnackBar(
        context,
        message: 'Could not save item: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Item'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Listing Type',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Gap(8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Lost Item'),
                      icon: Icon(Icons.search_rounded),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Found Item'),
                      icon: Icon(Icons.check_circle_outline),
                    ),
                  ],
                  selected: {_isFoundSelected},
                  onSelectionChanged: (selection) {
                    setState(() => _isFoundSelected = selection.first);
                  },
                ),
                const Gap(20),
                InkWell(
                  onTap: _showImageSourceSheet,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: _selectedImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 10,
                                bottom: 10,
                                child: FilledButton.tonalIcon(
                                  onPressed: _showImageSourceSheet,
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(0, 36),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Change'),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 40,
                                color: AppTheme.primaryColor.withValues(alpha: 0.8),
                              ),
                              const Gap(10),
                              const Text(
                                'Tap to add a photo *',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const Gap(4),
                              const Text(
                                'Camera or Gallery',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const Gap(20),
                TextFormField(
                  controller: _itemNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    hintText: 'e.g. Black Leather Wallet',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the item name';
                    }
                    return null;
                  },
                ),
                const Gap(14),
                TextFormField(
                  controller: _itemDescController,
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Color, brand, distinguishing marks...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a short description';
                    }
                    return null;
                  },
                ),
                const Gap(14),
                TextFormField(
                  controller: _itemLocController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    hintText: 'Where was it lost or found?',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the location';
                    }
                    return null;
                  },
                ),
                const Gap(18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.contact_phone_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Posting as ${widget.user.username}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              widget.user.phoneNo.isNotEmpty
                                  ? 'Contact: ${widget.user.phoneNo}'
                                  : widget.user.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Publish Report'),
                ),
                const Gap(10),
                OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
