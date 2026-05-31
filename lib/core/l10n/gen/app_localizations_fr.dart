// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'GreenerHerd';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabAnimals => 'Animaux';

  @override
  String get tabTasks => 'Tâches';

  @override
  String get tabFinance => 'Finance';

  @override
  String get tabReports => 'Rapports';

  @override
  String get tabOverview => 'Aperçu';

  @override
  String get tabNutrition => 'Nutrition';

  @override
  String get tabBreeding => 'Reproduction';

  @override
  String get tabMilking => 'Traite';

  @override
  String get tabHealth => 'Santé';

  @override
  String get tabWeight => 'Poids';

  @override
  String get tabMedia => 'Médias';

  @override
  String goodMorning(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get animals => 'Animaux';

  @override
  String get addNew => 'Ajouter';

  @override
  String get profile => 'Profil';

  @override
  String get groups => 'Groupes';

  @override
  String get inventory => 'Inventaire';

  @override
  String get help => 'Aide';

  @override
  String get reports => 'Rapports';

  @override
  String get settings => 'Paramètres';

  @override
  String get signIn => 'Connexion';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get language => 'Langue';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get onboardingFarmTitle => 'Configurer votre ferme';

  @override
  String get onboardingSpeciesTitle => 'Votre bétail';

  @override
  String get onboardingAnimalsTitle => 'Ajouter des animaux';

  @override
  String get skipForNow => 'Passer pour l\'instant';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get pregnant => 'Gestante';

  @override
  String get lactating => 'En lactation';

  @override
  String get readyToBreed => 'Prête à reproduire';

  @override
  String get sick => 'Malade';

  @override
  String get cullFlagged => 'Réforme signalée';

  @override
  String get allSpecies => 'Toutes espèces';

  @override
  String get cattle => 'Bovins';

  @override
  String get goats => 'Chèvres';

  @override
  String get sheep => 'Moutons';

  @override
  String get tasksToday => 'Tâches du jour';

  @override
  String get overdue => 'En retard';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get finance => 'Finance';

  @override
  String get income => 'Revenus';

  @override
  String get expense => 'Dépenses';

  @override
  String get net => 'Net';

  @override
  String get livestockValue => 'Valeur du cheptel';

  @override
  String get subscription => 'Abonnement';

  @override
  String get buyAnimals => 'Acheter des animaux';

  @override
  String get sellAnimals => 'Vendre des animaux';

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
  String get people => 'Personnes';

  @override
  String get marketplace => 'Marché';

  @override
  String get fixTheGap => 'Combler l\'écart';

  @override
  String get alertsAndTasks => 'Alertes et tâches';

  @override
  String get animalNotFound => 'Animal introuvable';

  @override
  String get groupNotFound => 'Groupe introuvable';

  @override
  String get methaneEmissions => 'Émissions de méthane';

  @override
  String get methaneRegionMiddleEast => 'Moyen-Orient (CCG)';

  @override
  String get groupAverage => 'Moyenne du groupe';

  @override
  String get groupTotal => 'Group total';

  @override
  String get emissionsTotal => 'Emissions total';

  @override
  String methaneCo2eGroupTotal(String co2e, int headCount) {
    return '$co2e kg CO₂e · $headCount head';
  }

  @override
  String get methaneByAnimal => 'Par animal (CH₄ / jour)';

  @override
  String methaneMoreAnimals(int count) {
    return '+ $count animaux supplémentaires';
  }

  @override
  String methaneCh4Grams(String grams) {
    return '$grams g CH₄';
  }

  @override
  String methaneCo2eSummary(String co2e, String weight) {
    return '$co2e kg éq. CO₂ · $weight kg poids vif moy.';
  }

  @override
  String methaneGramsShort(String grams) {
    return '$grams g';
  }

  @override
  String methaneAgeMonths(int months) {
    return '$months mois';
  }

  @override
  String lactationNumber(int number) {
    return 'Lactation $number';
  }

  @override
  String lactationDayOf305(String stage, int day) {
    return '$stage · Jour $day sur 305';
  }

  @override
  String lactationCalvingExpected(String date, String litres) {
    return 'Vêlage $date · ~$litres L attendus aujourd\'hui';
  }

  @override
  String get lactationCurveTitle =>
      'Courbe de lactation (lait vs jour de lactation)';

  @override
  String get lactationCurveLegend =>
      'Trait plein = lait enregistré · pointillé = attendu (moyenne race)';

  @override
  String get lactationChartNeedsData =>
      'Enregistrez au moins deux traites pour afficher la courbe.';

  @override
  String chartDayLitres(int day, String litres) {
    return 'Jour $day\n$litres L';
  }

  @override
  String get milkingTodayVolume => 'Volume du jour';

  @override
  String get notRecorded => 'Non enregistré';

  @override
  String litresValue(String litres) {
    return '$litres L';
  }

  @override
  String get recordMilk => 'Enregistrer le lait';

  @override
  String get recordBulkMilkSale => 'Vente de lait en vrac (revenu)';

  @override
  String get withdrawalMilkBlocked =>
      'Période de retrait active — le lait ne peut pas être vendu ni enregistré pour consommation humaine.';

  @override
  String get todayVsRequirement => 'Aujourd\'hui vs besoins';

  @override
  String get milkingKpis => 'Indicateurs de traite';

  @override
  String get topProducers => 'Meilleures productrices';

  @override
  String get todaysFeed => 'Alimentation du jour';

  @override
  String get energyGapDetected => 'Déficit énergétique détecté';

  @override
  String get lactationStageFresh => 'Début de lactation';

  @override
  String get lactationStagePeak => 'Pic de lactation';

  @override
  String get lactationStageMid => 'Mi-lactation';

  @override
  String get lactationStageLate => 'Fin de lactation';

  @override
  String get lactationStageDry => 'Tarissement';

  @override
  String get species => 'Espèce';

  @override
  String get sex => 'Sexe';

  @override
  String get breed => 'Race';

  @override
  String get group => 'Groupe';

  @override
  String get purpose => 'Objectif';

  @override
  String get groupPurpose => 'Group purpose';

  @override
  String get animalPurpose => 'Animal purpose';

  @override
  String get female => 'Femelle';

  @override
  String get male => 'Mâle';

  @override
  String get loadingBreeds => 'Chargement des races…';

  @override
  String get saveAnimal => 'Enregistrer l\'animal';

  @override
  String get saveGroup => 'Enregistrer le groupe';

  @override
  String get newAnimal => 'Nouvel animal';

  @override
  String get newGroup => 'Nouveau groupe';

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
  String get markPregnant => 'Marquer gestante';

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
  String get continueButton => 'Continuer';

  @override
  String get enterAnimalsIndividually => 'Saisir les animaux individuellement';

  @override
  String get tag => 'Étiquette';

  @override
  String get weight => 'Poids';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get tagNumber => 'Numéro d\'étiquette';

  @override
  String get weightKg => 'Poids (kg)';

  @override
  String get weightHint => 'ex. 412';

  @override
  String get birthDateOptional => 'Date de naissance (facultatif)';

  @override
  String bornOnDate(int day, int month, int year) {
    return 'Né le $day/$month/$year';
  }

  @override
  String get groupName => 'Nom du groupe';

  @override
  String get descriptionOptional => 'Description (facultatif)';

  @override
  String get ageNew => 'Nouveau';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get continueWithFacebook => 'Continuer avec Facebook';

  @override
  String get newFarmSetup => 'Nouvelle ferme';

  @override
  String get welcomeTo => 'Bienvenue sur';

  @override
  String get welcomeBrand => 'Greener Herd';

  @override
  String get gaveBirth => 'A mis bas';

  @override
  String get recordBirthSubtitle => 'Enregistrer naissance vivante ou mort-né';

  @override
  String get miscarriage => 'Fausses couches';

  @override
  String get miscarriageSubtitle =>
      'Retirer la gestation et signaler pour suivi';

  @override
  String get flagForCull => 'Marquer pour réforme';

  @override
  String get clearCullFlag => 'Retirer marque réforme';

  @override
  String get markSold => 'Marquer vendu';

  @override
  String get recordBirth => 'Enregistrer la naissance';

  @override
  String get bornAlive => 'Né vivant';

  @override
  String get bornAliveSubtitle => 'Gestation levée ; tag lactation si absent';

  @override
  String get stillborn => 'Mort-né';

  @override
  String get stillbornSubtitle => 'Gestation levée ; mort-né enregistré';

  @override
  String get saveBirthRecord => 'Enregistrer la naissance';

  @override
  String get pregnancyOutcome => 'Issue de la gestation';

  @override
  String get howDidPregnancyEnd => 'Comment s\'est terminée la gestation ?';

  @override
  String birthRecordedFor(String tag) {
    return 'Naissance enregistrée pour #$tag';
  }

  @override
  String stillbirthRecordedFor(String tag) {
    return 'Mort-né enregistré pour #$tag';
  }

  @override
  String get recordMiscarriage => 'Enregistrer fausses couches';

  @override
  String miscarriageRecordedFor(String tag) {
    return 'Fausses couches enregistrées pour #$tag';
  }

  @override
  String get miscarriageConfirmBody =>
      'Cela retire le statut gestant et ajoute un flag pour suivi Santé et rapports.';

  @override
  String get confirmMiscarriage => 'Confirmer fausses couches';

  @override
  String get newTask => 'Nouvelle tâche';

  @override
  String get voiceAddTask => 'Ajouter une tâche vocale';

  @override
  String get voiceHoldMock => 'Maintenir pour parler (simulation)';

  @override
  String get hold => 'Maintenir';

  @override
  String get dismiss => 'Ignorer';

  @override
  String get complete => 'Terminer';

  @override
  String get addedManually => 'Ajoutée manuellement';

  @override
  String get taskTitle => 'Titre';

  @override
  String get feed => 'Alimentation';

  @override
  String get medicine => 'Médicament';

  @override
  String get mealPlans => 'Plans de repas';

  @override
  String get viewMealPlans => 'Voir les plans de repas';

  @override
  String get recordFeeding => 'Enregistrer l\'alimentation';

  @override
  String get addFeed => 'Ajouter aliment';

  @override
  String get addMedicine => 'Ajouter médicament';

  @override
  String get medicineName => 'Nom du médicament';

  @override
  String get medicineTypeLabel => 'Type (ex. ANTIBIOTIC)';

  @override
  String get medicineProductSource => 'Produit';

  @override
  String get fromProductList => 'Depuis la liste';

  @override
  String get customMedicineName => 'Nom personnalisé';

  @override
  String get selectMedicineProduct => 'Sélectionner un médicament';

  @override
  String get searchCatalogue => 'Rechercher dans le catalogue';

  @override
  String get medicineProductsAvailable => 'correspondances';

  @override
  String medicineCatalogueSearchHint(int count) {
    return 'Rechercher parmi $count produits du catalogue';
  }

  @override
  String get activeIngredient => 'Principe actif';

  @override
  String get dosage => 'Dosage';

  @override
  String get routeOfAdministration => 'Voie d\'administration';

  @override
  String get inStockLabel => 'En stock';

  @override
  String get selectMedicineOrEnterName =>
      'Choisissez un produit dans la liste ci-dessus';

  @override
  String get withdrawalPrefilledHint =>
      'Les périodes de retrait sont préremplies — modifiez si votre vétérinaire l\'indique.';

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
  String get selectProduct => 'Choisir le produit';

  @override
  String get quantity => 'Quantité';

  @override
  String get unit => 'Unité';

  @override
  String get addFeedProduct => 'Ajouter produit alimentaire';

  @override
  String get noFeedInInventory => 'Pas encore d\'aliment en stock.';

  @override
  String get noMedicineInInventory => 'Pas encore de médicaments en stock.';

  @override
  String get lowStock => 'Stock bas';

  @override
  String lowStockFeedBanner(int count) {
    return '$count aliment(s) sous une semaine de réserve';
  }

  @override
  String get recordExpense => 'Enregistrer dépense';

  @override
  String get recordIncome => 'Enregistrer revenu';

  @override
  String get exportCsv => 'Exporter CSV';

  @override
  String get exportPdf => 'Exporter PDF';

  @override
  String get printReport => 'Imprimer le rapport';

  @override
  String get milkSale => 'Vente de lait';

  @override
  String get amount => 'Montant';

  @override
  String get addEntry => 'Ajouter une entrée';

  @override
  String get categoryOptionalPreset => 'Catégorie (préréglage facultatif)';

  @override
  String get category => 'Catégorie';

  @override
  String get description => 'Description';

  @override
  String get recentEntries => 'Entrées récentes';

  @override
  String get general => 'Général';

  @override
  String get edit => 'Modifier';

  @override
  String get animalsCount => 'Animaux';

  @override
  String get females => 'Femelles';

  @override
  String get avgPerHead => 'Moy. / tête';

  @override
  String get todayTotal => 'Total du jour';

  @override
  String get onWithdrawal => 'En retrait';

  @override
  String get recordAction => 'Enregistrer';

  @override
  String get updateAction => 'Update';

  @override
  String get updateFeeding => 'Update feeding';

  @override
  String get updatingFeeding => 'Updating…';

  @override
  String get noFeedToday => 'Aucun aliment enregistré aujourd\'hui.';

  @override
  String get nutritionNoFeedLoggedHint =>
      'Actual intake is zero until you log feed in Today\'s feed below.';

  @override
  String get noMilkToday => 'Aucun enregistrement de lait aujourd\'hui.';

  @override
  String get dryMatter => 'Matière sèche';

  @override
  String get crudeProtein => 'Protéine brute';

  @override
  String get energyMe => 'Énergie (ME)';

  @override
  String get ndf => 'NDF';

  @override
  String get calcium => 'Calcium';

  @override
  String get phosphorus => 'Phosphorus';

  @override
  String get legendOk => 'OK';

  @override
  String get legendWarning => 'Alerte';

  @override
  String get legendAction => 'Action';

  @override
  String get purposeHeading => 'OBJECTIF';

  @override
  String get descriptionHeading => 'DESCRIPTION';

  @override
  String get noDescriptionRecorded => 'Aucune description enregistrée.';

  @override
  String get live => 'En direct';

  @override
  String loadedCount(int count) {
    return '$count chargés';
  }

  @override
  String get perHead => 'Par tête';

  @override
  String get dailyCostPerHead => 'Coût journalier / tête';

  @override
  String get todaysVolume => 'Volume du jour';

  @override
  String avgLitresMilking(String avg, int count) {
    return 'Moy. $avg L/tête · $count traite(s)';
  }

  @override
  String withdrawalDays(int days) {
    return 'Retrait · $days j';
  }

  @override
  String get noAnimalsInGroup => 'Aucun animal assigné à ce groupe.';

  @override
  String get groupTitle => 'Groupe';

  @override
  String get recentVaccinations => 'Vaccinations récentes';

  @override
  String get activeTreatments => 'Traitements actifs';

  @override
  String get sickAnimals => 'Animaux malades';

  @override
  String get breedingStatus => 'Statut';

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
  String get gestationMonths => 'Gestation (mois)';

  @override
  String gestationMonthsValue(int months) {
    return '$months mois';
  }

  @override
  String get markReadyToBreed => 'Marquer prête à la reproduction';

  @override
  String get recordPregnancyOutcome => 'Enregistrer issue gestation';

  @override
  String get clearReadyToBreed => 'Retirer prête à reproduire';

  @override
  String get breedingHistory => 'Historique reproduction';

  @override
  String get breedingStatusUpdated => 'Statut reproduction mis à jour';

  @override
  String get breedingOpen => 'Libre';

  @override
  String get recentMiscarriage => 'Fausses couches récentes';

  @override
  String get markedReadyToBreed => 'Marquée prête à reproduire';

  @override
  String get pregnancyConfirmed => 'Gestation confirmée';

  @override
  String pregnancyConfirmedMo(int months) {
    return 'Gestation confirmée ($months mois)';
  }

  @override
  String get lactatingPostCalving => 'Lactation / post-mise bas';

  @override
  String get stillbirthRecorded => 'Mort-né enregistré';

  @override
  String get miscarriageRecorded => 'Fausses couches enregistrées';

  @override
  String get noBreedingEventsYet => 'Aucun événement reproduction enregistré.';

  @override
  String get breedingOverview => 'Aperçu reproduction';

  @override
  String get pregnantAnimals => 'Animaux gestants';

  @override
  String gestationMonthsSubtitle(int months) {
    return '$months mois de gestation';
  }

  @override
  String get openAnimalProfiles => 'Ouvrir les profils animaux';

  @override
  String get openAnimalsForBreeding =>
      'Ouvrez les profils pour les actions de reproduction.';

  @override
  String get farmName => 'Nom de la ferme';

  @override
  String get currency => 'Devise';

  @override
  String get selectSpeciesOnFarm => 'Sélectionnez les espèces de votre ferme';

  @override
  String get primaryPurpose => 'Objectif principal';

  @override
  String purposeForSpecies(String species) {
    return 'Primary purpose for $species';
  }

  @override
  String get setThePurposeForEachSpecies =>
      'Set the primary purpose for each species';

  @override
  String get purposeMilk => 'Lait';

  @override
  String get purposeMeat => 'Viande';

  @override
  String get purposeMilkMeat => 'Lait et viande';

  @override
  String get chooseHowToAddAnimals =>
      'Choisissez comment ajouter vos premiers animaux. Vous pourrez le faire plus tard depuis l\'onglet Animaux.';

  @override
  String get enterAsGroup => 'Saisir en groupe';

  @override
  String get selectAtLeastOneSpecies => 'Sélectionnez au moins une espèce';

  @override
  String get selectAtLeastOneAnimal => 'Select at least one animal';

  @override
  String get myFarm => 'Ma ferme';

  @override
  String linkedToAccount(String provider) {
    return 'Lié au compte $provider';
  }

  @override
  String get providerGoogle => 'Google';

  @override
  String get providerApple => 'Apple';

  @override
  String get providerFacebook => 'Facebook';

  @override
  String get inviteTeamMember => 'Inviter un membre';

  @override
  String get inviteTeamSubtitle =>
      'Envoyez un lien par e-mail ou WhatsApp pour rejoindre votre ferme.';

  @override
  String get fullName => 'Nom complet';

  @override
  String get email => 'E-mail';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get phoneWithCountryCode => 'Téléphone (indicatif pays)';

  @override
  String get role => 'Rôle';

  @override
  String get manager => 'Gestionnaire';

  @override
  String get farmHand => 'Ouvrier agricole';

  @override
  String get veterinarian => 'Vétérinaire';

  @override
  String get sendInvite => 'Envoyer l\'invitation';

  @override
  String get enterValidEmail => 'Entrez un e-mail valide';

  @override
  String get enterValidPhone => 'Entrez un téléphone valide';

  @override
  String inviteSentOpen(String channel) {
    return 'Invitation envoyée — ouvrez $channel pour terminer';
  }

  @override
  String inviteCreated(String link) {
    return 'Invitation créée. Lien : $link';
  }

  @override
  String inviteFailed(String error) {
    return 'Échec de l\'invitation : $error';
  }

  @override
  String joinFarmSubject(String farmName) {
    return 'Rejoindre $farmName sur GreenerHerd';
  }

  @override
  String get channelEmail => 'e-mail';

  @override
  String get channelWhatsapp => 'WhatsApp';

  @override
  String get recordPurchase => 'Enregistrer achat';

  @override
  String get supplier => 'Fournisseur';

  @override
  String get animalsPurchased => 'Animaux achetés';

  @override
  String get totalSar => 'Total (SAR)';

  @override
  String get user => 'Utilisateur';

  @override
  String get notificationsRecommended => 'Notifications et tâches recommandées';

  @override
  String get notificationsSubtitle =>
      'Rappels alimentation, reproduction, santé, météo';

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
  String get inviteManageTeam => 'Inviter et gérer votre équipe';

  @override
  String get notFound => 'Introuvable';

  @override
  String get errorGeneric => 'Une erreur s\'est produite';

  @override
  String get loading => 'Chargement';

  @override
  String get alerts => 'Alertes';

  @override
  String get farmOwner => 'Propriétaire de la ferme';

  @override
  String get manageGroups => 'Gérer les groupes';

  @override
  String get exportPdfCsvSubtitle => 'Exporter PDF / CSV';

  @override
  String get feedAndMedicalStock => 'Stock alimentation et médical';

  @override
  String get supportTopics => 'Support et sujets';

  @override
  String get validMilkVolume => 'Entrez un volume de lait valide (litres)';

  @override
  String get milkBlockedWithdrawal =>
      'Enregistrement lait bloqué pendant retrait médicament';

  @override
  String recordedMilkFor(String litres, String tag) {
    return 'Enregistré $litres L pour #$tag';
  }

  @override
  String previousTodayMilk(String litres) {
    return 'Aujourd\'hui précédent : $litres L';
  }

  @override
  String get todaysMilkLitres => 'Lait du jour (litres)';

  @override
  String get recordMilkSaleIncome => 'Enregistrer revenu vente lait';

  @override
  String get recordMilkSaleIncomeSubtitle =>
      'Ajoute un revenu dans l\'onglet Finance';

  @override
  String get saleAmountSar => 'Montant vente (SAR)';

  @override
  String get catalogGaps => 'Écarts catalogue';

  @override
  String get recommendedFeeds => 'Aliments recommandés';

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
  String get applyToMorningMix => 'Appliquer au mélange du matin';

  @override
  String get feedPlanApplied => 'Plan alimentaire appliqué';

  @override
  String get couldNotApplyFeedPlan => 'Impossible d\'appliquer le plan';

  @override
  String failedToApplyPlan(String error) {
    return 'Échec d\'application : $error';
  }

  @override
  String get source => 'Source';

  @override
  String get standard => 'Standard';

  @override
  String get custom => 'Personnalisé';

  @override
  String get catalogueProduct => 'Produit catalogue';

  @override
  String get marketplaceListingName => 'Nom annonce marché';

  @override
  String get productName => 'Nom du produit';

  @override
  String get currentStockKg => 'Stock actuel (kg)';

  @override
  String get purchasedVolumeKg => 'Volume acheté (kg)';

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
    return 'Coût unitaire précédent : $cost SAR/kg';
  }

  @override
  String get stockUpdated => 'Stock mis à jour';

  @override
  String inventoryLastPurchaseKg(String kg) {
    return '+$kg kg purchased';
  }

  @override
  String get unitCostSar => 'Coût unitaire (SAR/kg)';

  @override
  String get supplierName => 'Nom du fournisseur';

  @override
  String get supplierPhone => 'Téléphone fournisseur';

  @override
  String get nutritionalInformation => 'Informations nutritionnelles';

  @override
  String get dryMatterPercent => 'Matière sèche %';

  @override
  String get crudeProteinPercent => 'Protéine brute %';

  @override
  String get nemMcalPerKg => 'NEm (Mcal/kg)';

  @override
  String get addToInventory => 'Ajouter au stock';

  @override
  String get feedType => 'Type d\'aliment';

  @override
  String avgWithdrawalRemaining(String days) {
    return 'Moy. $days j restants';
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
