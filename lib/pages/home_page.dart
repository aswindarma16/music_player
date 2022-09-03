import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home_page_bloc.dart';
import '../blocs/music_player_bloc.dart';
import '../globals.dart';
import '../models/music.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool availableToPop = false;

  TextEditingController searchTextController = TextEditingController();

  AudioPlayer? audioPlayer;

  final justAudioPlayer = just_audio.AudioPlayer();

  Duration? musicDuration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    availableToPop = Navigator.canPop(context);
  }

  @override
  void dispose() {
    searchTextController.dispose();
    audioPlayer?.dispose();
    super.dispose();
  }

  List<Widget> musicWidgetList(List<Music> musicList, BuildContext blocContext, Music? selectedMusic) {
    List<Widget> musicWidgetList = [];

    if(musicList.isNotEmpty) {
      musicList.asMap().forEach((index, music) {
        musicWidgetList.add(
          Container(
            color: selectedMusic?.trackId == music.trackId ? Colors.lightBlue : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            child: GestureDetector(
              onTap: () async {
                audioPlayer ??= AudioPlayer();

                if(audioPlayer != null) {
                  audioPlayer?.onPositionChanged.listen((newPosition) {
                    BlocProvider.of<MusicPlayerBloc>(blocContext).add(
                      SetPosition(
                        newPosition: newPosition
                      )
                    );
                  });

                  audioPlayer?.onPlayerComplete.listen((event) {
                    audioPlayer?.seek(Duration.zero);
                    BlocProvider.of<MusicPlayerBloc>(blocContext).add(
                      PauseMusic()
                    );
                    BlocProvider.of<MusicPlayerBloc>(blocContext).add(
                      const SetPosition(
                        newPosition: Duration.zero
                      )
                    );
                  });
                }

                audioPlayer?.stop();

                musicDuration = await justAudioPlayer.setUrl(music.previewUrl);
                await audioPlayer?.setSourceUrl(music.previewUrl);
                await audioPlayer?.resume();

                if(!mounted) return;
                BlocProvider.of<HomePageBloc>(blocContext).add(
                  SetCurrentPlayingMusic(
                    selectedMusic: music
                  )
                );
                BlocProvider.of<MusicPlayerBloc>(blocContext).add(
                  PlayMusic(
                    music: music
                  )
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    music.imagePreview,
                    height: 100.0,
                    width: 100.0,
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          music.trackName,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                        Text(
                          music.artistName,
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                        Text(
                          music.albumName,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        );

        if(index != musicList.length - 1) {
          musicWidgetList.add(
            const Divider(
              height: 5.0,
              thickness: 1.0,
              color: Colors.black54,
            ),
          );
        }
      });
    }

    return musicWidgetList;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onWillPopExit(context, availableToPop),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) {
                  return HomePageBloc();
                },
              ),
              BlocProvider(
                create: (context) {
                  return MusicPlayerBloc();
                },
              ),
            ],
            child: Builder(
              builder: (pageContext) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        const Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: TextField(
                            controller: searchTextController,
                            enabled: true,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (String searchKeyword) {
                              BlocProvider.of<HomePageBloc>(pageContext).add(
                                LoadData(
                                  searchKeyword: searchKeyword
                                )
                              );
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(10),
                              hintText: "Search artist",
                              hintStyle: const TextStyle(
                                color: Colors.black26,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 0.8,
                                ),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 0.8,
                                ),
                                borderRadius: BorderRadius.circular(8)
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                        const Divider(
                          height: 5.0,
                          thickness: 1.0,
                          color: Colors.black54,
                        ),
                        BlocBuilder<HomePageBloc, HomePageState>(
                          builder: (context, homePageState) {
                            return homePageState is HomePageInitial ? SizedBox(
                              height: MediaQuery.of(context).size.height - 117.0,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: musicWidgetList(homePageState.musicList, context, homePageState.currentPlayingMusic),
                                ),
                              ),
                            ) : 
                            homePageState is HomePageError ? Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: defaultErrorWidget(
                                () => BlocProvider.of<HomePageBloc>(context).add(
                                  LoadData(
                                    searchKeyword: searchTextController.text
                                  )
                                )
                              ),
                            ) : Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: loadingProgressIndicator,
                            );
                          },
                        ),
                      ],
                    ),
                    BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                      builder: (context, musicPlayerState) {
                        return musicPlayerState is MusicPlayerInitial ? Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 130.0,
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: const Border(
                                  top: BorderSide(
                                    color: Colors.black26,
                                    width: 1.0
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, 20),
                                    blurRadius: 50,
                                    color: Colors.black.withOpacity(0.30),
                                    spreadRadius: 1
                                  )
                                ]
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // GestureDetector(
                                      //   onTap: () {
                                          
                                      //   },
                                      //   child: const SizedBox(
                                      //     width: 50.0,
                                      //     child: Icon(
                                      //       Icons.skip_previous_sharp,
                                      //       color: Colors.black,
                                      //       size: 40.0,
                                      //     ),
                                      //   ),
                                      // ),
                                      const Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                                      GestureDetector(
                                        onTap: () async {
                                          if(musicPlayerState.isPlaying) {
                                            audioPlayer?.pause();
                                            BlocProvider.of<MusicPlayerBloc>(context).add(
                                              PauseMusic()
                                            );
                                          }
                                          else {
                                            audioPlayer?.resume();
                                            BlocProvider.of<MusicPlayerBloc>(context).add(
                                              PlayMusic(
                                                music: musicPlayerState.currentPlayingMusic,
                                              )
                                            );
                                          }
                                        },
                                        child: SizedBox(
                                          width: 50.0,
                                          child: Icon(
                                            musicPlayerState.isPlaying ? Icons.pause_sharp : Icons.play_arrow,
                                            color: Colors.black,
                                            size: 40.0,
                                          ),
                                        ),
                                      ),
                                      const Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                                      // GestureDetector(
                                      //   onTap: () {

                                      //   },
                                      //   child: const SizedBox(
                                      //     width: 50.0,
                                      //     child: Icon(
                                      //       Icons.skip_previous_sharp,
                                      //       color: Colors.black,
                                      //       size: 40.0,
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                                  Text(
                                    "${musicPlayerState.currentPlayingMusic?.trackName} - ${musicPlayerState.currentPlayingMusic?.artistName}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Slider(
                                      min: 0,
                                      max: musicDuration!.inSeconds.toDouble(),
                                      value: musicPlayerState.currentAudioPlayerPosition.inSeconds.toDouble(),
                                      onChanged: (value) async {
                                        final Duration selectedNewPosition = Duration(seconds: value.toInt());
                                        await audioPlayer?.seek(selectedNewPosition);
                                        if(!mounted) return;
                                        BlocProvider.of<MusicPlayerBloc>(context).add(
                                          SetPosition(
                                            newPosition: selectedNewPosition
                                          )
                                        );
                                      },
                                    ),
                                  )
                                ],
                              )
                            )
                          ],
                        ) : Container();
                      }
                    ),
                  ],
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}