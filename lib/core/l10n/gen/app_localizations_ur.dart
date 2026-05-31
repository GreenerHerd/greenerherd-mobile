// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'GreenerHerd';

  @override
  String get tabHome => 'ہوم';

  @override
  String get tabAnimals => 'جانور';

  @override
  String get tabTasks => 'کام';

  @override
  String get tabFinance => 'مالیات';

  @override
  String get tabReports => 'رپورٹس';

  @override
  String get tabOverview => 'جائزہ';

  @override
  String get tabNutrition => 'غذائیت';

  @override
  String get tabBreeding => 'نسل بڑھانا';

  @override
  String get tabMilking => 'دودھ';

  @override
  String get tabHealth => 'صحت';

  @override
  String get tabWeight => 'وزن';

  @override
  String get tabMedia => 'میڈیا';

  @override
  String goodMorning(String name) {
    return 'صبح بخیر، $name';
  }

  @override
  String get animals => 'جانور';

  @override
  String get addNew => 'نیا شامل کریں';

  @override
  String get profile => 'پروفائل';

  @override
  String get groups => 'گروپس';

  @override
  String get inventory => 'انوینٹری';

  @override
  String get help => 'مدد';

  @override
  String get reports => 'رپورٹس';

  @override
  String get settings => 'ترتیبات';

  @override
  String get signIn => 'سائن ان';

  @override
  String get signOut => 'سائن آؤٹ';

  @override
  String get language => 'زبان';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get onboardingFarmTitle => 'فارم سیٹ اپ';

  @override
  String get onboardingSpeciesTitle => 'آپ کے مویشی';

  @override
  String get onboardingAnimalsTitle => 'جانور شامل کریں';

  @override
  String get skipForNow => 'ابھی چھوڑیں';

  @override
  String get save => 'محفوظ';

  @override
  String get cancel => 'منسوخ';

  @override
  String get delete => 'حذف';

  @override
  String get pregnant => 'حاملہ';

  @override
  String get lactating => 'دودھ والی';

  @override
  String get readyToBreed => 'نسل بڑھانے کے لیے تیار';

  @override
  String get sick => 'بیمار';

  @override
  String get cullFlagged => 'ذبح کے لیے نشان زد';

  @override
  String get allSpecies => 'تمام اقسام';

  @override
  String get cattle => 'گائے';

  @override
  String get goats => 'بکریاں';

  @override
  String get sheep => 'بھیڑیں';

  @override
  String get tasksToday => 'آج کے کام';

  @override
  String get overdue => 'تاخیر';

  @override
  String get today => 'آج';

  @override
  String get thisWeek => 'اس ہفتے';

  @override
  String get finance => 'مالیات';

  @override
  String get income => 'آمدنی';

  @override
  String get expense => 'خرچ';

  @override
  String get net => 'خالص';

  @override
  String get livestockValue => 'مویشیوں کی قیمت';

  @override
  String get subscription => 'سبسکرپشن';

  @override
  String get buyAnimals => 'جانور خریدیں';

  @override
  String get sellAnimals => 'جانور بیچیں';

  @override
  String get buyAnimalsInventorySubtitle =>
      'Record a purchase and add animals to the herd';

  @override
  String get sellAnimalsInventorySubtitle =>
      'Sell animals and update herd inventory';

  @override
  String get purchaser => 'Purchaser';

  @override
  String get pricePaidSar => 'Price paid (SAR)';

  @override
  String get dateOfSale => 'Date of sale';

  @override
  String get totalWeightKgOptional => 'Total weight (kg, optional)';

  @override
  String get salePurposeOptional => 'Purpose of sale (optional)';

  @override
  String get searchFarmTags => 'Search tags on the farm';

  @override
  String get animalsToSell => 'Animals to sell';

  @override
  String get confirmSale => 'Confirm sale';

  @override
  String get saleRecorded => 'Sale recorded';

  @override
  String get addAtLeastOneAnimal => 'Add at least one animal to sell';

  @override
  String get enterPurchaserAndPrice => 'Enter purchaser and price paid';

  @override
  String get noAnimalsMatchTag => 'No active animals match this tag';

  @override
  String get animalAlreadyInSaleList => 'Already added to this sale';

  @override
  String get removeFromSaleList => 'Remove';

  @override
  String get addToSale => 'Add';

  @override
  String get inventoryBurgerSubtitle => 'Feed, medical & livestock';

  @override
  String get people => 'لوگ';

  @override
  String get marketplace => 'مارکیٹ';

  @override
  String get fixTheGap => 'خلا پُر کریں';

  @override
  String get alertsAndTasks => 'الرٹس اور کام';

  @override
  String get animalNotFound => 'جانور نہیں ملا';

  @override
  String get groupNotFound => 'گروپ نہیں ملا';

  @override
  String get methaneEmissions => 'میتھین اخراج';

  @override
  String get methaneRegionMiddleEast => 'مشرق وسطی (خلیجی)';

  @override
  String get groupAverage => 'گروپ اوسط';

  @override
  String get groupTotal => 'Group total';

  @override
  String get emissionsTotal => 'Emissions total';

  @override
  String methaneCo2eGroupTotal(String co2e, int headCount) {
    return '$co2e kg CO₂e · $headCount head';
  }

  @override
  String get methaneByAnimal => 'جانور کے حساب سے (CH₄ / دن)';

  @override
  String methaneMoreAnimals(int count) {
    return '+ $count مزید جانور';
  }

  @override
  String methaneCh4Grams(String grams) {
    return '$grams g CH₄';
  }

  @override
  String methaneCo2eSummary(String co2e, String weight) {
    return '$co2e kg CO₂e · $weight kg اوسط وزن';
  }

  @override
  String methaneGramsShort(String grams) {
    return '$grams g';
  }

  @override
  String methaneAgeMonths(int months) {
    return '$months ماہ';
  }

  @override
  String lactationNumber(int number) {
    return 'دودھ کی مدت $number';
  }

  @override
  String lactationDayOf305(String stage, int day) {
    return '$stage · دن $day از 305';
  }

  @override
  String lactationCalvingExpected(String date, String litres) {
    return 'بچھڑا $date · آج ~$litres L متوقع';
  }

  @override
  String get lactationCurveTitle => 'دودھ کا منحنی (دودھ بمقابلہ دن)';

  @override
  String get lactationCurveLegend =>
      'ٹھوس لائن = ریکارڈ شدہ · ٹیڑھی = متوقع (نسل اوسط)';

  @override
  String get lactationChartNeedsData =>
      'منحنی دکھانے کے لیے کم از کم دو دودھ ریکارڈ کریں۔';

  @override
  String chartDayLitres(int day, String litres) {
    return 'دن $day\n$litres L';
  }

  @override
  String get milkingTodayVolume => 'آج کا حجم';

  @override
  String get notRecorded => 'ریکارڈ نہیں';

  @override
  String litresValue(String litres) {
    return '$litres L';
  }

  @override
  String get recordMilk => 'دودھ ریکارڈ کریں';

  @override
  String get recordBulkMilkSale => 'بلک دودھ فروخت (آمدنی)';

  @override
  String get withdrawalMilkBlocked =>
      'واپسی کی مدت — انسانی استعمال کے لیے دودھ فروخت یا ریکارڈ نہیں ہو سکتا۔';

  @override
  String get todayVsRequirement => 'آج بمقابلہ ضرورت';

  @override
  String get milkingKpis => 'دودھ کے اشاریے';

  @override
  String get topProducers => 'بہترین پیداوار';

  @override
  String get todaysFeed => 'آج کا چارہ';

  @override
  String get energyGapDetected => 'توانائی کی کمی';

  @override
  String get lactationStageFresh => 'ابتدائی دودھ';

  @override
  String get lactationStagePeak => 'دودھ کی چوٹی';

  @override
  String get lactationStageMid => 'درمیانی دودھ';

  @override
  String get lactationStageLate => 'آخری دودھ';

  @override
  String get lactationStageDry => 'خشک مدت';

  @override
  String get species => 'قسم';

  @override
  String get sex => 'جنس';

  @override
  String get breed => 'نسل';

  @override
  String get group => 'گروپ';

  @override
  String get purpose => 'مقصد';

  @override
  String get groupPurpose => 'Group purpose';

  @override
  String get animalPurpose => 'Animal purpose';

  @override
  String get female => 'مادہ';

  @override
  String get male => 'نر';

  @override
  String get loadingBreeds => 'نسلیں لوڈ ہو رہی ہیں…';

  @override
  String get saveAnimal => 'جانور محفوظ کریں';

  @override
  String get saveGroup => 'گروپ محفوظ کریں';

  @override
  String get newAnimal => 'نیا جانور';

  @override
  String get newGroup => 'نیا گروپ';

  @override
  String get onboardNewAnimal => 'Onboard new animal';

  @override
  String get onboardNewGroup => 'Onboard new group';

  @override
  String get groupWizardDetails => 'Group details';

  @override
  String get groupWizardHerd => 'Herd profile';

  @override
  String get groupWizardAnimals => 'Individual animals';

  @override
  String get groupWizardSummary => 'Group summary';

  @override
  String get addAMeal => 'Add a meal';

  @override
  String get addAnotherGroup => 'Add another group';

  @override
  String get saveMeal => 'Save meal';

  @override
  String get searchMeals => 'Search meals';

  @override
  String get mealAmountKg => 'Amount (kg)';

  @override
  String get groupCreatedMessage =>
      'Your group is ready. Add a meal now or skip and set feeding up later.';

  @override
  String get purchaseWizardDetails => 'Purchase details';

  @override
  String get purchaseWizardLivestock => 'Livestock profile';

  @override
  String get purchaseWizardAnimals => 'Individual animals';

  @override
  String get finishPurchase => 'Complete purchase';

  @override
  String get purchaseRecorded => 'Purchase recorded';

  @override
  String get enterSupplierAndPrice =>
      'Enter where animals were bought from and purchase price';

  @override
  String get numberOfAnimalsPurchased => 'Number of animals purchased';

  @override
  String get headCount => 'Number in group';

  @override
  String get ageRange => 'Age range';

  @override
  String get vaccinated => 'Vaccinated';

  @override
  String get vaccinationEvent => 'Vaccination event';

  @override
  String get createVaccinationEvent => 'Create vaccination event';

  @override
  String get selectVaccinationEvent => 'Select vaccination event';

  @override
  String get noVaccinationEvents => 'No vaccination events on file';

  @override
  String get noActiveVaccinationEvents =>
      'No active vaccination events in the last 48 hours';

  @override
  String animalInGroup(int index) {
    return 'Animal $index';
  }

  @override
  String get markPregnant => 'حاملہ نشان لگائیں';

  @override
  String get monthsPregnant => 'Months pregnant';

  @override
  String get weaned => 'Weaned';

  @override
  String get markSick => 'Sick';

  @override
  String get sickDescription => 'Illness description';

  @override
  String get markCull => 'Cull';

  @override
  String get finishGroup => 'Complete group';

  @override
  String wizardStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get continueButton => 'جاری رکھیں';

  @override
  String get enterAnimalsIndividually => 'جانور الگ الگ درج کریں';

  @override
  String get tag => 'ٹیگ';

  @override
  String get weight => 'وزن';

  @override
  String get dateOfBirth => 'تاریخ پیدائش';

  @override
  String get tagNumber => 'ٹیگ نمبر';

  @override
  String get weightKg => 'وزن (کلو)';

  @override
  String get weightHint => 'مثال: 412';

  @override
  String get birthDateOptional => 'تاریخ پیدائش (اختیاری)';

  @override
  String bornOnDate(int day, int month, int year) {
    return 'پیدائش $day/$month/$year';
  }

  @override
  String get groupName => 'گروپ کا نام';

  @override
  String get descriptionOptional => 'تفصیل (اختیاری)';

  @override
  String get ageNew => 'نیا';

  @override
  String get continueWithGoogle => 'Google کے ساتھ جاری رکھیں';

  @override
  String get continueWithApple => 'Apple کے ساتھ جاری رکھیں';

  @override
  String get continueWithFacebook => 'Facebook کے ساتھ جاری رکھیں';

  @override
  String get newFarmSetup => 'نیا فارم سیٹ اپ';

  @override
  String get welcomeTo => 'خوش آمدید';

  @override
  String get welcomeBrand => 'Greener Herd';

  @override
  String get gaveBirth => 'بچہ پیدا ہوا';

  @override
  String get recordBirthSubtitle => 'زندہ پیدائش یا مردہ پیدائش درج کریں';

  @override
  String get miscarriage => 'اسقاط حمل';

  @override
  String get miscarriageSubtitle =>
      'حمل ختم کریں اور فالو اپ کے لیے نشان لگائیں';

  @override
  String get flagForCull => 'ذبح کے لیے نشان';

  @override
  String get clearCullFlag => 'ذبح کا نشان ہٹائیں';

  @override
  String get markSold => 'فروخت درج کریں';

  @override
  String get recordBirth => 'پیدائش درج کریں';

  @override
  String get bornAlive => 'زندہ پیدا';

  @override
  String get bornAliveSubtitle => 'حمل ختم؛ دودھ کا ٹیگ صرف اگر نہ ہو';

  @override
  String get stillborn => 'مردہ پیدائش';

  @override
  String get stillbornSubtitle => 'حمل ختم؛ مردہ پیدائش درج';

  @override
  String get saveBirthRecord => 'پیدائش کا ریکارڈ محفوظ کریں';

  @override
  String get pregnancyOutcome => 'حمل کا نتیجہ';

  @override
  String get howDidPregnancyEnd => 'حمل کیسے ختم ہوا؟';

  @override
  String birthRecordedFor(String tag) {
    return 'پیدائش #$tag کے لیے درج';
  }

  @override
  String stillbirthRecordedFor(String tag) {
    return 'مردہ پیدائش #$tag کے لیے درج';
  }

  @override
  String get recordMiscarriage => 'اسقاط حمل درج کریں';

  @override
  String miscarriageRecordedFor(String tag) {
    return 'اسقاط حمل #$tag کے لیے درج';
  }

  @override
  String get miscarriageConfirmBody =>
      'یہ حاملہ حیثیت ختم کرے گا اور صحت/رپورٹس میں فالو اپ کے لیے نشان لگائے گا۔';

  @override
  String get confirmMiscarriage => 'اسقاط حمل کی تصدیق';

  @override
  String get newTask => 'نیا کام';

  @override
  String get voiceAddTask => 'آواز سے کام شامل کریں';

  @override
  String get voiceHoldMock => 'بولنے کے لیے دبائیں (نمونہ)';

  @override
  String get hold => 'دبائیں';

  @override
  String get dismiss => 'رد کریں';

  @override
  String get complete => 'مکمل';

  @override
  String get addedManually => 'دستی شامل';

  @override
  String get taskTitle => 'عنوان';

  @override
  String get feed => 'چارہ';

  @override
  String get medicine => 'دوا';

  @override
  String get mealPlans => 'کھانے کے منصوبے';

  @override
  String get viewMealPlans => 'کھانے کے منصوبے دیکھیں';

  @override
  String get recordFeeding => 'کھلانا درج کریں';

  @override
  String get addFeed => 'چارہ شامل کریں';

  @override
  String get addMedicine => 'دوا شامل کریں';

  @override
  String get medicineName => 'دوا کا نام';

  @override
  String get medicineTypeLabel => 'قسم (مثلاً ANTIBIOTIC)';

  @override
  String get medicineProductSource => 'مصنوعات';

  @override
  String get fromProductList => 'فہرست سے';

  @override
  String get customMedicineName => 'اپنا نام';

  @override
  String get selectMedicineProduct => 'دوا منتخب کریں';

  @override
  String get searchCatalogue => 'فہرست میں تلاش';

  @override
  String get medicineProductsAvailable => 'مماثل';

  @override
  String medicineCatalogueSearchHint(int count) {
    return '$count مصنوعات کی فہرست میں تلاش کریں';
  }

  @override
  String get activeIngredient => 'فعال جزو';

  @override
  String get dosage => 'مقدار';

  @override
  String get routeOfAdministration => 'استعمال کا طریقہ';

  @override
  String get inStockLabel => 'اسٹاک میں';

  @override
  String get selectMedicineOrEnterName => 'اوپر کی فہرست سے مصنوعات منتخب کریں';

  @override
  String get withdrawalPrefilledHint =>
      'واپسی کی مدتیں مصنوعات سے پہلے سے بھرتی ہیں — اگر آپ کے ڈاکٹر نے کہا ہو تو تبدیل کریں۔';

  @override
  String get medicineNameRequired => 'Select a medicine or enter a custom name';

  @override
  String get supplierNameRequired => 'Supplier name is required';

  @override
  String get estimatedWeeklyUsage =>
      'Estimated weekly usage (for low-stock alerts)';

  @override
  String get saving => 'Saving…';

  @override
  String get selectProduct => 'مصنوعات منتخب کریں';

  @override
  String get quantity => 'مقدار';

  @override
  String get unit => 'یونٹ';

  @override
  String get addFeedProduct => 'چارے کی مصنوعات شامل کریں';

  @override
  String get noFeedInInventory => 'ابھی کوئی چارہ نہیں۔';

  @override
  String get noMedicineInInventory => 'ابھی کوئی دوا نہیں۔';

  @override
  String get lowStock => 'کم اسٹاک';

  @override
  String lowStockFeedBanner(int count) {
    return '$count چارے کی اشیاء ایک ہفتے سے کم';
  }

  @override
  String get recordExpense => 'خرچ درج کریں';

  @override
  String get recordIncome => 'آمدنی درج کریں';

  @override
  String get exportCsv => 'CSV برآمد';

  @override
  String get exportPdf => 'PDF برآمد';

  @override
  String get printReport => 'رپورٹ پرنٹ';

  @override
  String get milkSale => 'دودھ کی فروخت';

  @override
  String get amount => 'رقم';

  @override
  String get addEntry => 'انٹری شامل کریں';

  @override
  String get categoryOptionalPreset => 'زمرہ (اختیاری)';

  @override
  String get category => 'زمرہ';

  @override
  String get description => 'تفصیل';

  @override
  String get recentEntries => 'حالیہ انٹریاں';

  @override
  String get general => 'عام';

  @override
  String get edit => 'ترمیم';

  @override
  String get animalsCount => 'جانور';

  @override
  String get females => 'مادیاں';

  @override
  String get avgPerHead => 'اوسط/سر';

  @override
  String get todayTotal => 'آج کا کل';

  @override
  String get onWithdrawal => 'واپسی کی مدت';

  @override
  String get recordAction => 'درج کریں';

  @override
  String get updateAction => 'Update';

  @override
  String get updateFeeding => 'Update feeding';

  @override
  String get updatingFeeding => 'Updating…';

  @override
  String get noFeedToday => 'آج کوئی چارہ درج نہیں۔';

  @override
  String get nutritionNoFeedLoggedHint =>
      'Actual intake is zero until you log feed in Today\'s feed below.';

  @override
  String get noMilkToday => 'آج کوئی دودھ ریکارڈ نہیں۔';

  @override
  String get dryMatter => 'خشک مادہ';

  @override
  String get crudeProtein => 'خام پروٹین';

  @override
  String get energyMe => 'توانائی (ME)';

  @override
  String get ndf => 'NDF';

  @override
  String get calcium => 'Calcium';

  @override
  String get phosphorus => 'Phosphorus';

  @override
  String get legendOk => 'ٹھیک';

  @override
  String get legendWarning => 'انتباہ';

  @override
  String get legendAction => 'عمل';

  @override
  String get purposeHeading => 'مقصد';

  @override
  String get descriptionHeading => 'تفصیل';

  @override
  String get noDescriptionRecorded => 'کوئی تفصیل درج نہیں۔';

  @override
  String get live => 'لائیو';

  @override
  String loadedCount(int count) {
    return '$count لوڈ';
  }

  @override
  String get perHead => 'فی سر';

  @override
  String get dailyCostPerHead => 'روزانہ لاگت / سر';

  @override
  String get todaysVolume => 'آج کا حجم';

  @override
  String avgLitresMilking(String avg, int count) {
    return 'اوسط $avg L/سر · $count دودھ';
  }

  @override
  String withdrawalDays(int days) {
    return 'واپسی · $days دن';
  }

  @override
  String get noAnimalsInGroup => 'اس گروپ میں ابھی کوئی جانور نہیں۔';

  @override
  String get groupTitle => 'گروپ';

  @override
  String get recentVaccinations => 'حالیہ ویکسین';

  @override
  String get activeTreatments => 'فعال علاج';

  @override
  String get sickAnimals => 'بیمار جانور';

  @override
  String get breedingStatus => 'حیثیت';

  @override
  String get breedingStatusSection => 'Breeding status';

  @override
  String get markAsHeifer => 'Heifer';

  @override
  String get heiferHint => 'Young female cattle that has not yet calved';

  @override
  String get dueDateLabel => 'Due date';

  @override
  String get chooseDueDate => 'Tap to choose due date';

  @override
  String get prolificacyLabel => 'Prolificacy';

  @override
  String get breedingStatusConflict =>
      'An animal cannot be both ready to breed and pregnant';

  @override
  String get fertilityMethodRequired => 'Choose a fertility method';

  @override
  String get gestation => 'حمل';

  @override
  String get gestationMonths => 'حمل (مہینے)';

  @override
  String gestationMonthsValue(int months) {
    return '$months مہینے';
  }

  @override
  String get markReadyToBreed => 'نسل کشی کے لیے تیار';

  @override
  String get recordPregnancyOutcome => 'حمل کا نتیجہ درج کریں';

  @override
  String get clearReadyToBreed => 'تیار نشان ہٹائیں';

  @override
  String get breedingHistory => 'نسل کشی کی تاریخ';

  @override
  String get breedingStatusUpdated => 'نسل کشی کی حیثیت اپ ڈیٹ';

  @override
  String get breedingOpen => 'کھلا';

  @override
  String get recentMiscarriage => 'حالیہ اسقاط';

  @override
  String get markedReadyToBreed => 'نسل کشی کے لیے تیار نشان';

  @override
  String get pregnancyConfirmed => 'حمل کی تصدیق';

  @override
  String pregnancyConfirmedMo(int months) {
    return 'حمل کی تصدیق ($months مہینے)';
  }

  @override
  String get lactatingPostCalving => 'دودھ / پیدائش کے بعد';

  @override
  String get stillbirthRecorded => 'مردہ پیدائش درج';

  @override
  String get miscarriageRecorded => 'اسقاط حمل درج';

  @override
  String get noBreedingEventsYet => 'ابھی کوئی نسل کشی واقعہ نہیں۔';

  @override
  String get breedingOverview => 'نسل کشی کا جائزہ';

  @override
  String get pregnantAnimals => 'حاملہ جانور';

  @override
  String gestationMonthsSubtitle(int months) {
    return '$months مہینے حمل';
  }

  @override
  String get openAnimalProfiles => 'جانور پروفائل کھولیں';

  @override
  String get openAnimalsForBreeding => 'ہر پروفائل سے نسل کشی کے اقدامات کریں۔';

  @override
  String get farmName => 'فارم کا نام';

  @override
  String get currency => 'کرنسی';

  @override
  String get selectSpeciesOnFarm => 'فارم پر اقسام منتخب کریں';

  @override
  String get primaryPurpose => 'بنیادی مقصد';

  @override
  String purposeForSpecies(String species) {
    return 'Primary purpose for $species';
  }

  @override
  String get setThePurposeForEachSpecies =>
      'Set the primary purpose for each species';

  @override
  String get purposeMilk => 'دودھ';

  @override
  String get purposeMeat => 'گوشت';

  @override
  String get purposeMilkMeat => 'دودھ اور گوشت';

  @override
  String get chooseHowToAddAnimals =>
      'پہلے جانور کیسے شامل کریں۔ بعد میں جانور ٹیب سے بھی کر سکتے ہیں۔';

  @override
  String get enterAsGroup => 'گروپ کے طور پر درج کریں';

  @override
  String get selectAtLeastOneSpecies => 'کم از کم ایک قسم منتخب کریں';

  @override
  String get selectAtLeastOneAnimal => 'Select at least one animal';

  @override
  String get myFarm => 'میرا فارم';

  @override
  String linkedToAccount(String provider) {
    return '$provider اکاؤنٹ سے منسلک';
  }

  @override
  String get providerGoogle => 'Google';

  @override
  String get providerApple => 'Apple';

  @override
  String get providerFacebook => 'Facebook';

  @override
  String get inviteTeamMember => 'ٹیم ممبر کو مدعو کریں';

  @override
  String get inviteTeamSubtitle => 'ای میل یا واٹس ایپ سے لنک بھیجیں۔';

  @override
  String get fullName => 'پورا نام';

  @override
  String get email => 'ای میل';

  @override
  String get whatsapp => 'واٹس ایپ';

  @override
  String get phoneWithCountryCode => 'فون (ملک کوڈ کے ساتھ)';

  @override
  String get role => 'کردار';

  @override
  String get manager => 'مینیجر';

  @override
  String get farmHand => 'فارم ہینڈ';

  @override
  String get veterinarian => 'ویٹرنری';

  @override
  String get sendInvite => 'دعوت بھیجیں';

  @override
  String get enterValidEmail => 'درست ای میل درج کریں';

  @override
  String get enterValidPhone => 'درست فون درج کریں';

  @override
  String inviteSentOpen(String channel) {
    return 'دعوت بھیجی — $channel کھولیں';
  }

  @override
  String inviteCreated(String link) {
    return 'دعوت بنی۔ لنک: $link';
  }

  @override
  String inviteFailed(String error) {
    return 'دعوت ناکام: $error';
  }

  @override
  String joinFarmSubject(String farmName) {
    return '$farmName پر GreenerHerd میں شامل ہوں';
  }

  @override
  String get channelEmail => 'ای میل';

  @override
  String get channelWhatsapp => 'واٹس ایپ';

  @override
  String get recordPurchase => 'خریداری درج کریں';

  @override
  String get supplier => 'سپلائر';

  @override
  String get animalsPurchased => 'خریدے گئے جانور';

  @override
  String get totalSar => 'کل (SAR)';

  @override
  String get user => 'صارف';

  @override
  String get notificationsRecommended => 'اطلاعات اور تجویز کردہ کام';

  @override
  String get notificationsSubtitle => 'چارہ، نسل، صحت، موسم کی یاددہانی';

  @override
  String get notificationsDigestAt => 'Daily digest at 06:00';

  @override
  String get preferences => 'Preferences';

  @override
  String get appSettings => 'App settings';

  @override
  String get helpSupport => 'Help & support';

  @override
  String get farmSection => 'Farm';

  @override
  String get switchFarm => 'Switch';

  @override
  String get location => 'Location';

  @override
  String get fullAccess => 'Full access';

  @override
  String get manageTeam => 'Manage';

  @override
  String get switchFarmMock => 'Farm switching is not available in this demo.';

  @override
  String get inviteManageTeam => 'ٹیم کو مدعو اور منظم کریں';

  @override
  String get notFound => 'نہیں ملا';

  @override
  String get errorGeneric => 'کچھ غلط ہو گیا';

  @override
  String get loading => 'لوڈ ہو رہا ہے';

  @override
  String get alerts => 'انتباہات';

  @override
  String get farmOwner => 'فارم مالک';

  @override
  String get manageGroups => 'گروپس منظم کریں';

  @override
  String get exportPdfCsvSubtitle => 'PDF / CSV برآمد';

  @override
  String get feedAndMedicalStock => 'چارہ اور دوا کا اسٹاک';

  @override
  String get supportTopics => 'سپورٹ اور موضوعات';

  @override
  String get validMilkVolume => 'درست دودھ کا حجم (لیٹر) درج کریں';

  @override
  String get milkBlockedWithdrawal => 'دوا واپسی کے دوران دودھ درج نہیں';

  @override
  String recordedMilkFor(String litres, String tag) {
    return '$litres L #$tag کے لیے درج';
  }

  @override
  String previousTodayMilk(String litres) {
    return 'پہلے آج: $litres L';
  }

  @override
  String get todaysMilkLitres => 'آج کا دودھ (لیٹر)';

  @override
  String get recordMilkSaleIncome => 'دودھ فروخت کی آمدنی درج کریں';

  @override
  String get recordMilkSaleIncomeSubtitle => 'مالیہ ٹیب میں آمدنی شامل';

  @override
  String get saleAmountSar => 'فروخت رقم (SAR)';

  @override
  String get catalogGaps => 'کیٹلاگ خلا';

  @override
  String get recommendedFeeds => 'تجویز کردہ چارہ';

  @override
  String get addSupplement => 'Add a supplement';

  @override
  String get useFromInventory => 'Use what you have';

  @override
  String get preFormulatedMixes => 'Pre-formulated mixes';

  @override
  String get suppliersNearYou => 'Suppliers near you';

  @override
  String get topPick => 'Top pick';

  @override
  String get supplementAdded => 'Added';

  @override
  String get supplementAdd => '+ Add';

  @override
  String get supplementAddedToTodaysFeed =>
      'Added to today\'s feed · nutrition updated';

  @override
  String recommendedFeedWeight(String kg) {
    return 'Recommended: $kg kg';
  }

  @override
  String supplementNutrientsAtWeight(String energy, String protein) {
    return 'Energy $energy MJ · Protein $protein kg';
  }

  @override
  String get supplementRemoved => 'Supplement removed';

  @override
  String buyProductTaskTitle(String product) {
    return 'Buy $product';
  }

  @override
  String get buyTaskCreated => 'Buy task added to your task list';

  @override
  String get projectedDailyCost => 'Projected daily cost';

  @override
  String get recomputeGapHint =>
      'Greener Herd will recompute the gap after the next feeding is logged.';

  @override
  String get kgPerDay => 'kg/day';

  @override
  String get energyImpact => 'Energy';

  @override
  String get proteinImpact => 'Protein';

  @override
  String get applyToMorningMix => 'صبح کے مکس پر لاگو کریں';

  @override
  String get feedPlanApplied => 'چارے کا منصوبہ لاگو';

  @override
  String get couldNotApplyFeedPlan => 'منصوبہ لاگو نہیں ہو سکا';

  @override
  String failedToApplyPlan(String error) {
    return 'ناکام: $error';
  }

  @override
  String get source => 'ماخذ';

  @override
  String get standard => 'معیاری';

  @override
  String get custom => 'اپنی مرضی';

  @override
  String get catalogueProduct => 'کیٹلاگ مصنوعات';

  @override
  String get marketplaceListingName => 'مارکیٹ لسٹنگ نام';

  @override
  String get productName => 'مصنوعات کا نام';

  @override
  String get currentStockKg => 'موجودہ اسٹاک (کلو)';

  @override
  String get purchasedVolumeKg => 'خریدا حجم (کلو)';

  @override
  String get purchasedVolumeRequired => 'Enter purchased volume (kg)';

  @override
  String get unitCostRequired => 'Enter unit cost (SAR per kg)';

  @override
  String inventoryCurrentStockKg(String kg) {
    return 'Current stock: $kg kg';
  }

  @override
  String get feedProductAlreadyInInventory =>
      'This product is already in your inventory.';

  @override
  String get feedAddProductOnlyHint =>
      'Add feed product is for new items only. To buy more of an existing product, record a new purchase from the feed list.';

  @override
  String get feedRecordNewPurchase => 'Record new purchase';

  @override
  String inventoryCostPerKg(String cost) {
    return '$cost SAR/kg';
  }

  @override
  String inventoryPreviousUnitCost(String cost) {
    return 'پچھلی یونٹ لاگت: $cost SAR/کلو';
  }

  @override
  String get stockUpdated => 'اسٹاک اپ ڈیٹ ہو گیا';

  @override
  String inventoryLastPurchaseKg(String kg) {
    return '+$kg kg purchased';
  }

  @override
  String get unitCostSar => 'یونٹ لاگت (SAR/کلو)';

  @override
  String get supplierName => 'سپلائر نام';

  @override
  String get supplierPhone => 'سپلائر فون';

  @override
  String get nutritionalInformation => 'غذائی معلومات';

  @override
  String get dryMatterPercent => 'خشک مادہ %';

  @override
  String get crudeProteinPercent => 'خام پروٹین %';

  @override
  String get nemMcalPerKg => 'NEm (Mcal/کلو)';

  @override
  String get addToInventory => 'انوینٹری میں شامل';

  @override
  String get feedType => 'چارے کی قسم';

  @override
  String avgWithdrawalRemaining(String days) {
    return 'اوسط $days دن باقی';
  }

  @override
  String get addAnimalTitle => 'Add animal';

  @override
  String get backButton => 'Back';

  @override
  String get origin => 'Origin';

  @override
  String get bornOnFarm => 'Born on farm';

  @override
  String get purchased => 'Purchased';

  @override
  String get earTag => 'Ear tag';

  @override
  String get earTagHint => 'e.g. 0473';

  @override
  String get nameOptional => 'Name (optional)';

  @override
  String get nameOptionalHint => 'You can add this later.';

  @override
  String get nameOptionalPlaceholder => 'e.g. Salwa';

  @override
  String get newbornDetails => 'Newborn details';

  @override
  String get sizeAtBirth => 'Size at birth';

  @override
  String get birthSizeSmall => 'Small';

  @override
  String get birthSizeMedium => 'Medium';

  @override
  String get birthSizeLarge => 'Large';

  @override
  String get vigour => 'Vigour';

  @override
  String get vigourWeak => 'Weak';

  @override
  String get vigourAverage => 'Average';

  @override
  String get vigourStrong => 'Strong';

  @override
  String get birthingAssistance => 'Birthing assistance';

  @override
  String get assistanceNone => 'None — natural birth';

  @override
  String get assistanceEasyPull => 'Easy pull (1 person)';

  @override
  String get assistanceHardPull => 'Hard pull (2+ people)';

  @override
  String get assistanceVet => 'Vet assisted';

  @override
  String get assistanceCSection => 'C-section';

  @override
  String get animalIsTwin => 'This animal is a twin';

  @override
  String get birthWeightHint => 'Birth weight';

  @override
  String get heightCm => 'Height';

  @override
  String get purchaseDate => 'Purchase date';

  @override
  String get dobIfKnown => 'Date of birth (if known)';

  @override
  String get dobOrAgeRangeHint => 'Or pick an age range below.';

  @override
  String get ageRangeIfUnknown => 'Age range (if DOB unknown)';

  @override
  String get pickAgeRange => 'Pick a range…';

  @override
  String get supplierSource => 'Supplier / source';

  @override
  String get supplierHint => 'e.g. Al-Wafi Genetics, market, neighbour…';

  @override
  String get purchasePrice => 'Purchase price';

  @override
  String get sireOptional => 'Sire (optional)';

  @override
  String get damOptional => 'Dam (optional)';

  @override
  String get mothersTag => 'Mother\'s tag';

  @override
  String get parentSearchHint => 'Search or enter';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Anything else worth recording';

  @override
  String get youreAdding => 'You\'re adding';

  @override
  String get summaryOriginBorn => 'Born on farm';

  @override
  String get summaryOriginPurchased => 'Purchased';

  @override
  String summaryOriginPurchasedFrom(String supplier) {
    return 'Purchased from $supplier';
  }

  @override
  String get selectGroupRequired => 'Select a group or create a new one';

  @override
  String breedForSpecies(String species) {
    return 'Breed ($species)';
  }

  @override
  String get goat => 'Goat';

  @override
  String groupSpeciesLabel(String name, String species) {
    return '$name · $species';
  }

  @override
  String get groupOfLivestock => 'Group of livestock';

  @override
  String get livestockExisting => 'Existing';

  @override
  String get livestockNewBorn => 'New (born)';

  @override
  String get livestockNewPurchased => 'New (purchased)';

  @override
  String animalsAvailable(int count, String species) {
    return '$count $species available';
  }

  @override
  String noAnimalsForSpecies(String species) {
    return 'No $species on the farm yet.';
  }

  @override
  String get createGroupAction => 'Create group';

  @override
  String createGroupWithAnimals(int count) {
    return 'Create group · $count animal';
  }

  @override
  String createGroupWithAnimalsPlural(int count) {
    return 'Create group · $count animals';
  }

  @override
  String addLivestockLabel(String label) {
    return 'Add $label';
  }

  @override
  String tapToRegisterLivestock(String label, String species) {
    return 'Tap Add $label to register one or more $species now.';
  }

  @override
  String addingCountToGroupOnSave(int count) {
    return 'Adding $count to the group on save';
  }

  @override
  String get addAnotherAnimal => 'Add another';

  @override
  String newbornAnimalN(int n) {
    return 'Newborn #$n';
  }

  @override
  String purchasedAnimalN(int n) {
    return 'Purchased #$n';
  }

  @override
  String get groupDescriptionHint => 'Housing, feeding cadence, notes';

  @override
  String get groupNameHint => 'e.g. Milking B';

  @override
  String get removeAnimal => 'Remove';

  @override
  String get userRoleOwner => 'Owner';

  @override
  String get userRoleManager => 'Manager';

  @override
  String get userRoleFarmHand => 'Farm hand';

  @override
  String get userRoleVet => 'Vet';

  @override
  String get reportsSubtitle => 'PDF · downloadable';

  @override
  String get dateRange => 'Date range';

  @override
  String get last90Days => 'Last 90 days';

  @override
  String get fromDate => 'From';

  @override
  String get toDate => 'To';

  @override
  String get availableReports => 'Available reports';

  @override
  String get reportPreview => 'Report preview';

  @override
  String get recordsIncluded => 'Records included';

  @override
  String get inSelectedRange => 'In the selected range';

  @override
  String get window => 'Window';

  @override
  String get last90DaysRange => 'Feb 07 – May 08';

  @override
  String get speciesCovered => 'Species covered';

  @override
  String get speciesCoveredValue => 'Cattle · Goat · Sheep';

  @override
  String get generated => 'Generated';

  @override
  String get generatedToday => 'Today, 09:14';

  @override
  String get headline => 'Headline';

  @override
  String get perGroup => 'Per-group';

  @override
  String get auditableDetail => 'Auditable detail';

  @override
  String get exportReport => 'Export';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get signatureLineNote =>
      'Includes signature line for veterinary / auditor handoff.';

  @override
  String get breedingKpis => 'Breeding KPIs';

  @override
  String get pregnancyRate => 'Pregnancy rate';

  @override
  String get aiAttempts30d => 'AI attempts (30d)';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get successRate => 'Success rate';

  @override
  String get miscarriagesCount => 'Miscarriages';

  @override
  String get aiProviderPerformance => 'AI provider performance';

  @override
  String get weightMonthsTitle => 'Weight · 5 months';

  @override
  String weightGrowthPct(int pct) {
    return '+$pct%';
  }

  @override
  String get currentWeightLabel => 'Current';

  @override
  String weightDeltaKg(int kg) {
    return '+$kg kg';
  }

  @override
  String get artificialInseminations => 'Artificial inseminations';

  @override
  String recordsOnFile(int count) {
    return '$count records on file';
  }

  @override
  String get noAiRecordsYet => 'No AI records yet';

  @override
  String get noAiRecordsHint =>
      'Log inseminations or natural services to track attempts and outcomes.';

  @override
  String get addAi => 'Add AI';

  @override
  String get recordAi => 'Record AI';

  @override
  String aiAttemptTitle(int n) {
    return 'Artificial insemination · Attempt $n';
  }

  @override
  String get sireLabel => 'SIRE';

  @override
  String get technicianLabel => 'TECHNICIAN';

  @override
  String get semenBatchLabel => 'SEMEN BATCH';

  @override
  String get resultDateLabel => 'RESULT DATE';

  @override
  String get miscarriagesSection => 'Miscarriages';

  @override
  String get noLossesRecorded => 'No losses recorded';

  @override
  String get noMiscarriagesYet => 'No miscarriages recorded';

  @override
  String get noMiscarriagesHint =>
      'Log a pregnancy loss to track gestation day, cause and follow-up.';

  @override
  String get breedingFemalesOnly =>
      'Breeding history is shown for females only.';

  @override
  String get healthcareHistory => 'Healthcare history';

  @override
  String get vaccinationsSection => 'Vaccinations';

  @override
  String get recordTreatment => 'Record treatment';

  @override
  String get updateTreatment => 'Update treatment';

  @override
  String get updateTreatmentSubtitle =>
      'Change illness notes or medicine details';

  @override
  String get illnessSymptomsLabel => 'Illness / symptoms';

  @override
  String get treatmentMedicineLabel => 'Medicine / treatment';

  @override
  String get treatmentRecorded => 'Treatment recorded';

  @override
  String get treatmentUpdated => 'Treatment updated';

  @override
  String get markedCured => 'Marked as cured';

  @override
  String get underTreatmentDefault => 'Under treatment';

  @override
  String get withdrawalPeriodActive => 'Withdrawal period active';

  @override
  String withdrawalMilkSafe(String date) {
    return 'Milk safe from $date. Do not sell this animal\'s milk until cleared.';
  }

  @override
  String get activeIllnessDetail =>
      'Mastitis · day 3 of 5 of treatment. Penicillin G — 5 ml IM daily.';

  @override
  String get individualTasks => 'Individual tasks';

  @override
  String addTaskForAnimal(String name) {
    return 'Add task for $name';
  }

  @override
  String get noTasksForAnimal => 'No upcoming tasks for this animal.';

  @override
  String get recurring => 'Recurring';

  @override
  String get allTasks => 'All';

  @override
  String tasksDueSubtitle(int due, int overdue) {
    return '$due due · $overdue overdue';
  }

  @override
  String get voiceLanguages => 'EN · AR · UR · FR · transcribed by AI';

  @override
  String get nothingForFilter => 'Nothing for this filter.';

  @override
  String get editTask => 'Edit task';

  @override
  String get methodLabel => 'Method';

  @override
  String get fertilityMethodLabel => 'Fertility method';

  @override
  String get readyToBreedMethodHint =>
      'Choose how this animal will be bred. Sponges synchronize heat for timed insemination in goats and sheep.';

  @override
  String get breedingMethodNatural => 'Natural service';

  @override
  String get breedingMethodAi => 'Artificial insemination';

  @override
  String get breedingMethodEmbryonic => 'Embryo transfer';

  @override
  String get breedingMethodSponges => 'Sponges';

  @override
  String get providerLabel => 'Provider';

  @override
  String get attemptNumberLabel => 'Attempt #';

  @override
  String get resolved => 'Resolved';

  @override
  String get activeStatus => 'Active';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get markCured => 'Mark cured';

  @override
  String get recordDeath => 'Record death';

  @override
  String get deathReason => 'Cause of death';

  @override
  String get deathReasonHint => 'Illness, injury, unknown…';

  @override
  String get confirmRecordDeath => 'Confirm death';

  @override
  String confirmRecordDeathMessage(String animal, String reason) {
    return 'Record $animal as deceased?\n\nReason: $reason\n\nThe animal will be removed from its group. This cannot be undone.';
  }

  @override
  String get animalRecordedDeceased => 'Death recorded';

  @override
  String get deceased => 'Deceased';

  @override
  String get removedFromGroupNote => 'Removed from group';

  @override
  String get cullType => 'Cull type';

  @override
  String get cullReason => 'Cull reason';
}
