// lib/services/search_service.dart
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../models/task.dart';
import '../models/folder_model.dart';

class SearchResult {
  final String id;
  final String title;
  final String snippet;
  final DateTime timestamp;
  final SearchResultType type;
  final String? folderId;
  final List<String> matchedTokens;
  final double relevanceScore;
  final dynamic originalItem;

  SearchResult({
    required this.id,
    required this.title,
    required this.snippet,
    required this.timestamp,
    required this.type,
    this.folderId,
    this.matchedTokens = const [],
    this.relevanceScore = 0.0,
    required this.originalItem,
  });
}

enum SearchResultType {
  note,
  task,
}

class SearchService {
  // 搜索配置
  static const int snippetLength = 150;
  static const int minQueryLength = 2;

  // 在笔记中搜索
  List<SearchResult> searchNotes(List<Note> notes, String query) {
    if (query.length < minQueryLength) return [];

    final queryTokens = _tokenize(query);
    final results = <SearchResult>[];

    for (final note in notes) {
      final titleTokens = _tokenize(note.title);
      final contentTokens = _tokenize(note.content);
      final matchedTokens = <String>{};
      var relevanceScore = 0.0;

      // 检查标题匹配
      for (final queryToken in queryTokens) {
        for (final titleToken in titleTokens) {
          if (titleToken.contains(queryToken)) {
            matchedTokens.add(titleToken);
            relevanceScore += 2.0; // 标题匹配权重更高
          }
        }
      }

      // 检查内容匹配
      for (final queryToken in queryTokens) {
        for (final contentToken in contentTokens) {
          if (contentToken.contains(queryToken)) {
            matchedTokens.add(contentToken);
            relevanceScore += 1.0;
          }
        }
      }

      // 检查标签匹配
      for (final tag in note.tags) {
        final tagTokens = _tokenize(tag);
        for (final queryToken in queryTokens) {
          for (final tagToken in tagTokens) {
            if (tagToken.contains(queryToken)) {
              matchedTokens.add(tagToken);
              relevanceScore += 1.5; // 标签匹配权重适中
            }
          }
        }
      }

      // 如果有匹配，创建搜索结果
      if (matchedTokens.isNotEmpty) {
        final snippet = _createSnippet(note.content, queryTokens);
        results.add(SearchResult(
          id: note.id,
          title: note.title,
          snippet: snippet,
          timestamp: note.modifiedAt,
          type: SearchResultType.note,
          folderId: note.folderId,
          matchedTokens: matchedTokens.toList(),
          relevanceScore: relevanceScore,
          originalItem: note,
        ));
      }
    }

    // 按相关性和时间排序
    results.sort((a, b) {
      final scoreCompare = b.relevanceScore.compareTo(a.relevanceScore);
      if (scoreCompare != 0) return scoreCompare;
      return b.timestamp.compareTo(a.timestamp);
    });

    return results;
  }

  // 在任务中搜索
  List<SearchResult> searchTasks(List<Task> tasks, String query) {
    if (query.length < minQueryLength) return [];

    final queryTokens = _tokenize(query);
    final results = <SearchResult>[];

    for (final task in tasks) {
      final titleTokens = _tokenize(task.title);
      final matchedTokens = <String>{};
      var relevanceScore = 0.0;

      // 检查标题匹配
      for (final queryToken in queryTokens) {
        for (final titleToken in titleTokens) {
          if (titleToken.contains(queryToken)) {
            matchedTokens.add(titleToken);
            relevanceScore += 1.0;
          }
        }
      }

      // 检查子任务匹配
      for (final subTask in task.subtasks) {
        final subTaskTokens = _tokenize(subTask.title);
        for (final queryToken in queryTokens) {
          for (final subTaskToken in subTaskTokens) {
            if (subTaskToken.contains(queryToken)) {
              matchedTokens.add(subTaskToken);
              relevanceScore += 0.5; // 子任务匹配权重较低
            }
          }
        }
      }

      // 如果有匹配，创建搜索结果
      if (matchedTokens.isNotEmpty) {
        final subTasksText = task.subtasks.isNotEmpty
            ? 'Subtasks: ${task.subtasks.map((st) => st.title).join(", ")}'
            : '';

        final status = task.isCompleted ? 'Completed' : 'In progress';
        final dueText = task.reminder != null
            ? 'Due: ${_formatDate(task.reminder!)}'
            : '';

        final snippet = [status, dueText, subTasksText]
            .where((s) => s.isNotEmpty)
            .join(' • ');

        results.add(SearchResult(
          id: task.id,
          title: task.title,
          snippet: snippet,
          timestamp: task.createdAt,
          type: SearchResultType.task,
          matchedTokens: matchedTokens.toList(),
          relevanceScore: relevanceScore,
          originalItem: task,
        ));
      }
    }

    // 按相关性和时间排序
    results.sort((a, b) {
      final scoreCompare = b.relevanceScore.compareTo(a.relevanceScore);
      if (scoreCompare != 0) return scoreCompare;
      return b.timestamp.compareTo(a.timestamp);
    });

    return results;
  }

