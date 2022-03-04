import 'package:audio_manager/audio_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fav_songs/ui/songs_player.dart';
import 'package:fav_songs/ui/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('songs');
    final width = MediaQuery.of(context).size.width;

    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return  Container(
            width: double.infinity,
            decoration: BoxDecoration(
                image: background()
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: appBar("Reminds me of you" , false),
          body: Container(
            width: width,
            decoration: BoxDecoration(
              image: background()
            ),
            child: ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context , index){
                print(snapshot.data.docs.length);
                  return _bildListTile(snapshot.data.docs[index] , index , snapshot.data.docs);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _bildListTile(DocumentSnapshot song , int index , List songs){
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: (){

        //AudioManager.instance.stop();
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
          return SongsPlayer(currentIndex: index, songs: songs);
        }));

      },
      child: Container(
        width: width,
        margin: EdgeInsets.only(right: 10.0 , left: 10.0 , top: 10.0),
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(20.0),topRight: Radius.circular(20.0),topLeft: Radius.circular(20.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 7.0
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              width: 75.0,
              height: 85.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                  image: NetworkImage(song.data()["coverUrl"]),
                  fit: BoxFit.cover
                )
              ),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.data()["title"],
                    style: TextStyle(
                      fontFamily: "Grands",
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 5.0,),
                  Text(
                    song.data()["desc"],
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}
