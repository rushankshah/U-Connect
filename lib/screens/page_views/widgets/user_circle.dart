import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_connect/provider/user_provider.dart';
import 'package:u_connect/screens/page_views/widgets/user_details_container.dart';
import 'package:u_connect/utils/utilities.dart';
class UserCircle extends StatelessWidget {
  
    @override
    Widget build(BuildContext context) {
      UserProvider userProvider = Provider.of<UserProvider>(context);
      return GestureDetector(
        onTap:() => showModalBottomSheet(
                context: context, 
                builder: (context) => UserDetailsContainer(),
                backgroundColor: Colors.white,
                isScrollControlled: true
              ),
              child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.orange
          ),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(
                  Utils.getInitials(userProvider.getUser.name),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 2
                    ),
                    color: Colors.green
                  ),
                ),
              )          
            ],
          ),
        ),
      );
    }
  }
