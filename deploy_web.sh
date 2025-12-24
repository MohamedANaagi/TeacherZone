#!/bin/bash

# Script لبناء ونشر الويب على Firebase Hosting
# الاستخدام: ./deploy_web.sh

set -e  # إيقاف التنفيذ عند حدوث خطأ

echo "🚀 بدء عملية البناء والنشر..."
echo ""

# الخطوة 1: بناء المشروع للويب
echo "📦 جاري بناء المشروع للويب (Release)..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "❌ فشل بناء المشروع!"
    exit 1
fi

echo "✅ تم بناء المشروع بنجاح!"
echo ""

# الخطوة 2: نشر على Firebase Hosting
echo "🌐 جاري النشر على Firebase Hosting..."
firebase deploy --only hosting

if [ $? -ne 0 ]; then
    echo "❌ فشل النشر على Firebase!"
    exit 1
fi

echo ""
echo "✅ تم النشر بنجاح! 🎉"
echo "🌍 الموقع متاح الآن على: https://teacherzone-eb4fb-35b30.web.app"

