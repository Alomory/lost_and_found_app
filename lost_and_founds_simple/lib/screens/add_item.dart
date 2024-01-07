import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_founds_simple/data/list_of_items_dummy.dart';
import 'package:lost_and_founds_simple/model/item.dart';
import 'package:lost_and_founds_simple/model/user.dart';
import 'package:lost_and_founds_simple/screens/home_screen.dart';
import 'package:provider/provider.dart';

class AddItem extends StatefulWidget {
  final User user;
  const AddItem({super.key, required this.user});
  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescController = TextEditingController();
  final TextEditingController _itemLocController = TextEditingController();
  bool isFoundSelected = true;
  File? _selectedImage;

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _itemNameController.dispose();
    _itemLocController.dispose();
    _itemDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ListOfItems>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                LostOrFound(),
                TextFormField(
                  controller: _itemNameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the item name';
                    }
                    return null;
                  },
                  autofocus: true, // Set focus on customer ID
                  focusNode: _focusNode,
                ),
                TextFormField(
                  controller: _itemDescController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'At least enter some description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _itemLocController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the location you found/lost it';
                    }
                    return null;
                  },
                ),
                const Gap(20),
                Row(
                  children: [
                    const Text('Pick Image: '),
                    Gap(20),
                    TextButton(
                        onPressed: () {
                          _pickImage(ImageSource.gallery);
                        },
                        child: const Text("Gallery")),
                    Gap(20),
                    TextButton(
                        onPressed: () {
                          _pickImage(ImageSource.camera);
                        },
                        child: const Text("Camera")),
                  ],
                ),
                Gap(10),
                Container(
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          width: 150,
                          height: 150,
                        )
                      : const Text(
                          'No Image selected*',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                ),
                const Gap(30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedImage != null) {
                            _showDataDialog(context, provider);
                          }
                        }
                      },
                      child: Text('Submit'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                            MaterialPageRoute(builder: (context) {
                          return HomeScreen(
                            user: widget.user,
                          );
                        }));
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                ),
                const Gap(100),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Note, go to account info to edit the following: ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    Text(
                      "User ID: ${widget.user.userName}",
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.red),
                    ),
                    Text(
                      "Phone : ${widget.user.phoneNo}",
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.red),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDataDialog(context, ListOfItems provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Post Item: '),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Item Name: ${_itemNameController.text}'),
              Text('Item Description: ${_itemDescController.text}'),
              Text('Location:  ${_itemLocController.text}'),
              Image.file(
                _selectedImage!,
                width: 50,
                height: 50,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Item newItem = Item(
                  imageUrl: _selectedImage!,
                  itemName: _itemNameController.text,
                  itemDescription: _itemDescController.text,
                  location: _itemLocController.text,
                  user: widget.user,
                  type: isFoundSelected, // Set the type as needed
                );
                //provider.addItem(newItem);
                print("#Debug add_item.dart -> type of added item = ${newItem.type}");

                Navigator.of(context).pop<Item>(newItem);
                if(newItem != null){
                  Navigator.of(context).pop<Item>(newItem);
                }
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _focusNode.requestFocus();
              },
              child: const Text('Back to edit'),
            ),
          ],
        );
      },
    );
  }

  Future _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    setState(() {
      _selectedImage = File(pickedImage!.path);
      print("#Debug add_item-> image path = ${_selectedImage!.path}");
    });
  }

  Widget LostOrFound() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isFoundSelected = false;
            });
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isFoundSelected ?  Colors.grey:Colors.blue ,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text(
              'Lost',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isFoundSelected = true;
            });
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isFoundSelected ?  Colors.green:Colors.grey ,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text(
              'Found',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
