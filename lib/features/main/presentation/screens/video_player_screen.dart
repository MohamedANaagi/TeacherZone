import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/services/bunny_storage_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  final String? videoDescription;
  final String courseId;
  final String videoId;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.videoTitle,
    this.videoDescription,
    required this.courseId,
    required this.videoId,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  
  // Base URL للفيديو (بدون جودة)
  late String _baseVideoUrl;
  
  // استخدام HLS للجودة التكيفية التلقائية
  bool _useHls = true;

  @override
  void initState() {
    super.initState();
    // استخراج base URL من videoUrl (إزالة أي جودة موجودة)
    _baseVideoUrl = widget.videoUrl;
    final qualityPattern = RegExp(r'/play_\d+p\.mp4$|/playlist\.m3u8$');
    if (qualityPattern.hasMatch(_baseVideoUrl)) {
      _baseVideoUrl = _baseVideoUrl.replaceAll(qualityPattern, '');
    }
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      }

      // تنظيف المشغل القديم
      _chewieController?.dispose();
      await _videoPlayerController?.dispose();

      // التحقق من جاهزية الفيديو في Bunny Stream (إذا كان URL من Bunny Stream)
      if (_baseVideoUrl.contains('b-cdn.net') || _baseVideoUrl.contains('bunnycdn.com')) {
        debugPrint('🔍 التحقق من جاهزية الفيديو في Bunny Stream...');
        try {
          // استخراج videoId من URL
          final uri = Uri.parse(_baseVideoUrl);
          final pathParts = uri.path.split('/');
          if (pathParts.isNotEmpty) {
            final videoId = pathParts.last;
            final isReady = await BunnyStorageService.isVideoReady(videoId);
            if (!isReady) {
              throw Exception(
                'الفيديو قيد المعالجة في Bunny Stream. يرجى الانتظار قليلاً ثم المحاولة مرة أخرى.',
              );
            }
            debugPrint('✅ الفيديو جاهز للتشغيل');
          }
        } catch (e) {
          debugPrint('⚠️ خطأ في التحقق من جاهزية الفيديو: $e');
          // نستمر في المحاولة حتى لو فشل التحقق
        }
      }

      // محاولة تشغيل الفيديو بترتيب: HLS -> 720p MP4 -> 480p MP4 -> 360p MP4
      final List<String> urlsToTry = [
        if (_useHls) BunnyStorageService.getHlsPlaylistUrl(_baseVideoUrl),
        BunnyStorageService.getVideoUrlWithQuality(_baseVideoUrl, '720p'),
        BunnyStorageService.getVideoUrlWithQuality(_baseVideoUrl, '480p'),
        BunnyStorageService.getVideoUrlWithQuality(_baseVideoUrl, '360p'),
      ];

      String? successfulUrl;
      Exception? lastException;

      for (final videoUrl in urlsToTry) {
        try {
          debugPrint('🎬 محاولة تشغيل الفيديو من URL: $videoUrl');
          debugPrint('📹 Base URL: $_baseVideoUrl');

          // إضافة referer header لتجاوز "Block direct url file access" في Bunny Stream
          _videoPlayerController = VideoPlayerController.networkUrl(
            Uri.parse(videoUrl),
            httpHeaders: {
              'Referer': 'https://vz-c07dacb9-781.b-cdn.net/',
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          );

          await _videoPlayerController!.initialize();
          successfulUrl = videoUrl;
          debugPrint('✅ نجح تحميل الفيديو من: $videoUrl');
          break;
        } catch (e) {
          debugPrint('❌ فشل تحميل الفيديو من $videoUrl: $e');
          lastException = e is Exception ? e : Exception(e.toString());
          _videoPlayerController?.dispose();
          _videoPlayerController = null;
          // استمرار المحاولة مع URL التالي
          continue;
        }
      }

      if (successfulUrl == null) {
        throw lastException ?? Exception('فشل تحميل الفيديو من جميع المصادر المتاحة');
      }

      if (!mounted) {
        _videoPlayerController?.dispose();
        return;
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryColor,
          handleColor: AppColors.primaryColor,
          backgroundColor: AppColors.borderColor,
          bufferedColor: AppColors.borderLight,
        ),
        placeholder: Container(
          color: AppColors.backgroundLight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ أثناء تحميل الفيديو',
                  style: AppStyles.textSecondaryStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: AppStyles.textSecondaryStyle.copyWith(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحميل الفيديو: $e');
      debugPrint('📹 Base URL: $_baseVideoUrl');
      debugPrint('🔗 Video URL: ${_useHls ? BunnyStorageService.getHlsPlaylistUrl(_baseVideoUrl) : BunnyStorageService.getVideoUrlWithQuality(_baseVideoUrl, '720p')}');
      
      String errorMessage = 'حدث خطأ أثناء تحميل الفيديو';
      if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        errorMessage = 'خطأ 403: الفيديو محمي أو غير متاح.\n\n'
            '🔧 الحل من لوحة تحكم Bunny Stream:\n\n'
            '1. اذهب إلى https://bunny.net/\n'
            '2. Stream → Library (ID: 570093)\n'
            '3. Settings → Security\n'
            '4. ✅ فعّل "Enable Direct Play"\n'
            '5. ✅ تأكد من أن "Token Authentication" معطل\n'
            '6. ✅ تأكد من أن "Enable Token Authentication" معطل\n'
            '7. افتح الفيديو الفردي وتأكد من "Visibility" = "Public"\n\n'
            '📹 Video ID: ${_baseVideoUrl.split('/').last}\n'
            '🔗 URL: $_baseVideoUrl';
      } else if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        errorMessage = 'خطأ 404: الفيديو غير موجود.\n\n'
            'التحقق:\n'
            '1. تأكد من أن URL الفيديو صحيح\n'
            '2. تأكد من أن الفيديو موجود في Bunny Stream\n'
            '3. تحقق من CDN URL في الإعدادات';
      } else if (e.toString().contains('MEDIA_ERR_SRC_NOT_SUPPORTED') || 
                 e.toString().contains('Format error') ||
                 e.toString().contains('unsuitable')) {
        errorMessage = 'الفيديو غير جاهز أو غير مدعوم.\n\n'
            'السبب المحتمل:\n'
            '1. الفيديو قيد المعالجة في Bunny Stream\n'
            '2. انتظر بضع دقائق ثم حاول مرة أخرى\n'
            '3. تحقق من حالة الفيديو في Bunny Stream Dashboard\n\n'
            '📹 Video ID: ${_baseVideoUrl.split('/').last}';
      } else if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        errorMessage = 'انتهت مهلة الاتصال.\n\n'
            'يرجى التحقق من:\n'
            '1. اتصال الإنترنت\n'
            '2. سرعة الاتصال\n'
            '3. المحاولة مرة أخرى';
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = errorMessage;
        });
      }
      // Cleanup on error
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.videoTitle,
          style: AppStyles.subHeadingStyle.copyWith(
            color: AppColors.secondaryColor,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // مؤشر HLS Adaptive Streaming
          Tooltip(
            message: 'HLS Adaptive Streaming - الجودة التكيفية التلقائية',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'HLS',
                    style: AppStyles.textPrimaryStyle.copyWith(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : _hasError
              ? _buildErrorWidget()
              : _buildVideoPlayer(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 24),
            Text(
              'حدث خطأ أثناء تحميل الفيديو',
              style: AppStyles.headingStyle.copyWith(
                color: AppColors.secondaryColor,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: AppStyles.textSecondaryStyle.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _initializePlayer();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoPlayerController == null || _chewieController == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          // Video Player
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: Chewie(
                  controller: _chewieController!,
                ),
              ),
            ),
          ),
          // Video Info
          if (widget.videoDescription != null &&
              widget.videoDescription!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الوصف',
                    style: AppStyles.subHeadingStyle.copyWith(
                      color: AppColors.secondaryColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.videoDescription!,
                    style: AppStyles.textSecondaryStyle.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

