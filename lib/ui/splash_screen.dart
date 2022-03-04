import 'package:fav_songs/ui/HomePage.dart';
import 'package:fav_songs/ui/widgets.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(seconds: 6)).then((value) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    });

  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: width,
        decoration: BoxDecoration(
          image: background()
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80.0,),
            Container(
              width: 300.0,
              height: 300.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                image: DecorationImage(
                  image: AssetImage("assets/images/antique2.jpg"),
                  fit: BoxFit.cover
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 7.0
                  )
                ]
              ),
            ),
            SizedBox(height: 120.0,),
            Container(
              child: Text(
                "There is a memory in every song",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Grands",
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.blue,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 1.0)
                    )
                  ]
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
