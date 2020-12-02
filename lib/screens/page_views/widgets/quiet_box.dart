import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuietBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          color: Colors.orange,
          padding: EdgeInsets.symmetric(vertical: 35, horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Chat Screen ✍',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                'Search for a contact and start texting 🙌',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 30,
                  color: Colors.black
                ),
              ),
              SizedBox(
                height: 25,
              ),
              FlatButton(
                color: Colors.orangeAccent,
                child: Text('Search'),
                onPressed: () => Navigator.pushNamed(context, '/searchScreen'),
              )
            ],
          ),
        ),
      ),
    );
  }
}