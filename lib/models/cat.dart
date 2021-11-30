// 板块分类
class Cat {
  // 分类id
  final String fid;

  // 分类名称
  final String name;

  // 板块
  late List<CatForum> forums;

  Cat(this.fid, this.name);

  Cat.fromJson(Map<String, dynamic> json)
      : fid = json['fid'],
        name = json['name'];
}

// 分类下板块
class CatForum {
  // 板块id
  final String fid;

  // 板块名称
  final String name;

  // 帖子数
  final int threads;

  // 回复数
  final int posts;

  // 今日回复数
  final int todayPosts;

  // 描述
  final String? description;

  // 图标
  final String? icon;

  CatForum(this.fid, this.name, this.threads, this.posts, this.todayPosts,
      this.description, this.icon);

  CatForum.fromJson(Map<String, dynamic> json)
      : fid = json['fid'],
        name = json['name'],
        threads = int.parse(json['threads'] ?? '0'),
        posts = int.parse(json['posts'] ?? '0'),
        todayPosts = int.parse(json['todayposts'] ?? '0'),
        description = json['description'],
        icon = json['icon'];
}
