import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/instruction_models.dart';



import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/instruction_models.dart';
//
// class StorageService {
//   static const String _lastInstructionKey = 'last_instruction';
//   static const String _lastInstructionHashKey = 'last_instruction_hash';
//
//   Future<InstructionData?> getLastInstruction() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final instructionJson = prefs.getString(_lastInstructionKey);
//
//       if (instructionJson != null) {
//         final Map<String, dynamic> data = json.decode(instructionJson);
//         return InstructionData.fromJson(data);
//       }
//     } catch (e) {
//       print('Error reading last instruction: $e');
//     }
//     return null;
//   }
//
//   Future<void> saveLastInstruction(InstructionData data) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final instructionJson = json.encode(data.toJson());
//       final instructionHash = _calculateHash(instructionJson);
//
//       await prefs.setString(_lastInstructionKey, instructionJson);
//       await prefs.setString(_lastInstructionHashKey, instructionHash);
//     } catch (e) {
//       print('Error saving last instruction: $e');
//     }
//   }
//
//   Future<InstructionData?> loadJsonInstructions() async {
//     try {
//       final jsonString = await rootBundle.loadString('assets/instructions.json');
//       return _parseInstructionData(jsonString);
//     } catch (e) {
//       print('Error loading JSON instructions: $e');
//     }
//     return null;
//   }
//
//   Future<bool> hasJsonInstructionsChanged() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final lastHash = prefs.getString(_lastInstructionHashKey);
//       final currentJsonString = await rootBundle.loadString('assets/instructions.json');
//       final currentHash = _calculateHash(currentJsonString);
//
//       return lastHash != currentHash;
//     } catch (e) {
//       print('Error checking JSON changes: $e');
//       return false;
//     }
//   }
//
//   InstructionData? _parseInstructionData(String jsonString) {
//     try {
//       final jsonResponse = json.decode(jsonString);
//       final instructionResponse = InstructionResponse.fromJson(jsonResponse);
//
//       if (instructionResponse.instructions.isNotEmpty) {
//         return instructionResponse.instructions.first.data;
//       }
//     } catch (e) {
//       print('Error parsing instruction data: $e');
//     }
//     return null;
//   }
//
//   String _calculateHash(String input) {
//     // Simple hash calculation for change detection
//     return input.length.toString() + input.hashCode.toString();
//   }
// }


import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/instruction_models.dart';

class StorageService {
  static const String _lastInstructionKey = 'last_instruction';
  static const String _lastInstructionHashKey = 'last_instruction_hash';

  Future<InstructionData?> getLastInstruction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final instructionJson = prefs.getString(_lastInstructionKey);

      if (instructionJson != null) {
        final Map<String, dynamic> data = json.decode(instructionJson);
        return InstructionData.fromJson(data);
      }
    } catch (e) {
      print('Error reading last instruction: $e');
    }
    return null;
  }

  Future<void> saveLastInstruction(InstructionData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final instructionJson = json.encode(data.toJson());
      final instructionHash = _calculateHash(instructionJson);

      await prefs.setString(_lastInstructionKey, instructionJson);
      await prefs.setString(_lastInstructionHashKey, instructionHash);
    } catch (e) {
      print('Error saving last instruction: $e');
    }
  }

  Future<InstructionData?> loadJsonInstructions() async {
    try {
      final jsonString = await rootBundle.loadString('assets/instructions.json');
      return _parseInstructionData(jsonString);
    } catch (e) {
      print('Error loading JSON instructions: $e');
    }
    return null;
  }

  Future<bool> hasJsonInstructionsChanged() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastHash = prefs.getString(_lastInstructionHashKey);
      final currentJsonString = await rootBundle.loadString('assets/instructions.json');
      final currentHash = _calculateHash(currentJsonString);

      return lastHash != currentHash;
    } catch (e) {
      print('Error checking JSON changes: $e');
      return false;
    }
  }

  InstructionData? _parseInstructionData(String jsonString) {
    try {
      final jsonResponse = json.decode(jsonString);
      final instructionResponse = InstructionResponse.fromJson(jsonResponse);

      if (instructionResponse.instructions.isNotEmpty) {
        return instructionResponse.instructions.first.data;
      }
    } catch (e) {
      print('Error parsing instruction data: $e');
    }
    return null;
  }

  String _calculateHash(String input) {
    // Simple hash calculation for change detection
    return input.length.toString() + input.hashCode.toString();
  }
}