import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('ur')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GreenerHerd'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get tabAnimals;

  /// No description provided for @tabTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tabTasks;

  /// No description provided for @tabFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get tabFinance;

  /// No description provided for @tabReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get tabReports;

  /// No description provided for @tabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tabOverview;

  /// No description provided for @tabNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get tabNutrition;

  /// No description provided for @tabBreeding.
  ///
  /// In en, this message translates to:
  /// **'Breeding'**
  String get tabBreeding;

  /// No description provided for @tabMilking.
  ///
  /// In en, this message translates to:
  /// **'Milking'**
  String get tabMilking;

  /// No description provided for @tabHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get tabHealth;

  /// No description provided for @tabWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get tabWeight;

  /// No description provided for @tabMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get tabMedia;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String goodMorning(String name);

  /// No description provided for @animals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animals;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add new'**
  String get addNew;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageUrdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get languageUrdu;

  /// No description provided for @onboardingFarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your farm'**
  String get onboardingFarmTitle;

  /// No description provided for @onboardingSpeciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your livestock'**
  String get onboardingSpeciesTitle;

  /// No description provided for @onboardingAnimalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add animals'**
  String get onboardingAnimalsTitle;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @pregnant.
  ///
  /// In en, this message translates to:
  /// **'Pregnant'**
  String get pregnant;

  /// No description provided for @lactating.
  ///
  /// In en, this message translates to:
  /// **'Lactating'**
  String get lactating;

  /// No description provided for @readyToBreed.
  ///
  /// In en, this message translates to:
  /// **'Ready to breed'**
  String get readyToBreed;

  /// No description provided for @sick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get sick;

  /// No description provided for @cullFlagged.
  ///
  /// In en, this message translates to:
  /// **'Cull flagged'**
  String get cullFlagged;

  /// No description provided for @allSpecies.
  ///
  /// In en, this message translates to:
  /// **'All species'**
  String get allSpecies;

  /// No description provided for @cattle.
  ///
  /// In en, this message translates to:
  /// **'Cattle'**
  String get cattle;

  /// No description provided for @goats.
  ///
  /// In en, this message translates to:
  /// **'Goats'**
  String get goats;

  /// No description provided for @sheep.
  ///
  /// In en, this message translates to:
  /// **'Sheep'**
  String get sheep;

  /// No description provided for @tasksToday.
  ///
  /// In en, this message translates to:
  /// **'Tasks today'**
  String get tasksToday;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @livestockValue.
  ///
  /// In en, this message translates to:
  /// **'Livestock value'**
  String get livestockValue;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @buyAnimals.
  ///
  /// In en, this message translates to:
  /// **'Buy animals'**
  String get buyAnimals;

  /// No description provided for @sellAnimals.
  ///
  /// In en, this message translates to:
  /// **'Sell animals'**
  String get sellAnimals;

  /// No description provided for @buyAnimalsInventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record a purchase and add animals to the herd'**
  String get buyAnimalsInventorySubtitle;

  /// No description provided for @sellAnimalsInventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sell animals and update herd inventory'**
  String get sellAnimalsInventorySubtitle;

  /// No description provided for @purchaser.
  ///
  /// In en, this message translates to:
  /// **'Purchaser'**
  String get purchaser;

  /// No description provided for @pricePaidSar.
  ///
  /// In en, this message translates to:
  /// **'Price paid (SAR)'**
  String get pricePaidSar;

  /// No description provided for @dateOfSale.
  ///
  /// In en, this message translates to:
  /// **'Date of sale'**
  String get dateOfSale;

  /// No description provided for @totalWeightKgOptional.
  ///
  /// In en, this message translates to:
  /// **'Total weight (kg, optional)'**
  String get totalWeightKgOptional;

  /// No description provided for @salePurposeOptional.
  ///
  /// In en, this message translates to:
  /// **'Purpose of sale (optional)'**
  String get salePurposeOptional;

  /// No description provided for @searchFarmTags.
  ///
  /// In en, this message translates to:
  /// **'Search tags on the farm'**
  String get searchFarmTags;

  /// No description provided for @animalsToSell.
  ///
  /// In en, this message translates to:
  /// **'Animals to sell'**
  String get animalsToSell;

  /// No description provided for @confirmSale.
  ///
  /// In en, this message translates to:
  /// **'Confirm sale'**
  String get confirmSale;

  /// No description provided for @saleRecorded.
  ///
  /// In en, this message translates to:
  /// **'Sale recorded'**
  String get saleRecorded;

  /// No description provided for @addAtLeastOneAnimal.
  ///
  /// In en, this message translates to:
  /// **'Add at least one animal to sell'**
  String get addAtLeastOneAnimal;

  /// No description provided for @enterPurchaserAndPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter purchaser and price paid'**
  String get enterPurchaserAndPrice;

  /// No description provided for @noAnimalsMatchTag.
  ///
  /// In en, this message translates to:
  /// **'No active animals match this tag'**
  String get noAnimalsMatchTag;

  /// No description provided for @animalAlreadyInSaleList.
  ///
  /// In en, this message translates to:
  /// **'Already added to this sale'**
  String get animalAlreadyInSaleList;

  /// No description provided for @removeFromSaleList.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeFromSaleList;

  /// No description provided for @addToSale.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addToSale;

  /// No description provided for @inventoryBurgerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Feed, medical & livestock'**
  String get inventoryBurgerSubtitle;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @fixTheGap.
  ///
  /// In en, this message translates to:
  /// **'Fix the gap'**
  String get fixTheGap;

  /// No description provided for @alertsAndTasks.
  ///
  /// In en, this message translates to:
  /// **'Alerts & tasks'**
  String get alertsAndTasks;

  /// No description provided for @animalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Animal not found'**
  String get animalNotFound;

  /// No description provided for @groupNotFound.
  ///
  /// In en, this message translates to:
  /// **'Group not found'**
  String get groupNotFound;

  /// No description provided for @methaneEmissions.
  ///
  /// In en, this message translates to:
  /// **'Methane emissions'**
  String get methaneEmissions;

  /// No description provided for @methaneRegionMiddleEast.
  ///
  /// In en, this message translates to:
  /// **'Middle East (GCC)'**
  String get methaneRegionMiddleEast;

  /// No description provided for @groupAverage.
  ///
  /// In en, this message translates to:
  /// **'Group average'**
  String get groupAverage;

  /// No description provided for @groupTotal.
  ///
  /// In en, this message translates to:
  /// **'Group total'**
  String get groupTotal;

  /// No description provided for @emissionsTotal.
  ///
  /// In en, this message translates to:
  /// **'Emissions total'**
  String get emissionsTotal;

  /// No description provided for @methaneCo2eGroupTotal.
  ///
  /// In en, this message translates to:
  /// **'{co2e} kg CO₂e · {headCount} head'**
  String methaneCo2eGroupTotal(String co2e, int headCount);

  /// No description provided for @methaneByAnimal.
  ///
  /// In en, this message translates to:
  /// **'By animal (CH₄ / day)'**
  String get methaneByAnimal;

  /// No description provided for @methaneMoreAnimals.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more animals'**
  String methaneMoreAnimals(int count);

  /// No description provided for @methaneCh4Grams.
  ///
  /// In en, this message translates to:
  /// **'{grams} g CH₄'**
  String methaneCh4Grams(String grams);

  /// No description provided for @methaneCo2eSummary.
  ///
  /// In en, this message translates to:
  /// **'{co2e} kg CO₂e · {weight} kg avg BW'**
  String methaneCo2eSummary(String co2e, String weight);

  /// No description provided for @methaneGramsShort.
  ///
  /// In en, this message translates to:
  /// **'{grams} g'**
  String methaneGramsShort(String grams);

  /// No description provided for @methaneAgeMonths.
  ///
  /// In en, this message translates to:
  /// **'{months} mo'**
  String methaneAgeMonths(int months);

  /// No description provided for @lactationNumber.
  ///
  /// In en, this message translates to:
  /// **'Lactation {number}'**
  String lactationNumber(int number);

  /// No description provided for @lactationDayOf305.
  ///
  /// In en, this message translates to:
  /// **'{stage} · Day {day} of 305'**
  String lactationDayOf305(String stage, int day);

  /// No description provided for @lactationCalvingExpected.
  ///
  /// In en, this message translates to:
  /// **'Calving {date} · expected ~{litres} L today'**
  String lactationCalvingExpected(String date, String litres);

  /// No description provided for @lactationCurveTitle.
  ///
  /// In en, this message translates to:
  /// **'Lactation curve (milk vs day in milk)'**
  String get lactationCurveTitle;

  /// No description provided for @lactationCurveLegend.
  ///
  /// In en, this message translates to:
  /// **'Solid line = recorded milk · dashed = expected (breed average)'**
  String get lactationCurveLegend;

  /// No description provided for @lactationChartNeedsData.
  ///
  /// In en, this message translates to:
  /// **'Record at least two milkings to show the lactation curve.'**
  String get lactationChartNeedsData;

  /// No description provided for @chartDayLitres.
  ///
  /// In en, this message translates to:
  /// **'Day {day}\n{litres} L'**
  String chartDayLitres(int day, String litres);

  /// No description provided for @milkingTodayVolume.
  ///
  /// In en, this message translates to:
  /// **'Today\'s volume'**
  String get milkingTodayVolume;

  /// No description provided for @notRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get notRecorded;

  /// No description provided for @litresValue.
  ///
  /// In en, this message translates to:
  /// **'{litres} L'**
  String litresValue(String litres);

  /// No description provided for @recordMilk.
  ///
  /// In en, this message translates to:
  /// **'Record milk'**
  String get recordMilk;

  /// No description provided for @recordBulkMilkSale.
  ///
  /// In en, this message translates to:
  /// **'Record bulk milk sale (income)'**
  String get recordBulkMilkSale;

  /// No description provided for @withdrawalMilkBlocked.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal period active — milk cannot be sold or recorded for human consumption.'**
  String get withdrawalMilkBlocked;

  /// No description provided for @todayVsRequirement.
  ///
  /// In en, this message translates to:
  /// **'Today v Required Nutrition'**
  String get todayVsRequirement;

  /// No description provided for @milkingKpis.
  ///
  /// In en, this message translates to:
  /// **'Milking KPIs'**
  String get milkingKpis;

  /// No description provided for @topProducers.
  ///
  /// In en, this message translates to:
  /// **'Top producers'**
  String get topProducers;

  /// No description provided for @todaysFeed.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Feed'**
  String get todaysFeed;

  /// No description provided for @energyGapDetected.
  ///
  /// In en, this message translates to:
  /// **'Energy gap detected'**
  String get energyGapDetected;

  /// No description provided for @lactationStageFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh (early lactation)'**
  String get lactationStageFresh;

  /// No description provided for @lactationStagePeak.
  ///
  /// In en, this message translates to:
  /// **'Peak lactation'**
  String get lactationStagePeak;

  /// No description provided for @lactationStageMid.
  ///
  /// In en, this message translates to:
  /// **'Mid lactation'**
  String get lactationStageMid;

  /// No description provided for @lactationStageLate.
  ///
  /// In en, this message translates to:
  /// **'Late lactation'**
  String get lactationStageLate;

  /// No description provided for @lactationStageDry.
  ///
  /// In en, this message translates to:
  /// **'Dry period'**
  String get lactationStageDry;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @sex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @groupPurpose.
  ///
  /// In en, this message translates to:
  /// **'Group purpose'**
  String get groupPurpose;

  /// No description provided for @animalPurpose.
  ///
  /// In en, this message translates to:
  /// **'Animal purpose'**
  String get animalPurpose;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @loadingBreeds.
  ///
  /// In en, this message translates to:
  /// **'Loading breeds…'**
  String get loadingBreeds;

  /// No description provided for @saveAnimal.
  ///
  /// In en, this message translates to:
  /// **'Save animal'**
  String get saveAnimal;

  /// No description provided for @saveGroup.
  ///
  /// In en, this message translates to:
  /// **'Save group'**
  String get saveGroup;

  /// No description provided for @newAnimal.
  ///
  /// In en, this message translates to:
  /// **'New animal'**
  String get newAnimal;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroup;

  /// No description provided for @onboardNewAnimal.
  ///
  /// In en, this message translates to:
  /// **'Onboard new animal'**
  String get onboardNewAnimal;

  /// No description provided for @onboardNewGroup.
  ///
  /// In en, this message translates to:
  /// **'Onboard new group'**
  String get onboardNewGroup;

  /// No description provided for @groupWizardDetails.
  ///
  /// In en, this message translates to:
  /// **'Group details'**
  String get groupWizardDetails;

  /// No description provided for @groupWizardHerd.
  ///
  /// In en, this message translates to:
  /// **'Herd profile'**
  String get groupWizardHerd;

  /// No description provided for @groupWizardAnimals.
  ///
  /// In en, this message translates to:
  /// **'Individual animals'**
  String get groupWizardAnimals;

  /// No description provided for @groupWizardSummary.
  ///
  /// In en, this message translates to:
  /// **'Group summary'**
  String get groupWizardSummary;

  /// No description provided for @addAMeal.
  ///
  /// In en, this message translates to:
  /// **'Add a meal'**
  String get addAMeal;

  /// No description provided for @addAnotherGroup.
  ///
  /// In en, this message translates to:
  /// **'Add another group'**
  String get addAnotherGroup;

  /// No description provided for @saveMeal.
  ///
  /// In en, this message translates to:
  /// **'Save meal'**
  String get saveMeal;

  /// No description provided for @searchMeals.
  ///
  /// In en, this message translates to:
  /// **'Search meals'**
  String get searchMeals;

  /// No description provided for @mealAmountKg.
  ///
  /// In en, this message translates to:
  /// **'Amount (kg)'**
  String get mealAmountKg;

  /// No description provided for @groupCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your group is ready. Add a meal now or skip and set feeding up later.'**
  String get groupCreatedMessage;

  /// No description provided for @purchaseWizardDetails.
  ///
  /// In en, this message translates to:
  /// **'Purchase details'**
  String get purchaseWizardDetails;

  /// No description provided for @purchaseWizardLivestock.
  ///
  /// In en, this message translates to:
  /// **'Livestock profile'**
  String get purchaseWizardLivestock;

  /// No description provided for @purchaseWizardAnimals.
  ///
  /// In en, this message translates to:
  /// **'Individual animals'**
  String get purchaseWizardAnimals;

  /// No description provided for @finishPurchase.
  ///
  /// In en, this message translates to:
  /// **'Complete purchase'**
  String get finishPurchase;

  /// No description provided for @purchaseRecorded.
  ///
  /// In en, this message translates to:
  /// **'Purchase recorded'**
  String get purchaseRecorded;

  /// No description provided for @enterSupplierAndPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter where animals were bought from and purchase price'**
  String get enterSupplierAndPrice;

  /// No description provided for @numberOfAnimalsPurchased.
  ///
  /// In en, this message translates to:
  /// **'Number of animals purchased'**
  String get numberOfAnimalsPurchased;

  /// No description provided for @headCount.
  ///
  /// In en, this message translates to:
  /// **'Number in group'**
  String get headCount;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get ageRange;

  /// No description provided for @vaccinated.
  ///
  /// In en, this message translates to:
  /// **'Vaccinated'**
  String get vaccinated;

  /// No description provided for @vaccinationEvent.
  ///
  /// In en, this message translates to:
  /// **'Vaccination event'**
  String get vaccinationEvent;

  /// No description provided for @createVaccinationEvent.
  ///
  /// In en, this message translates to:
  /// **'Create vaccination event'**
  String get createVaccinationEvent;

  /// No description provided for @selectVaccinationEvent.
  ///
  /// In en, this message translates to:
  /// **'Select vaccination event'**
  String get selectVaccinationEvent;

  /// No description provided for @noVaccinationEvents.
  ///
  /// In en, this message translates to:
  /// **'No vaccination events on file'**
  String get noVaccinationEvents;

  /// No description provided for @noActiveVaccinationEvents.
  ///
  /// In en, this message translates to:
  /// **'No active vaccination events in the last 48 hours'**
  String get noActiveVaccinationEvents;

  /// No description provided for @animalInGroup.
  ///
  /// In en, this message translates to:
  /// **'Animal {index}'**
  String animalInGroup(int index);

  /// No description provided for @markPregnant.
  ///
  /// In en, this message translates to:
  /// **'Mark pregnant'**
  String get markPregnant;

  /// No description provided for @monthsPregnant.
  ///
  /// In en, this message translates to:
  /// **'Months pregnant'**
  String get monthsPregnant;

  /// No description provided for @weaned.
  ///
  /// In en, this message translates to:
  /// **'Weaned'**
  String get weaned;

  /// No description provided for @markSick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get markSick;

  /// No description provided for @sickDescription.
  ///
  /// In en, this message translates to:
  /// **'Illness description'**
  String get sickDescription;

  /// No description provided for @markCull.
  ///
  /// In en, this message translates to:
  /// **'Cull'**
  String get markCull;

  /// No description provided for @finishGroup.
  ///
  /// In en, this message translates to:
  /// **'Complete group'**
  String get finishGroup;

  /// No description provided for @wizardStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String wizardStepOf(int current, int total);

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @enterAnimalsIndividually.
  ///
  /// In en, this message translates to:
  /// **'Enter animals individually'**
  String get enterAnimalsIndividually;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @tagNumber.
  ///
  /// In en, this message translates to:
  /// **'Tag number'**
  String get tagNumber;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @weightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 412'**
  String get weightHint;

  /// No description provided for @birthDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Birth date (optional)'**
  String get birthDateOptional;

  /// No description provided for @bornOnDate.
  ///
  /// In en, this message translates to:
  /// **'Born {day}/{month}/{year}'**
  String bornOnDate(int day, int month, int year);

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @ageNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get ageNew;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// No description provided for @newFarmSetup.
  ///
  /// In en, this message translates to:
  /// **'New farm setup'**
  String get newFarmSetup;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// No description provided for @welcomeBrand.
  ///
  /// In en, this message translates to:
  /// **'Greener Herd'**
  String get welcomeBrand;

  /// No description provided for @gaveBirth.
  ///
  /// In en, this message translates to:
  /// **'Gave birth'**
  String get gaveBirth;

  /// No description provided for @recordBirthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record live birth or stillborn'**
  String get recordBirthSubtitle;

  /// No description provided for @miscarriage.
  ///
  /// In en, this message translates to:
  /// **'Miscarriage'**
  String get miscarriage;

  /// No description provided for @miscarriageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear pregnancy and flag for follow-up'**
  String get miscarriageSubtitle;

  /// No description provided for @flagForCull.
  ///
  /// In en, this message translates to:
  /// **'Flag for cull'**
  String get flagForCull;

  /// No description provided for @clearCullFlag.
  ///
  /// In en, this message translates to:
  /// **'Clear cull flag'**
  String get clearCullFlag;

  /// No description provided for @markSold.
  ///
  /// In en, this message translates to:
  /// **'Mark sold'**
  String get markSold;

  /// No description provided for @recordBirth.
  ///
  /// In en, this message translates to:
  /// **'Record birth'**
  String get recordBirth;

  /// No description provided for @bornAlive.
  ///
  /// In en, this message translates to:
  /// **'Born alive'**
  String get bornAlive;

  /// No description provided for @bornAliveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy cleared; lactating tag added only if not already set'**
  String get bornAliveSubtitle;

  /// No description provided for @stillborn.
  ///
  /// In en, this message translates to:
  /// **'Stillborn'**
  String get stillborn;

  /// No description provided for @stillbornSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy cleared; stillborn recorded'**
  String get stillbornSubtitle;

  /// No description provided for @saveBirthRecord.
  ///
  /// In en, this message translates to:
  /// **'Save birth record'**
  String get saveBirthRecord;

  /// No description provided for @pregnancyOutcome.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy outcome'**
  String get pregnancyOutcome;

  /// No description provided for @howDidPregnancyEnd.
  ///
  /// In en, this message translates to:
  /// **'How did the pregnancy end?'**
  String get howDidPregnancyEnd;

  /// No description provided for @birthRecordedFor.
  ///
  /// In en, this message translates to:
  /// **'Birth recorded for #{tag}'**
  String birthRecordedFor(String tag);

  /// No description provided for @stillbirthRecordedFor.
  ///
  /// In en, this message translates to:
  /// **'Stillbirth recorded for #{tag}'**
  String stillbirthRecordedFor(String tag);

  /// No description provided for @recordMiscarriage.
  ///
  /// In en, this message translates to:
  /// **'Record miscarriage'**
  String get recordMiscarriage;

  /// No description provided for @miscarriageRecordedFor.
  ///
  /// In en, this message translates to:
  /// **'Miscarriage recorded for #{tag}'**
  String miscarriageRecordedFor(String tag);

  /// No description provided for @miscarriageConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will clear the pregnant status and add a miscarriage flag for follow-up in Health and reports.'**
  String get miscarriageConfirmBody;

  /// No description provided for @confirmMiscarriage.
  ///
  /// In en, this message translates to:
  /// **'Confirm miscarriage'**
  String get confirmMiscarriage;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @voiceAddTask.
  ///
  /// In en, this message translates to:
  /// **'Voice add a task'**
  String get voiceAddTask;

  /// No description provided for @voiceHoldMock.
  ///
  /// In en, this message translates to:
  /// **'Hold to talk (mock)'**
  String get voiceHoldMock;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get hold;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @addedManually.
  ///
  /// In en, this message translates to:
  /// **'Added manually'**
  String get addedManually;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskTitle;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @medicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicine;

  /// No description provided for @mealPlans.
  ///
  /// In en, this message translates to:
  /// **'Meal plans'**
  String get mealPlans;

  /// No description provided for @viewMealPlans.
  ///
  /// In en, this message translates to:
  /// **'View meal plans'**
  String get viewMealPlans;

  /// No description provided for @recordFeeding.
  ///
  /// In en, this message translates to:
  /// **'Record feeding'**
  String get recordFeeding;

  /// No description provided for @addFeed.
  ///
  /// In en, this message translates to:
  /// **'Add feed'**
  String get addFeed;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add medicine'**
  String get addMedicine;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine name'**
  String get medicineName;

  /// No description provided for @medicineTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type (e.g. ANTIBIOTIC)'**
  String get medicineTypeLabel;

  /// No description provided for @medicineProductSource.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get medicineProductSource;

  /// No description provided for @fromProductList.
  ///
  /// In en, this message translates to:
  /// **'From list'**
  String get fromProductList;

  /// No description provided for @customMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Custom name'**
  String get customMedicineName;

  /// No description provided for @selectMedicineProduct.
  ///
  /// In en, this message translates to:
  /// **'Select medicine'**
  String get selectMedicineProduct;

  /// No description provided for @searchCatalogue.
  ///
  /// In en, this message translates to:
  /// **'Search catalogue'**
  String get searchCatalogue;

  /// No description provided for @medicineProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'matches'**
  String get medicineProductsAvailable;

  /// No description provided for @medicineCatalogueSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search {count} catalogue products'**
  String medicineCatalogueSearchHint(int count);

  /// No description provided for @activeIngredient.
  ///
  /// In en, this message translates to:
  /// **'Active ingredient'**
  String get activeIngredient;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @routeOfAdministration.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeOfAdministration;

  /// No description provided for @inStockLabel.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStockLabel;

  /// No description provided for @selectMedicineOrEnterName.
  ///
  /// In en, this message translates to:
  /// **'Pick a product from the list above'**
  String get selectMedicineOrEnterName;

  /// No description provided for @withdrawalPrefilledHint.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal periods are pre-filled from the product — adjust if your vet advises differently.'**
  String get withdrawalPrefilledHint;

  /// No description provided for @medicineNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a medicine or enter a custom name'**
  String get medicineNameRequired;

  /// No description provided for @supplierNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Supplier name is required'**
  String get supplierNameRequired;

  /// No description provided for @estimatedWeeklyUsage.
  ///
  /// In en, this message translates to:
  /// **'Estimated weekly usage (for low-stock alerts)'**
  String get estimatedWeeklyUsage;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select product'**
  String get selectProduct;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @addFeedProduct.
  ///
  /// In en, this message translates to:
  /// **'Add feed product'**
  String get addFeedProduct;

  /// No description provided for @noFeedInInventory.
  ///
  /// In en, this message translates to:
  /// **'No feed in inventory yet.'**
  String get noFeedInInventory;

  /// No description provided for @noMedicineInInventory.
  ///
  /// In en, this message translates to:
  /// **'No medicines in inventory yet.'**
  String get noMedicineInInventory;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStock;

  /// No description provided for @lowStockFeedBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} feed item(s) below one week\'s supply'**
  String lowStockFeedBanner(int count);

  /// No description provided for @recordExpense.
  ///
  /// In en, this message translates to:
  /// **'Record expense'**
  String get recordExpense;

  /// No description provided for @recordIncome.
  ///
  /// In en, this message translates to:
  /// **'Record income'**
  String get recordIncome;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @printReport.
  ///
  /// In en, this message translates to:
  /// **'Print report'**
  String get printReport;

  /// No description provided for @milkSale.
  ///
  /// In en, this message translates to:
  /// **'Milk sale'**
  String get milkSale;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get addEntry;

  /// No description provided for @categoryOptionalPreset.
  ///
  /// In en, this message translates to:
  /// **'Category (optional preset)'**
  String get categoryOptionalPreset;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @recentEntries.
  ///
  /// In en, this message translates to:
  /// **'Recent entries'**
  String get recentEntries;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @animalsCount.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animalsCount;

  /// No description provided for @females.
  ///
  /// In en, this message translates to:
  /// **'Females'**
  String get females;

  /// No description provided for @avgPerHead.
  ///
  /// In en, this message translates to:
  /// **'Avg / head'**
  String get avgPerHead;

  /// No description provided for @todayTotal.
  ///
  /// In en, this message translates to:
  /// **'Today total'**
  String get todayTotal;

  /// No description provided for @onWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'On withdrawal'**
  String get onWithdrawal;

  /// No description provided for @recordAction.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordAction;

  /// No description provided for @updateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// No description provided for @updateFeeding.
  ///
  /// In en, this message translates to:
  /// **'Update feeding'**
  String get updateFeeding;

  /// No description provided for @updatingFeeding.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get updatingFeeding;

  /// No description provided for @noFeedToday.
  ///
  /// In en, this message translates to:
  /// **'No feed recorded today.'**
  String get noFeedToday;

  /// No description provided for @nutritionNoFeedLoggedHint.
  ///
  /// In en, this message translates to:
  /// **'Actual intake is zero until you log feed in Today\'s feed below.'**
  String get nutritionNoFeedLoggedHint;

  /// No description provided for @noMilkToday.
  ///
  /// In en, this message translates to:
  /// **'No milk records today.'**
  String get noMilkToday;

  /// No description provided for @dryMatter.
  ///
  /// In en, this message translates to:
  /// **'Dry matter'**
  String get dryMatter;

  /// No description provided for @crudeProtein.
  ///
  /// In en, this message translates to:
  /// **'Crude protein'**
  String get crudeProtein;

  /// No description provided for @energyMe.
  ///
  /// In en, this message translates to:
  /// **'Energy (ME)'**
  String get energyMe;

  /// No description provided for @ndf.
  ///
  /// In en, this message translates to:
  /// **'NDF'**
  String get ndf;

  /// No description provided for @calcium.
  ///
  /// In en, this message translates to:
  /// **'Calcium'**
  String get calcium;

  /// No description provided for @phosphorus.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus'**
  String get phosphorus;

  /// No description provided for @legendOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get legendOk;

  /// No description provided for @legendWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get legendWarning;

  /// No description provided for @legendAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get legendAction;

  /// No description provided for @purposeHeading.
  ///
  /// In en, this message translates to:
  /// **'PURPOSE'**
  String get purposeHeading;

  /// No description provided for @descriptionHeading.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get descriptionHeading;

  /// No description provided for @noDescriptionRecorded.
  ///
  /// In en, this message translates to:
  /// **'No description recorded.'**
  String get noDescriptionRecorded;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @loadedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} loaded'**
  String loadedCount(int count);

  /// No description provided for @perHead.
  ///
  /// In en, this message translates to:
  /// **'Per head'**
  String get perHead;

  /// No description provided for @dailyCostPerHead.
  ///
  /// In en, this message translates to:
  /// **'Daily cost / head'**
  String get dailyCostPerHead;

  /// No description provided for @todaysVolume.
  ///
  /// In en, this message translates to:
  /// **'Today\'s volume'**
  String get todaysVolume;

  /// No description provided for @avgLitresMilking.
  ///
  /// In en, this message translates to:
  /// **'Avg {avg} L/head · {count} milking'**
  String avgLitresMilking(String avg, int count);

  /// No description provided for @withdrawalDays.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal · {days} d'**
  String withdrawalDays(int days);

  /// No description provided for @noAnimalsInGroup.
  ///
  /// In en, this message translates to:
  /// **'No animals assigned to this group yet.'**
  String get noAnimalsInGroup;

  /// No description provided for @groupTitle.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupTitle;

  /// No description provided for @recentVaccinations.
  ///
  /// In en, this message translates to:
  /// **'Recent vaccinations'**
  String get recentVaccinations;

  /// No description provided for @activeTreatments.
  ///
  /// In en, this message translates to:
  /// **'Active treatments'**
  String get activeTreatments;

  /// No description provided for @sickAnimals.
  ///
  /// In en, this message translates to:
  /// **'Sick animals'**
  String get sickAnimals;

  /// No description provided for @breedingStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get breedingStatus;

  /// No description provided for @breedingStatusSection.
  ///
  /// In en, this message translates to:
  /// **'Breeding status'**
  String get breedingStatusSection;

  /// No description provided for @markAsHeifer.
  ///
  /// In en, this message translates to:
  /// **'Heifer'**
  String get markAsHeifer;

  /// No description provided for @heiferHint.
  ///
  /// In en, this message translates to:
  /// **'Young female cattle that has not yet calved'**
  String get heiferHint;

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDateLabel;

  /// No description provided for @chooseDueDate.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose due date'**
  String get chooseDueDate;

  /// No description provided for @prolificacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Prolificacy'**
  String get prolificacyLabel;

  /// No description provided for @breedingStatusConflict.
  ///
  /// In en, this message translates to:
  /// **'An animal cannot be both ready to breed and pregnant'**
  String get breedingStatusConflict;

  /// No description provided for @fertilityMethodRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a fertility method'**
  String get fertilityMethodRequired;

  /// No description provided for @gestation.
  ///
  /// In en, this message translates to:
  /// **'Gestation'**
  String get gestation;

  /// No description provided for @gestationMonths.
  ///
  /// In en, this message translates to:
  /// **'Gestation (months)'**
  String get gestationMonths;

  /// No description provided for @gestationMonthsValue.
  ///
  /// In en, this message translates to:
  /// **'{months} months'**
  String gestationMonthsValue(int months);

  /// No description provided for @markReadyToBreed.
  ///
  /// In en, this message translates to:
  /// **'Mark ready to breed'**
  String get markReadyToBreed;

  /// No description provided for @recordPregnancyOutcome.
  ///
  /// In en, this message translates to:
  /// **'Record pregnancy outcome'**
  String get recordPregnancyOutcome;

  /// No description provided for @clearReadyToBreed.
  ///
  /// In en, this message translates to:
  /// **'Clear ready to breed'**
  String get clearReadyToBreed;

  /// No description provided for @breedingHistory.
  ///
  /// In en, this message translates to:
  /// **'Breeding history'**
  String get breedingHistory;

  /// No description provided for @breedingStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Breeding status updated'**
  String get breedingStatusUpdated;

  /// No description provided for @breedingOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get breedingOpen;

  /// No description provided for @recentMiscarriage.
  ///
  /// In en, this message translates to:
  /// **'Recent miscarriage'**
  String get recentMiscarriage;

  /// No description provided for @markedReadyToBreed.
  ///
  /// In en, this message translates to:
  /// **'Marked ready to breed'**
  String get markedReadyToBreed;

  /// No description provided for @pregnancyConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy confirmed'**
  String get pregnancyConfirmed;

  /// No description provided for @pregnancyConfirmedMo.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy confirmed ({months} mo)'**
  String pregnancyConfirmedMo(int months);

  /// No description provided for @lactatingPostCalving.
  ///
  /// In en, this message translates to:
  /// **'Lactating / post-calving'**
  String get lactatingPostCalving;

  /// No description provided for @stillbirthRecorded.
  ///
  /// In en, this message translates to:
  /// **'Stillbirth recorded'**
  String get stillbirthRecorded;

  /// No description provided for @miscarriageRecorded.
  ///
  /// In en, this message translates to:
  /// **'Miscarriage recorded'**
  String get miscarriageRecorded;

  /// No description provided for @noBreedingEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No breeding events recorded yet.'**
  String get noBreedingEventsYet;

  /// No description provided for @breedingOverview.
  ///
  /// In en, this message translates to:
  /// **'Breeding overview'**
  String get breedingOverview;

  /// No description provided for @pregnantAnimals.
  ///
  /// In en, this message translates to:
  /// **'Pregnant animals'**
  String get pregnantAnimals;

  /// No description provided for @gestationMonthsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{months} months gestation'**
  String gestationMonthsSubtitle(int months);

  /// No description provided for @openAnimalProfiles.
  ///
  /// In en, this message translates to:
  /// **'Open animal profiles'**
  String get openAnimalProfiles;

  /// No description provided for @openAnimalsForBreeding.
  ///
  /// In en, this message translates to:
  /// **'Open animals for breeding actions from each animal profile.'**
  String get openAnimalsForBreeding;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm name'**
  String get farmName;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @selectSpeciesOnFarm.
  ///
  /// In en, this message translates to:
  /// **'Select the species on your farm'**
  String get selectSpeciesOnFarm;

  /// No description provided for @primaryPurpose.
  ///
  /// In en, this message translates to:
  /// **'Primary purpose'**
  String get primaryPurpose;

  /// No description provided for @purposeForSpecies.
  ///
  /// In en, this message translates to:
  /// **'Primary purpose for {species}'**
  String purposeForSpecies(String species);

  /// No description provided for @setThePurposeForEachSpecies.
  ///
  /// In en, this message translates to:
  /// **'Set the primary purpose for each species'**
  String get setThePurposeForEachSpecies;

  /// No description provided for @purposeMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get purposeMilk;

  /// No description provided for @purposeMeat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get purposeMeat;

  /// No description provided for @purposeMilkMeat.
  ///
  /// In en, this message translates to:
  /// **'Milk & Meat'**
  String get purposeMilkMeat;

  /// No description provided for @chooseHowToAddAnimals.
  ///
  /// In en, this message translates to:
  /// **'Choose how to add your first animals. You can always do this later from the Animals tab.'**
  String get chooseHowToAddAnimals;

  /// No description provided for @enterAsGroup.
  ///
  /// In en, this message translates to:
  /// **'Enter as a group'**
  String get enterAsGroup;

  /// No description provided for @selectAtLeastOneSpecies.
  ///
  /// In en, this message translates to:
  /// **'Select at least one species'**
  String get selectAtLeastOneSpecies;

  /// No description provided for @selectAtLeastOneAnimal.
  ///
  /// In en, this message translates to:
  /// **'Select at least one animal'**
  String get selectAtLeastOneAnimal;

  /// No description provided for @myFarm.
  ///
  /// In en, this message translates to:
  /// **'My farm'**
  String get myFarm;

  /// No description provided for @linkedToAccount.
  ///
  /// In en, this message translates to:
  /// **'Linked to {provider} account'**
  String linkedToAccount(String provider);

  /// No description provided for @providerGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get providerGoogle;

  /// No description provided for @providerApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get providerApple;

  /// No description provided for @providerFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get providerFacebook;

  /// No description provided for @inviteTeamMember.
  ///
  /// In en, this message translates to:
  /// **'Invite team member'**
  String get inviteTeamMember;

  /// No description provided for @inviteTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send an app link by email or WhatsApp. They can open it to join your farm.'**
  String get inviteTeamSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @phoneWithCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Phone (with country code)'**
  String get phoneWithCountryCode;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @farmHand.
  ///
  /// In en, this message translates to:
  /// **'Farm hand'**
  String get farmHand;

  /// No description provided for @veterinarian.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian'**
  String get veterinarian;

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send invite'**
  String get sendInvite;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone'**
  String get enterValidPhone;

  /// No description provided for @inviteSentOpen.
  ///
  /// In en, this message translates to:
  /// **'Invite sent — open {channel} to finish'**
  String inviteSentOpen(String channel);

  /// No description provided for @inviteCreated.
  ///
  /// In en, this message translates to:
  /// **'Invite created. Link: {link}'**
  String inviteCreated(String link);

  /// No description provided for @inviteFailed.
  ///
  /// In en, this message translates to:
  /// **'Invite failed: {error}'**
  String inviteFailed(String error);

  /// No description provided for @joinFarmSubject.
  ///
  /// In en, this message translates to:
  /// **'Join {farmName} on GreenerHerd'**
  String joinFarmSubject(String farmName);

  /// No description provided for @channelEmail.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get channelEmail;

  /// No description provided for @channelWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get channelWhatsapp;

  /// No description provided for @recordPurchase.
  ///
  /// In en, this message translates to:
  /// **'Record purchase'**
  String get recordPurchase;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @animalsPurchased.
  ///
  /// In en, this message translates to:
  /// **'Animals purchased'**
  String get animalsPurchased;

  /// No description provided for @totalSar.
  ///
  /// In en, this message translates to:
  /// **'Total (SAR)'**
  String get totalSar;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @notificationsRecommended.
  ///
  /// In en, this message translates to:
  /// **'Notifications & recommended tasks'**
  String get notificationsRecommended;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders for feed, breeding, health, weather'**
  String get notificationsSubtitle;

  /// No description provided for @notificationsDigestAt.
  ///
  /// In en, this message translates to:
  /// **'Daily digest at 06:00'**
  String get notificationsDigestAt;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettings;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpSupport;

  /// No description provided for @farmSection.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get farmSection;

  /// No description provided for @switchFarm.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchFarm;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @fullAccess.
  ///
  /// In en, this message translates to:
  /// **'Full access'**
  String get fullAccess;

  /// No description provided for @manageTeam.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageTeam;

  /// No description provided for @switchFarmMock.
  ///
  /// In en, this message translates to:
  /// **'Farm switching is not available in this demo.'**
  String get switchFarmMock;

  /// No description provided for @inviteManageTeam.
  ///
  /// In en, this message translates to:
  /// **'Invite and manage your team'**
  String get inviteManageTeam;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @farmOwner.
  ///
  /// In en, this message translates to:
  /// **'Farm owner'**
  String get farmOwner;

  /// No description provided for @manageGroups.
  ///
  /// In en, this message translates to:
  /// **'Manage groups'**
  String get manageGroups;

  /// No description provided for @exportPdfCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export PDF / CSV'**
  String get exportPdfCsvSubtitle;

  /// No description provided for @feedAndMedicalStock.
  ///
  /// In en, this message translates to:
  /// **'Feed & medical stock'**
  String get feedAndMedicalStock;

  /// No description provided for @supportTopics.
  ///
  /// In en, this message translates to:
  /// **'Support & topics'**
  String get supportTopics;

  /// No description provided for @validMilkVolume.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid milk volume (litres)'**
  String get validMilkVolume;

  /// No description provided for @milkBlockedWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Milk recording blocked during medicine withdrawal'**
  String get milkBlockedWithdrawal;

  /// No description provided for @recordedMilkFor.
  ///
  /// In en, this message translates to:
  /// **'Recorded {litres} L for #{tag}'**
  String recordedMilkFor(String litres, String tag);

  /// No description provided for @previousTodayMilk.
  ///
  /// In en, this message translates to:
  /// **'Previous today: {litres} L'**
  String previousTodayMilk(String litres);

  /// No description provided for @todaysMilkLitres.
  ///
  /// In en, this message translates to:
  /// **'Today\'s milk (litres)'**
  String get todaysMilkLitres;

  /// No description provided for @recordMilkSaleIncome.
  ///
  /// In en, this message translates to:
  /// **'Record milk sale income'**
  String get recordMilkSaleIncome;

  /// No description provided for @recordMilkSaleIncomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds income on the Finance tab'**
  String get recordMilkSaleIncomeSubtitle;

  /// No description provided for @saleAmountSar.
  ///
  /// In en, this message translates to:
  /// **'Sale amount (SAR)'**
  String get saleAmountSar;

  /// No description provided for @catalogGaps.
  ///
  /// In en, this message translates to:
  /// **'Catalog gaps'**
  String get catalogGaps;

  /// No description provided for @recommendedFeeds.
  ///
  /// In en, this message translates to:
  /// **'Recommended feeds'**
  String get recommendedFeeds;

  /// No description provided for @addSupplement.
  ///
  /// In en, this message translates to:
  /// **'Add a supplement'**
  String get addSupplement;

  /// No description provided for @useFromInventory.
  ///
  /// In en, this message translates to:
  /// **'Use what you have'**
  String get useFromInventory;

  /// No description provided for @preFormulatedMixes.
  ///
  /// In en, this message translates to:
  /// **'Pre-formulated mixes'**
  String get preFormulatedMixes;

  /// No description provided for @suppliersNearYou.
  ///
  /// In en, this message translates to:
  /// **'Suppliers near you'**
  String get suppliersNearYou;

  /// No description provided for @topPick.
  ///
  /// In en, this message translates to:
  /// **'Top pick'**
  String get topPick;

  /// No description provided for @supplementAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get supplementAdded;

  /// No description provided for @supplementAdd.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get supplementAdd;

  /// No description provided for @supplementAddedToTodaysFeed.
  ///
  /// In en, this message translates to:
  /// **'Added to today\'s feed · nutrition updated'**
  String get supplementAddedToTodaysFeed;

  /// No description provided for @recommendedFeedWeight.
  ///
  /// In en, this message translates to:
  /// **'Recommended: {kg} kg'**
  String recommendedFeedWeight(String kg);

  /// No description provided for @supplementNutrientsAtWeight.
  ///
  /// In en, this message translates to:
  /// **'Energy {energy} MJ · Protein {protein} kg'**
  String supplementNutrientsAtWeight(String energy, String protein);

  /// No description provided for @supplementRemoved.
  ///
  /// In en, this message translates to:
  /// **'Supplement removed'**
  String get supplementRemoved;

  /// No description provided for @buyProductTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy {product}'**
  String buyProductTaskTitle(String product);

  /// No description provided for @buyTaskCreated.
  ///
  /// In en, this message translates to:
  /// **'Buy task added to your task list'**
  String get buyTaskCreated;

  /// No description provided for @projectedDailyCost.
  ///
  /// In en, this message translates to:
  /// **'Projected daily cost'**
  String get projectedDailyCost;

  /// No description provided for @recomputeGapHint.
  ///
  /// In en, this message translates to:
  /// **'Greener Herd will recompute the gap after the next feeding is logged.'**
  String get recomputeGapHint;

  /// No description provided for @kgPerDay.
  ///
  /// In en, this message translates to:
  /// **'kg/day'**
  String get kgPerDay;

  /// No description provided for @energyImpact.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energyImpact;

  /// No description provided for @proteinImpact.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get proteinImpact;

  /// No description provided for @applyToMorningMix.
  ///
  /// In en, this message translates to:
  /// **'Apply to morning mix'**
  String get applyToMorningMix;

  /// No description provided for @feedPlanApplied.
  ///
  /// In en, this message translates to:
  /// **'Feed plan applied'**
  String get feedPlanApplied;

  /// No description provided for @couldNotApplyFeedPlan.
  ///
  /// In en, this message translates to:
  /// **'Could not apply feed plan'**
  String get couldNotApplyFeedPlan;

  /// No description provided for @failedToApplyPlan.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply plan: {error}'**
  String failedToApplyPlan(String error);

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @catalogueProduct.
  ///
  /// In en, this message translates to:
  /// **'Catalogue product'**
  String get catalogueProduct;

  /// No description provided for @marketplaceListingName.
  ///
  /// In en, this message translates to:
  /// **'Marketplace listing name'**
  String get marketplaceListingName;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @currentStockKg.
  ///
  /// In en, this message translates to:
  /// **'Current stock (kg)'**
  String get currentStockKg;

  /// No description provided for @purchasedVolumeKg.
  ///
  /// In en, this message translates to:
  /// **'Purchased volume (kg)'**
  String get purchasedVolumeKg;

  /// No description provided for @purchasedVolumeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter purchased volume (kg)'**
  String get purchasedVolumeRequired;

  /// No description provided for @unitCostRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter unit cost (SAR per kg)'**
  String get unitCostRequired;

  /// No description provided for @inventoryCurrentStockKg.
  ///
  /// In en, this message translates to:
  /// **'Current stock: {kg} kg'**
  String inventoryCurrentStockKg(String kg);

  /// No description provided for @feedProductAlreadyInInventory.
  ///
  /// In en, this message translates to:
  /// **'This product is already in your inventory.'**
  String get feedProductAlreadyInInventory;

  /// No description provided for @feedAddProductOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Add feed product is for new items only. To buy more of an existing product, record a new purchase from the feed list.'**
  String get feedAddProductOnlyHint;

  /// No description provided for @feedRecordNewPurchase.
  ///
  /// In en, this message translates to:
  /// **'Record new purchase'**
  String get feedRecordNewPurchase;

  /// No description provided for @inventoryCostPerKg.
  ///
  /// In en, this message translates to:
  /// **'{cost} SAR/kg'**
  String inventoryCostPerKg(String cost);

  /// No description provided for @inventoryPreviousUnitCost.
  ///
  /// In en, this message translates to:
  /// **'Previous unit cost: {cost} SAR/kg'**
  String inventoryPreviousUnitCost(String cost);

  /// No description provided for @stockUpdated.
  ///
  /// In en, this message translates to:
  /// **'Stock updated'**
  String get stockUpdated;

  /// No description provided for @inventoryLastPurchaseKg.
  ///
  /// In en, this message translates to:
  /// **'+{kg} kg purchased'**
  String inventoryLastPurchaseKg(String kg);

  /// No description provided for @unitCostSar.
  ///
  /// In en, this message translates to:
  /// **'Unit cost (SAR/kg)'**
  String get unitCostSar;

  /// No description provided for @supplierName.
  ///
  /// In en, this message translates to:
  /// **'Supplier name'**
  String get supplierName;

  /// No description provided for @supplierPhone.
  ///
  /// In en, this message translates to:
  /// **'Supplier phone'**
  String get supplierPhone;

  /// No description provided for @nutritionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Nutritional information'**
  String get nutritionalInformation;

  /// No description provided for @dryMatterPercent.
  ///
  /// In en, this message translates to:
  /// **'Dry matter %'**
  String get dryMatterPercent;

  /// No description provided for @crudeProteinPercent.
  ///
  /// In en, this message translates to:
  /// **'Crude protein %'**
  String get crudeProteinPercent;

  /// No description provided for @nemMcalPerKg.
  ///
  /// In en, this message translates to:
  /// **'NEm (Mcal/kg)'**
  String get nemMcalPerKg;

  /// No description provided for @addToInventory.
  ///
  /// In en, this message translates to:
  /// **'Add to inventory'**
  String get addToInventory;

  /// No description provided for @feedType.
  ///
  /// In en, this message translates to:
  /// **'Feed type'**
  String get feedType;

  /// No description provided for @avgWithdrawalRemaining.
  ///
  /// In en, this message translates to:
  /// **'Avg {days} d remaining'**
  String avgWithdrawalRemaining(String days);

  /// No description provided for @addAnimalTitle.
  ///
  /// In en, this message translates to:
  /// **'Add animal'**
  String get addAnimalTitle;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @bornOnFarm.
  ///
  /// In en, this message translates to:
  /// **'Born on farm'**
  String get bornOnFarm;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// No description provided for @earTag.
  ///
  /// In en, this message translates to:
  /// **'Ear tag'**
  String get earTag;

  /// No description provided for @earTagHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 0473'**
  String get earTagHint;

  /// No description provided for @nameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get nameOptional;

  /// No description provided for @nameOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'You can add this later.'**
  String get nameOptionalHint;

  /// No description provided for @nameOptionalPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Salwa'**
  String get nameOptionalPlaceholder;

  /// No description provided for @newbornDetails.
  ///
  /// In en, this message translates to:
  /// **'Newborn details'**
  String get newbornDetails;

  /// No description provided for @sizeAtBirth.
  ///
  /// In en, this message translates to:
  /// **'Size at birth'**
  String get sizeAtBirth;

  /// No description provided for @birthSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get birthSizeSmall;

  /// No description provided for @birthSizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get birthSizeMedium;

  /// No description provided for @birthSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get birthSizeLarge;

  /// No description provided for @vigour.
  ///
  /// In en, this message translates to:
  /// **'Vigour'**
  String get vigour;

  /// No description provided for @vigourWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get vigourWeak;

  /// No description provided for @vigourAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get vigourAverage;

  /// No description provided for @vigourStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get vigourStrong;

  /// No description provided for @birthingAssistance.
  ///
  /// In en, this message translates to:
  /// **'Birthing assistance'**
  String get birthingAssistance;

  /// No description provided for @assistanceNone.
  ///
  /// In en, this message translates to:
  /// **'None — natural birth'**
  String get assistanceNone;

  /// No description provided for @assistanceEasyPull.
  ///
  /// In en, this message translates to:
  /// **'Easy pull (1 person)'**
  String get assistanceEasyPull;

  /// No description provided for @assistanceHardPull.
  ///
  /// In en, this message translates to:
  /// **'Hard pull (2+ people)'**
  String get assistanceHardPull;

  /// No description provided for @assistanceVet.
  ///
  /// In en, this message translates to:
  /// **'Vet assisted'**
  String get assistanceVet;

  /// No description provided for @assistanceCSection.
  ///
  /// In en, this message translates to:
  /// **'C-section'**
  String get assistanceCSection;

  /// No description provided for @animalIsTwin.
  ///
  /// In en, this message translates to:
  /// **'This animal is a twin'**
  String get animalIsTwin;

  /// No description provided for @birthWeightHint.
  ///
  /// In en, this message translates to:
  /// **'Birth weight'**
  String get birthWeightHint;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightCm;

  /// No description provided for @purchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase date'**
  String get purchaseDate;

  /// No description provided for @dobIfKnown.
  ///
  /// In en, this message translates to:
  /// **'Date of birth (if known)'**
  String get dobIfKnown;

  /// No description provided for @dobOrAgeRangeHint.
  ///
  /// In en, this message translates to:
  /// **'Or pick an age range below.'**
  String get dobOrAgeRangeHint;

  /// No description provided for @ageRangeIfUnknown.
  ///
  /// In en, this message translates to:
  /// **'Age range (if DOB unknown)'**
  String get ageRangeIfUnknown;

  /// No description provided for @pickAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Pick a range…'**
  String get pickAgeRange;

  /// No description provided for @supplierSource.
  ///
  /// In en, this message translates to:
  /// **'Supplier / source'**
  String get supplierSource;

  /// No description provided for @supplierHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Al-Wafi Genetics, market, neighbour…'**
  String get supplierHint;

  /// No description provided for @purchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase price'**
  String get purchasePrice;

  /// No description provided for @sireOptional.
  ///
  /// In en, this message translates to:
  /// **'Sire (optional)'**
  String get sireOptional;

  /// No description provided for @damOptional.
  ///
  /// In en, this message translates to:
  /// **'Dam (optional)'**
  String get damOptional;

  /// No description provided for @mothersTag.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s tag'**
  String get mothersTag;

  /// No description provided for @parentSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search or enter'**
  String get parentSearchHint;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Anything else worth recording'**
  String get notesHint;

  /// No description provided for @youreAdding.
  ///
  /// In en, this message translates to:
  /// **'You\'re adding'**
  String get youreAdding;

  /// No description provided for @summaryOriginBorn.
  ///
  /// In en, this message translates to:
  /// **'Born on farm'**
  String get summaryOriginBorn;

  /// No description provided for @summaryOriginPurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get summaryOriginPurchased;

  /// No description provided for @summaryOriginPurchasedFrom.
  ///
  /// In en, this message translates to:
  /// **'Purchased from {supplier}'**
  String summaryOriginPurchasedFrom(String supplier);

  /// No description provided for @selectGroupRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a group or create a new one'**
  String get selectGroupRequired;

  /// No description provided for @breedForSpecies.
  ///
  /// In en, this message translates to:
  /// **'Breed ({species})'**
  String breedForSpecies(String species);

  /// No description provided for @goat.
  ///
  /// In en, this message translates to:
  /// **'Goat'**
  String get goat;

  /// No description provided for @groupSpeciesLabel.
  ///
  /// In en, this message translates to:
  /// **'{name} · {species}'**
  String groupSpeciesLabel(String name, String species);

  /// No description provided for @groupOfLivestock.
  ///
  /// In en, this message translates to:
  /// **'Group of livestock'**
  String get groupOfLivestock;

  /// No description provided for @livestockExisting.
  ///
  /// In en, this message translates to:
  /// **'Existing'**
  String get livestockExisting;

  /// No description provided for @livestockNewBorn.
  ///
  /// In en, this message translates to:
  /// **'New (born)'**
  String get livestockNewBorn;

  /// No description provided for @livestockNewPurchased.
  ///
  /// In en, this message translates to:
  /// **'New (purchased)'**
  String get livestockNewPurchased;

  /// No description provided for @animalsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} {species} available'**
  String animalsAvailable(int count, String species);

  /// No description provided for @noAnimalsForSpecies.
  ///
  /// In en, this message translates to:
  /// **'No {species} on the farm yet.'**
  String noAnimalsForSpecies(String species);

  /// No description provided for @createGroupAction.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroupAction;

  /// No description provided for @createGroupWithAnimals.
  ///
  /// In en, this message translates to:
  /// **'Create group · {count} animal'**
  String createGroupWithAnimals(int count);

  /// No description provided for @createGroupWithAnimalsPlural.
  ///
  /// In en, this message translates to:
  /// **'Create group · {count} animals'**
  String createGroupWithAnimalsPlural(int count);

  /// No description provided for @addLivestockLabel.
  ///
  /// In en, this message translates to:
  /// **'Add {label}'**
  String addLivestockLabel(String label);

  /// No description provided for @tapToRegisterLivestock.
  ///
  /// In en, this message translates to:
  /// **'Tap Add {label} to register one or more {species} now.'**
  String tapToRegisterLivestock(String label, String species);

  /// No description provided for @addingCountToGroupOnSave.
  ///
  /// In en, this message translates to:
  /// **'Adding {count} to the group on save'**
  String addingCountToGroupOnSave(int count);

  /// No description provided for @addAnotherAnimal.
  ///
  /// In en, this message translates to:
  /// **'Add another'**
  String get addAnotherAnimal;

  /// No description provided for @newbornAnimalN.
  ///
  /// In en, this message translates to:
  /// **'Newborn #{n}'**
  String newbornAnimalN(int n);

  /// No description provided for @purchasedAnimalN.
  ///
  /// In en, this message translates to:
  /// **'Purchased #{n}'**
  String purchasedAnimalN(int n);

  /// No description provided for @groupDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Housing, feeding cadence, notes'**
  String get groupDescriptionHint;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Milking B'**
  String get groupNameHint;

  /// No description provided for @removeAnimal.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAnimal;

  /// No description provided for @userRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get userRoleOwner;

  /// No description provided for @userRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get userRoleManager;

  /// No description provided for @userRoleFarmHand.
  ///
  /// In en, this message translates to:
  /// **'Farm hand'**
  String get userRoleFarmHand;

  /// No description provided for @userRoleVet.
  ///
  /// In en, this message translates to:
  /// **'Vet'**
  String get userRoleVet;

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PDF · downloadable'**
  String get reportsSubtitle;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRange;

  /// No description provided for @last90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get last90Days;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toDate;

  /// No description provided for @availableReports.
  ///
  /// In en, this message translates to:
  /// **'Available reports'**
  String get availableReports;

  /// No description provided for @reportPreview.
  ///
  /// In en, this message translates to:
  /// **'Report preview'**
  String get reportPreview;

  /// No description provided for @recordsIncluded.
  ///
  /// In en, this message translates to:
  /// **'Records included'**
  String get recordsIncluded;

  /// No description provided for @inSelectedRange.
  ///
  /// In en, this message translates to:
  /// **'In the selected range'**
  String get inSelectedRange;

  /// No description provided for @window.
  ///
  /// In en, this message translates to:
  /// **'Window'**
  String get window;

  /// No description provided for @last90DaysRange.
  ///
  /// In en, this message translates to:
  /// **'Feb 07 – May 08'**
  String get last90DaysRange;

  /// No description provided for @speciesCovered.
  ///
  /// In en, this message translates to:
  /// **'Species covered'**
  String get speciesCovered;

  /// No description provided for @speciesCoveredValue.
  ///
  /// In en, this message translates to:
  /// **'Cattle · Goat · Sheep'**
  String get speciesCoveredValue;

  /// No description provided for @generated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get generated;

  /// No description provided for @generatedToday.
  ///
  /// In en, this message translates to:
  /// **'Today, 09:14'**
  String get generatedToday;

  /// No description provided for @headline.
  ///
  /// In en, this message translates to:
  /// **'Headline'**
  String get headline;

  /// No description provided for @perGroup.
  ///
  /// In en, this message translates to:
  /// **'Per-group'**
  String get perGroup;

  /// No description provided for @auditableDetail.
  ///
  /// In en, this message translates to:
  /// **'Auditable detail'**
  String get auditableDetail;

  /// No description provided for @exportReport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportReport;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @signatureLineNote.
  ///
  /// In en, this message translates to:
  /// **'Includes signature line for veterinary / auditor handoff.'**
  String get signatureLineNote;

  /// No description provided for @breedingKpis.
  ///
  /// In en, this message translates to:
  /// **'Breeding KPIs'**
  String get breedingKpis;

  /// No description provided for @pregnancyRate.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy rate'**
  String get pregnancyRate;

  /// No description provided for @aiAttempts30d.
  ///
  /// In en, this message translates to:
  /// **'AI attempts (30d)'**
  String get aiAttempts30d;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success rate'**
  String get successRate;

  /// No description provided for @miscarriagesCount.
  ///
  /// In en, this message translates to:
  /// **'Miscarriages'**
  String get miscarriagesCount;

  /// No description provided for @aiProviderPerformance.
  ///
  /// In en, this message translates to:
  /// **'AI provider performance'**
  String get aiProviderPerformance;

  /// No description provided for @weightMonthsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight · 5 months'**
  String get weightMonthsTitle;

  /// No description provided for @weightGrowthPct.
  ///
  /// In en, this message translates to:
  /// **'+{pct}%'**
  String weightGrowthPct(int pct);

  /// No description provided for @currentWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentWeightLabel;

  /// No description provided for @weightDeltaKg.
  ///
  /// In en, this message translates to:
  /// **'+{kg} kg'**
  String weightDeltaKg(int kg);

  /// No description provided for @artificialInseminations.
  ///
  /// In en, this message translates to:
  /// **'Artificial inseminations'**
  String get artificialInseminations;

  /// No description provided for @recordsOnFile.
  ///
  /// In en, this message translates to:
  /// **'{count} records on file'**
  String recordsOnFile(int count);

  /// No description provided for @noAiRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No AI records yet'**
  String get noAiRecordsYet;

  /// No description provided for @noAiRecordsHint.
  ///
  /// In en, this message translates to:
  /// **'Log inseminations or natural services to track attempts and outcomes.'**
  String get noAiRecordsHint;

  /// No description provided for @addAi.
  ///
  /// In en, this message translates to:
  /// **'Add AI'**
  String get addAi;

  /// No description provided for @recordAi.
  ///
  /// In en, this message translates to:
  /// **'Record AI'**
  String get recordAi;

  /// No description provided for @aiAttemptTitle.
  ///
  /// In en, this message translates to:
  /// **'Artificial insemination · Attempt {n}'**
  String aiAttemptTitle(int n);

  /// No description provided for @sireLabel.
  ///
  /// In en, this message translates to:
  /// **'SIRE'**
  String get sireLabel;

  /// No description provided for @technicianLabel.
  ///
  /// In en, this message translates to:
  /// **'TECHNICIAN'**
  String get technicianLabel;

  /// No description provided for @semenBatchLabel.
  ///
  /// In en, this message translates to:
  /// **'SEMEN BATCH'**
  String get semenBatchLabel;

  /// No description provided for @resultDateLabel.
  ///
  /// In en, this message translates to:
  /// **'RESULT DATE'**
  String get resultDateLabel;

  /// No description provided for @miscarriagesSection.
  ///
  /// In en, this message translates to:
  /// **'Miscarriages'**
  String get miscarriagesSection;

  /// No description provided for @noLossesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No losses recorded'**
  String get noLossesRecorded;

  /// No description provided for @noMiscarriagesYet.
  ///
  /// In en, this message translates to:
  /// **'No miscarriages recorded'**
  String get noMiscarriagesYet;

  /// No description provided for @noMiscarriagesHint.
  ///
  /// In en, this message translates to:
  /// **'Log a pregnancy loss to track gestation day, cause and follow-up.'**
  String get noMiscarriagesHint;

  /// No description provided for @breedingFemalesOnly.
  ///
  /// In en, this message translates to:
  /// **'Breeding history is shown for females only.'**
  String get breedingFemalesOnly;

  /// No description provided for @healthcareHistory.
  ///
  /// In en, this message translates to:
  /// **'Healthcare history'**
  String get healthcareHistory;

  /// No description provided for @vaccinationsSection.
  ///
  /// In en, this message translates to:
  /// **'Vaccinations'**
  String get vaccinationsSection;

  /// No description provided for @recordTreatment.
  ///
  /// In en, this message translates to:
  /// **'Record treatment'**
  String get recordTreatment;

  /// No description provided for @updateTreatment.
  ///
  /// In en, this message translates to:
  /// **'Update treatment'**
  String get updateTreatment;

  /// No description provided for @updateTreatmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change illness notes or medicine details'**
  String get updateTreatmentSubtitle;

  /// No description provided for @illnessSymptomsLabel.
  ///
  /// In en, this message translates to:
  /// **'Illness / symptoms'**
  String get illnessSymptomsLabel;

  /// No description provided for @treatmentMedicineLabel.
  ///
  /// In en, this message translates to:
  /// **'Medicine / treatment'**
  String get treatmentMedicineLabel;

  /// No description provided for @treatmentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Treatment recorded'**
  String get treatmentRecorded;

  /// No description provided for @treatmentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Treatment updated'**
  String get treatmentUpdated;

  /// No description provided for @markedCured.
  ///
  /// In en, this message translates to:
  /// **'Marked as cured'**
  String get markedCured;

  /// No description provided for @underTreatmentDefault.
  ///
  /// In en, this message translates to:
  /// **'Under treatment'**
  String get underTreatmentDefault;

  /// No description provided for @withdrawalPeriodActive.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal period active'**
  String get withdrawalPeriodActive;

  /// No description provided for @withdrawalMilkSafe.
  ///
  /// In en, this message translates to:
  /// **'Milk safe from {date}. Do not sell this animal\'s milk until cleared.'**
  String withdrawalMilkSafe(String date);

  /// No description provided for @activeIllnessDetail.
  ///
  /// In en, this message translates to:
  /// **'Mastitis · day 3 of 5 of treatment. Penicillin G — 5 ml IM daily.'**
  String get activeIllnessDetail;

  /// No description provided for @individualTasks.
  ///
  /// In en, this message translates to:
  /// **'Individual tasks'**
  String get individualTasks;

  /// No description provided for @addTaskForAnimal.
  ///
  /// In en, this message translates to:
  /// **'Add task for {name}'**
  String addTaskForAnimal(String name);

  /// No description provided for @noTasksForAnimal.
  ///
  /// In en, this message translates to:
  /// **'No upcoming tasks for this animal.'**
  String get noTasksForAnimal;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// No description provided for @allTasks.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTasks;

  /// No description provided for @tasksDueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{due} due · {overdue} overdue'**
  String tasksDueSubtitle(int due, int overdue);

  /// No description provided for @voiceLanguages.
  ///
  /// In en, this message translates to:
  /// **'EN · AR · UR · FR · transcribed by AI'**
  String get voiceLanguages;

  /// No description provided for @nothingForFilter.
  ///
  /// In en, this message translates to:
  /// **'Nothing for this filter.'**
  String get nothingForFilter;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @methodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get methodLabel;

  /// No description provided for @fertilityMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Fertility method'**
  String get fertilityMethodLabel;

  /// No description provided for @readyToBreedMethodHint.
  ///
  /// In en, this message translates to:
  /// **'Choose how this animal will be bred. Sponges synchronize heat for timed insemination in goats and sheep.'**
  String get readyToBreedMethodHint;

  /// No description provided for @breedingMethodNatural.
  ///
  /// In en, this message translates to:
  /// **'Natural service'**
  String get breedingMethodNatural;

  /// No description provided for @breedingMethodAi.
  ///
  /// In en, this message translates to:
  /// **'Artificial insemination'**
  String get breedingMethodAi;

  /// No description provided for @breedingMethodEmbryonic.
  ///
  /// In en, this message translates to:
  /// **'Embryo transfer'**
  String get breedingMethodEmbryonic;

  /// No description provided for @breedingMethodSponges.
  ///
  /// In en, this message translates to:
  /// **'Sponges'**
  String get breedingMethodSponges;

  /// No description provided for @providerLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get providerLabel;

  /// No description provided for @attemptNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Attempt #'**
  String get attemptNumberLabel;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @markCured.
  ///
  /// In en, this message translates to:
  /// **'Mark cured'**
  String get markCured;

  /// No description provided for @recordDeath.
  ///
  /// In en, this message translates to:
  /// **'Record death'**
  String get recordDeath;

  /// No description provided for @deathReason.
  ///
  /// In en, this message translates to:
  /// **'Cause of death'**
  String get deathReason;

  /// No description provided for @deathReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Illness, injury, unknown…'**
  String get deathReasonHint;

  /// No description provided for @confirmRecordDeath.
  ///
  /// In en, this message translates to:
  /// **'Confirm death'**
  String get confirmRecordDeath;

  /// No description provided for @confirmRecordDeathMessage.
  ///
  /// In en, this message translates to:
  /// **'Record {animal} as deceased?\n\nReason: {reason}\n\nThe animal will be removed from its group. This cannot be undone.'**
  String confirmRecordDeathMessage(String animal, String reason);

  /// No description provided for @animalRecordedDeceased.
  ///
  /// In en, this message translates to:
  /// **'Death recorded'**
  String get animalRecordedDeceased;

  /// No description provided for @deceased.
  ///
  /// In en, this message translates to:
  /// **'Deceased'**
  String get deceased;

  /// No description provided for @removedFromGroupNote.
  ///
  /// In en, this message translates to:
  /// **'Removed from group'**
  String get removedFromGroupNote;

  /// No description provided for @cullType.
  ///
  /// In en, this message translates to:
  /// **'Cull type'**
  String get cullType;

  /// No description provided for @cullReason.
  ///
  /// In en, this message translates to:
  /// **'Cull reason'**
  String get cullReason;

  /// No description provided for @breedingCycleKpiTitle.
  ///
  /// In en, this message translates to:
  /// **'Breeding cycle'**
  String get breedingCycleKpiTitle;

  /// No description provided for @breedingCycleKpiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Months since calving sets lactation nutrition and when the next breeding cycle can start.'**
  String get breedingCycleKpiSubtitle;

  /// No description provided for @monthsSinceCalvingLabel.
  ///
  /// In en, this message translates to:
  /// **'Months since calving'**
  String get monthsSinceCalvingLabel;

  /// No description provided for @lactationPhaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Lactation phase'**
  String get lactationPhaseLabel;

  /// No description provided for @monthsSinceCalvingValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Fresh calving (0 mo)} =1{1 month} other{{count} months}}'**
  String monthsSinceCalvingValue(int count);

  /// No description provided for @decreaseMonthsSinceCalving.
  ///
  /// In en, this message translates to:
  /// **'Decrease months since calving'**
  String get decreaseMonthsSinceCalving;

  /// No description provided for @increaseMonthsSinceCalving.
  ///
  /// In en, this message translates to:
  /// **'Increase months since calving'**
  String get increaseMonthsSinceCalving;

  /// No description provided for @breedingCycleReadyForRebreeding.
  ///
  /// In en, this message translates to:
  /// **'Ready for next breeding — mark Ready to Breed when scheduled.'**
  String get breedingCycleReadyForRebreeding;

  /// No description provided for @breedingCycleWaitingPeriod.
  ///
  /// In en, this message translates to:
  /// **'Voluntary waiting period — {months} month(s) until re-breeding window.'**
  String breedingCycleWaitingPeriod(int months);

  /// No description provided for @breedingCycleBlockedPregnant.
  ///
  /// In en, this message translates to:
  /// **'Currently pregnant — next breeding cycle starts after calving.'**
  String get breedingCycleBlockedPregnant;

  /// No description provided for @groupBreedingCycleKpiTitle.
  ///
  /// In en, this message translates to:
  /// **'Herd breeding cycle'**
  String get groupBreedingCycleKpiTitle;

  /// No description provided for @groupBreedingCycleKpiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Median months since calving across lactating females drives group nutrition and re-breeding planning.'**
  String get groupBreedingCycleKpiSubtitle;

  /// No description provided for @groupMedianMonthsSinceCalving.
  ///
  /// In en, this message translates to:
  /// **'Median months since calving'**
  String get groupMedianMonthsSinceCalving;

  /// No description provided for @groupLactatingFemales.
  ///
  /// In en, this message translates to:
  /// **'Lactating females'**
  String get groupLactatingFemales;

  /// No description provided for @groupReadyForRebreeding.
  ///
  /// In en, this message translates to:
  /// **'Ready for re-breeding'**
  String get groupReadyForRebreeding;

  /// No description provided for @groupWaitingForRebreeding.
  ///
  /// In en, this message translates to:
  /// **'In waiting period'**
  String get groupWaitingForRebreeding;

  /// No description provided for @groupLactationStageBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Lactation stages in group'**
  String get groupLactationStageBreakdown;

  /// No description provided for @groupAnimalsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 animal} other{{count} animals}}'**
  String groupAnimalsCount(int count);

  /// No description provided for @groupBreedingCycleNutritionNote.
  ///
  /// In en, this message translates to:
  /// **'Voluntary waiting period is {months} months after calving. Edit individual animals below to update months since calving.'**
  String groupBreedingCycleNutritionNote(int months);

  /// No description provided for @monthsSinceCalvingShort.
  ///
  /// In en, this message translates to:
  /// **'{count} mo since calving'**
  String monthsSinceCalvingShort(int count);

  /// No description provided for @readyToBreedEligibleNotTagged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 over 2 mo since calving · not tagged ready} other{{count} over 2 mo since calving · not tagged ready}}'**
  String readyToBreedEligibleNotTagged(int count);

  /// No description provided for @feedRestrictedDueToAnimalStatus.
  ///
  /// In en, this message translates to:
  /// **'Some feed items are restricted due to the animal status.'**
  String get feedRestrictedDueToAnimalStatus;

  /// No description provided for @feedEligibilityWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Feed restriction warning'**
  String get feedEligibilityWarningTitle;

  /// No description provided for @feedEligibilityAddProductWarning.
  ///
  /// In en, this message translates to:
  /// **'{product} may not be suitable for all animals on your farm.'**
  String feedEligibilityAddProductWarning(String product);

  /// No description provided for @feedEligibilityImpactedAnimals.
  ///
  /// In en, this message translates to:
  /// **'Impacted animals: {tags}'**
  String feedEligibilityImpactedAnimals(String tags);

  /// No description provided for @feedMealPlanRestrictedTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal plan \"{mealName}\" has restricted feeds'**
  String feedMealPlanRestrictedTitle(String mealName);

  /// No description provided for @feedMealPlanRestrictedBody.
  ///
  /// In en, this message translates to:
  /// **'Some ingredients in this meal plan are not eligible for animals in the selected group.'**
  String get feedMealPlanRestrictedBody;

  /// No description provided for @groupHerdRequirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Herd daily requirements'**
  String get groupHerdRequirementsTitle;

  /// No description provided for @groupHerdRequirementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Summed from each animal\'s nutrition profile'**
  String get groupHerdRequirementsSubtitle;

  /// No description provided for @groupHerdRequirementsProfiles.
  ///
  /// In en, this message translates to:
  /// **'{count} animals · mixed profiles'**
  String groupHerdRequirementsProfiles(int count);

  /// No description provided for @supplementDosageCapPerAnimal.
  ///
  /// In en, this message translates to:
  /// **'Max {kg} kg per animal per day'**
  String supplementDosageCapPerAnimal(String kg);

  /// No description provided for @supplementDosageCapGroup.
  ///
  /// In en, this message translates to:
  /// **'Group limit {kg} kg per day'**
  String supplementDosageCapGroup(String kg);

  /// No description provided for @supplementDosageCappedHint.
  ///
  /// In en, this message translates to:
  /// **'Suggested amount capped by feed eligibility rules'**
  String get supplementDosageCappedHint;

  /// No description provided for @addAnyway.
  ///
  /// In en, this message translates to:
  /// **'Add anyway'**
  String get addAnyway;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
