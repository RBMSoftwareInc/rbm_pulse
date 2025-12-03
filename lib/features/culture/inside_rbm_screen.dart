import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/animated_card.dart';
import '../../core/widgets/shimmer_card.dart';
import '../../core/animations/fade_in_animation.dart';
import '../../core/animations/scale_animation.dart';
import '../../core/utils/navigation_helper.dart';
import 'models/culture_post.dart';
import 'services/culture_service.dart';
import 'screens/create_post_screen.dart';
import 'screens/post_detail_screen.dart';
import 'screens/pulse_moments_screen.dart';
import 'widgets/hero_card.dart';
import 'widgets/post_card.dart';

class InsideRbmScreen extends StatefulWidget {
  const InsideRbmScreen({super.key});

  @override
  State<InsideRbmScreen> createState() => _InsideRbmScreenState();
}

class _InsideRbmScreenState extends State<InsideRbmScreen> {
  final CultureService _service = CultureService();
  CulturePost? _heroPost;
  List<CulturePost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final hero = await _service.getHeroPost();
      final posts = await _service.getPosts(page: 1, pageSize: 10);
      if (mounted) {
        setState(() {
          _heroPost = hero;
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user info for notifications
    final session = Supabase.instance.client.auth.currentSession;
    final userId = session?.user.id;

    return Scaffold(
      appBar: AppHeader(
        title: 'Inside RBM',
        showBackButton: false,
        userId: userId,
      ),
      floatingActionButton: ScaleAnimation(
        delay: const Duration(milliseconds: 800),
        beginScale: 0.0,
        endScale: 1.0,
        curve: Curves.elasticOut,
        child: FloatingActionButton.extended(
          onPressed: () {
            NavigationHelper.pushSlide(
              context,
              CreatePostScreen(
                onPostCreated: () => _loadContent(),
              ),
            );
          },
          backgroundColor: const Color(0xFFD72631),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Create Post',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1B1B1B), Color(0xFF2C2C2C)],
                ),
              ),
              child: _isLoading
                  ? ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: 5,
                      itemBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: ShimmerCard(height: 200),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadContent,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pulse Moments Section
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 100),
                              child: _buildPulseMomentsSection(),
                            ),

                            const SizedBox(height: 24),

                            // Hero Card
                            if (_heroPost != null) ...[
                              FadeInAnimation(
                                delay: const Duration(milliseconds: 200),
                                child: AnimatedCard(
                                  onTap: () => _navigateToPost(_heroPost!),
                                  child: HeroCard(
                                    post: _heroPost!,
                                    onTap: () {},
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Featured Posts Label
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 300),
                              child: Text(
                                'Featured Stories',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Posts List with staggered animations
                            ..._posts.asMap().entries.map((entry) {
                              final index = entry.key;
                              final post = entry.value;
                              return FadeInAnimation(
                                delay: Duration(milliseconds: 400 + (index * 100)),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: AnimatedCard(
                                    onTap: () => _navigateToPost(post),
                                    child: PostCard(
                                      post: post,
                                      onTap: () {},
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }

  Widget _buildPulseMomentsSection() {
    return AnimatedCard(
      onTap: () {
        NavigationHelper.pushSlide(
          context,
          const PulseMomentsScreen(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFD72631),
              Color(0xFF8B1A1F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.auto_awesome_outlined,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Pulse Moments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Roboto',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Top performers this week',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Roboto',
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPost(CulturePost post) {
    NavigationHelper.pushSlide(
      context,
      PostDetailScreen(
        post: post,
        onPostUpdated: () => _loadContent(),
      ),
    );
  }
}
