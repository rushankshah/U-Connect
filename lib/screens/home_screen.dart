import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:u_connect/enums/user_state.dart';
import 'package:u_connect/provider/user_provider.dart';
import 'package:u_connect/res/firebase_methods.dart';
import 'package:u_connect/screens/call_screens/pickup/pickup_layout.dart';
import 'page_views/chat_list_screen.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  FirebaseMethods firebaseMethods = FirebaseMethods();
  PageController _pageController;
  int _page = 0;
  double _fontSize = 15;
  UserProvider userProvider;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_)async{  
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();
      firebaseMethods.setUserState(userId: userProvider.getUser.uid, userState: UserState.Online);
    });
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    String currentUserId = (userProvider != null && userProvider.getUser != null) ? userProvider.getUser.uid : '';
    switch(state){
      
      case AppLifecycleState.resumed:
        currentUserId != null ? firebaseMethods.setUserState(userId: currentUserId, userState: UserState.Online) : print('Online');
        break;
      case AppLifecycleState.inactive:
        currentUserId != null ? firebaseMethods.setUserState(userId: currentUserId, userState: UserState.Offline) : print('Offline');
        break;
      case AppLifecycleState.paused:
        currentUserId != null ? firebaseMethods.setUserState(userId: currentUserId, userState: UserState.Waiting) : print('Waiting');
        break;
      case AppLifecycleState.detached:
        currentUserId != null ? firebaseMethods.setUserState(userId: currentUserId, userState: UserState.Offline) : print('Offline');
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
          scaffold: Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          children: <Widget>[
            Container(
              child: ChatListScreen(),
            ),
            Center(child: Text('Call Logs'),),
            Center(child: Text('Contacts Screen'),),
          ],
          controller: _pageController,
          onPageChanged: onPageChanged,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              title: Text('Chats',style: TextStyle(fontSize: _fontSize, color: (_page == 0) ? Colors.orange : Colors.grey),),
              icon: Icon(
                Icons.chat,
                color: (_page == 0) ? Colors.orange : Colors.grey,
                ),
            ),
            BottomNavigationBarItem(
              title: Text('Calls',style: TextStyle(fontSize: _fontSize, color: (_page == 1) ? Colors.orange : Colors.grey),),
              icon: Icon(
                Icons.call,
                color: (_page == 1) ? Colors.orange : Colors.grey,
                )
            ),
            BottomNavigationBarItem(
              title: Text(
                'Contacts',
                style: TextStyle(fontSize: _fontSize, color: (_page == 2) ? Colors.orange : Colors.grey,)
                ),
              icon: Icon(
                Icons.contacts,
                color: (_page == 2) ? Colors.orange : Colors.grey,
                )
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }
  onPageChanged(int page){
    setState(() {
      _page = page;
    });
  }
  navigationTapped(int page){
    _pageController.jumpToPage(page);
  }
}