const List<Song> songs = [
  // Song('bit_forrest.mp3', 'Bit Forrest', artist: 'bertz'),
  // Song('free_run.mp3', 'Free Run', artist: 'TAD'),
  // Song('tropical_fantasy.mp3', 'Tropical Fantasy', artist: 'Spring Spring'),
  Song('life_force3.mp3', 'Life Force - Stage 3', artist: 'Konami'),
  Song('life_force5.mp3', 'Life Force - Stage 5', artist: 'Konami'),
];

class Song {
  final String filename;

  final String name;

  final String? artist;

  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'Song<$filename>';
}
