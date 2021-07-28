class Cat {
  String? fid;
  String? name;
  List<Forum>? forums;

  Cat.fromJson(Map<String, dynamic> json) {
    fid = json['fid'];
    name = json['name'];
  }
}

class Forum {
  String? fid;
  String? name;
  int? threads;
  int? posts;
  int? todayPosts;
  String? description;
  String? icon;

  Forum.fromJson(Map<String, dynamic> json) {
    fid = json['fid'];
    name = json['name'];
    var threadsStr = json['threads'];
    if (threadsStr != null) {
      threads = int.parse(threadsStr);
    }
    var postsStr = json['posts'];
    if (postsStr != null) {
      posts = int.parse(postsStr);
    }
    var todayPostsStr = json['todayposts'];
    if (todayPostsStr != null) {
      todayPosts = int.parse(todayPostsStr);
    }
    description = json['description'];
    icon = json['icon'];
  }
}
