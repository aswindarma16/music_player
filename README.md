# music_player

Supported device: Android mobile phone with min SDK 16

Supported feature:
1. search music
2. select music to play
3. play/pause music
4. search music without stop/pause current playing music
5. play the music in the background

Libraries/dependencies:
1. http -> to call HTTP request
2. equatable -> for the BLoC
3. flutter_bloc -> for the BLoC
4. audioplayers -> for the audio player
5. just_audio -> to get the audio duration, because audioplayers plugin have some issue when getting the audio duration

How to build/deploy the app:
1. make sure you already have flutter sdk installed
2. after you download the whole project folder, run "flutter pub get" inside it
3. run "flutter build apk" to export an APK file. The location of the exported file will be written on the log after you run the command.

OR

You can use the app-release.apk file from the repository.

