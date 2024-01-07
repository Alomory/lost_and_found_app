import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_founds_simple/data/list_of_items_dummy.dart';
import 'package:lost_and_founds_simple/model/item.dart';
import 'package:lost_and_founds_simple/model/user.dart';
import 'package:lost_and_founds_simple/screens/add_item.dart';
import 'package:lost_and_founds_simple/screens/item_details.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Item> items = [];
  late ListOfItems dummyData = Provider.of<ListOfItems>(context, listen: false);
  late Orientation currentOrientation;

  @override
  void initState() {
    super.initState();
    initializeData();
    print("#Debug home_screen.dart -> we came back to home page (initState)");
  }

  // Initialize data when the widget is created
  void initializeData() async {
    dummyData = Provider.of<ListOfItems>(context, listen: false);
    if (dummyData.itemList.isEmpty) {
      await dummyData.initializeItems();
    } // await for the initialization to complete
    setState(() {
      items = dummyData.itemList;
    });
    // print("#Debug home.dart -> All ${items.length}");
    // print("#Debug home.dart -> UserList ${widget.user.getUserList()?.length}");
  }

  @override
  Widget build(BuildContext context) {
    currentOrientation = MediaQuery.of(context).orientation;
    print("#Debug home_screen.dart -> we came back to home page (build widget)");
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popAndPushNamed("./");
              },
              child: Row(
                children: [
                  Text(widget.user.userName
                      .split(" ")[0]
                      .toString()
                      .toUpperCase()),
                  const Icon(Icons.person),
                ],
              ),
            )
          ],
          automaticallyImplyLeading: false,
          title: const Text('The Losts & Founds'),
          centerTitle: true,
          notificationPredicate: (ScrollNotification notification) {
            return notification.depth == 1;
          },
          scrolledUnderElevation: 4.0,
          shadowColor: Theme.of(context).shadowColor,
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.cloud_outlined),
                text: 'Lost',
              ),
              Tab(
                icon: Icon(Icons.beach_access_sharp),
                text: 'Founds',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Display Lost Items
            _buildItemListView(false),
            // Display Found Items
            _buildItemListView(true),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            Item addedItem = await Navigator.of(context).push(
              
               MaterialPageRoute(builder: (context) {
              return AddItem(
                user: widget.user,
              );

            }));
            setState(() {
              items.add(addedItem);
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildItemListView(bool isFound) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (items[index].type == isFound) {
          return _itemCard(context, items[index], index);
        } else {
          return Container();
        }
      },
    );
  }

  // A placeholder method to simulate each item 
  Widget _itemCard(context, Item item, int index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.94,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        color: Colors.white70,
        elevation: 5,
        child: GestureDetector(
          onTap: () async{
            Item result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ItemDetails(
                counter: index,
                item: item,
                user: widget.user,
              );
            }));
            if(result != null){
              if(result.itemName != item.itemName ||
              result.itemDescription != item.itemDescription ||
              result.location != item.location){
                setState(() {
                  
                });
              }
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.28,
                      maxHeight: MediaQuery.of(context).size.width * 0.28,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Hero(
                        tag: "Item$index",
                        child: Image.file(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.width * 20,
                          width: MediaQuery.of(context).size.width * 20,
                        ),
                      ),
                    ),
                  )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                      child: Text(
                        item.itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                        child: _itemLabel(
                            "Description: \n", item.itemDescription)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                      child: _itemLabel("Location: \n", item.location),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
                      child: RichText(
                        text: TextSpan(
                          text: "Posted by: \n",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                              fontWeight: FontWeight
                                  .bold), // Set the desired text color
                          children: <TextSpan>[
                            const TextSpan(
                              text: "Name: ",
                            ),
                            TextSpan(
                                text: item.user.userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal)),
                            const TextSpan(
                              text: "\nPhone No:",
                            ),
                            TextSpan(
                                text: item.user.phoneNo,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal)),
                            const TextSpan(
                              text: "\nDate: ",
                            ),
                            TextSpan(
                                text: DateFormat('dd/MM/yyyy')
                                    .format(item.dateTime),
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal)),
                            const TextSpan(
                              text: " - Time: ",
                            ),
                            TextSpan(
                                text: DateFormat('HH:mm').format(item.dateTime),
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemLabel(String pretext, String posttext) {
    return RichText(
      text: TextSpan(
        text: pretext,
        style: const TextStyle(
            color: Colors.black,
            fontSize: 12.0,
            fontWeight: FontWeight.bold),
        children: <TextSpan>[
          TextSpan(
            text: posttext,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
