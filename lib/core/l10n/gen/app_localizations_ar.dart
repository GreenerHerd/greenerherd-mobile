// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'GreenerHerd';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabAnimals => 'الحيوانات';

  @override
  String get tabTasks => 'المهام';

  @override
  String get tabFinance => 'المالية';

  @override
  String get tabReports => 'التقارير';

  @override
  String get tabOverview => 'نظرة عامة';

  @override
  String get tabNutrition => 'التغذية';

  @override
  String get tabBreeding => 'التربية';

  @override
  String get tabMilking => 'الحلب';

  @override
  String get tabHealth => 'الصحة';

  @override
  String get tabWeight => 'الوزن';

  @override
  String get tabMedia => 'الوسائط';

  @override
  String goodMorning(String name) {
    return 'صباح الخير، $name';
  }

  @override
  String get animals => 'الحيوانات';

  @override
  String get addNew => 'إضافة';

  @override
  String get profile => 'الملف';

  @override
  String get groups => 'المجموعات';

  @override
  String get inventory => 'المخزون';

  @override
  String get help => 'المساعدة';

  @override
  String get reports => 'التقارير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get language => 'اللغة';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get onboardingFarmTitle => 'إعداد المزرعة';

  @override
  String get onboardingSpeciesTitle => 'مواشيك';

  @override
  String get onboardingAnimalsTitle => 'إضافة حيوانات';

  @override
  String get skipForNow => 'تخطي الآن';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get pregnant => 'حامل';

  @override
  String get lactating => 'مرضعة';

  @override
  String get readyToBreed => 'جاهزة للتزاوج';

  @override
  String get sick => 'مريض';

  @override
  String get cullFlagged => 'محدد للذبح';

  @override
  String get allSpecies => 'كل الأنواع';

  @override
  String get cattle => 'أبقار';

  @override
  String get goats => 'ماعز';

  @override
  String get sheep => 'أغنام';

  @override
  String get tasksToday => 'مهام اليوم';

  @override
  String get overdue => 'متأخرة';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get finance => 'المالية';

  @override
  String get income => 'دخل';

  @override
  String get expense => 'مصروف';

  @override
  String get net => 'صافي';

  @override
  String get livestockValue => 'قيمة القطيع';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get buyAnimals => 'شراء حيوانات';

  @override
  String get sellAnimals => 'بيع حيوانات';

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
  String get people => 'الأشخاص';

  @override
  String get marketplace => 'السوق';

  @override
  String get fixTheGap => 'سد الفجوة';

  @override
  String get alertsAndTasks => 'التنبيهات والمهام';

  @override
  String get animalNotFound => 'الحيوان غير موجود';

  @override
  String get groupNotFound => 'المجموعة غير موجودة';

  @override
  String get methaneEmissions => 'انبعاثات الميثان';

  @override
  String get methaneRegionMiddleEast => 'الشرق الأوسط (دول الخليج)';

  @override
  String get groupAverage => 'متوسط المجموعة';

  @override
  String get groupTotal => 'Group total';

  @override
  String get emissionsTotal => 'Emissions total';

  @override
  String methaneCo2eGroupTotal(String co2e, int headCount) {
    return '$co2e kg CO₂e · $headCount head';
  }

  @override
  String get methaneByAnimal => 'حسب الحيوان (CH₄ / يوم)';

  @override
  String methaneMoreAnimals(int count) {
    return '+ $count حيوانات إضافية';
  }

  @override
  String methaneCh4Grams(String grams) {
    return '$grams غ CH₄';
  }

  @override
  String methaneCo2eSummary(String co2e, String weight) {
    return '$co2e كغ مكافئ CO₂ · $weight كغ متوسط الوزن';
  }

  @override
  String methaneGramsShort(String grams) {
    return '$grams غ';
  }

  @override
  String methaneAgeMonths(int months) {
    return '$months شهر';
  }

  @override
  String lactationNumber(int number) {
    return 'الإدرار $number';
  }

  @override
  String lactationDayOf305(String stage, int day) {
    return '$stage · اليوم $day من 305';
  }

  @override
  String lactationCalvingExpected(String date, String litres) {
    return 'الولادة $date · متوقع ~$litres لتر اليوم';
  }

  @override
  String get lactationCurveTitle => 'منحنى الإدرار (الحليب مقابل يوم الإدرار)';

  @override
  String get lactationCurveLegend =>
      'خط متصل = حليب مسجّل · متقطع = متوقع (متوسط السلالة)';

  @override
  String get lactationChartNeedsData =>
      'سجّل حلبتين على الأقل لعرض منحنى الإدرار.';

  @override
  String chartDayLitres(int day, String litres) {
    return 'اليوم $day\n$litres ل';
  }

  @override
  String get milkingTodayVolume => 'حجم اليوم';

  @override
  String get notRecorded => 'غير مسجّل';

  @override
  String litresValue(String litres) {
    return '$litres ل';
  }

  @override
  String get recordMilk => 'تسجيل الحليب';

  @override
  String get recordBulkMilkSale => 'تسجيل بيع حليب بالجملة (دخل)';

  @override
  String get withdrawalMilkBlocked =>
      'فترة السحب نشطة — لا يمكن بيع الحليب أو تسجيله للاستهلاك البشري.';

  @override
  String get todayVsRequirement => 'اليوم مقابل الاحتياج';

  @override
  String get milkingKpis => 'مؤشرات الحلب';

  @override
  String get topProducers => 'أعلى المنتجات';

  @override
  String get todaysFeed => 'علف اليوم';

  @override
  String get energyGapDetected => 'فجوة طاقة مكتشفة';

  @override
  String get lactationStageFresh => 'مبكرة (بداية الإدرار)';

  @override
  String get lactationStagePeak => 'ذروة الإدرار';

  @override
  String get lactationStageMid => 'منتصف الإدرار';

  @override
  String get lactationStageLate => 'متأخرة';

  @override
  String get lactationStageDry => 'فترة الجفاف';

  @override
  String get species => 'النوع';

  @override
  String get sex => 'الجنس';

  @override
  String get breed => 'السلالة';

  @override
  String get group => 'المجموعة';

  @override
  String get purpose => 'الغرض';

  @override
  String get groupPurpose => 'Group purpose';

  @override
  String get animalPurpose => 'Animal purpose';

  @override
  String get female => 'أنثى';

  @override
  String get male => 'ذكر';

  @override
  String get loadingBreeds => 'جاري تحميل السلالات…';

  @override
  String get saveAnimal => 'حفظ الحيوان';

  @override
  String get saveGroup => 'حفظ المجموعة';

  @override
  String get newAnimal => 'حيوان جديد';

  @override
  String get newGroup => 'مجموعة جديدة';

  @override
  String get moveGroupTitle => 'Move to group';

  @override
  String moveGroupCurrent(String name) {
    return 'Current group: $name';
  }

  @override
  String get moveToNewGroup => 'Create new group';

  @override
  String get moveToNewGroupSubtitle =>
      'Add a group and move this animal into it';

  @override
  String get removeFromGroup => 'No group';

  @override
  String get moveGroupNoGroups =>
      'No other groups for this species yet. Create one above.';

  @override
  String animalMovedToGroup(String tag, String groupName) {
    return 'Moved #$tag to $groupName';
  }

  @override
  String animalRemovedFromGroup(String tag) {
    return 'Removed #$tag from its group';
  }

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
  String get markPregnant => 'تحديد حامل';

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
  String get continueButton => 'متابعة';

  @override
  String get enterAnimalsIndividually => 'إدخال الحيوانات فردياً';

  @override
  String get tag => 'الوسم';

  @override
  String get weight => 'الوزن';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get tagNumber => 'رقم الوسم';

  @override
  String get weightKg => 'الوزن (كغ)';

  @override
  String get weightHint => 'مثال: 412';

  @override
  String get birthDateOptional => 'تاريخ الميلاد (اختياري)';

  @override
  String bornOnDate(int day, int month, int year) {
    return 'ولد $day/$month/$year';
  }

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get ageNew => 'جديد';

  @override
  String get continueWithGoogle => 'المتابعة مع Google';

  @override
  String get continueWithApple => 'المتابعة مع Apple';

  @override
  String get continueWithFacebook => 'المتابعة مع Facebook';

  @override
  String get newFarmSetup => 'إعداد مزرعة جديدة';

  @override
  String get welcomeTo => 'مرحباً بك في';

  @override
  String get welcomeBrand => 'Greener Herd';

  @override
  String get gaveBirth => 'ولدت';

  @override
  String get recordBirthSubtitle => 'تسجيل ولادة حية أو ميتة';

  @override
  String get miscarriage => 'إجهاض';

  @override
  String get miscarriageSubtitle => 'إزالة الحمل ووضع علامة للمتابعة';

  @override
  String get flagForCull => 'تحديد للذبح';

  @override
  String get clearCullFlag => 'إزالة علامة الذبح';

  @override
  String get markSold => 'تسجيل البيع';

  @override
  String get recordBirth => 'تسجيل الولادة';

  @override
  String get bornAlive => 'ولد حياً';

  @override
  String get bornAliveSubtitle =>
      'إزالة الحمل؛ إضافة علامة الإدرار إن لم تكن موجودة';

  @override
  String get stillborn => 'مولود ميت';

  @override
  String get stillbornSubtitle => 'إزالة الحمل؛ تسجيل ولادة ميتة';

  @override
  String get saveBirthRecord => 'حفظ سجل الولادة';

  @override
  String get pregnancyOutcome => 'نتيجة الحمل';

  @override
  String get howDidPregnancyEnd => 'كيف انتهى الحمل؟';

  @override
  String birthRecordedFor(String tag) {
    return 'سُجلت الولادة للوسم #$tag';
  }

  @override
  String stillbirthRecordedFor(String tag) {
    return 'سُجلت ولادة ميتة للوسم #$tag';
  }

  @override
  String get recordMiscarriage => 'تسجيل إجهاض';

  @override
  String miscarriageRecordedFor(String tag) {
    return 'سُجل إجهاض للوسم #$tag';
  }

  @override
  String get miscarriageConfirmBody =>
      'سيُزال وضع الحمل وتُضاف علامة إجهاض للمتابعة في الصحة والتقارير.';

  @override
  String get confirmMiscarriage => 'تأكيد الإجهاض';

  @override
  String get newTask => 'مهمة جديدة';

  @override
  String get voiceAddTask => 'إضافة مهمة صوتياً';

  @override
  String get voiceHoldMock => 'اضغط للتحدث (تجريبي)';

  @override
  String get hold => 'اضغط';

  @override
  String get dismiss => 'تجاهل';

  @override
  String get complete => 'إكمال';

  @override
  String get addedManually => 'أُضيفت يدوياً';

  @override
  String get taskTitle => 'العنوان';

  @override
  String get feed => 'العلف';

  @override
  String get medicine => 'الدواء';

  @override
  String get mealPlans => 'خطط الوجبات';

  @override
  String get viewMealPlans => 'عرض خطط الوجبات';

  @override
  String get recordFeeding => 'تسجيل التغذية';

  @override
  String get addFeed => 'إضافة علف';

  @override
  String get addMedicine => 'إضافة دواء';

  @override
  String get medicineName => 'اسم الدواء';

  @override
  String get medicineTypeLabel => 'النوع (مثل ANTIBIOTIC)';

  @override
  String get medicineProductSource => 'المنتج';

  @override
  String get fromProductList => 'من القائمة';

  @override
  String get customMedicineName => 'اسم مخصص';

  @override
  String get selectMedicineProduct => 'اختر الدواء';

  @override
  String get searchCatalogue => 'البحث في القائمة';

  @override
  String get medicineProductsAvailable => 'نتائج';

  @override
  String medicineCatalogueSearchHint(int count) {
    return 'ابحث بين $count منتجاً من القائمة';
  }

  @override
  String get activeIngredient => 'المادة الفعالة';

  @override
  String get dosage => 'الجرعة';

  @override
  String get routeOfAdministration => 'طريقة الإعطاء';

  @override
  String get inStockLabel => 'متوفر في المخزون';

  @override
  String get selectMedicineOrEnterName => 'اختر منتجاً من القائمة أعلاه';

  @override
  String get withdrawalPrefilledHint =>
      'فترات السحب معبأة مسبقاً من المنتج — عدّلها إذا نصح الطبيب البيطري بذلك.';

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
  String get selectProduct => 'اختر المنتج';

  @override
  String get quantity => 'الكمية';

  @override
  String get unit => 'الوحدة';

  @override
  String get addFeedProduct => 'إضافة منتج علف';

  @override
  String get noFeedInInventory => 'لا يوجد علف في المخزون بعد.';

  @override
  String get noMedicineInInventory => 'لا توجد أدوية في المخزون بعد.';

  @override
  String get lowStock => 'مخزون منخفض';

  @override
  String lowStockFeedBanner(int count) {
    return '$count عنصر(عناصر) علف أقل من أسبوع من التوريد';
  }

  @override
  String get recordExpense => 'تسجيل مصروف';

  @override
  String get recordIncome => 'تسجيل دخل';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get printReport => 'طباعة التقرير';

  @override
  String get milkSale => 'بيع الحليب';

  @override
  String get amount => 'المبلغ';

  @override
  String get addEntry => 'إضافة قيد';

  @override
  String get categoryOptionalPreset => 'الفئة (اختياري)';

  @override
  String get category => 'الفئة';

  @override
  String get description => 'الوصف';

  @override
  String get recentEntries => 'القيود الأخيرة';

  @override
  String get general => 'عام';

  @override
  String get edit => 'تعديل';

  @override
  String get animalsCount => 'الحيوانات';

  @override
  String get females => 'الإناث';

  @override
  String get avgPerHead => 'متوسط/رأس';

  @override
  String get todayTotal => 'إجمالي اليوم';

  @override
  String get onWithdrawal => 'في فترة السحب';

  @override
  String get recordAction => 'تسجيل';

  @override
  String get updateAction => 'Update';

  @override
  String get updateFeeding => 'Update feeding';

  @override
  String get updatingFeeding => 'Updating…';

  @override
  String get noFeedToday => 'لم يُسجّل علف اليوم.';

  @override
  String get nutritionNoFeedLoggedHint =>
      'Actual intake is zero until you log feed in Today\'s feed below.';

  @override
  String get noMilkToday => 'لا سجلات حليب اليوم.';

  @override
  String get dryMatter => 'المادة الجافة';

  @override
  String get crudeProtein => 'البروتين الخام';

  @override
  String get energyMe => 'الطاقة (ME)';

  @override
  String get ndf => 'NDF';

  @override
  String get calcium => 'Calcium';

  @override
  String get phosphorus => 'Phosphorus';

  @override
  String get legendOk => 'جيد';

  @override
  String get legendWarning => 'تحذير';

  @override
  String get legendAction => 'إجراء';

  @override
  String get purposeHeading => 'الغرض';

  @override
  String get descriptionHeading => 'الوصف';

  @override
  String get noDescriptionRecorded => 'لا يوجد وصف مسجّل.';

  @override
  String get live => 'مباشر';

  @override
  String loadedCount(int count) {
    return '$count محمّل';
  }

  @override
  String get perHead => 'لكل رأس';

  @override
  String get dailyCostPerHead => 'التكلفة اليومية / رأس';

  @override
  String get todaysVolume => 'حجم اليوم';

  @override
  String avgLitresMilking(String avg, int count) {
    return 'متوسط $avg ل/رأس · $count حلب';
  }

  @override
  String withdrawalDays(int days) {
    return 'سحب · $days ي';
  }

  @override
  String get noAnimalsInGroup => 'لا حيوانات في هذه المجموعة بعد.';

  @override
  String get groupTitle => 'المجموعة';

  @override
  String get recentVaccinations => 'تطعيمات حديثة';

  @override
  String get activeTreatments => 'علاجات نشطة';

  @override
  String get sickAnimals => 'حيوانات مريضة';

  @override
  String get breedingStatus => 'الحالة';

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
  String get gestation => 'الحمل';

  @override
  String get gestationMonths => 'مدة الحمل (أشهر)';

  @override
  String gestationMonthsValue(int months) {
    return '$months أشهر';
  }

  @override
  String get markReadyToBreed => 'تحديد جاهز للتزاوج';

  @override
  String get recordPregnancyOutcome => 'تسجيل نتيجة الحمل';

  @override
  String get clearReadyToBreed => 'إزالة جاهز للتزاوج';

  @override
  String get breedingHistory => 'سجل التربية';

  @override
  String get breedingStatusUpdated => 'تم تحديث حالة التربية';

  @override
  String get breedingOpen => 'غير مخصّص';

  @override
  String get recentMiscarriage => 'إجهاض حديث';

  @override
  String get markedReadyToBreed => 'حُدد جاهز للتزاوج';

  @override
  String get pregnancyConfirmed => 'تأكيد الحمل';

  @override
  String pregnancyConfirmedMo(int months) {
    return 'تأكيد الحمل ($months شهر)';
  }

  @override
  String get lactatingPostCalving => 'مرضعة / بعد الولادة';

  @override
  String get stillbirthRecorded => 'سُجلت ولادة ميتة';

  @override
  String get miscarriageRecorded => 'سُجل إجهاض';

  @override
  String get noBreedingEventsYet => 'لا أحداث تربية مسجّلة بعد.';

  @override
  String get breedingOverview => 'نظرة التربية';

  @override
  String get pregnantAnimals => 'حيوانات حامل';

  @override
  String gestationMonthsSubtitle(int months) {
    return '$months أشهر حمل';
  }

  @override
  String get openAnimalProfiles => 'فتح ملفات الحيوانات';

  @override
  String get openAnimalsForBreeding => 'افتح ملفات الحيوانات لإجراءات التربية.';

  @override
  String get farmName => 'اسم المزرعة';

  @override
  String get currency => 'العملة';

  @override
  String get selectSpeciesOnFarm => 'اختر الأنواع في مزرعتك';

  @override
  String get primaryPurpose => 'الغرض الرئيسي';

  @override
  String purposeForSpecies(String species) {
    return 'Primary purpose for $species';
  }

  @override
  String get setThePurposeForEachSpecies =>
      'Set the primary purpose for each species';

  @override
  String get purposeMilk => 'حليب';

  @override
  String get purposeMeat => 'لحم';

  @override
  String get purposeMilkMeat => 'حليب ولحم';

  @override
  String get chooseHowToAddAnimals =>
      'اختر كيفية إضافة أول حيواناتك. يمكنك لاحقاً من تبويب الحيوانات.';

  @override
  String get enterAsGroup => 'إدخال كمجموعة';

  @override
  String get selectAtLeastOneSpecies => 'اختر نوعاً واحداً على الأقل';

  @override
  String get selectAtLeastOneAnimal => 'Select at least one animal';

  @override
  String get myFarm => 'مزرعتي';

  @override
  String linkedToAccount(String provider) {
    return 'مرتبط بحساب $provider';
  }

  @override
  String get providerGoogle => 'Google';

  @override
  String get providerApple => 'Apple';

  @override
  String get providerFacebook => 'Facebook';

  @override
  String get inviteTeamMember => 'دعوة عضو فريق';

  @override
  String get inviteTeamSubtitle =>
      'أرسل رابط التطبيق بالبريد أو واتساب للانضمام لمزرعتك.';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get email => 'البريد';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get phoneWithCountryCode => 'الهاتف (مع رمز الدولة)';

  @override
  String get role => 'الدور';

  @override
  String get manager => 'مدير';

  @override
  String get farmHand => 'عامل مزرعة';

  @override
  String get veterinarian => 'طبيب بيطري';

  @override
  String get sendInvite => 'إرسال الدعوة';

  @override
  String get enterValidEmail => 'أدخل بريداً صالحاً';

  @override
  String get enterValidPhone => 'أدخل هاتفاً صالحاً';

  @override
  String inviteSentOpen(String channel) {
    return 'أُرسلت الدعوة — افتح $channel للإكمال';
  }

  @override
  String inviteCreated(String link) {
    return 'تم إنشاء الدعوة. الرابط: $link';
  }

  @override
  String inviteFailed(String error) {
    return 'فشلت الدعوة: $error';
  }

  @override
  String joinFarmSubject(String farmName) {
    return 'انضم إلى $farmName على GreenerHerd';
  }

  @override
  String get channelEmail => 'البريد';

  @override
  String get channelWhatsapp => 'واتساب';

  @override
  String get recordPurchase => 'تسجيل شراء';

  @override
  String get supplier => 'المورد';

  @override
  String get animalsPurchased => 'حيوانات مشتراة';

  @override
  String get totalSar => 'الإجمالي (ريال)';

  @override
  String get user => 'مستخدم';

  @override
  String get notificationsRecommended => 'التنبيهات والمهام الموصى بها';

  @override
  String get notificationsSubtitle => 'تذكيرات للعلف والتربية والصحة والطقس';

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
  String get inviteManageTeam => 'دعوة وإدارة فريقك';

  @override
  String get notFound => 'غير موجود';

  @override
  String get errorGeneric => 'حدث خطأ';

  @override
  String get loading => 'جاري التحميل';

  @override
  String get alerts => 'التنبيهات';

  @override
  String get farmOwner => 'مالك المزرعة';

  @override
  String get manageGroups => 'إدارة المجموعات';

  @override
  String get exportPdfCsvSubtitle => 'تصدير PDF / CSV';

  @override
  String get feedAndMedicalStock => 'مخزون العلف والأدوية';

  @override
  String get supportTopics => 'الدعم والمواضيع';

  @override
  String get validMilkVolume => 'أدخل حجماً صالحاً للحليب (لتر)';

  @override
  String get milkBlockedWithdrawal =>
      'تسجيل الحليب محظور أثناء فترة سحب الدواء';

  @override
  String recordedMilkFor(String litres, String tag) {
    return 'سُجل $litres ل للوسم #$tag';
  }

  @override
  String previousTodayMilk(String litres) {
    return 'سابقاً اليوم: $litres ل';
  }

  @override
  String get todaysMilkLitres => 'حليب اليوم (لتر)';

  @override
  String get milkSessionMorning => 'Morning';

  @override
  String get milkSessionEvening => 'Evening';

  @override
  String get milkSessionDaily => 'Daily total';

  @override
  String get milkRecordDate => 'Milk date';

  @override
  String get changeDate => 'Change';

  @override
  String get milkLitresMorning => 'Morning milk (litres)';

  @override
  String get milkLitresEvening => 'Evening milk (litres)';

  @override
  String get milkLitresDaily => 'Daily total milk (litres)';

  @override
  String get recentMilkRecords => 'Recent records';

  @override
  String recordedMilkSessionFor(
      String litres, String session, String tag, String date) {
    return 'Recorded $litres L ($session) for #$tag on $date';
  }

  @override
  String get recordMilkSaleIncome => 'تسجيل دخل بيع الحليب';

  @override
  String get recordMilkSaleIncomeSubtitle => 'يُضاف دخل في تبويب المالية';

  @override
  String get saleAmountSar => 'مبلغ البيع (ريال)';

  @override
  String get catalogGaps => 'فجوات الكتالوج';

  @override
  String get recommendedFeeds => 'أعلاف موصى بها';

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
  String get applyToMorningMix => 'تطبيق على خليط الصباح';

  @override
  String get feedPlanApplied => 'تم تطبيق خطة العلف';

  @override
  String get couldNotApplyFeedPlan => 'تعذر تطبيق خطة العلف';

  @override
  String failedToApplyPlan(String error) {
    return 'فشل التطبيق: $error';
  }

  @override
  String get source => 'المصدر';

  @override
  String get standard => 'قياسي';

  @override
  String get custom => 'مخصص';

  @override
  String get catalogueProduct => 'منتج الكتالوج';

  @override
  String get marketplaceListingName => 'اسم إدراج السوق';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get currentStockKg => 'المخزون الحالي (كغ)';

  @override
  String get purchasedVolumeKg => 'الحجم المشترى (كغ)';

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
    return 'تكلفة الوحدة السابقة: $cost ريال/كغ';
  }

  @override
  String get stockUpdated => 'تم تحديث المخزون';

  @override
  String inventoryLastPurchaseKg(String kg) {
    return '+$kg kg purchased';
  }

  @override
  String get unitCostSar => 'تكلفة الوحدة (ريال/كغ)';

  @override
  String get supplierName => 'اسم المورد';

  @override
  String get supplierPhone => 'هاتف المورد';

  @override
  String get nutritionalInformation => 'المعلومات الغذائية';

  @override
  String get dryMatterPercent => 'المادة الجافة %';

  @override
  String get crudeProteinPercent => 'البروتين الخام %';

  @override
  String get nemMcalPerKg => 'NEm (مكال/كغ)';

  @override
  String get addToInventory => 'إضافة للمخزون';

  @override
  String get feedType => 'نوع العلف';

  @override
  String avgWithdrawalRemaining(String days) {
    return 'متوسط $days ي متبقية';
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
  String get treatmentStepIllness => 'Symptoms';

  @override
  String get treatmentStepMedicine => 'Treatment';

  @override
  String get administeredByLabel => 'Administered by';

  @override
  String get administeredByHint => 'Who administered';

  @override
  String get administeredDateLabel => 'Administered date';

  @override
  String get milkWithdrawalDaysLabel => 'Milk withdrawal (days)';

  @override
  String get milkWithdrawalHint => 'Days before milk is safe';

  @override
  String get meatWithdrawalDaysLabel => 'Meat withdrawal (days)';

  @override
  String get meatWithdrawalHint => 'Days before meat is safe';

  @override
  String get treatmentFrequencyLabel => 'Frequency';

  @override
  String get treatmentFrequencyOnce => 'Once';

  @override
  String get treatmentFrequencyDaily => 'Daily';

  @override
  String get treatmentFrequencyWeekly => 'Weekly';

  @override
  String get treatmentFrequencyMonthly => 'Monthly';

  @override
  String get treatmentNotesLabel => 'Treatment notes';

  @override
  String get batchNumberLabel => 'Batch number';

  @override
  String get batchNumberHint => 'Optional batch / lot number';

  @override
  String get expiryDateLabel => 'Expiry date';

  @override
  String get addTreatmentPhoto => 'Add photo';

  @override
  String get addTreatmentPhotoHint => 'Photo of medicine label or packaging';

  @override
  String get addMedicineToInventoryHint =>
      'Add a product to your medical inventory';

  @override
  String get selectMedicineFirst => 'Select a medicine';

  @override
  String get medicineRequired =>
      'Select a medicine from inventory or the product list';

  @override
  String get administeredByRequired => 'Enter who administered the treatment';

  @override
  String get dosageRequired => 'Enter dosage (e.g. 5 ml IM)';

  @override
  String get notInInventoryBanner =>
      'Not in your inventory — add it to track stock';

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

  @override
  String get breedingCycleKpiTitle => 'دورة التربية';

  @override
  String get breedingCycleKpiSubtitle =>
      'الأشهر منذ الولادة تحدد تغذية الإدرار وموعد بدء دورة التربية التالية.';

  @override
  String get monthsSinceCalvingLabel => 'الأشهر منذ الولادة';

  @override
  String get lactationPhaseLabel => 'مرحلة الإدرار';

  @override
  String get milkingTabLactationUnavailable =>
      'Lactation phase is set on this tab once the animal is old enough to lactate. Use the Breeding tab for months since calving and re-breeding timing.';

  @override
  String monthsSinceCalvingValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أشهر',
      one: 'شهر واحد',
      zero: 'ولادة حديثة (0 شهر)',
    );
    return '$_temp0';
  }

  @override
  String get decreaseMonthsSinceCalving => 'تقليل الأشهر منذ الولادة';

  @override
  String get increaseMonthsSinceCalving => 'زيادة الأشهر منذ الولادة';

  @override
  String get breedingCycleReadyForRebreeding =>
      'جاهزة للتزاوج التالي — حدّدي جاهزة للتزاوج عند التخطيط.';

  @override
  String breedingCycleWaitingPeriod(int months) {
    return 'فترة انتظار طوعية — $months شهر حتى نافذة إعادة التزاوج.';
  }

  @override
  String get breedingCycleBlockedPregnant =>
      'حامل حالياً — تبدأ دورة التربية التالية بعد الولادة.';

  @override
  String get groupBreedingCycleKpiTitle => 'دورة تربية القطيع';

  @override
  String get groupBreedingCycleKpiSubtitle =>
      'متوسط الأشهر منذ الولادة للإناث المدرّة يحدد تغذية المجموعة وتخطيط إعادة التزاوج.';

  @override
  String get groupMedianMonthsSinceCalving => 'متوسط الأشهر منذ الولادة';

  @override
  String get groupLactatingFemales => 'إناث مدرّة';

  @override
  String get groupReadyForRebreeding => 'جاهزة لإعادة التزاوج';

  @override
  String get groupWaitingForRebreeding => 'في فترة الانتظار';

  @override
  String get groupLactationStageBreakdown => 'مراحل الإدرار في المجموعة';

  @override
  String groupAnimalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حيوانات',
      one: 'حيوان واحد',
    );
    return '$_temp0';
  }

  @override
  String groupBreedingCycleNutritionNote(int months) {
    return 'فترة الانتظار الطوعية $months أشهر بعد الولادة. عدّل الحيوانات أدناه لتحديث الأشهر منذ الولادة.';
  }

  @override
  String monthsSinceCalvingShort(int count) {
    return '$count شهر منذ الولادة';
  }

  @override
  String readyToBreedEligibleNotTagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تجاوزت 2 شهراً منذ الولادة · غير محددة جاهزة',
      one: '1 تجاوزت 2 شهراً منذ الولادة · غير محددة جاهزة',
    );
    return '$_temp0';
  }

  @override
  String get dashboardKpiPregnant => 'PREGNANT';

  @override
  String get dashboardKpiReadyToBreed => 'READY TO BREED';

  @override
  String get dashboardKpiLactating => 'LACTATING';

  @override
  String get dashboardKpiWeaning => 'WEANING';

  @override
  String get dashboardKpiSick => 'SICK';

  @override
  String get dashboardKpiCullFlagged => 'CULL FLAGGED';

  @override
  String get dashboardKpiSickHint => 'under treatment';

  @override
  String get dashboardKpiCullHint => 'reviewable';

  @override
  String get dashboardKpiWeaningHint => '0–3 months · nutrition weaning';

  @override
  String dashboardKpiLactatingAvgMilk(String avg) {
    return '$avg L/day avg (prior milk records)';
  }

  @override
  String get dashboardKpiLactatingNoMilkData => 'record milk to show average';

  @override
  String get feedRestrictedDueToAnimalStatus =>
      'بعض أعلاف القطيع مقيدة بسبب حالة الحيوان.';

  @override
  String get feedEligibilityWarningTitle => 'تحذير قيود العلف';

  @override
  String feedEligibilityAddProductWarning(String product) {
    return 'قد لا يناسب $product جميع الحيوانات في المزرعة.';
  }

  @override
  String feedEligibilityImpactedAnimals(String tags) {
    return 'الحيوانات المتأثرة: $tags';
  }

  @override
  String feedMealPlanRestrictedTitle(String mealName) {
    return 'خطة \"$mealName\" تحتوي على أعلاف مقيدة';
  }

  @override
  String get feedMealPlanRestrictedBody =>
      'بعض مكونات هذه الخطة غير مؤهلة لحيوانات المجموعة المحددة.';

  @override
  String get groupHerdRequirementsTitle => 'الاحتياجات اليومية للقطيع';

  @override
  String get groupHerdRequirementsSubtitle => 'مجموع ملفات التغذية لكل حيوان';

  @override
  String groupHerdRequirementsProfiles(int count) {
    return '$count حيوان · ملفات متنوعة';
  }

  @override
  String supplementDosageCapPerAnimal(String kg) {
    return 'حد أقصى $kg كغ لكل حيوان يومياً';
  }

  @override
  String supplementDosageCapGroup(String kg) {
    return 'حد المجموعة $kg كغ يومياً';
  }

  @override
  String get supplementDosageCappedHint =>
      'الكمية المقترحة محدودة بقواعد الأهلية';

  @override
  String get addAnyway => 'إضافة على أي حال';

  @override
  String get groupBreedingMethodLabel => 'Default breeding method';

  @override
  String get groupBreedingMethodHint =>
      'Used for all eligible animals in this group and to generate breeding tasks.';

  @override
  String get breedingTasksScheduled => 'Breeding tasks added to your task list';

  @override
  String get breedingTaskNaturalObserveTitle => 'Observe for heat';

  @override
  String get breedingTaskNaturalObserveSubtitle =>
      'Watch for standing heat before natural service';

  @override
  String get breedingTaskCycleCheckTitle => 'Cycle check';

  @override
  String get breedingTaskCycleCheckSubtitle =>
      'Confirm return to heat or schedule re-breeding';

  @override
  String get breedingTaskPregnancyConfirmTitle => 'Pregnancy check';

  @override
  String get breedingTaskPregnancyConfirmSubtitle =>
      'Confirm pregnancy or plan next cycle';

  @override
  String get breedingTaskAiRecordTitle => 'Record AI';

  @override
  String get breedingTaskAiRecordSubtitle =>
      'Log semen, technician, and timing';

  @override
  String get breedingTaskAiConceptionCheckTitle => 'Conception check';

  @override
  String get breedingTaskAiConceptionCheckSubtitle =>
      'Palpation or ultrasound around day 18';

  @override
  String get breedingTaskPregnancyScanTitle => 'Pregnancy scan';

  @override
  String get breedingTaskPregnancyScanSubtitle =>
      'Ultrasound or palpation to confirm pregnancy';

  @override
  String get breedingTaskPregnancyNutritionTitle =>
      'Pregnancy nutrition review';

  @override
  String get breedingTaskPregnancyNutritionSubtitle =>
      'Adjust ration for confirmed pregnancy';

  @override
  String get breedingTaskEmbryoTransferTitle => 'Embryo transfer';

  @override
  String get breedingTaskEmbryoTransferSubtitle =>
      'Record donor, recipient sync, and transfer details';

  @override
  String get breedingTaskPostTransferCheckTitle => 'Post-transfer check';

  @override
  String get breedingTaskPostTransferCheckSubtitle =>
      'Monitor recipient for acceptance signs';

  @override
  String get breedingTaskEarlyPregnancyCheckTitle => 'Early pregnancy check';

  @override
  String get breedingTaskEarlyPregnancyCheckSubtitle =>
      'Confirm implantation around day 30';

  @override
  String get breedingTaskSpongeInsertTitle => 'Insert sponges';

  @override
  String get breedingTaskSpongeInsertSubtitle =>
      'Synchronize heat for timed breeding';

  @override
  String get breedingTaskSpongeRemoveTitle => 'Remove sponges';

  @override
  String get breedingTaskSpongeRemoveSubtitle =>
      'Remove sponges and prepare for AI or natural service';

  @override
  String get lactationCycleLabel => 'Lactation cycle';

  @override
  String get lactationCycleHint =>
      'Sets lactating status and drives nutrition and feed eligibility for this animal.';

  @override
  String get lactationCycleEarly => 'Early lactation';

  @override
  String get lactationCycleMid => 'Mid lactation';

  @override
  String get lactationCycleLate => 'Late lactation';

  @override
  String get lactationCycleCloseLateLactation =>
      'Close to dry-off (late lactation)';

  @override
  String get lactationCycleCloseToDryOffPreCalving =>
      'Close to dry-off (pre-calving)';

  @override
  String get lactationCycleDry => 'Dry (not lactating)';

  @override
  String get lactationCycleNone => 'Not lactating';

  @override
  String get lactationCycleSingle => 'Lactating (single)';

  @override
  String get lactationCycleTwin => 'Lactating (twins)';

  @override
  String get groupLactationCycleTitle => 'Lactation cycle by animal';

  @override
  String get groupLactationCycleHint =>
      'Set each female\'s cycle to update lactating status, nutrition, and which feeds they can receive.';
}
