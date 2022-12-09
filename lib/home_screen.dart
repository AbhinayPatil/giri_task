import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  late String url;
  void getData() {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final docRef = db.collection("songs").doc("willow");
    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        log(data.toString());
        url = data["song_url"];
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  @override
  void initState() {
    super.initState();

    getData();

    setAudio();

    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == PlayerState.PLAYING;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        position = Duration.zero;
        isPlaying = false;
      });
    });
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    audioPlayer.setUrl(url);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 241, 232, 248),
            Color.fromARGB(255, 185, 178, 236),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            const Icon(
              Icons.chevron_left_rounded,
              color: Colors.black,
              size: 50,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.20,
            ),
            Center(
              child: Container(
                height: MediaQuery.of(context).size.width * 0.6,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Lottie.asset(
                  'assets/purplecircle.json',
                  height: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            const Center(
              child: Text(
                "Music",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Arial",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: Slider(
                inactiveColor: Colors.white,
                activeColor: const Color.fromARGB(255, 142, 133, 208),
                min: 0.0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (double value) {
                  setState(() {
                    final position = Duration(seconds: value.toInt());
                    audioPlayer.seek(position);
                    audioPlayer.resume();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(position.toString().split(".")[0].substring(3)),
                  Text(duration.toString().split(".")[0].substring(3)),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.replay),
                const Icon(
                  Icons.skip_previous_rounded,
                  size: 35,
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: IconButton(
                    icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow_outlined),
                    onPressed: () async {
                      if (isPlaying) {
                        await audioPlayer.pause();
                      } else {
                        await audioPlayer.resume();
                      }
                    },
                    iconSize: 35,
                    color: const Color.fromARGB(255, 142, 133, 208),
                  ),
                ),
                const Icon(
                  Icons.skip_next_rounded,
                  size: 35,
                ),
                GestureDetector(
                  child: const Icon(Icons.loop),
                  onTap: () {
                    //getData();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
