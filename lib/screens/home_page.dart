import 'package:chirp/providers/user_provider.dart';
import 'package:chirp/screens/bird_catalogue_page.dart';
import 'package:chirp/screens/bird_map_page.dart';
import 'package:chirp/screens/latest_finds_page.dart';
import 'package:chirp/screens/my_aviary_page.dart';
import 'package:flutter/material.dart';
import 'package:chirp/screens/login_screen.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    LatestFindsPage(),
    MyAviaryPage(),
    BirdCataloguePage(),
    BirdMapPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final username = Provider.of<UserProvider>(context).username;

    void logout() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        actions: [
          TextButton(
            onPressed: () => logout(),
            child: const Text('Logout', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),

      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() => selectedIndex = index);
              },
              labelType: NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.explore),
                  label: Text('Latest Finds'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.photo_library),
                  label: Text('My Aviary'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book),
                  label: Text('Catalogue'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.map),
                  label: Text('Bird Map'),
                ),
              ],
            ),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
      bottomNavigationBar:
          isDesktop
              ? null
              : BottomNavigationBar(
                backgroundColor: Colors.blueGrey[900], // dark background
                selectedItemColor: Colors.lightGreen, // active icon/text color
                unselectedItemColor: Colors.green[900], // inactive color
                currentIndex: selectedIndex,
                onTap: (index) {
                  setState(() => selectedIndex = index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.explore),
                    label: 'Finds',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.photo_library),
                    label: 'My Aviary',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book),
                    label: 'Catalogue',
                  ),
                  BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
                ],
              ),
    );
  }
}
