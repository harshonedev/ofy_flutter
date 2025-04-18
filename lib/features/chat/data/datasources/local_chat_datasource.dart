import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/message_model.dart';

abstract class LocalChatDataSource {
  /// Gets the cached list of messages
  ///
  /// Throws [CacheException] if no cached data is present
  Future<List<MessageModel>> getCachedMessages();

  /// Saves messages to local cache
  Future<bool> cacheMessages(List<MessageModel> messages);

  /// Clears all cached messages
  Future<bool> clearCache();
}

class LocalChatDataSourceImpl implements LocalChatDataSource {
  final String _cachedMessagesKey = 'CACHED_MESSAGES';

  @override
  Future<List<MessageModel>> getCachedMessages() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final jsonString = sharedPreferences.getStringList(_cachedMessagesKey);

    if (jsonString != null) {
      return jsonString
          .map((message) => MessageModel.fromJson(json.decode(message)))
          .toList();
    } else {
      return [];
    }
  }

  @override
  Future<bool> cacheMessages(List<MessageModel> messages) async {
    final sharedPreferences = await SharedPreferences.getInstance();

    final jsonStringList =
        messages.map((message) => json.encode(message.toJson())).toList();

    return await sharedPreferences.setStringList(_cachedMessagesKey, jsonStringList);
  }

  @override
  Future<bool> clearCache() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.remove(_cachedMessagesKey);
  }
}
