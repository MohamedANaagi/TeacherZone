import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
// للويب فقط - استخدام HTML File API مباشرة
import 'dart:html' as html if (dart.library.html) 'dart:html';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/bunny_storage_service.dart';
import '../../data/models/course_model.dart';
import '../../data/models/video_model.dart';
import '../widgets/admin_app_bar.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../user/presentation/cubit/user_cubit.dart';

class AdminManageVideosScreen extends StatefulWidget {
  const AdminManageVideosScreen({super.key});

  @override
  State<AdminManageVideosScreen> createState() =>
      _AdminManageVideosScreenState();
}

class _AdminManageVideosScreenState extends State<AdminManageVideosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _videoTitleController = TextEditingController();
  final _videoDescriptionController = TextEditingController();
  final _videoHoursController = TextEditingController(text: '0'); // الساعات
  final _videoMinutesController = TextEditingController(text: '0'); // الدقائق

  String? _selectedCourseId;
  bool _isLoading = false;
  File? _selectedVideoFile; // ملف الفيديو المختار (لـ iOS و Android)
  PlatformFile? _selectedPlatformFile; // PlatformFile للويب
  String? _uploadedVideoUrl; // URL الفيديو بعد الرفع
  Future<List<CourseModel>>? _coursesFuture; // لحفظ Future الكورسات
  Future<List<VideoModel>>? _videosFuture; // لحفظ Future الفيديوهات

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _videoTitleController.dispose();
    _videoDescriptionController.dispose();
    _videoHoursController.dispose();
    _videoMinutesController.dispose();
    super.dispose();
  }

  /// تحويل الساعات والدقائق إلى تنسيق "HH:MM"
  String _formatDuration(int hours, int minutes) {
    // التأكد من أن القيم صحيحة
    final h = hours.clamp(0, 99);
    final m = minutes.clamp(0, 59);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// اختيار ملف فيديو
  /// يدعم الويب و iOS و Android
  Future<void> _pickVideoFile() async {
    if (!mounted) return;
    
    try {
      debugPrint('🎬 بدء اختيار ملف الفيديو...');
      
      // للويب: استخدام HTML File API مباشرة لتجنب مشاكل file_picker
      if (kIsWeb) {
        debugPrint('🌐 استخدام HTML File API للويب...');
        
        // إنشاء input element مخفي
        final input = html.FileUploadInputElement()
          ..accept = 'video/*'
          ..style.display = 'none';
        
        html.document.body!.append(input);
        
        // انتظار اختيار المستخدم للملف
        final completer = Completer<html.File?>();
        
        input.onChange.listen((event) {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            completer.complete(files.first);
          } else {
            completer.complete(null);
          }
          input.remove(); // إزالة input بعد الاستخدام
        });
        
        // فتح dialog اختيار الملف
        input.click();
        
        // انتظار اختيار المستخدم
        final htmlFile = await completer.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            input.remove();
            return null;
          },
        );
        
        if (!mounted) return;
        
        if (htmlFile == null) {
          debugPrint('ℹ️ المستخدم ألغى اختيار الملف');
          return;
        }
        
        debugPrint('📁 الملف المختار: ${htmlFile.name}');
        debugPrint('📦 حجم الملف: ${htmlFile.size} bytes');
        
        // قراءة الملف باستخدام FileReader
        final reader = html.FileReader();
        final bytesCompleter = Completer<Uint8List>();
        
        // استخدام onLoad بدلاً من onLoadEnd لتجنب مشاكل التوقيت
        reader.onLoad.listen((_) {
          try {
            // قراءة ArrayBuffer وتحويله إلى Uint8List
            final result = reader.result;
            
            if (result == null) {
              bytesCompleter.completeError(Exception('فشل قراءة الملف: النتيجة فارغة'));
              return;
            }
            
            Uint8List bytes;
            
            // في dart:html، readAsArrayBuffer يعيد ByteBuffer مباشرة
            // لكن في release build قد يكون هناك اختلاف
            try {
              // محاولة قراءة كـ ByteBuffer (الطريقة الأساسية)
              if (result is ByteBuffer) {
                bytes = result.asUint8List();
                debugPrint('✅ تم قراءة الملف كـ ByteBuffer (${bytes.length} bytes)');
              } else {
                // محاولة تحويل مباشرة
                final buffer = result as ByteBuffer;
                bytes = buffer.asUint8List();
                debugPrint('✅ تم قراءة الملف بعد التحويل (${bytes.length} bytes)');
              }
            } catch (e) {
              // إذا فشل، جرب طرق أخرى
              debugPrint('⚠️ محاولة طريقة بديلة لقراءة الملف...');
              debugPrint('   نوع النتيجة: ${result.runtimeType}');
              
              if (result is TypedData) {
                bytes = Uint8List.view(result.buffer);
                debugPrint('✅ تم قراءة الملف كـ TypedData (${bytes.length} bytes)');
              } else if (result is List) {
                bytes = Uint8List.fromList(result.cast<int>());
                debugPrint('✅ تم قراءة الملف كـ List (${bytes.length} bytes)');
              } else {
                debugPrint('❌ نوع غير معروف: ${result.runtimeType}');
                bytesCompleter.completeError(Exception('نوع غير معروف للنتيجة: ${result.runtimeType}'));
                return;
              }
            }
            
            bytesCompleter.complete(bytes);
          } catch (e, stackTrace) {
            debugPrint('❌ خطأ في قراءة الملف: $e');
            debugPrint('📚 Stack trace: $stackTrace');
            bytesCompleter.completeError(Exception('فشل قراءة الملف: $e'));
          }
        });
        
        reader.onError.listen((error) {
          debugPrint('❌ خطأ في FileReader: $error');
          bytesCompleter.completeError(Exception('خطأ في FileReader: $error'));
        });
        
        // قراءة الملف كـ ArrayBuffer
        reader.readAsArrayBuffer(htmlFile);
        
        final fileBytes = await bytesCompleter.future;
        
        debugPrint('✅ تم قراءة الملف بنجاح (${fileBytes.length} bytes)');
        
        // إنشاء PlatformFile مع bytes
        final platformFile = PlatformFile(
          name: htmlFile.name,
          size: htmlFile.size.toInt(),
          bytes: fileBytes,
          path: null,
          readStream: null,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم اختيار الفيديو: ${htmlFile.name}'),
              backgroundColor: AppColors.successColor,
            ),
          );
          
          setState(() {
            _selectedVideoFile = null;
            _uploadedVideoUrl = null;
            _selectedPlatformFile = platformFile;
          });
          
          debugPrint('✅ تم حفظ PlatformFile بنجاح');
        }
      } else {
        // للـ iOS و Android: استخدام file_picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
          allowedExtensions: null,
        );

        if (!mounted) return;

        if (result == null || result.files.isEmpty) {
          debugPrint('ℹ️ المستخدم ألغى اختيار الملف');
          return;
        }

        final selectedFile = result.files.first;
        
        if (selectedFile.path != null && selectedFile.path!.isNotEmpty) {
          debugPrint('✅ مسار الملف: ${selectedFile.path}');
          final file = File(selectedFile.path!);
          
          if (await file.exists()) {
            if (mounted) {
              setState(() {
                _selectedVideoFile = file;
                _uploadedVideoUrl = null;
                _selectedPlatformFile = null;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم اختيار الفيديو: ${selectedFile.name}'),
                  backgroundColor: AppColors.successColor,
                ),
              );
            }
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ خطأ في اختيار الفيديو: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      
      if (mounted) {
        // استخراج رسالة خطأ واضحة
        String errorMessage = 'حدث خطأ في اختيار الفيديو';
        final errorString = e.toString();
        
        if (errorString.contains('LateInitializationError')) {
          errorMessage = 'خطأ في تهيئة الملف. يرجى المحاولة مرة أخرى.';
        } else if (errorString.contains('Permission')) {
          errorMessage = 'لا توجد صلاحيات للوصول إلى الملفات. يرجى التحقق من الإعدادات.';
        } else if (errorString.contains('StateError')) {
          errorMessage = 'خطأ في حالة الملف. يرجى المحاولة مرة أخرى.';
        } else {
          errorMessage = 'حدث خطأ: ${errorString.length > 100 ? errorString.substring(0, 100) + "..." : errorString}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<List<CourseModel>> _getAdminCodeAndLoadCourses() async {
    // الحصول على adminCode من UserCubit (المسجل عند تسجيل الدخول)
    final adminCode = context.read<UserCubit>().state.adminCode;
    return await InjectionContainer.adminRepo.getCourses(adminCode: adminCode);
  }

  void _loadCourses() {
    setState(() {
      _coursesFuture = _getAdminCodeAndLoadCourses().catchError((
        e,
      ) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل جلب الكورسات: ${e.toString()}'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
        return <CourseModel>[];
      });
    });
  }

  Future<List<VideoModel>> _getAdminCodeAndLoadVideos(String courseId) async {
    // الحصول على adminCode من UserCubit (المسجل عند تسجيل الدخول)
    final adminCode = context.read<UserCubit>().state.adminCode;
    return await InjectionContainer.adminRepo.getVideosByCourseId(courseId, adminCode: adminCode);
  }

  void _loadVideosForCourse(String courseId) {
    setState(() {
      _videosFuture = _getAdminCodeAndLoadVideos(courseId)
          .catchError((e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('فشل جلب الفيديوهات: ${e.toString()}'),
                  backgroundColor: AppColors.errorColor,
                ),
              );
            }
            return <VideoModel>[];
          });
    });
  }

  Future<void> _addVideo() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار الكورس أولاً'),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }

    if (_selectedVideoFile == null && _selectedPlatformFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار ملف الفيديو أولاً'),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // الحصول على adminCode من UserCubit (المسجل عند تسجيل الدخول)
      final adminCode = context.read<UserCubit>().state.adminCode;
      if (adminCode == null || adminCode.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('كود الأدمن غير موجود. يجب تسجيل الدخول بكود أدمن أولاً'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // رفع الفيديو إلى Bunny Storage
      String videoUrl;
      if (_uploadedVideoUrl != null) {
        // إذا كان الفيديو مرفوعاً مسبقاً، استخدم نفس URL
        videoUrl = _uploadedVideoUrl!;
      } else {
        // رفع الفيديو إلى Bunny Storage
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('جاري رفع الفيديو...'),
              backgroundColor: AppColors.infoColor,
            ),
          );
        }

        // إنشاء اسم فريد للفيديو
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final originalFileName = kIsWeb 
            ? (_selectedPlatformFile?.name ?? 'video.mp4')
            : _selectedVideoFile!.path.split('/').last;
        final fileName = '${_selectedCourseId}_${timestamp}_$originalFileName';
        
        // رفع الفيديو حسب المنصة
        if (kIsWeb) {
          // للويب: استخدام bytes أو قراءة من stream
          Uint8List? videoBytes;
          
          if (_selectedPlatformFile?.bytes != null && _selectedPlatformFile!.bytes!.isNotEmpty) {
            // استخدام bytes مباشرة
            videoBytes = _selectedPlatformFile!.bytes;
            debugPrint('✅ استخدام bytes مباشرة (${videoBytes?.length ?? 0} bytes)');
          } else if (_selectedPlatformFile?.readStream != null) {
            // قراءة من stream
            debugPrint('📡 قراءة الملف من stream عند الرفع...');
            final chunks = <List<int>>[];
            await for (final chunk in _selectedPlatformFile!.readStream!) {
              chunks.add(chunk);
            }
            // دمج جميع الـ chunks
            final totalLength = chunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
            videoBytes = Uint8List(totalLength);
            int offset = 0;
            for (final chunk in chunks) {
              videoBytes.setRange(offset, offset + chunk.length, chunk);
              offset += chunk.length;
            }
            debugPrint('✅ تم قراءة الملف من stream (${videoBytes.length} bytes)');
          } else {
            throw Exception('لم يتم اختيار ملف فيديو أو الملف غير قابل للقراءة');
          }
          
          videoUrl = await BunnyStorageService.uploadVideo(
            videoBytes: videoBytes!,
            fileName: fileName,
          );
        } else {
          // لـ iOS و Android: استخدام File
          if (_selectedVideoFile == null) {
            throw Exception('لم يتم اختيار ملف فيديو');
          }
          videoUrl = await BunnyStorageService.uploadVideo(
            videoFile: _selectedVideoFile!,
            fileName: fileName,
          );
        }
        
        setState(() {
          _uploadedVideoUrl = videoUrl;
        });
      }

      // حساب مدة الفيديو من الساعات والدقائق
      final hours = int.tryParse(_videoHoursController.text) ?? 0;
      final minutes = int.tryParse(_videoMinutesController.text) ?? 0;
      final duration = _formatDuration(hours, minutes);

      // إضافة الفيديو إلى Firestore
      await InjectionContainer.addVideoUseCase(
        courseId: _selectedCourseId!,
        title: _videoTitleController.text,
        url: videoUrl,
        description: _videoDescriptionController.text.isEmpty
            ? null
            : _videoDescriptionController.text,
        duration: duration,
        adminCode: adminCode,
      );

      // مسح الحقول
      _videoTitleController.clear();
      _videoDescriptionController.clear();
      _videoHoursController.text = '0';
      _videoMinutesController.text = '0';
      setState(() {
        _selectedVideoFile = null;
        _selectedPlatformFile = null;
        _uploadedVideoUrl = null;
      });

      // إعادة تحميل الفيديوهات بعد الإضافة
      if (_selectedCourseId != null) {
        _loadVideosForCourse(_selectedCourseId!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الفيديو بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } on ValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // استخراج رسالة خطأ واضحة
        String errorMessage = 'حدث خطأ أثناء رفع الفيديو';
        final errorString = e.toString();
        
        if (errorString.contains('انتهت مهلة')) {
          errorMessage = 'انتهت مهلة رفع الفيديو. الملف كبير جداً أو اتصال الإنترنت بطيء. يرجى المحاولة مرة أخرى.';
        } else if (errorString.contains('الاتصال')) {
          errorMessage = 'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';
        } else if (errorString.contains('CORS') || errorString.contains('cors')) {
          errorMessage = 'خطأ في الاتصال. يرجى التحقق من إعدادات الخادم والمحاولة مرة أخرى.';
        } else {
          errorMessage = 'حدث خطأ: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteVideo(String videoId) async {
    try {
      await InjectionContainer.adminRepo.deleteVideo(videoId);

      // إعادة تحميل الفيديوهات بعد الحذف
      if (_selectedCourseId != null) {
        _loadVideosForCourse(_selectedCourseId!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الفيديو بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الفيديو: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  String? _getSelectedCourseTitle(List<CourseModel> courses) {
    if (_selectedCourseId == null) return null;
    try {
      return courses.firstWhere((c) => c.id == _selectedCourseId).title;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AdminAppBar(title: 'إدارة الفيديوهات'),
      body: FutureBuilder<List<CourseModel>>(
        future: _coursesFuture,
        builder: (context, coursesSnapshot) {
          if (coursesSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (coursesSnapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ في جلب الكورسات',
                    style: AppStyles.textSecondaryStyle,
                  ),
                ],
              ),
            );
          }

          final courses = coursesSnapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اختيار الكورس
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر الكورس',
                        style: AppStyles.subHeadingStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCourseId,
                          decoration: InputDecoration(
                            hintText: 'اختر الكورس',
                            hintStyle: AppStyles.textSecondaryStyle,
                            prefixIcon: const Icon(
                              Icons.menu_book,
                              color: AppColors.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.secondaryColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                          items: courses.map((course) {
                            return DropdownMenuItem<String>(
                              value: course.id,
                              child: Text(
                                course.title,
                                style: AppStyles.textPrimaryStyle,
                                textDirection: TextDirection.rtl,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCourseId = value;
                              if (value != null) {
                                _loadVideosForCourse(value);
                              } else {
                                _videosFuture = null;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                if (_selectedCourseId != null) ...[
                  const SizedBox(height: 24),
                  // نموذج إضافة فيديو جديد
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إضافة فيديو للكورس: ${_getSelectedCourseTitle(courses)}',
                            style: AppStyles.subHeadingStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // حقل عنوان الفيديو
                          CustomTextField(
                            controller: _videoTitleController,
                            hintText: 'عنوان الفيديو',
                            icon: Icons.video_label,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال عنوان الفيديو';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // زر اختيار ملف الفيديو
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: (_selectedVideoFile != null || _selectedPlatformFile != null)
                                    ? AppColors.successColor
                                    : AppColors.borderColor,
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              onTap: _isLoading ? null : _pickVideoFile,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      (_selectedVideoFile != null || _selectedPlatformFile != null)
                                          ? Icons.check_circle
                                          : Icons.video_file,
                                      color: (_selectedVideoFile != null || _selectedPlatformFile != null)
                                          ? AppColors.successColor
                                          : AppColors.primaryColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (_selectedVideoFile != null || _selectedPlatformFile != null)
                                                ? 'تم اختيار الفيديو'
                                                : 'اختر ملف الفيديو',
                                            style: AppStyles.textPrimaryStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (_selectedVideoFile != null || _selectedPlatformFile != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              kIsWeb
                                                  ? (_selectedPlatformFile?.name ?? '')
                                                  : (_selectedVideoFile?.path.split('/').last ?? ''),
                                              style: AppStyles.textSecondaryStyle.copyWith(
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (_selectedVideoFile != null || _selectedPlatformFile != null)
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: _isLoading
                                            ? null
                                            : () {
                                                setState(() {
                                                  _selectedVideoFile = null;
                                                  _selectedPlatformFile = null;
                                                  _uploadedVideoUrl = null;
                                                });
                                              },
                                        color: AppColors.errorColor,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_uploadedVideoUrl != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.successColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.successColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'تم رفع الفيديو بنجاح',
                                      style: AppStyles.textPrimaryStyle.copyWith(
                                        fontSize: 12,
                                        color: AppColors.successColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          // حقل الوصف (اختياري)
                          CustomTextField(
                            controller: _videoDescriptionController,
                            hintText: 'وصف الفيديو (اختياري)',
                            icon: Icons.description,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          // حقول مدة الفيديو (الساعات والدقائق)
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _videoHoursController,
                                  hintText: 'الساعات',
                                  icon: Icons.access_time,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'مطلوب';
                                    }
                                    final hours = int.tryParse(value);
                                    if (hours == null || hours < 0 || hours > 99) {
                                      return '0-99';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  ':',
                                  style: AppStyles.subHeadingStyle.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _videoMinutesController,
                                  hintText: 'الدقائق',
                                  icon: Icons.timer,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'مطلوب';
                                    }
                                    final minutes = int.tryParse(value);
                                    if (minutes == null || minutes < 0 || minutes > 59) {
                                      return '0-59';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // نص توضيحي
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'أدخل مدة الفيديو بالساعات (0-99) والدقائق (0-59)',
                              style: AppStyles.textSecondaryStyle.copyWith(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // زر الإضافة
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _addVideo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.secondaryColor,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'إضافة الفيديو',
                                      style: AppStyles.subTextStyle.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // قائمة الفيديوهات للكورس المختار
                  FutureBuilder<List<VideoModel>>(
                    future: _videosFuture,
                    builder: (context, videosSnapshot) {
                      if (videosSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (videosSnapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: AppColors.errorColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'حدث خطأ في جلب الفيديوهات',
                                  style: AppStyles.textSecondaryStyle.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final videos = videosSnapshot.data ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'فيديوهات الكورس (${videos.length})',
                            style: AppStyles.subHeadingStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          videos.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(40),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.video_library_outlined,
                                          size: 60,
                                          color: AppColors.textLight,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'لا توجد فيديوهات لهذا الكورس',
                                          style: AppStyles.textSecondaryStyle
                                              .copyWith(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: videos.length,
                                  itemBuilder: (context, index) {
                                    final video = videos[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.borderColor,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // أيقونة الفيديو
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: AppColors.accentColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.play_circle_outline,
                                              color: AppColors.accentColor,
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // معلومات الفيديو
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  video.title,
                                                  style: AppStyles
                                                      .subHeadingStyle
                                                      .copyWith(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (video.description != null &&
                                                    video
                                                        .description!
                                                        .isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    video.description!,
                                                    style: AppStyles
                                                        .textSecondaryStyle,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                                const SizedBox(height: 4),
                                                Text(
                                                  video.url,
                                                  style: AppStyles
                                                      .textSecondaryStyle
                                                      .copyWith(fontSize: 11),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _deleteVideo(video.id),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            color: AppColors.errorColor,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
