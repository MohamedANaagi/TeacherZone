# دليل نشر التطبيق على Firebase Hosting

## الإعدادات الحالية

- **Project ID**: `teacherzone-eb4fb`
- **Site ID**: `teacherzone-eb4fb-35b30`

## خطوات النشر

### 1. بناء المشروع للويب

```bash
flutter build web --release
```

### 2. النشر على Firebase

```bash
firebase deploy --only hosting
```

### 3. الوصول للتطبيق

بعد النشر، سيكون التطبيق متاحاً على:
- `https://teacherzone-eb4fb-35b30.web.app`
- `https://teacherzone-eb4fb-35b30.firebaseapp.com`

## المتطلبات

1. **تثبيت Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **تسجيل الدخول**:
   ```bash
   firebase login
   ```

3. **التحقق من المشروع**:
   ```bash
   firebase projects:list
   ```

## تحديث التطبيق

عند إجراء تغييرات:

```bash
flutter build web --release
firebase deploy --only hosting
```

## ملاحظات

- تأكد من أن Firebase Web App مضاف في Firebase Console
- تأكد من أن قواعد Firestore و Storage تسمح بالوصول من الويب

