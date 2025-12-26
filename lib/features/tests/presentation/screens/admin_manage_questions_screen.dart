import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/bunny_storage_service.dart';
import '../../data/models/question_model.dart';
import '../../data/models/test_model.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../admin/presentation/widgets/admin_app_bar.dart';

class AdminManageQuestionsScreen extends StatefulWidget {
  final TestModel test;

  const AdminManageQuestionsScreen({super.key, required this.test});

  @override
  State<AdminManageQuestionsScreen> createState() =>
      _AdminManageQuestionsScreenState();
}

class _AdminManageQuestionsScreenState
    extends State<AdminManageQuestionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctAnswerIndex = 0;
  bool _isLoading = false;
  Future<List<QuestionModel>>? _questionsFuture;

  // للصور
  File? _selectedImageFile; // ملف الصورة المختار (لـ iOS و Android)
  PlatformFile? _selectedPlatformFile; // PlatformFile للويب
  String? _uploadedImageUrl; // URL الصورة بعد الرفع
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<List<QuestionModel>> _loadQuestions() async {
    try {
      final questions = await InjectionContainer.testRepo.getQuestionsByTestId(
        widget.test.id,
      );
      return questions.cast<QuestionModel>();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل جلب الأسئلة: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
      return <QuestionModel>[];
    }
  }

  void _loadQuestionsWrapper() {
    if (!mounted) return;
    setState(() {
      _questionsFuture = _loadQuestions();
    });
  }

  void _addOption() {
    if (!mounted) return;
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (!mounted) return;
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
        if (_correctAnswerIndex >= _optionControllers.length) {
          _correctAnswerIndex = _optionControllers.length - 1;
        }
      });
    }
  }

  /// اختيار صورة للسؤال
  /// يستخدم FilePicker لجميع المنصات (مثل اختيار الفيديو)
  Future<void> _pickImage() async {
    if (!mounted) return;
    
    try {
      debugPrint('🖼️ بدء اختيار صورة...');
      
      // استخدام file_picker لجميع المنصات (مثل اختيار الفيديو)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        allowedExtensions: null,
      );

      if (!mounted) return;

      if (result == null || result.files.isEmpty) {
        debugPrint('ℹ️ المستخدم ألغى اختيار الملف');
        return;
      }

      final selectedFile = result.files.first;
      debugPrint('📁 الملف المختار: ${selectedFile.name}');
      debugPrint('📦 حجم الملف: ${selectedFile.size} bytes');
      
      if (kIsWeb) {
        // للويب: استخدام PlatformFile مباشرة (يحتوي على bytes)
        if (mounted) {
          setState(() {
            _selectedImageFile = null;
            _uploadedImageUrl = null;
            _selectedPlatformFile = selectedFile;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم اختيار الصورة: ${selectedFile.name}'),
              backgroundColor: AppColors.successColor,
            ),
          );
          
          debugPrint('✅ تم حفظ PlatformFile للويب بنجاح');
        }
      } else {
        // للـ iOS و Android: استخدام file_picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
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
                _selectedImageFile = file;
                _selectedPlatformFile = null;
                _uploadedImageUrl = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم اختيار الصورة: ${selectedFile.name}'),
                  backgroundColor: AppColors.successColor,
                ),
              );
            }
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ خطأ في اختيار الصورة: $e');
      debugPrint('📚 Stack trace: $stackTrace');

      if (mounted) {
        // استخراج رسالة خطأ واضحة
        String errorMessage = 'فشل اختيار الصورة';
        final errorString = e.toString();

        if (errorString.contains('LateInitializationError')) {
          errorMessage = 'خطأ في تهيئة الملف. يرجى المحاولة مرة أخرى.';
        } else if (errorString.contains('Permission')) {
          errorMessage =
              'لا توجد صلاحيات للوصول إلى الملفات. يرجى التحقق من الإعدادات.';
        } else if (errorString.contains('StateError')) {
          errorMessage = 'خطأ في حالة الملف. يرجى المحاولة مرة أخرى.';
        } else {
          errorMessage =
              'فشل اختيار الصورة: ${errorString.length > 100 ? errorString.substring(0, 100) + "..." : errorString}';
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

  /// رفع الصورة إلى Bunny Storage
  Future<String?> _uploadImageToBunny() async {
    if (_selectedImageFile == null && _selectedPlatformFile == null) {
      return null;
    }

    setState(() => _isUploadingImage = true);

    try {
      String fileName;
      String? imageUrl;

      if (kIsWeb) {
        if (_selectedPlatformFile == null ||
            _selectedPlatformFile!.bytes == null) {
          throw Exception('لم يتم اختيار صورة');
        }

        // إنشاء اسم ملف فريد
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = _selectedPlatformFile!.extension ?? 'jpg';
        fileName = 'questions/question_${widget.test.id}_$timestamp.$extension';

        // رفع الصورة
        imageUrl = await BunnyStorageService.uploadImage(
          imageBytes: _selectedPlatformFile!.bytes,
          fileName: fileName,
        );
      } else {
        if (_selectedImageFile == null) {
          throw Exception('لم يتم اختيار صورة');
        }

        // إنشاء اسم ملف فريد
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = _selectedImageFile!.path.split('.').last;
        fileName = 'questions/question_${widget.test.id}_$timestamp.$extension';

        // رفع الصورة
        imageUrl = await BunnyStorageService.uploadImage(
          imageFile: _selectedImageFile,
          fileName: fileName,
        );
      }

      if (mounted) {
        setState(() {
          _uploadedImageUrl = imageUrl;
          _isUploadingImage = false;
        });
      }

      return imageUrl;
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);

        // استخراج رسالة خطأ واضحة
        String errorMessage = 'فشل رفع الصورة';
        final errorString = e.toString();

        if (errorString.contains('انتهت مهلة')) {
          errorMessage =
              'انتهت مهلة رفع الصورة. الملف كبير جداً أو اتصال الإنترنت بطيء. يرجى المحاولة مرة أخرى.';
        } else if (errorString.contains('الاتصال')) {
          errorMessage =
              'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';
        } else if (errorString.contains('CORS') ||
            errorString.contains('cors')) {
          errorMessage =
              'خطأ في الاتصال. يرجى التحقق من إعدادات الخادم والمحاولة مرة أخرى.';
        } else {
          errorMessage = 'فشل رفع الصورة: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return null;
    }
  }

  /// إزالة الصورة المختارة
  void _removeImage() {
    if (!mounted) return;
    setState(() {
      _selectedImageFile = null;
      _selectedPlatformFile = null;
      _uploadedImageUrl = null;
    });
  }

  Future<void> _addQuestion() async {
    // التحقق من وجود نص السؤال أو صورة
    if ((_questionTextController.text.trim().isEmpty) &&
        (_selectedImageFile == null &&
            _selectedPlatformFile == null &&
            _uploadedImageUrl == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال نص السؤال أو رفع صورة'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // التحقق من أن جميع الخيارات مملوءة
    for (var controller in _optionControllers) {
      if (controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء ملء جميع الخيارات'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // رفع الصورة إذا كانت موجودة
      String? imageUrl = _uploadedImageUrl;
      if (imageUrl == null &&
          (_selectedImageFile != null || _selectedPlatformFile != null)) {
        imageUrl = await _uploadImageToBunny();
      }

      if (!mounted) return;

      final options = _optionControllers.map((c) => c.text).toList();

      await InjectionContainer.addQuestionUseCase(
        testId: widget.test.id,
        questionText: _questionTextController.text,
        imageUrl: imageUrl,
        options: options,
        correctAnswerIndex: _correctAnswerIndex,
      );

      if (!mounted) return;

      _questionTextController.clear();
      for (var controller in _optionControllers) {
        controller.clear();
      }
      _correctAnswerIndex = 0;
      _removeImage();

      _loadQuestionsWrapper();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة السؤال بنجاح'),
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
        String errorMessage = 'حدث خطأ أثناء إضافة السؤال';
        final errorString = e.toString();

        if (errorString.contains('انتهت مهلة')) {
          errorMessage = 'انتهت مهلة العملية. يرجى المحاولة مرة أخرى.';
        } else if (errorString.contains('الاتصال')) {
          errorMessage =
              'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';
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

  Future<void> _deleteQuestion(String questionId) async {
    try {
      await InjectionContainer.testRepo.deleteQuestion(questionId);
      _loadQuestionsWrapper();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف السؤال بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف السؤال: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AdminAppBar(title: 'إدارة أسئلة: ${widget.test.title}'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نموذج إضافة سؤال جديد
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
                      'إضافة سؤال جديد',
                      style: AppStyles.subHeadingStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // نص السؤال
                    CustomTextField(
                      controller: _questionTextController,
                      hintText: 'نص السؤال (اختياري إذا كانت هناك صورة)',
                      icon: Icons.help_outline,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      maxLines: 3,
                      // لا نحتاج validator هنا لأننا نتحقق في _addQuestion
                    ),
                    const SizedBox(height: 16),
                    // رفع صورة
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.image, color: AppColors.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'صورة السؤال (اختياري)',
                                style: AppStyles.subHeadingStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_uploadedImageUrl != null ||
                              _selectedImageFile != null ||
                              _selectedPlatformFile != null) ...[
                            // عرض الصورة المختارة
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb && _selectedPlatformFile != null
                                    ? Image.memory(
                                        _selectedPlatformFile!.bytes!,
                                        fit: BoxFit.contain,
                                      )
                                    : _selectedImageFile != null
                                    ? Image.file(
                                        _selectedImageFile!,
                                        fit: BoxFit.contain,
                                      )
                                    : _uploadedImageUrl != null
                                    ? Image.network(
                                        _uploadedImageUrl!,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                ),
                                              );
                                            },
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _removeImage,
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('إزالة الصورة'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.errorColor,
                                      side: BorderSide(
                                        color: AppColors.errorColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            // زر اختيار الصورة
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isUploadingImage
                                    ? null
                                    : _pickImage,
                                icon: _isUploadingImage
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.upload_file),
                                label: Text(
                                  _isUploadingImage
                                      ? 'جاري الرفع...'
                                      : 'اختيار صورة',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryColor,
                                  side: BorderSide(
                                    color: AppColors.primaryColor,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'الخيارات (اختيار متعدد)',
                      style: AppStyles.subHeadingStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      _optionControllers.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _optionControllers[index],
                                hintText: 'الخيار ${index + 1}',
                                icon: Icons.radio_button_unchecked,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال الخيار';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Radio<int>(
                              value: index,
                              groupValue: _correctAnswerIndex,
                              onChanged: (value) {
                                if (!mounted) return;
                                setState(() {
                                  _correctAnswerIndex = value!;
                                });
                              },
                              activeColor: AppColors.examColor,
                            ),
                            if (_optionControllers.length > 2)
                              IconButton(
                                onPressed: () => _removeOption(index),
                                icon: const Icon(Icons.delete_outline),
                                color: AppColors.errorColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'الإجابة الصحيحة: الخيار ${_correctAnswerIndex + 1}',
                          style: AppStyles.textSecondaryStyle.copyWith(
                            color: AppColors.examColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _addOption,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة خيار'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.examColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.secondaryColor,
                                  ),
                                ),
                              )
                            : Text(
                                'إضافة السؤال',
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
            // قائمة الأسئلة المضافة
            FutureBuilder<List<QuestionModel>>(
              future: _questionsFuture ?? Future.value(<QuestionModel>[]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
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
                            'حدث خطأ في جلب الأسئلة',
                            style: AppStyles.textSecondaryStyle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final questions = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الأسئلة المضافة (${questions.length})',
                      style: AppStyles.subHeadingStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    questions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.help_outline,
                                    size: 60,
                                    color: AppColors.textLight,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد أسئلة مضافة',
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
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              final question = questions[index];
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'السؤال ${index + 1}',
                                                style: AppStyles
                                                    .textSecondaryStyle
                                                    .copyWith(
                                                      fontSize: 12,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              if (question
                                                  .questionText
                                                  .isNotEmpty)
                                                Text(
                                                  question.questionText,
                                                  style: AppStyles
                                                      .subHeadingStyle
                                                      .copyWith(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              if (question.imageUrl != null &&
                                                  question
                                                      .imageUrl!
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 12),
                                                Container(
                                                  height: 200,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          AppColors.borderColor,
                                                    ),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    child: Image.network(
                                                      question.imageUrl!,
                                                      fit: BoxFit.contain,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return const Center(
                                                              child: Icon(
                                                                Icons
                                                                    .broken_image,
                                                                size: 50,
                                                              ),
                                                            );
                                                          },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 12),
                                              ...List.generate(
                                                question.options.length,
                                                (optionIndex) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 8,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        optionIndex ==
                                                                question
                                                                    .correctAnswerIndex
                                                            ? Icons.check_circle
                                                            : Icons
                                                                  .radio_button_unchecked,
                                                        size: 20,
                                                        color:
                                                            optionIndex ==
                                                                question
                                                                    .correctAnswerIndex
                                                            ? AppColors
                                                                  .successColor
                                                            : AppColors
                                                                  .textSecondary,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          question
                                                              .options[optionIndex],
                                                          style: AppStyles.textPrimaryStyle.copyWith(
                                                            fontWeight:
                                                                optionIndex ==
                                                                    question
                                                                        .correctAnswerIndex
                                                                ? FontWeight
                                                                      .bold
                                                                : FontWeight
                                                                      .normal,
                                                            color:
                                                                optionIndex ==
                                                                    question
                                                                        .correctAnswerIndex
                                                                ? AppColors
                                                                      .successColor
                                                                : AppColors
                                                                      .textPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _deleteQuestion(question.id),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          color: AppColors.errorColor,
                                        ),
                                      ],
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
        ),
      ),
    );
  }
}
