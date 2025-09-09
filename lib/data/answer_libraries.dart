/// 答案库数据模型和预设答案库
class AnswerLibrary {
  final String id;
  final String name;
  final String description;
  final List<String> answers;
  final String? author;
  final String? category;

  const AnswerLibrary({
    required this.id,
    required this.name,
    required this.description,
    required this.answers,
    this.author,
    this.category,
  });
}

/// 预设的答案库
class AnswerLibraries {
  static const AnswerLibrary defaultLibrary = AnswerLibrary(
    id: 'default',
    name: '经典答案库',
    description: '包含是、否、也许等经典回答',
    answers: [
      '是的',
      '不是',
      '也许',
      '当然',
      '绝对不是',
      '很有可能',
      '问问你的心',
      '现在还不是时候',
      '专心致志',
      '毫无疑问',
      '我的回答是否定的',
      '我的消息来源说不',
      '前景不明朗，再问一次',
      '再问一次',
      '最好现在不要告诉你',
      '无法预测',
      '专注然后再问',
      '不要依赖它',
      '你可以依靠它',
      '绝对是的'
    ],
  );

  static const AnswerLibrary maoZedongLibrary = AnswerLibrary(
    id: 'mao_zedong',
    name: '毛泽东语录',
    description: '毛泽东主席的经典语录和哲理名言',
    author: '毛泽东',
    category: '名人语录',
    answers: [
      // 革命与斗争
      '造反有理！',
      '一切反动派都是纸老虎！',
      '哪里有压迫，哪里就有反抗',
      '星星之火，可以燎原',
      '枪杆子里面出政权',
      
      // 学习与进步
      '好好学习，天天向上',
      '虚心使人进步，骄傲使人落后',
      '饭可以一日不吃，觉可以一日不睡，书不可以一日不读',
      '活到老，学到老，改造到老',
      '读书是学习，使用也是学习，而且是更重要的学习',
      
      // 人民与群众
      '人民，只有人民，才是创造世界历史的动力',
      '兵民是胜利之本',
      '妇女能顶半边天',
      '为人民服务',
      '群众是真正的英雄',
      
      // 战略与战术
      '不打无准备之战',
      '打得赢就打，打不赢就走',
      '敌进我退，敌驻我扰，敌疲我打，敌退我追',
      '集中优势兵力，各个歼灭敌人',
      '战略上藐视敌人，战术上重视敌人',
      
      // 人生与哲理
      '世上无难事，只要肯登攀',
      '自信人生二百年，会当水击三千里',
      '数风流人物，还看今朝',
      '不到长城非好汉',
      '实践是检验真理的唯一标准',
      
      // 实事求是
      '没有调查就没有发言权',
      '实事求是',
      '从群众中来，到群众中去',
      '具体问题具体分析',
      '矛盾是事物发展的动力',
      
      // 革命乐观主义
      '与天奋斗，其乐无穷！与地奋斗，其乐无穷！与人奋斗，其乐无穷！',
      '下定决心，不怕牺牲，排除万难，去争取胜利',
      '雄关漫道真如铁，而今迈步从头越',
      '牢骚太盛防肠断，风物长宜放眼量',
      '天要下雨，娘要嫁人，由他去吧！',
    ],
  );

  static const AnswerLibrary zenLibrary = AnswerLibrary(
    id: 'zen',
    name: '禅意答案',
    description: '充满东方智慧的禅意回答',
    category: '哲学',
    answers: [
      '随缘',
      '一切皆有可能',
      '顺其自然',
      '静待花开',
      '心如止水',
      '万物皆空',
      '缘起缘灭',
      '活在当下',
      '放下执念',
      '心随境转',
      '道法自然',
      '知足常乐',
      '静观其变',
      '大道至简',
      '返璞归真',
      '见山还是山',
      '一念之间',
      '明心见性',
      '随遇而安',
      '无为而治',
    ],
  );

  static const AnswerLibrary encouragingLibrary = AnswerLibrary(
    id: 'encouraging',
    name: '正能量答案',
    description: '充满鼓励和正能量的回答',
    category: '励志',
    answers: [
      '你一定可以的！',
      '相信自己',
      '勇往直前',
      '永不放弃',
      '坚持就是胜利',
      '加油，你是最棒的',
      '明天会更好',
      '一切皆有可能',
      '相信奇迹',
      '你值得拥有',
      '全力以赴',
      '梦想成真',
      '未来可期',
      '你比想象中更强大',
      '保持信心',
      '勇敢去做',
      '成功在望',
      '希望就在前方',
      '你的努力终将得到回报',
      '继续前进',
    ],
  );

  /// 所有可用的答案库
  static const List<AnswerLibrary> allLibraries = [
    defaultLibrary,
    maoZedongLibrary,
    zenLibrary,
    encouragingLibrary,
  ];

  /// 根据ID获取答案库
  static AnswerLibrary? getLibraryById(String id) {
    try {
      return allLibraries.firstWhere((lib) => lib.id == id);
    } catch (e) {
      return null;
    }
  }
}
