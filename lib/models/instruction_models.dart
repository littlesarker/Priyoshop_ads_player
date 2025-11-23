class InstructionResponse {
  final List<Instruction> instructions;

  InstructionResponse({required this.instructions});

  factory InstructionResponse.fromJson(Map<String, dynamic> json) {
    var instructionsList = json['instructions'] as List;
    return InstructionResponse(
      instructions: instructionsList
          .map((instruction) => Instruction.fromJson(instruction))
          .toList(),
    );
  }
}

class Instruction {
  final String type;
  final String name;
  final InstructionData data;

  Instruction({required this.type, required this.name, required this.data});

  factory Instruction.fromJson(Map<String, dynamic> json) {
    return Instruction(
      type: json['type'],
      name: json['name'],
      data: InstructionData.fromJson(json['data']),
    );
  }
}

class InstructionData {
  final String playlistRepeat;
  final List<PlaylistItem> playlist;

  InstructionData({required this.playlistRepeat, required this.playlist});

  factory InstructionData.fromJson(Map<String, dynamic> json) {
    var playlistList = json['playlist'] as List;
    return InstructionData(
      playlistRepeat: json['playlist_repeat'],
      playlist: playlistList
          .map((item) => PlaylistItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlist_repeat': playlistRepeat,
      'playlist': playlist.map((item) => item.toJson()).toList(),
    };
  }
}

class PlaylistItem {
  final String folder;
  final List<String> files;
  final int adId;
  final int repeat;
  final int sequence;

  PlaylistItem({
    required this.folder,
    required this.files,
    required this.adId,
    required this.repeat,
    required this.sequence,
  });

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    var filesList = json['files'] as List;
    return PlaylistItem(
      folder: json['folder'],
      files: filesList.map((file) => file.toString()).toList(),
      adId: json['ad_id'],
      repeat: json['repeat'],
      sequence: json['sequence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folder': folder,
      'files': files,
      'ad_id': adId,
      'repeat': repeat,
      'sequence': sequence,
    };
  }
}