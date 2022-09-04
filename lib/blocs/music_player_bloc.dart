import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/music.dart';

String formatDuration(Duration duration) {
  String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return "$minutes:$seconds";
}

// Music Player Event ========================================================= START
class MusicPlayerEvent extends Equatable {
  const MusicPlayerEvent();
  
  @override
  List<Object?> get props => [];
}

class PlayMusic extends MusicPlayerEvent {
  final Music? music;
  
  const PlayMusic({
    required this.music,
  });
}

class PauseMusic extends MusicPlayerEvent {}

class SetPosition extends MusicPlayerEvent {
  final Duration newPosition;
  
  const SetPosition({
    required this.newPosition,
  });
}
// Music Player Event ========================================================= END

// Music Player State ========================================================= START
abstract class MusicPlayerState extends Equatable {
  @override
  List<Object> get props => [];
}

class MusicPlayerInitial extends MusicPlayerState {
  final bool isPlaying;
  final Duration currentAudioPlayerPosition;
  final Music? currentPlayingMusic;

  MusicPlayerInitial({
    required this.isPlaying,
    required this.currentAudioPlayerPosition,
    required this.currentPlayingMusic
  });
}

class MusicPlayerLoading extends MusicPlayerState {}

class MusicPlayerError extends MusicPlayerState {
  final String errorMessage;

  MusicPlayerError({
    required this.errorMessage
  });
}
// Music Player State ========================================================= END

// Music Player Bloc ========================================================= START
class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState> {
  MusicPlayerBloc() : super(
    MusicPlayerLoading()
  ) {
    on<PlayMusic>(_mapPlayMusicToState);
    on<PauseMusic>(_mapPauseMusicToState);
    on<SetPosition>(_mapSetPositionToState);
  }

  void _mapPlayMusicToState(PlayMusic event, Emitter emit) async {
    final currentState = state;
    Duration currentAudioPlayerPosition = Duration.zero;

    if(currentState is MusicPlayerInitial) {
      currentAudioPlayerPosition = currentState.currentAudioPlayerPosition;
    }

    emit(MusicPlayerLoading());
    emit(
      MusicPlayerInitial(
        isPlaying: true,
        currentAudioPlayerPosition: currentAudioPlayerPosition,
        currentPlayingMusic: event.music
      )
    );
  }

  void _mapPauseMusicToState(PauseMusic event, Emitter emit) async {
    final currentState = state;
    Duration currentAudioPlayerPosition = Duration.zero;
    Music? currentPlayingMusic;

    if(currentState is MusicPlayerInitial) {
      currentAudioPlayerPosition = currentState.currentAudioPlayerPosition;
      currentPlayingMusic = currentState.currentPlayingMusic;
    }

    emit(MusicPlayerLoading());
    emit(
      MusicPlayerInitial(
        isPlaying: false,
        currentAudioPlayerPosition: currentAudioPlayerPosition,
        currentPlayingMusic: currentPlayingMusic
      )
    );
  }

  void _mapSetPositionToState(SetPosition event, Emitter emit) async {
    final currentState = state;
    bool isPlaying = false;
    Music? currentPlayingMusic;

    if(currentState is MusicPlayerInitial) {
      isPlaying = currentState.isPlaying;
      currentPlayingMusic = currentState.currentPlayingMusic;
    }

    emit(MusicPlayerLoading());
    emit(
      MusicPlayerInitial(
        isPlaying: isPlaying,
        currentAudioPlayerPosition: event.newPosition,
        currentPlayingMusic: currentPlayingMusic
      )
    );
  }
}
// Music Player Bloc ========================================================= END