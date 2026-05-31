// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GreenerHerd';

  @override
  String get tabHome => 'Home';

  @override
  String get tabAnimals => 'Animals';

  @override
  String get tabTasks => 'Tasks';

  @override
  String get tabFinance => 'Finance';

  @override
  String get tabReports => 'Reports';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabNutrition => 'Nutrition';

  @override
  String get tabBreeding => 'Breeding';

  @override
  String get tabMilking => 'Milking';

  @override
  String get tabHealth => 'Health';

  @override
  String get tabWeight => 'Weight';

  @override
  String get tabMedia => 'Media';

  @override
  String goodMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String get animals => 'Animals';

  @override
  String get addNew => 'Add new';

  @override
  String get profile => 'Profile';

  @override
  String get groups => 'Groups';

  @override
  String get inventory => 'Inventory';

  @override
  String get help => 'Help';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageFrench => 'French';

  @override
  String get languageUrdu => 'Urdu';

  @override
  String get onboardingFarmTitle => 'Set up your farm';

  @override
  String get onboardingSpeciesTitle => 'Your livestock';

  @override
  String get onboardingAnimalsTitle => 'Add animals';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get pregnant => 'Pregnant';

  @override
  String get lactating => 'Lactating';

  @override
  String get readyToBreed => 'Ready to breed';

  @override
  String get sick => 'Sick';

  @override
  String get cullFlagged => 'Cull flagged';

  @override
  String get allSpecies => 'All species';

  @override
  String get cattle => 'Cattle';

  @override
  String get goats => 'Goats';

  @override
  String get sheep => 'Sheep';

  @override
  String get tasksToday => 'Tasks today';

  @override
  String get overdue => 'Overdue';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get finance => 'Finance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get net => 'Net';

  @override
  String get livestockValue => 'Livestock value';

  @override
  String get subscription => 'Subscription';

  @override
  String get buyAnimals => 'Buy animals';

  @override
  String get sellAnimals => 'Sell animals';

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
  String get people => 'People';

  @override
  String get marketplace => 'Marketplace';

  @override
  String get fixTheGap => 'Fix the gap';

  @override
  String get alertsAndTasks => 'Alerts & tasks';

  @override
  String get animalNotFound => 'Animal not found';

  @override
  String get groupNotFound => 'Group not found';

  @override
  String get methaneEmissions => 'Methane emissions';

  @override
  String get methaneRegionMiddleEast => 'Middle East (GCC)';

  @override
  String get groupAverage => 'Group average';

  @override
  String get groupTotal => 'Group total';

  @override
  String get emissionsTotal => 'Emissions total';

  @override
  String methaneCo2eGroupTotal(String co2e, int headCount) {
    return '$co2e kg CO₂e · $headCount head';
  }

  @override
  String get methaneByAnimal => 'By animal (CH₄ / day)';

  @override
  String methaneMoreAnimals(int count) {
    return '+ $count more animals';
  }

  @override
  String methaneCh4Grams(String grams) {
    return '$grams g CH₄';
  }

  @override
  String methaneCo2eSummary(String co2e, String weight) {
    return '$co2e kg CO₂e · $weight kg avg BW';
  }

  @override
  String methaneGramsShort(String grams) {
    return '$grams g';
  }

  @override
  String methaneAgeMonths(int months) {
    return '$months mo';
  }

  @override
  String lactationNumber(int number) {
    return 'Lactation $number';
  }

  @override
  String lactationDayOf305(String stage, int day) {
    return '$stage · Day $day of 305';
  }

  @override
  String lactationCalvingExpected(String date, String litres) {
    return 'Calving $date · expected ~$litres L today';
  }

  @override
  String get lactationCurveTitle => 'Lactation curve (milk vs day in milk)';

  @override
  String get lactationCurveLegend =>
      'Solid line = recorded milk · dashed = expected (breed average)';

  @override
  String get lactationChartNeedsData =>
      'Record at least two milkings to show the lactation curve.';

  @override
  String chartDayLitres(int day, String litres) {
    return 'Day $day\n$litres L';
  }

  @override
  String get milkingTodayVolume => 'Today\'s volume';

  @override
  String get notRecorded => 'Not recorded';

  @override
  String litresValue(String litres) {
    return '$litres L';
  }

  @override
  String get recordMilk => 'Record milk';

  @override
  String get recordBulkMilkSale => 'Record bulk milk sale (income)';

  @override
  String get withdrawalMilkBlocked =>
      'Withdrawal period active — milk cannot be sold or recorded for human consumption.';

  @override
  String get todayVsRequirement => 'Today v Required Nutrition';

  @override
  String get milkingKpis => 'Milking KPIs';

  @override
  String get topProducers => 'Top producers';

  @override
  String get todaysFeed => 'Today\'s Feed';

  @override
  String get energyGapDetected => 'Energy gap detected';

  @override
  String get lactationStageFresh => 'Fresh (early lactation)';

  @override
  String get lactationStagePeak => 'Peak lactation';

  @override
  String get lactationStageMid => 'Mid lactation';

  @override
  String get lactationStageLate => 'Late lactation';

  @override
  String get lactationStageDry => 'Dry period';

  @override
  String get species => 'Species';

  @override
  String get sex => 'Sex';

  @override
  String get breed => 'Breed';

  @override
  String get group => 'Group';

  @override
  String get purpose => 'Purpose';

  @override
  String get groupPurpose => 'Group purpose';

  @override
  String get animalPurpose => 'Animal purpose';

  @override
  String get female => 'Female';

  @override
  String get male => 'Male';

  @override
  String get loadingBreeds => 'Loading breeds…';

  @override
  String get saveAnimal => 'Save animal';

  @override
  String get saveGroup => 'Save group';

  @override
  String get newAnimal => 'New animal';

  @override
  String get newGroup => 'New group';

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
  String get markPregnant => 'Mark pregnant';

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
  String get continueButton => 'Continue';

  @override
  String get enterAnimalsIndividually => 'Enter animals individually';

  @override
  String get tag => 'Tag';

  @override
  String get weight => 'Weight';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get tagNumber => 'Tag number';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get weightHint => 'e.g. 412';

  @override
  String get birthDateOptional => 'Birth date (optional)';

  @override
  String bornOnDate(int day, int month, int year) {
    return 'Born $day/$month/$year';
  }

  @override
  String get groupName => 'Group name';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get ageNew => 'New';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithFacebook => 'Continue with Facebook';

  @override
  String get newFarmSetup => 'New farm setup';

  @override
  String get welcomeTo => 'Welcome to';

  @override
  String get welcomeBrand => 'Greener Herd';

  @override
  String get gaveBirth => 'Gave birth';

  @override
  String get recordBirthSubtitle => 'Record live birth or stillborn';

  @override
  String get miscarriage => 'Miscarriage';

  @override
  String get miscarriageSubtitle => 'Clear pregnancy and flag for follow-up';

  @override
  String get flagForCull => 'Flag for cull';

  @override
  String get clearCullFlag => 'Clear cull flag';

  @override
  String get markSold => 'Mark sold';

  @override
  String get recordBirth => 'Record birth';

  @override
  String get bornAlive => 'Born alive';

  @override
  String get bornAliveSubtitle =>
      'Pregnancy cleared; lactating tag added only if not already set';

  @override
  String get stillborn => 'Stillborn';

  @override
  String get stillbornSubtitle => 'Pregnancy cleared; stillborn recorded';

  @override
  String get saveBirthRecord => 'Save birth record';

  @override
  String get pregnancyOutcome => 'Pregnancy outcome';

  @override
  String get howDidPregnancyEnd => 'How did the pregnancy end?';

  @override
  String birthRecordedFor(String tag) {
    return 'Birth recorded for #$tag';
  }

  @override
  String stillbirthRecordedFor(String tag) {
    return 'Stillbirth recorded for #$tag';
  }

  @override
  String get recordMiscarriage => 'Record miscarriage';

  @override
  String miscarriageRecordedFor(String tag) {
    return 'Miscarriage recorded for #$tag';
  }

  @override
  String get miscarriageConfirmBody =>
      'This will clear the pregnant status and add a miscarriage flag for follow-up in Health and reports.';

  @override
  String get confirmMiscarriage => 'Confirm miscarriage';

  @override
  String get newTask => 'New task';

  @override
  String get voiceAddTask => 'Voice add a task';

  @override
  String get voiceHoldMock => 'Hold to talk (mock)';

  @override
  String get hold => 'Hold';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get complete => 'Complete';

  @override
  String get addedManually => 'Added manually';

  @override
  String get taskTitle => 'Title';

  @override
  String get feed => 'Feed';

  @override
  String get medicine => 'Medicine';

  @override
  String get mealPlans => 'Meal plans';

  @override
  String get viewMealPlans => 'View meal plans';

  @override
  String get recordFeeding => 'Record feeding';

  @override
  String get addFeed => 'Add feed';

  @override
  String get addMedicine => 'Add medicine';

  @override
  String get medicineName => 'Medicine name';

  @override
  String get medicineTypeLabel => 'Type (e.g. ANTIBIOTIC)';

  @override
  String get medicineProductSource => 'Product';

  @override
  String get fromProductList => 'From list';

  @override
  String get customMedicineName => 'Custom name';

  @override
  String get selectMedicineProduct => 'Select medicine';

  @override
  String get searchCatalogue => 'Search catalogue';

  @override
  String get medicineProductsAvailable => 'matches';

  @override
  String medicineCatalogueSearchHint(int count) {
    return 'Search $count catalogue products';
  }

  @override
  String get activeIngredient => 'Active ingredient';

  @override
  String get dosage => 'Dosage';

  @override
  String get routeOfAdministration => 'Route';

  @override
  String get inStockLabel => 'In stock';

  @override
  String get selectMedicineOrEnterName => 'Pick a product from the list above';

  @override
  String get withdrawalPrefilledHint =>
      'Withdrawal periods are pre-filled from the product — adjust if your vet advises differently.';

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
  String get selectProduct => 'Select product';

  @override
  String get quantity => 'Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get addFeedProduct => 'Add feed product';

  @override
  String get noFeedInInventory => 'No feed in inventory yet.';

  @override
  String get noMedicineInInventory => 'No medicines in inventory yet.';

  @override
  String get lowStock => 'Low stock';

  @override
  String lowStockFeedBanner(int count) {
    return '$count feed item(s) below one week\'s supply';
  }

  @override
  String get recordExpense => 'Record expense';

  @override
  String get recordIncome => 'Record income';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get printReport => 'Print report';

  @override
  String get milkSale => 'Milk sale';

  @override
  String get amount => 'Amount';

  @override
  String get addEntry => 'Add entry';

  @override
  String get categoryOptionalPreset => 'Category (optional preset)';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get recentEntries => 'Recent entries';

  @override
  String get general => 'General';

  @override
  String get edit => 'Edit';

  @override
  String get animalsCount => 'Animals';

  @override
  String get females => 'Females';

  @override
  String get avgPerHead => 'Avg / head';

  @override
  String get todayTotal => 'Today total';

  @override
  String get onWithdrawal => 'On withdrawal';

  @override
  String get recordAction => 'Record';

  @override
  String get updateAction => 'Update';

  @override
  String get updateFeeding => 'Update feeding';

  @override
  String get updatingFeeding => 'Updating…';

  @override
  String get noFeedToday => 'No feed recorded today.';

  @override
  String get nutritionNoFeedLoggedHint =>
      'Actual intake is zero until you log feed in Today\'s feed below.';

  @override
  String get noMilkToday => 'No milk records today.';

  @override
  String get dryMatter => 'Dry matter';

  @override
  String get crudeProtein => 'Crude protein';

  @override
  String get energyMe => 'Energy (ME)';

  @override
  String get ndf => 'NDF';

  @override
  String get calcium => 'Calcium';

  @override
  String get phosphorus => 'Phosphorus';

  @override
  String get legendOk => 'OK';

  @override
  String get legendWarning => 'Warning';

  @override
  String get legendAction => 'Action';

  @override
  String get purposeHeading => 'PURPOSE';

  @override
  String get descriptionHeading => 'DESCRIPTION';

  @override
  String get noDescriptionRecorded => 'No description recorded.';

  @override
  String get live => 'Live';

  @override
  String loadedCount(int count) {
    return '$count loaded';
  }

  @override
  String get perHead => 'Per head';

  @override
  String get dailyCostPerHead => 'Daily cost / head';

  @override
  String get todaysVolume => 'Today\'s volume';

  @override
  String avgLitresMilking(String avg, int count) {
    return 'Avg $avg L/head · $count milking';
  }

  @override
  String withdrawalDays(int days) {
    return 'Withdrawal · $days d';
  }

  @override
  String get noAnimalsInGroup => 'No animals assigned to this group yet.';

  @override
  String get groupTitle => 'Group';

  @override
  String get recentVaccinations => 'Recent vaccinations';

  @override
  String get activeTreatments => 'Active treatments';

  @override
  String get sickAnimals => 'Sick animals';

  @override
  String get breedingStatus => 'Status';

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
  String get gestation => 'Gestation';

  @override
  String get gestationMonths => 'Gestation (months)';

  @override
  String gestationMonthsValue(int months) {
    return '$months months';
  }

  @override
  String get markReadyToBreed => 'Mark ready to breed';

  @override
  String get recordPregnancyOutcome => 'Record pregnancy outcome';

  @override
  String get clearReadyToBreed => 'Clear ready to breed';

  @override
  String get breedingHistory => 'Breeding history';

  @override
  String get breedingStatusUpdated => 'Breeding status updated';

  @override
  String get breedingOpen => 'Open';

  @override
  String get recentMiscarriage => 'Recent miscarriage';

  @override
  String get markedReadyToBreed => 'Marked ready to breed';

  @override
  String get pregnancyConfirmed => 'Pregnancy confirmed';

  @override
  String pregnancyConfirmedMo(int months) {
    return 'Pregnancy confirmed ($months mo)';
  }

  @override
  String get lactatingPostCalving => 'Lactating / post-calving';

  @override
  String get stillbirthRecorded => 'Stillbirth recorded';

  @override
  String get miscarriageRecorded => 'Miscarriage recorded';

  @override
  String get noBreedingEventsYet => 'No breeding events recorded yet.';

  @override
  String get breedingOverview => 'Breeding overview';

  @override
  String get pregnantAnimals => 'Pregnant animals';

  @override
  String gestationMonthsSubtitle(int months) {
    return '$months months gestation';
  }

  @override
  String get openAnimalProfiles => 'Open animal profiles';

  @override
  String get openAnimalsForBreeding =>
      'Open animals for breeding actions from each animal profile.';

  @override
  String get farmName => 'Farm name';

  @override
  String get currency => 'Currency';

  @override
  String get selectSpeciesOnFarm => 'Select the species on your farm';

  @override
  String get primaryPurpose => 'Primary purpose';

  @override
  String purposeForSpecies(String species) {
    return 'Primary purpose for $species';
  }

  @override
  String get setThePurposeForEachSpecies =>
      'Set the primary purpose for each species';

  @override
  String get purposeMilk => 'Milk';

  @override
  String get purposeMeat => 'Meat';

  @override
  String get purposeMilkMeat => 'Milk & Meat';

  @override
  String get chooseHowToAddAnimals =>
      'Choose how to add your first animals. You can always do this later from the Animals tab.';

  @override
  String get enterAsGroup => 'Enter as a group';

  @override
  String get selectAtLeastOneSpecies => 'Select at least one species';

  @override
  String get selectAtLeastOneAnimal => 'Select at least one animal';

  @override
  String get myFarm => 'My farm';

  @override
  String linkedToAccount(String provider) {
    return 'Linked to $provider account';
  }

  @override
  String get providerGoogle => 'Google';

  @override
  String get providerApple => 'Apple';

  @override
  String get providerFacebook => 'Facebook';

  @override
  String get inviteTeamMember => 'Invite team member';

  @override
  String get inviteTeamSubtitle =>
      'Send an app link by email or WhatsApp. They can open it to join your farm.';

  @override
  String get fullName => 'Full name';

  @override
  String get email => 'Email';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get phoneWithCountryCode => 'Phone (with country code)';

  @override
  String get role => 'Role';

  @override
  String get manager => 'Manager';

  @override
  String get farmHand => 'Farm hand';

  @override
  String get veterinarian => 'Veterinarian';

  @override
  String get sendInvite => 'Send invite';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get enterValidPhone => 'Enter a valid phone';

  @override
  String inviteSentOpen(String channel) {
    return 'Invite sent — open $channel to finish';
  }

  @override
  String inviteCreated(String link) {
    return 'Invite created. Link: $link';
  }

  @override
  String inviteFailed(String error) {
    return 'Invite failed: $error';
  }

  @override
  String joinFarmSubject(String farmName) {
    return 'Join $farmName on GreenerHerd';
  }

  @override
  String get channelEmail => 'email';

  @override
  String get channelWhatsapp => 'WhatsApp';

  @override
  String get recordPurchase => 'Record purchase';

  @override
  String get supplier => 'Supplier';

  @override
  String get animalsPurchased => 'Animals purchased';

  @override
  String get totalSar => 'Total (SAR)';

  @override
  String get user => 'User';

  @override
  String get notificationsRecommended => 'Notifications & recommended tasks';

  @override
  String get notificationsSubtitle =>
      'Reminders for feed, breeding, health, weather';

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
  String get inviteManageTeam => 'Invite and manage your team';

  @override
  String get notFound => 'Not found';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get loading => 'Loading';

  @override
  String get alerts => 'Alerts';

  @override
  String get farmOwner => 'Farm owner';

  @override
  String get manageGroups => 'Manage groups';

  @override
  String get exportPdfCsvSubtitle => 'Export PDF / CSV';

  @override
  String get feedAndMedicalStock => 'Feed & medical stock';

  @override
  String get supportTopics => 'Support & topics';

  @override
  String get validMilkVolume => 'Enter a valid milk volume (litres)';

  @override
  String get milkBlockedWithdrawal =>
      'Milk recording blocked during medicine withdrawal';

  @override
  String recordedMilkFor(String litres, String tag) {
    return 'Recorded $litres L for #$tag';
  }

  @override
  String previousTodayMilk(String litres) {
    return 'Previous today: $litres L';
  }

  @override
  String get todaysMilkLitres => 'Today\'s milk (litres)';

  @override
  String get recordMilkSaleIncome => 'Record milk sale income';

  @override
  String get recordMilkSaleIncomeSubtitle => 'Adds income on the Finance tab';

  @override
  String get saleAmountSar => 'Sale amount (SAR)';

  @override
  String get catalogGaps => 'Catalog gaps';

  @override
  String get recommendedFeeds => 'Recommended feeds';

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
  String get applyToMorningMix => 'Apply to morning mix';

  @override
  String get feedPlanApplied => 'Feed plan applied';

  @override
  String get couldNotApplyFeedPlan => 'Could not apply feed plan';

  @override
  String failedToApplyPlan(String error) {
    return 'Failed to apply plan: $error';
  }

  @override
  String get source => 'Source';

  @override
  String get standard => 'Standard';

  @override
  String get custom => 'Custom';

  @override
  String get catalogueProduct => 'Catalogue product';

  @override
  String get marketplaceListingName => 'Marketplace listing name';

  @override
  String get productName => 'Product name';

  @override
  String get currentStockKg => 'Current stock (kg)';

  @override
  String get purchasedVolumeKg => 'Purchased volume (kg)';

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
    return 'Previous unit cost: $cost SAR/kg';
  }

  @override
  String get stockUpdated => 'Stock updated';

  @override
  String inventoryLastPurchaseKg(String kg) {
    return '+$kg kg purchased';
  }

  @override
  String get unitCostSar => 'Unit cost (SAR/kg)';

  @override
  String get supplierName => 'Supplier name';

  @override
  String get supplierPhone => 'Supplier phone';

  @override
  String get nutritionalInformation => 'Nutritional information';

  @override
  String get dryMatterPercent => 'Dry matter %';

  @override
  String get crudeProteinPercent => 'Crude protein %';

  @override
  String get nemMcalPerKg => 'NEm (Mcal/kg)';

  @override
  String get addToInventory => 'Add to inventory';

  @override
  String get feedType => 'Feed type';

  @override
  String avgWithdrawalRemaining(String days) {
    return 'Avg $days d remaining';
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

  @override
  String get breedingCycleKpiTitle => 'Breeding cycle';

  @override
  String get breedingCycleKpiSubtitle =>
      'Months since calving sets lactation nutrition and when the next breeding cycle can start.';

  @override
  String get monthsSinceCalvingLabel => 'Months since calving';

  @override
  String get lactationPhaseLabel => 'Lactation phase';

  @override
  String monthsSinceCalvingValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
      zero: 'Fresh calving (0 mo)',
    );
    return '$_temp0';
  }

  @override
  String get decreaseMonthsSinceCalving => 'Decrease months since calving';

  @override
  String get increaseMonthsSinceCalving => 'Increase months since calving';

  @override
  String get breedingCycleReadyForRebreeding =>
      'Ready for next breeding — mark Ready to Breed when scheduled.';

  @override
  String breedingCycleWaitingPeriod(int months) {
    return 'Voluntary waiting period — $months month(s) until re-breeding window.';
  }

  @override
  String get breedingCycleBlockedPregnant =>
      'Currently pregnant — next breeding cycle starts after calving.';

  @override
  String get groupBreedingCycleKpiTitle => 'Herd breeding cycle';

  @override
  String get groupBreedingCycleKpiSubtitle =>
      'Median months since calving across lactating females drives group nutrition and re-breeding planning.';

  @override
  String get groupMedianMonthsSinceCalving => 'Median months since calving';

  @override
  String get groupLactatingFemales => 'Lactating females';

  @override
  String get groupReadyForRebreeding => 'Ready for re-breeding';

  @override
  String get groupWaitingForRebreeding => 'In waiting period';

  @override
  String get groupLactationStageBreakdown => 'Lactation stages in group';

  @override
  String groupAnimalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animals',
      one: '1 animal',
    );
    return '$_temp0';
  }

  @override
  String groupBreedingCycleNutritionNote(int months) {
    return 'Voluntary waiting period is $months months after calving. Edit individual animals below to update months since calving.';
  }

  @override
  String monthsSinceCalvingShort(int count) {
    return '$count mo since calving';
  }

  @override
  String readyToBreedEligibleNotTagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count over 2 mo since calving · not tagged ready',
      one: '1 over 2 mo since calving · not tagged ready',
    );
    return '$_temp0';
  }

  @override
  String get feedRestrictedDueToAnimalStatus =>
      'Some feed items are restricted due to the animal status.';

  @override
  String get feedEligibilityWarningTitle => 'Feed restriction warning';

  @override
  String feedEligibilityAddProductWarning(String product) {
    return '$product may not be suitable for all animals on your farm.';
  }

  @override
  String feedEligibilityImpactedAnimals(String tags) {
    return 'Impacted animals: $tags';
  }

  @override
  String feedMealPlanRestrictedTitle(String mealName) {
    return 'Meal plan \"$mealName\" has restricted feeds';
  }

  @override
  String get feedMealPlanRestrictedBody =>
      'Some ingredients in this meal plan are not eligible for animals in the selected group.';

  @override
  String get addAnyway => 'Add anyway';
}
