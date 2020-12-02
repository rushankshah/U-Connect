import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:u_connect/models/user.dart';
import 'package:u_connect/res/firebase_repository.dart';
import 'package:u_connect/widgets/custom_tile.dart';
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FirebaseRepository _firebaseRepository = FirebaseRepository();
  List<User> userList;
  String query = '';
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _firebaseRepository.getCurrentUser().then((FirebaseUser user){
      _firebaseRepository.fetchAllUsers(user).then((List<User> usersList){
        setState(() {
          userList = usersList;
        });
      });
    });
  }
  searchAppBar(BuildContext context){
    return GradientAppBar(
      
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
        onPressed: (){
          Navigator.pop(context);
        },
      ),
      title: TextField(
        controller: controller,
        onChanged: (value){
          setState(() {
            query = value;
          });
        },
        cursorColor: Colors.black,
        autofocus: true,
        style: GoogleFonts.openSans(
          color: Colors.black,
          fontSize: 20
        ),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(
                Icons.close,
                color: Colors.black,
              ),
              onPressed: (){
                WidgetsBinding.instance.addPostFrameCallback((_) => controller.clear());
              },
          ),
          hintText: 'Search...',
          hintStyle: GoogleFonts.openSans(
            fontSize: 15,
            color: Colors.white
          )
        ),
      ),
    );
  }
  buildSuggestions(String query) {
    final List<User> suggestionList = query.isEmpty
        ? []
        : userList != null
            ? userList.where((User user) {
                String _getUsername = user.username.toLowerCase();
                String _query = query.toLowerCase();
                String _getName = user.name.toLowerCase();
                bool matchesUsername = _getUsername.contains(_query);
                bool matchesName = _getName.contains(_query);

                return (matchesUsername || matchesName);

                // (User user) => (user.username.toLowerCase().contains(query.toLowerCase()) ||
                //     (user.name.toLowerCase().contains(query.toLowerCase()))),
              }).toList()
            : [];

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: ((context, index) {
        User searchedUser = User(
            uid: suggestionList[index].uid,
            email: suggestionList[index].email,
            profilePhoto: suggestionList[index].profilePhoto,
            name: suggestionList[index].name,
            username: suggestionList[index].username);

        return CustomTile(
          mini: false,
          onTap: () {
            Navigator.pushReplacementNamed(context,'/chatScreen',arguments: searchedUser);
          },
          leading: CircleAvatar(
            backgroundImage: searchedUser.profilePhoto == null?NetworkImage('https://citizenmed.files.wordpress.com/2011/08/user-icon1.jpg'):NetworkImage(searchedUser.profilePhoto),
            backgroundColor: Colors.grey,
          ),
          title: Text(
            searchedUser.name,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            searchedUser.username,
            style: TextStyle(color: Colors.grey),
          ),
        );
      }),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: searchAppBar(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: buildSuggestions(query),
      ),
    );
  }
}