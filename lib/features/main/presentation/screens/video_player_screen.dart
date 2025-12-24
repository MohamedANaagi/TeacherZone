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

      // بناء URL الفيديو باستخدام HLS Playlist (adaptive streaming)
      final videoUrl = _useHls
          ? BunnyStorageService.getHlsPlaylistUrl(_baseVideoUrl)
          : BunnyStorageService.getVideoUrlWithQuality(
              _baseVideoUrl,
              '720p', // fallback quality
            );

      // لا نستخدم webview على iOS بسبب channel-error، نستخدم video_player مباشرة
      // HLS Playlist يدعم adaptive streaming تلقائياً
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      await _videoPlayerController!.initialize();

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
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
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

