import 'translation_keys.dart';

const zhCN = TranslationKeys(
  notes: {
    'title': '笔记',
    'noNotes': '暂无笔记',
    'startTyping': '开始输入',
    'untitled': '未命名',
    'noText': '无内容',
    'searchNotes': '搜索笔记',
    'characters': '字符',
  },
  folders: {
    'title': '文件夹',
    'newFolder': '新建文件夹',
    'folderName': '文件夹名称',
    'all': '全部',
    'uncategorized': '未分类',
    'moveToFolder': '移动到文件夹',
    'createFolder': '创建文件夹',
    'renameFolder': '重命名文件夹',
    'deleteFolder': '删除文件夹',
    'deleteFolderConfirm': '确定要删除此文件夹吗？所有笔记将移至未分类。',
  },
  tasks: {
    'title': '任务',
    'noTasks': '暂无任务',
    'addSubtask': "按'回车'创建子任务",
    'setReminder': '设置提醒',
    'completed': '已完成',
    'inProgress': '进行中',
  },
  actions: {
    'create': '创建',
    'rename': '重命名',
    'delete': '删除',
    'cancel': '取消',
    'save': '保存',
    'done': '完成',
    'share': '分享',
    'moveToTrash': '移到回收站',
    'restore': '恢复',
    'deletePermanently': '永久删除',
  },
  settings: {
    'title': '设置',
    'style': '样式',
    'fontSize': {
      'title': '字体大小',
      'small': '小',
      'medium': '中',
      'large': '大',
      'huge': '超大',
    },
    'sort': {
      'title': '排序',
      'byCreationDate': '按创建时间',
      'byModificationDate': '按修改时间',
    },
    'layout': {
      'title': '布局',
      'list': '列表',
      'grid': '网格',
    },
    'darkMode': '深色模式',
    'quickFeatures': '快捷功能',
    'quickNotes': '快速笔记',
    'reminders': '提醒',
    'highPriorityReminders': '高优先级提醒',
    'highPriorityRemindersDesc': '在静音或勿扰模式下也播放提醒音',
    'other': '其他',
    'privacyPolicy': '隐私政策',
    'dataSharing': '笔记第三方数据共享声明',
    'permissions': '权限详情',
    'sortByDate': '日期（最新优先）',
    'sortByTitle': '标题',
    'include': '包含',
    'folderExists': '已存在同名文件夹',
    'enterFolderName': '请输入文件夹名称',
  },
  alerts: {
    'exitConfirm': '确定要退出吗？',
    'exit': '退出',
    'deleteConfirm': '确定要删除吗？',
    'emptyTrashConfirm': '清空回收站？所有项目将被永久删除。',
    'error': '错误',
    'oops': '糟糕！出现了一些问题。',
    'tryAgain': '重试',
    'noFolders': '暂无文件夹',
    'noResults': '未找到与"{}"相关的结果',
    'startTyping': '输入以开始搜索',
    'searching': '搜索中...',
    'itemsInTrash': '回收站中的项目将在30天后永久删除',
    'noItemsInTrash': '回收站为空',
    'deleted': '已删除 {}',
  },
  time: {
    'today': '今天',
    'yesterday': '昨天',
    'tomorrow': '明天',
    'startDate': '开始日期',
    'endDate': '结束日期',
    'to': '至',
    'at': '于',
  },
  language: {
    'title': '语言',
    'selectLanguage': '选择语言',
    'english': 'English',
    'chinese': '中文',
  },
  share: {
    'shareNote': '分享笔记',
    'shareAsText': '分享为文本',
    'shareAsImage': '分享为图片',
    'exportAsMarkdown': '导出为 Markdown',
  },
  editor: {
    'list': '列表',
    'image': '片',
    'draw': '绘画',
    'checkList': '清单',
    'format': '格式',
  },
  dateFormat: {
    'shortTime': 'HH:mm',  // 24小时制时间格式
    'shortDate': 'M月d日',  // 短日期格式
    'fullDate': 'yyyy年M月d日',  // 完整日期格式
    'fullDateTime': 'yyyy年M月d日 HH:mm',  // 完整日期时间格式
    'yesterday': '昨天',
    'today': '今天',
    'tomorrow': '明天',
    'daysAgo': '{}天前',
    'inDays': '{}天后',
    'charactersCount': '{}个字符',  // 字符计数格式
  }, dialog: {},
);
