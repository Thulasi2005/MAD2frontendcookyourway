import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'customer_itemdetails_page.dart';

class BrowseMenuPage extends StatefulWidget {
  @override
  _BrowseMenuPageState createState() => _BrowseMenuPageState();
}

class _BrowseMenuPageState extends State<BrowseMenuPage> {
  Map<String, List<Map<String, dynamic>>> groupedMenuItems = {};
  bool isLoading = true;
  bool hasError = false;
  String? identifier;
  String? token;

  // Variables for animated highlighting
  int? highlightedIndex;
  static const Duration animationDuration = Duration(milliseconds: 300);
  bool isDarkMode = false; // Track dark mode state

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    if (args != null) {
      identifier = args['identifier'] ?? 'Unknown';
      token = args['token'] ?? 'No token';
    }

    fetchMenuItems();
  }

  Future<void> fetchMenuItems() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.26:8000/api/menu'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        groupedMenuItems.clear();

        if (data.isNotEmpty) {
          data.forEach((owner, items) {
            groupedMenuItems[owner] = List<Map<String, dynamic>>.from(items);
          });
        }

        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load menu items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching menu items: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentDarkMode = isDarkMode || Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Menu'),
        backgroundColor: isCurrentDarkMode ? Colors.grey[800] : Colors.green[100],
        actions: [
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value; // Toggle the dark mode state
              });
            },
          ),
        ],
      ),
      body: Container(
        color: isCurrentDarkMode ? Colors.black87 : Color(0xFFCAF1BC),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : hasError
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load menu items.',
                style: TextStyle(
                    fontSize: 18,
                    color: isCurrentDarkMode ? Colors.redAccent : Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchMenuItems,
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrentDarkMode ? Colors.grey : Color(0xFF212121),
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: groupedMenuItems.keys.length,
          itemBuilder: (context, index) {
            final owner = groupedMenuItems.keys.elementAt(index);
            final items = groupedMenuItems[owner]!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the owner identifier as a header
                  Text(
                    owner,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isCurrentDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  // List of menu items for the current owner
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, itemIndex) {
                      final item = items[itemIndex];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            highlightedIndex = itemIndex;
                          });
                          navigateToItemDetails(item['id']);
                        },
                        child: AnimatedContainer(
                          duration: animationDuration,
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: highlightedIndex == itemIndex
                                ? (isCurrentDarkMode
                                ? Colors.greenAccent // Change for dark mode
                                : Colors.green[200]) // Change for light mode
                                : (isCurrentDarkMode
                                ? Colors.grey[850]
                                : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: isCurrentDarkMode
                                    ? Colors.black54
                                    : Colors.grey,
                                blurRadius: 4.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              item['name'],
                              style: TextStyle(
                                  color: isCurrentDarkMode
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            subtitle: Text(
                              item['description'],
                              style: TextStyle(
                                color: isCurrentDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                            trailing: Text(
                              '\$${item['price']}',
                              style: TextStyle(
                                color: isCurrentDarkMode
                                    ? Colors.greenAccent
                                    : Colors.green,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: isCurrentDarkMode ? Colors.grey[900] : Colors.green,
          borderRadius: BorderRadius.circular(50), // Circle shape
          boxShadow: [
            BoxShadow(
              color: isCurrentDarkMode ? Colors.black54 : Colors.grey,
              blurRadius: 6.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/customercart', arguments: {
              'identifier': identifier,
              'token': token,
            });
          },
          child: Icon(
            Icons.shopping_cart,
            color: isCurrentDarkMode ? Colors.white : Colors.black, // Change icon color
          ),
        ),
      ),
    );
  }

  void navigateToItemDetails(int itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsPage(
          itemId: itemId,
          token: token!,
          identifier: identifier!,
        ),
      ),
    );
  }
}
