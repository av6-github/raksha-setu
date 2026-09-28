// lib/core/localization/app_localizations.dart
// Multilingual support foundation for 8 official languages of CAPF jawans:
// English, Hindi, Punjabi, Bengali, Assamese, Tamil, Telugu, and Marathi.

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_title': 'RakshaSetu',
      'tagline': 'Morale Wins Wars',
      'login': 'Sign In',
      'email': 'Service Email / ID',
      'password': 'Password',
      'biweekly_checkin': 'Biweekly Wellness Check-In',
      'offline_mode': 'Offline Mode Active',
      'offline_sync_pending': 'Pending sync items',
      'crisis_support': '24x7 Crisis Support',
      'welfare_firewall': 'Protected by Welfare-HR Firewall',
      'privacy_commitment': 'Consent-Based & Confidential',
    },
    'hi': {
      'app_title': 'रक्षासेतु (RakshaSetu)',
      'tagline': 'मनोबल से विजय',
      'login': 'साइन इन करें',
      'email': 'सेवा ईमेल / पहचान पत्र',
      'password': 'पासवर्ड',
      'biweekly_checkin': 'पाक्षिक स्वास्थ्य जांच (Check-In)',
      'offline_mode': 'ऑफलाइन मोड सक्रिय',
      'offline_sync_pending': 'लंबित सिंक डेटा',
      'crisis_support': '24x7 आपातकालीन सहायता',
      'welfare_firewall': 'कल्याण-एचआर फ़ायरवॉल द्वारा सुरक्षित',
      'privacy_commitment': 'सहमति-आधारित एवं पूर्णतः गोपनीय',
    },
    'pa': {
      'app_title': 'ਰਕਸ਼ਾਸੇਤੂ (RakshaSetu)',
      'tagline': 'ਮਨੋਬਲ ਨਾਲ ਜਿੱਤ',
      'login': 'ਸਾਈਨ ਇਨ ਕਰੋ',
      'email': 'ਸੇਵਾ ਈਮੇਲ / ਆਈਡੀ',
      'password': 'ਪਾਸਵਰਡ',
      'biweekly_checkin': 'ਪੰਦਰਵਾੜਾ ਸਿਹਤ ਜਾਂਚ (Check-In)',
      'offline_mode': 'ਆਫਲਾਈਨ ਮੋਡ ਸਰਗਰਮ',
      'offline_sync_pending': 'ਬਾਕੀ ਸਿੰਕ ਡੇਟਾ',
      'crisis_support': '24x7 ਸੰਕਟ ਸਹਾਇਤਾ',
      'welfare_firewall': 'ਭਲਾਈ-ਐਚਆਰ ਫਾਇਰਵਾਲ ਦੁਆਰਾ ਸੁਰੱਖਿਅਤ',
      'privacy_commitment': 'ਸਹਿਮਤੀ-ਅਧਾਰਤ ਅਤੇ ਗੁਪਤ',
    },
    'bn': {
      'app_title': 'রক্ষা সেতু (RakshaSetu)',
      'tagline': 'মনোবলে বিজয়',
      'login': 'সাইন ইন করুন',
      'email': 'পরিষেবা ইমেল / আইডি',
      'password': 'পাসওয়ার্ড',
      'biweekly_checkin': 'পাক্ষিক স্বাস্থ্য পরীক্ষা (Check-In)',
      'offline_mode': 'অফলাইন মোড সক্রিয়',
      'offline_sync_pending': 'অমীমাংসিত সিঙ্ক আইটেম',
      'crisis_support': '২৪x৭ সংকট সহায়তা',
      'welfare_firewall': 'ওয়েলফেয়ার-এইচআর ফায়ারওয়াল দ্বারা সুরক্ষিত',
      'privacy_commitment': 'সম্মতি-ভিত্তিক ও গোপনীয়',
    },
    'as': {
      'app_title': 'ৰক্ষা সেতু (RakshaSetu)',
      'tagline': 'মনোবলেৰে বিজয়',
      'login': 'ছাইন ইন কৰক',
      'email': 'সেৱা ইমেইল / আই ডি',
      'password': 'পাছৱৰ্ড',
      'biweekly_checkin': 'পষেকীয়া স্বাস্থ্য পৰীক্ষা (Check-In)',
      'offline_mode': 'অফলাইন মোড সক্ৰিয়',
      'offline_sync_pending': 'বাকী থকা চিন্ক আইটেম',
      'crisis_support': '২৪x৭ সংকটকালীন সহায়',
      'welfare_firewall': 'কল্যাণ-এইচআৰ ফায়াৰৱালেৰে সুৰক্ষিত',
      'privacy_commitment': 'সন্মতি-ভিত্তিক আৰু গোপনীয়',
    },
    'ta': {
      'app_title': 'ரக்ஷா சேது (RakshaSetu)',
      'tagline': 'மன உறுதியே வெற்றி தரும்',
      'login': 'உள்நுழைக',
      'email': 'பணி மின்னஞ்சல் / அடையாள எண்',
      'password': 'கடவுச்சொல்',
      'biweekly_checkin': 'இருவார நலச் சரிபார்ப்பு (Check-In)',
      'offline_mode': 'ஆஃப்லைன் முறை செயலில் உள்ளது',
      'offline_sync_pending': 'நிலுவையில் உள்ள ஒத்திசைவு உருப்படிகள்',
      'crisis_support': '24x7 அவசர கால ஆதரவு',
      'welfare_firewall': 'நலன்புரி-HR ஃபயர்வால் மூலம் பாதுகாக்கப்பட்டது',
      'privacy_commitment': 'ஒப்புதல் அடிப்படையிலானது & ரகசியமானது',
    },
    'te': {
      'app_title': 'రక్షా సేతు (RakshaSetu)',
      'tagline': 'మనోబలంతో విజయం',
      'login': 'సైన్ ఇన్ చేయండి',
      'email': 'సర్వీస్ ఈమెయిల్ / ఐడీ',
      'password': 'పాస్‌వర్డ్',
      'biweekly_checkin': 'రెండు వారాల ఆరోగ్య సమీక్ష (Check-In)',
      'offline_mode': 'ఆఫ్‌లైన్ మోడ్ సక్రియం',
      'offline_sync_pending': 'పెండింగ్ సింక్ అంశాలు',
      'crisis_support': '24x7 అత్యవసర మద్దతు',
      'welfare_firewall': 'సంక్షేమ-HR ఫైర్‌వాల్ రక్షణ',
      'privacy_commitment': 'సమ్మతి ఆధారితం మరియు పూర్తి గోప్యత',
    },
    'mr': {
      'app_title': 'रक्षासेतू (RakshaSetu)',
      'tagline': 'मनोधैर्याने विजय',
      'login': 'साइन इन करा',
      'email': 'सेवा ईमेल / आयडी',
      'password': 'पासवर्ड',
      'biweekly_checkin': 'पाक्षिक आरोग्य तपासणी (Check-In)',
      'offline_mode': 'ऑफलाइन मोड सक्रिय',
      'offline_sync_pending': 'प्रलंबित सिंक डेटा',
      'crisis_support': '२४x७ संकट निवारण सहाय्य',
      'welfare_firewall': 'कल्याण-एचआर फायरवॉलद्वारे संरक्षित',
      'privacy_commitment': 'संमती-आधारित आणि अत्यंत गोपनीय',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  static const supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('pa'),
    Locale('bn'),
    Locale('as'),
    Locale('ta'),
    Locale('te'),
    Locale('mr'),
  ];
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
        'en',
        'hi',
        'pa',
        'bn',
        'as',
        'ta',
        'te',
        'mr',
      ].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
