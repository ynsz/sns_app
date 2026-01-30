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
  final _limit = 5;
  int _page = 1;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _scrollController.dispose();
  }

  void _initialize() async {
    _fetchPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent - 100 <
          _scrollController.offset) {
        _fetchPosts();
      }
    });
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
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    final postList = await PostRepository().find(_page, _limit);
    setState(() {
      _posts = [..._posts, ...postList];
      _page++;
      _isLoading = false;
    });
  }

  void _deletePost(Post post) async {
    await PostRepository().delete(post.id);
    setState(() {
      _posts = _posts.where((p) => p.id != post.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Header(),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          controller: _scrollController,
          children: [
            PostInput(
              controller: _textController,
              content: _content,
              onChanged: (val) => setState(() {
                _content = val;
              }),
              onSubmited: _createPost,
            ),
            ..._posts.map(
              (post) => PostCard(
                post: post,
                onDeleteButtonTapped: currentUser!.id == post.userId
                    ? () => _deletePost(post)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