  // 高级搜索
  List<SearchResult> advancedSearch({
    required List<Note> notes,
    required List<Task> tasks,
    required String query,
    DateTime? startDate,
    DateTime? endDate,
    Set<String>? folders,
    bool includeNotes = true,
    bool includeTasks = true,
    bool includeCompleted = true,
    String? sortBy,
  }) {
    // 收集所有结果
    List<SearchResult> results = [];

    if (includeNotes) {
      final noteResults = searchNotes(notes, query);
      results.addAll(noteResults);
    }

    if (includeTasks) {
      final taskResults = searchTasks(tasks, query)
          .where((result) => includeCompleted ||
          !(result.originalItem as Task).isCompleted);
      results.addAll(taskResults);
    }

    // 应用日期过滤
    if (startDate != null || endDate != null) {
      results = results.where((result) {
        final date = result.timestamp;
        if (startDate != null && date.isBefore(startDate)) return false;
        if (endDate != null && date.isAfter(endDate)) return false;
        return true;
      }).toList();
    }

    // 应用文件夹过滤
    if (folders != null && folders.isNotEmpty) {
      results = results.where((result) {
        return result.folderId != null && folders.contains(result.folderId);
      }).toList();
    }

    // 应用排序
    switch (sortBy) {
      case 'date':
        results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'relevance':
        results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
        break;
      case 'title':
        results.sort((a, b) => a.title.compareTo(b.title));
        break;
      default:
      // 默认按相关性和日期排序
        results.sort((a, b) {
          final scoreCompare = b.relevanceScore.compareTo(a.relevanceScore);
          if (scoreCompare != 0) return scoreCompare;
          return b.timestamp.compareTo(a.timestamp);
        });
    }

    return results;
  }

  // 辅助方法：分词
  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[\s\p{P}]+', unicode: true))
        .where((token) => token.isNotEmpty)
        .toList();
  }

  // 辅助方法：创建摘要
  String _createSnippet(String content, List<String> queryTokens) {
    if (content.isEmpty) return '';

    // 找到第一个匹配的位置
    int matchStart = -1;
    String matchedToken = '';

    for (final token in queryTokens) {
      final index = content.toLowerCase().indexOf(token);
      if (index != -1 && (matchStart == -1 || index < matchStart)) {
        matchStart = index;
        matchedToken = token;
      }
    }

    if (matchStart == -1) {
      // 如果没有匹配，返回开头的一部分
      return content.length > snippetLength
          ? '${content.substring(0, snippetLength)}...'
          : content;
    }

    // 计算摘要的起始和结束位置
    final snippetStart = (matchStart - snippetLength ~/ 4).clamp(0, content.length);
    final snippetEnd = (matchStart + matchedToken.length + snippetLength ~/ 4)
        .clamp(0, content.length);

    String snippet = content.substring(snippetStart, snippetEnd);

    // 添加省略号
    if (snippetStart > 0) snippet = '...$snippet';
    if (snippetEnd < content.length) snippet = '$snippet...';

    return snippet;
  }

  // 辅助方法：格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      final weekday = [
        'Monday', 'Tuesday', 'Wednesday',
        'Thursday', 'Friday', 'Saturday', 'Sunday'
      ][date.weekday - 1];
      return weekday;
    } else {
      final month = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][date.month - 1];
      return '$month ${date.day}';
    }
  }
}
