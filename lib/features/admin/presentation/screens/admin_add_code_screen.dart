import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/image_storage_service.dart';
import '../../../../../core/services/video_progress_service.dart';
import '../../data/models/code_model.dart';
import '../widgets/admin_app_bar.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';

class AdminAddCodeScreen extends StatefulWidget {
  const AdminAddCodeScreen({super.key});

  @override
  State<AdminAddCodeScreen> createState() => _AdminAddCodeScreenState();
}

class _AdminAddCodeScreenState extends State<AdminAddCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subscriptionDaysController = TextEditingController();
  bool _isLoading = false;
  Future<List<CodeModel>>? _codesFuture; // لحفظ Future الأكواد
  int _refreshKey = 0; // لإعادة بناء FutureBuilder
  Timer? _expirationCheckTimer; // Timer للتحقق من الأكواد المنتهية

  @override
  void initState() {
    super.initState();
    _loadCodes();
    // بدء التحقق الدوري من الأكواد المنتهية كل دقيقة
    _startExpirationCheck();
  }

  /// بدء التحقق الدوري من الأكواد المنتهية
  void _startExpirationCheck() {
    _expirationCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndDeleteExpiredCodes();
    });
  }

  /// التحقق من الأكواد المنتهية وحذفها تلقائياً
  Future<void> _checkAndDeleteExpiredCodes() async {
    try {
      final codes = await InjectionContainer.adminRepo.getCodes();
      final now = DateTime.now();
      
      for (final code in codes) {
        if (code.subscriptionEndDate != null && 
            now.isAfter(code.subscriptionEndDate!)) {
          // حذف جميع بيانات الكود (الصورة، حالات المشاهدة)
          try {
            await _deleteCodeData(code.code);
            
            // حذف الكود من Firestore
            await InjectionContainer.adminRepo.deleteCode(code.id);
            
            if (mounted) {
              debugPrint('تم حذف الكود المنتهي وجميع بياناته: ${code.code}');
            }
          } catch (e) {
            debugPrint('خطأ في حذف الكود المنتهي ${code.code}: $e');
          }
        }
      }
      
      // إعادة تحميل الأكواد بعد الحذف
      if (mounted) {
        _loadCodes();
      }
    } catch (e) {
      debugPrint('خطأ في التحقق من الأكواد المنتهية: $e');
    }
  }

  @override
  void dispose() {
    _expirationCheckTimer?.cancel();
    _codeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _subscriptionDaysController.dispose();
    super.dispose();
  }

  void _loadCodes() {
    // إنشاء Future جديد في كل مرة لإجبار FutureBuilder على إعادة البناء
    final newFuture = InjectionContainer.adminRepo.getCodes().catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل جلب الأكواد: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
      return <CodeModel>[];
    });

    setState(() {
      _refreshKey++; // تحديث key لإعادة بناء FutureBuilder
      _codesFuture = newFuture;
    });
  }

  Future<void> _addCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // تحويل عدد الأيام إلى int
      int? subscriptionDays;
      if (_subscriptionDaysController.text.isNotEmpty) {
        subscriptionDays = int.tryParse(_subscriptionDaysController.text);
        if (subscriptionDays == null || subscriptionDays <= 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('عدد الأيام يجب أن يكون رقماً صحيحاً أكبر من صفر'),
                backgroundColor: AppColors.errorColor,
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      await InjectionContainer.addCodeUseCase(
        code: _codeController.text,
        name: _nameController.text,
        phone: _phoneController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        subscriptionDays: subscriptionDays,
      );

      if (mounted) {
        _codeController.clear();
        _nameController.clear();
        _phoneController.clear();
        _descriptionController.clear();
        _subscriptionDaysController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الكود بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );

        // انتظار قصير ثم إعادة تحميل للتأكد من تحديث Firestore
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _loadCodes();
          }
        });
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// حذف جميع بيانات الكود (الكود، الصورة، حالات المشاهدة)
  Future<void> _deleteCodeData(String code) async {
    try {
      // حذف الصورة المحلية
      await ImageStorageService.deleteProfileImage(code: code);
      debugPrint('تم حذف الصورة للكود: $code');

      // حذف حالات مشاهدة الفيديوهات
      await VideoProgressService.clearVideoProgressForCode(code: code);
      debugPrint('تم حذف حالات المشاهدة للكود: $code');
    } catch (e) {
      debugPrint('خطأ في حذف بيانات الكود $code: $e');
    }
  }

  Future<void> _deleteCode(String codeId) async {
    try {
      // جلب الكود قبل حذفه للحصول على code string
      final codes = await InjectionContainer.adminRepo.getCodes();
      final codeToDelete = codes.firstWhere(
        (code) => code.id == codeId,
        orElse: () => throw Exception('الكود غير موجود'),
      );
      final codeString = codeToDelete.code;

      // حذف جميع بيانات الكود (الصورة، حالات المشاهدة)
      await _deleteCodeData(codeString);

      // حذف الكود من Firestore
      await InjectionContainer.adminRepo.deleteCode(codeId);

      // إعادة تحميل قائمة الأكواد
      _loadCodes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الكود وجميع بياناته بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الكود: ${e.toString()}'),
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
      appBar: AdminAppBar(title: 'إضافة الأكواد'),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadCodes();
          // انتظار قليل للتأكد من اكتمال التحميل
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // نموذج إضافة كود جديد
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
                        'إضافة كود جديد',
                        style: AppStyles.subHeadingStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // حقل الكود
                      CustomTextField(
                        controller: _codeController,
                        hintText: 'أدخل الكود',
                        icon: Icons.vpn_key,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الكود';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // حقل الاسم
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'أدخل اسم الطالب',
                        icon: Icons.person_outline,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم الطالب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // حقل رقم الهاتف
                      CustomTextField(
                        controller: _phoneController,
                        hintText: 'أدخل رقم الهاتف',
                        icon: Icons.phone_outlined,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم الهاتف';
                          }
                          final cleanPhone = value.replaceAll(
                            RegExp(r'[^\d]'),
                            '',
                          );
                          if (cleanPhone.length < 10 ||
                              cleanPhone.length > 15) {
                            return 'رقم الهاتف يجب أن يحتوي على 10-15 رقم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // حقل الوصف (اختياري)
                      CustomTextField(
                        controller: _descriptionController,
                        hintText: 'الوصف (اختياري)',
                        icon: Icons.description,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // حقل عدد الأيام
                      CustomTextField(
                        controller: _subscriptionDaysController,
                        hintText: 'عدد أيام الاشتراك (اختياري)',
                        icon: Icons.calendar_today,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final days = int.tryParse(value);
                            if (days == null || days <= 0) {
                              return 'عدد الأيام يجب أن يكون رقماً صحيحاً أكبر من صفر';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // زر الإضافة
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
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
                                  'إضافة الكود',
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
              // قائمة الأكواد المضافة
              FutureBuilder<List<CodeModel>>(
                key: ValueKey(_refreshKey),
                future: _codesFuture ?? Future.value(<CodeModel>[]),
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
                              'حدث خطأ في جلب الأكواد',
                              style: AppStyles.textSecondaryStyle.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final codes = snapshot.data ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الأكواد المضافة (${codes.length})',
                        style: AppStyles.subHeadingStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      codes.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 60,
                                      color: AppColors.textLight,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'لا توجد أكواد مضافة',
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
                              itemCount: codes.length,
                              itemBuilder: (context, index) {
                                final code = codes[index];
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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              code.code,
                                              style: AppStyles.subHeadingStyle
                                                  .copyWith(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'الاسم: ${code.name}',
                                              style: AppStyles
                                                  .textSecondaryStyle
                                                  .copyWith(fontSize: 14),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'الهاتف: ${code.phone}',
                                              style: AppStyles
                                                  .textSecondaryStyle
                                                  .copyWith(fontSize: 14),
                                            ),
                                            if (code.subscriptionEndDate != null) ...[
                                              const SizedBox(height: 4),
                                              _SubscriptionCountdown(
                                                endDate: code.subscriptionEndDate!,
                                                codeId: code.id,
                                                onExpired: () {
                                                  // إعادة تحميل الأكواد عند انتهاء أحدها (بعد انتهاء بناء الـ widget tree)
                                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    if (mounted) {
                                                      _loadCodes();
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                            if (code.description != null &&
                                                code
                                                    .description!
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                code.description!,
                                                style: AppStyles
                                                    .textSecondaryStyle,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteCode(code.id),
                                        icon: const Icon(Icons.delete_outline),
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
          ),
        ),
      ),
    );
  }
}

/// Widget لعرض عداد تنازلي للأيام المتبقية في الاشتراك
class _SubscriptionCountdown extends StatefulWidget {
  final DateTime endDate;
  final String codeId;
  final VoidCallback? onExpired;

  const _SubscriptionCountdown({
    required this.endDate,
    required this.codeId,
    this.onExpired,
  });

  @override
  State<_SubscriptionCountdown> createState() => _SubscriptionCountdownState();
}

class _SubscriptionCountdownState extends State<_SubscriptionCountdown> {
  Timer? _timer;
  int _daysRemaining = 0;

  @override
  void initState() {
    super.initState();
    // تحديث العداد بعد انتهاء بناء الـ widget tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateCountdown();
      }
    });
    // تحديث العداد كل دقيقة
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final difference = widget.endDate.difference(now);
    final daysRemaining = difference.inDays;

    if (mounted) {
      final wasExpired = _daysRemaining > 0 && daysRemaining <= 0;
      
      setState(() {
        _daysRemaining = daysRemaining;
      });

      // إذا انتهى الاشتراك، استدعاء callback بعد انتهاء بناء الـ widget tree
      if (wasExpired && widget.onExpired != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.onExpired != null) {
            widget.onExpired!();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_daysRemaining <= 0) {
      return Text(
        'انتهى الاشتراك',
        style: AppStyles.textSecondaryStyle.copyWith(
          fontSize: 12,
          color: AppColors.errorColor,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return Text(
        'الأيام المتبقية: $_daysRemaining يوم',
        style: AppStyles.textSecondaryStyle.copyWith(
          fontSize: 12,
          color: _daysRemaining <= 7 
              ? AppColors.errorColor 
              : AppColors.successColor,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}
