import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/music.dart';
import '../repositories/music_list_repo.dart';
import 'music_player_bloc.dart';

// Home Page Event ========================================================= START
class HomePageEvent extends Equatable {
  const HomePageEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadData extends HomePageEvent {
  final String searchKeyword;
  
  const LoadData({
    required this.searchKeyword,
  });
}

class SetCurrentPlayingMusic extends HomePageEvent {
  final Music selectedMusic;
  
  const SetCurrentPlayingMusic({
    required this.selectedMusic,
  });
}
// Home Page Event ========================================================= END

// Home Page State ========================================================= START
abstract class HomePageState extends Equatable {
  @override
  List<Object> get props => [];
}

class HomePageInitial extends HomePageState {
  final List<Music> musicList;
  final Music? currentPlayingMusic;

  HomePageInitial({
    required this.musicList,
    required this.currentPlayingMusic
  });
}

class HomePageLoading extends HomePageState {}

class HomePageError extends HomePageState {
  final String errorMessage;

  HomePageError({
    required this.errorMessage
  });
}
// Home Page State ========================================================= END

// Home Page Bloc ========================================================= START
class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc() : super(
    HomePageInitial(
      musicList: const [],
      currentPlayingMusic: null
    )
  ) {
    on<LoadData>(_mapLoadDataToState);
    on<SetCurrentPlayingMusic>(_mapSetCurrentPlayingMusicToState);
  }

  void _mapLoadDataToState(LoadData event, Emitter emit) async {
    List<Music> musicList = [];

    emit(HomePageLoading());

    try {
      musicList = await getMusicList(event.searchKeyword);

      emit(
        HomePageInitial(
          musicList: musicList,
          currentPlayingMusic: null
        )
      );
    } catch(error) {
      emit(
        HomePageError(
          errorMessage: error.toString(),
        )
      );
    }
  }

  void _mapSetCurrentPlayingMusicToState(SetCurrentPlayingMusic event, Emitter emit) async {
    final currentState = state;
    List<Music> musicList = [];

    if(currentState is HomePageInitial) {
      musicList = currentState.musicList;
    }

    emit(HomePageLoading());
    emit(
      HomePageInitial(
        currentPlayingMusic: event.selectedMusic,
        musicList: musicList
      )
    );
  }
}
// Home Page Bloc ========================================================= END