import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sns_app/modules/auth/current_user_store.dart';
import 'package:sns_app/modules/posts/post.dart';
import 'package:sns_app/modules/posts/post.repository.dart';
import 'package:sns_app/widgets/header.dart';
import 'package:sns_app/widgets/post_card.dart';
import 'package:sns_app/widgets/post_input.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  String _content = "";
  List<Post> _posts = [];

  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  void _createPost() async {
    if (_content == "") return;
    final currentUser = ref.read(currentUserProvider);
    final post = await PostRepository().create(_content, currentUser!);
    _textController.text = "";
    setState(() {
      _posts = [post, ..._posts];
      _content = "";
    });
  }

  void _fetchPosts() async {
    final postList = await PostRepository().find();
    setState(() {
      _posts = postList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Header(),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            PostInput(
              controller: _textController,
              content: _content,
              onChanged: (val) => setState(() {
                _content = val;
              }),
              onSubmited: _createPost,
            ),
            ..._posts.map((post) => PostCard(post: post)),
          ],
        ),
      ),
    );
  }
}
