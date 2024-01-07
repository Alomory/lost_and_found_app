import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_founds_simple/data/list_of_items_dummy.dart';
import 'package:lost_and_founds_simple/model/item.dart';
import 'package:lost_and_founds_simple/model/user.dart';
import 'package:lost_and_founds_simple/screens/home_screen.dart';
import 'package:provider/provider.dart';

class ItemDetails extends StatefulWidget {
  const ItemDetails({
    Key? key,
    required this.counter,
    required this.item,
    required this.user,
  }) : super(key: key);

  final User user;

  final Item item;
  final int counter;

  @override
  _ItemDetailsState createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  late TextEditingController _itemNameController;
  late TextEditingController _itemDescriptionController;
  late TextEditingController _locationController;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(text: widget.item.itemName);
    _itemDescriptionController =
        TextEditingController(text: widget.item.itemDescription);
    _locationController = TextEditingController(text: widget.item.location);
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ListOfItems>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: "Item${widget.counter}",
              child: Image.file(widget.item.imageUrl, fit: BoxFit.fill),
            ),
            const SizedBox(height: 16.0),
            _buildLabel("Item Name"),
            _buildTextField(_itemNameController),
            const SizedBox(height: 8.0),
            _buildLabel("Description"),
            _buildTextField(_itemDescriptionController),
            const SizedBox(height: 8.0),
            _buildLabel("Location"),
            _buildTextField(_locationController),
            const SizedBox(height: 16.0),
            if (widget.user.email == widget.item.user.email)
              if (isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Item tempItem = Item(
                          imageUrl: widget.item.imageUrl,
                          itemName: _itemNameController.text,
                          itemDescription: _itemDescriptionController.text,
                          location: _locationController.text,
                          user: widget.item.user,
                          type: widget.item.type,
                        );
                        provider.updateItem(tempItem, widget.counter);
                        Navigator.of(context).pop<Item>(tempItem);
                      },
                      child: const Text("Submit"),
                    ),
                    ElevatedButton(
                      onPressed: () => _cancelEditing(),
                      child: const Text("Cancel"),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _startEditing(),
                      child: const Text("Edit"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        provider.deleteItem(widget.item);
                        Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (ctx){
                              return HomeScreen(user: widget.user);
                            }), (route) => false);
                      },
                      child: const Text("Delete"),
                    )
                  ],
                )
            else
              Gap(10),
            _buildLabel((widget.user.email == widget.item.user.email)
                ? "Owner: *"
                : "Posted By: *"),
            _buildTextFieldNonEditable(widget.item),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 16.0),
      readOnly: !isEditing,
      decoration: InputDecoration(
        filled: !isEditing,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(12.0),
      ),
      onTap: () {},
    );
  }

  Widget _buildTextFieldNonEditable(Item item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Name:            ',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold), // Set the desired text color
            children: <TextSpan>[
              TextSpan(
                text: item.user.userName,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            text: 'Phone No:    ',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold), // Set the desired text color
            children: <TextSpan>[
              TextSpan(
                text: item.user.phoneNo,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        labelText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
    );
  }

  void _startEditing() {
    setState(() {
      isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      isEditing = false;
      _itemNameController.text = widget.item.itemName;
      _itemDescriptionController.text = widget.item.itemDescription;
      _locationController.text = widget.item.location;
    });
  }
}
