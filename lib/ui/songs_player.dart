
import 'package:audio_manager/audio_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fav_songs/ui/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SongsPlayer extends StatefulWidget {
  int currentIndex;
  List<DocumentSnapshot> songs;

  SongsPlayer({this.currentIndex , this.songs});

  @override
  _SongsPlayerState createState() => _SongsPlayerState();
}

class _SongsPlayerState extends State<SongsPlayer> with SingleTickerProviderStateMixin , WidgetsBindingObserver{
  AppLifecycleState _notification;

  FToast fToast;

  bool isPlaying = false;
  Duration _duration;
  Duration _position;
  double _slider;
  double _sliderVolume;
  String _error;
  num curIndex = 0;
  PlayMode playMode = AudioManager.instance.playMode;
  var audioManagerInstance = AudioManager.instance;
  Animation rotateAnim;
  AnimationController animationController;
  List<AudioInfo> _list = [];
  int _currentIndex = 0;

  // final list = [
  //   {
  //     "title": "network",
  //     "desc": "network resouce playback",
  //     "url": "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.m4a",
  //     "coverUrl": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png"
  //   }
  // ];

  void setupAudio() {

    // Feed the audio list to audio manager
    audioManagerInstance.audioList = _list;
    audioManagerInstance.intercepter = true;


    // listen on the player events
    audioManagerInstance.onEvents((events, args) {
      print("$events, $args");
      switch (events) {
        case AudioManagerEvents.start:
          _slider = 0;
          break;
        case AudioManagerEvents.seekComplete:
          _slider = audioManagerInstance.position.inMilliseconds /
              audioManagerInstance.duration.inMilliseconds;
          setState(() {});
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = audioManagerInstance.isPlaying;

          setState(() {});
          break;
        case AudioManagerEvents.timeupdate:
          _slider = audioManagerInstance.position.inMilliseconds /
              audioManagerInstance.duration.inMilliseconds;
          audioManagerInstance.updateLrc(args["position"].toString());
          setState(() {});
          break;
        case AudioManagerEvents.ended:
          setState(() {
            if (_currentIndex < _list.length-1){
              _currentIndex += 1;
              audioManagerInstance.startInfo(_list[_currentIndex]);
              animationController.repeat();
            }
          });
          break;
        case AudioManagerEvents.error:
          print(args);
          _showToast("Error loading , try load next song then come back .");
          Navigator.pop(context);
          break;
        default:
          break;
      }
    });
  }

  _showToast(mess) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync),
          SizedBox(
            width: 12.0,
          ),
          Expanded(child: Text(mess)),
        ],
      ),
    );


    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 5),
    );
  }

  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);

    WidgetsBinding.instance.addObserver(this);

    widget.songs.forEach((item) => _list.add(AudioInfo(item.data()["url"],
        title: item.data()["title"], desc: item.data()["desc"], coverUrl: item.data()["coverUrl"])));

    _currentIndex = widget.currentIndex;

    setupAudio();


    audioManagerInstance.play(index: _currentIndex);

    animationController = AnimationController(duration: Duration(seconds: 6) , vsync: this);
    rotateAnim = Tween(begin: 0.0 , end:1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.bounceIn
      )
    );

    // animationController.addStatusListener((status) {
    //   if (status == AnimationStatus.completed){
    //     animationController.repeat();
    //   }
    // });

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      _notification = state;
      print("koko $state");
    });

  }

  void dispose(){
    AudioManager.instance.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget songProgress(BuildContext context) {
    var style = TextStyle(color: Colors.white);
    return Row(
      children: <Widget>[
        Text(
          _formatDuration(audioManagerInstance.position),
          style: style,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Colors.blueAccent,
                  overlayColor: Colors.blue,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey,
                ),
                child: Slider(
                  value: _slider ?? 0,
                  onChanged: (value) {
                    setState(() {
                      _slider = value;
                    });
                  },
                  onChangeEnd: (value) {
                    if (audioManagerInstance.duration != null) {
                      Duration msec = Duration(
                          milliseconds:
                          (audioManagerInstance.duration.inMilliseconds *
                              value)
                              .round());
                      audioManagerInstance.seekTo(msec);
                    }
                  },
                )),
          ),
        ),
        Text(
          _formatDuration(audioManagerInstance.duration),
          style: style,
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }


  Widget bottomPanel() {
    return Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: songProgress(context),
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CircleAvatar(
              child: Center(
                child: IconButton(
                    icon: Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      audioManagerInstance.previous();
                      _currentIndex = audioManagerInstance.curIndex;
                      animationController.repeat();
                      // if (_currentIndex != 0){
                      //   _currentIndex -= 1;
                      //   audioManagerInstance.play(index: _currentIndex);
                      //   animationController.repeat();
                      // }
                    }),
              ),
              backgroundColor: Colors.cyan.withOpacity(0.3),
            ),
            CircleAvatar(
              radius: 30,
              child: Center(
                child: IconButton(
                  onPressed: () async {
                    audioManagerInstance.playOrPause().catchError((e){
                      print("koko error player");
                      _showToast("Error loading , try load next song then come back .");
                      Navigator.of(context).pop();
                    });
                  },
                  padding: const EdgeInsets.all(0.0),
                  icon: Icon(
                    audioManagerInstance.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.cyan.withOpacity(0.3),
              child: Center(
                child: IconButton(
                    icon: Icon(
                      Icons.skip_next,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        // _currentIndex = ;
                        audioManagerInstance.next();
                        _currentIndex = audioManagerInstance.curIndex;
                        animationController.repeat();
                        // if (_currentIndex < _list.length-1){
                        //   _currentIndex += 1;
                        //   audioManagerInstance.play(index: _currentIndex);
                        //   animationController.repeat();
                        // }
                      });
                    }),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_notification == AppLifecycleState.resumed){
      setState(() {
        _currentIndex = audioManagerInstance.curIndex;
      });
    }
    var song = widget.songs[_currentIndex];
    final width = MediaQuery.of(context).size.width;
    animationController.forward();
    return Scaffold(
      appBar: appBar(song.data()["title"], true),
      body: AnimatedBuilder(
          animation: animationController,
          builder: (context, child){
            return Container(
              width: width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                image: background()
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 80.0),
                    child: Stack(
                      children: [
                        RotationTransition(
                          turns: rotateAnim,
                          child: GestureDetector(
                            onTap: (){
                              animationController.reset();
                              animationController.forward();
                              audioManagerInstance.playOrPause();
                            },
                            child: Container(
                              width: 250.0,
                              height: 250.0,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(song.data()["coverUrl"]),
                                      fit: BoxFit.cover
                                  ),
                                  borderRadius: BorderRadius.circular(125.0),
                                  boxShadow: [
                                    BoxShadow(blurRadius: 7.0 , color: Colors.black)
                                  ]
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 115.0,
                          left: 110.0,
                          child: Container(
                            width: 30.0,
                            height: 30.0,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(blurRadius: 1.0 , color: Colors.black)
                                ]
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 15.0,),
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text(
                          song.data()["title"],
                          style: TextStyle(
                              fontFamily: "Grands",
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                        SizedBox(height: 15.0,),
                        Container(
                          padding: EdgeInsets.only(left: 10.0 , right: 10.0),
                          child: Text(
                            song.data()["desc"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Grands",
                              fontSize: 18.0,
                                color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  Expanded(child: bottomPanel())
                ],
              ),
            );
          }),
    );
  }
}