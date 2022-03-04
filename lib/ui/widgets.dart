import 'package:flutter/material.dart';

DecorationImage background(){
  return DecorationImage(
    image: AssetImage("assets/images/antique_song.jpg"),
    fit: BoxFit.fill
  );
}

AppBar appBar(String title , bool goBack){
  return AppBar(
    title: Text(title),
    backgroundColor: Colors.orange,
    automaticallyImplyLeading: goBack,
  );
}