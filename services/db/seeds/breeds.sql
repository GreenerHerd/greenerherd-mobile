-- Generated from Breed Information.xlsx + Sheep_Characteristics.xlsx
-- Run: npm run db:extract-breeds (from services/db)

DELETE FROM breed_weight_by_age;
DELETE FROM breeds;

INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '3820d87d-7b6f-5227-a52b-b6d1f91cf4f5', 'CATTLE', 'ABERDEEN_ANGUS', 'Aberdeen Angus', 'أبردين أنجس', TRUE,
  'Scotland', 'Beef', 'Black', 'Low',
  'Poor', 'Good', 'Excellent', 'Excellent',
  'Docile', '850-1100', '550-700',
  'Moderate', '12-15', '145-155', '135-145', 'Marbled meat quality and easy calving'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '6ee78525-6a0e-549b-813c-f97171ecf757', 'CATTLE', 'AYRSHIRE', 'Ayrshire', 'أيرشاير', TRUE,
  'Scotland', 'Dairy', 'Red & White', '6000-8000',
  'Moderate', 'Good', 'Good', 'Good',
  'Alert', '800-1000', '550-650',
  'Moderate', '8-12', '145-155', '135-145', 'Grazing efficiency and udder health'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'e699b1dc-1e1e-5f48-9a2a-bfc03ccf7514', 'CATTLE', 'BALADI', 'Baladi', 'بلدي', TRUE,
  'Middle East', 'Dual Purpose', 'Light brown to dark brown', '1200-2000',
  'Excellent', 'High', 'Good', 'Good',
  'Docile', '400-500', '300-400',
  'Excellent to harsh conditions', '8-10', '125-135', '115-125', 'Heat tolerance and disease resistance'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'b95f45ad-27b1-5eb7-8e30-c144049b346e', 'CATTLE', 'BRAHMAN', 'Brahman', 'براهمان', TRUE,
  'India/USA', 'Beef', 'Grey/Red', 'Low',
  'Excellent', 'High', 'Good', 'Excellent',
  'Alert', '800-1100', '500-700',
  'Excellent in tropics', '12-15', '145-155', '135-145', 'Parasite resistance and heat tolerance'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '5f6d1f12-75c0-5dbe-ae19-a20872fb424f', 'CATTLE', 'CHAROLAIS', 'Charolais', 'شارولي', TRUE,
  'France', 'Beef', 'White/Cream', 'Low',
  'Poor', 'Moderate', 'Fair', 'Excellent',
  'Docile', '1000-1400', '750-1000',
  'Poor in hot climate', '8-12', '150-160', '140-150', 'Rapid growth and meat quality'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'fb1e051f-367f-522a-beab-2389401db309', 'CATTLE', 'EGYPTIAN_BALADI', 'Egyptian Baladi', 'بلدي مصري', TRUE,
  'Middle East', 'Dual Purpose', 'Light brown to dark brown', '1200-2000',
  'Excellent', 'High', 'Good', 'Good',
  'Docile', '400-500', '300-400',
  'Excellent to harsh conditions', '8-10', '125-135', '115-125', 'Heat tolerance and disease resistance'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'bac5afb5-7fce-5d68-ae3e-0b38c4e4a7ac', 'CATTLE', 'HALLIKAR', 'Hallikar', 'هاليكار', TRUE,
  'India', 'Draft/Meat', 'Grey-White', 'Low',
  'High', 'Good', 'Good', 'Excellent',
  'Active', '400-500', '300-400',
  'Good in tropical conditions', '12-15', '130-140', '120-130', 'Draft capacity and endurance'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '55a6c8ea-1c5f-5475-8fb8-9fba6ca00e93', 'CATTLE', 'HOLSTEIN', 'Holstein', 'هولشتاين', TRUE,
  'Netherlands', 'Dairy', 'Black & White/Red & White', '7000-9000',
  'Poor', 'Moderate', 'Fair', 'Excellent',
  'Docile', '1000-1200', '650-750',
  'Poor in hot climate', '5-7', '155-165', '145-155', 'Highest milk production worldwide'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '986483df-146d-5abb-9e53-186636e1cce3', 'CATTLE', 'IRAQI', 'Iraqi', 'عراقي', TRUE,
  'Iraq', 'Dual Purpose', 'Grey to Light Brown', '1500-2500',
  'Excellent', 'High', 'Good', 'Good',
  'Docile', '450-550', '350-450',
  'Excellent in arid zones', '8-12', '125-135', '115-125', 'Hardiness and adaptability'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'c8b9f901-0dbf-5e20-a857-0020903bc559', 'CATTLE', 'JERSEY', 'Jersey', 'جيرسي', TRUE,
  'Channel Islands', 'Dairy', 'Fawn/Brown', '4000-6000',
  'Moderate', 'Good', 'Excellent', 'Good',
  'Gentle', '600-700', '400-500',
  'Good', '12-15', '135-145', '125-135', 'High butterfat content milk'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '47f870e4-4767-5139-8601-607a337a7afb', 'CATTLE', 'LIBYAN_MAHALI', 'Libyan Mahali', 'محلي ليبي', TRUE,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'b02d39d0-e6e9-5148-8b4a-7d8bb257170f', 'CATTLE', 'LOCAL_HOLSTEIN_CROSS', 'Local Holstein Cross', 'محلي مهجن هولشتاين', TRUE,
  'Various', 'Dairy', 'Black & White/Red & White', '3500-5000',
  'Moderate', 'Moderate', 'Fair', 'Good',
  'Gentle', '650-750', '550-650',
  'Moderate', '6-8', '140-150', '130-140', 'Improved milk yield with local adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'a0a1657c-d165-5115-b52f-53e8972bff7d', 'CATTLE', 'MONTBELIARDE', 'Montbeliarde', 'مونبيليارد', TRUE,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'ec0200c0-93ce-507a-97e8-98f7f3c3ca25', 'CATTLE', 'MOROCCAN_BROWN_ATLAS', 'Moroccan Brown Atlas', 'الأطلس البني المغربي', TRUE,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '80fb5a70-ac87-5f2b-8559-19ddaaedd10c', 'CATTLE', 'OMAN_DHOFARI', 'Oman Dhofari', 'ظفاري عماني', TRUE,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'dc02a0ce-ca40-5657-9adb-d95d5be34a98', 'CATTLE', 'RED_HOLSTEIN', 'Red Holstein', 'هولشتاين أحمر', TRUE,
  'Netherlands', 'Dairy', 'Black & White/Red & White', '7000-9000',
  'Poor', 'Moderate', 'Fair', 'Excellent',
  'Docile', '1000-1200', '650-750',
  'Poor in hot climate', '5-7', '155-165', '145-155', 'Highest milk production worldwide'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '3e377a51-6f98-59ea-ad8e-77c6037c2ce5', 'CATTLE', 'RED_SINDHI', 'Red Sindhi', 'سندي أحمر', TRUE,
  'Pakistan', 'Dual Purpose', 'Deep Red', '1800-2500',
  'Excellent', 'High', 'Good', 'Good',
  'Docile', '450-550', '350-450',
  'Excellent in hot climate', '10-12', '130-140', '120-130', 'Heat tolerance and disease resistance'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '53aa21ba-4178-54ae-9a29-58cb9a5d8bb9', 'CATTLE', 'SAHIWAL', 'Sahiwal', 'ساهيوال', TRUE,
  'Pakistan/India', 'Dual Purpose', 'Red/Brown', '2000-2500',
  'Excellent', 'High', 'Excellent', 'Good',
  'Gentle', '500-600', '400-450',
  'Excellent in tropics', '12-15', '130-140', '120-130', 'Heat tolerance and tick resistance'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '4f76ce4f-e33d-528b-808d-174f605c5e3f', 'CATTLE', 'SAUDI_HASAWI', 'Saudi Hasawi', 'حساوي سعودي', TRUE,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '95e818de-a32a-5270-8f3e-913c7dbbe811', 'CATTLE', 'SHAMI_DAMASCUS', 'Shami/Damascus', 'شامي/دمشقي', TRUE,
  'Syria/Lebanon', 'Dual Purpose', 'Brown/Red', '2000-3000',
  'Excellent', 'High', 'Good', 'Good',
  'Gentle', '500-600', '400-500',
  'Very good in arid regions', '8-12', '130-140', '120-130', 'Adaptation to arid conditions and good milk fat content'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'ad033e4a-c780-5694-a326-280738a20861', 'CATTLE', 'SUDANESE_BUTANA', 'Sudanese Butana', 'بطانة سودانية', TRUE,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '08dca8a9-426c-57af-82bb-dfed6ae972b7', 'CATTLE', 'SUDANESE_KENANA', 'Sudanese Kenana', 'كنانة سودانية', TRUE,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'e75c831d-f3dd-5bc0-b05f-a41e13318122', 'CATTLE', 'SWISS_BROWN', 'Swiss Brown', 'سويس براون', TRUE,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '6103ed11-2e42-577d-ab59-d70f99675e0a', 'CATTLE', 'TUNISIAN_BLONDE_DU_CAP_BON', 'Tunisian Blonde du Cap Bon', 'بلوند كاب بون تونسي', TRUE,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '5dc16fdb-32f6-5500-82bf-dc74fbedd966', 'CATTLE', 'YEMEN_SOCOTRI', 'Yemen Socotri', 'سقطري يمني', TRUE,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '985d3ee2-d9a3-5ac4-a085-0bf5f749fa38', 'CATTLE', 'ZEBU', 'Zebu', 'زيبو', TRUE,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '6d9b2cae-3ea9-5c30-b76d-6d0bd5249279', 'GOAT', 'ALPINE', 'Alpine', 'ألبين', TRUE,
  'France', 'Dairy', 'Various', '600-900',
  'Moderate', 'Good', 'Good', 'Excellent',
  'Alert', '80-90', '60-70',
  'Moderate', NULL, '85-95', '75-85', 'Milk production'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'f6dbd7d3-cf1e-5a9d-b31d-6ba94d2668ca', 'GOAT', 'ARADI_AARDI', 'Aradi/Aardi', 'عارضي', TRUE,
  'Saudi Arabia', 'Dual Purpose', 'Brown/Black', '200-300',
  'Excellent', 'High', 'Good', 'Good',
  'Active', '65-75', '45-55',
  'Excellent', NULL, '75-85', '65-75', 'Desert adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '7f2ee145-4f54-5241-a704-b6d465c2bfd0', 'GOAT', 'ARDI', 'Ardi', 'عرضي', TRUE,
  'Saudi Arabia', 'Meat/Milk', 'Black/Brown', '200-300',
  'Excellent', 'High', 'Good', 'Good',
  'Active', '65-75', '45-55',
  'Excellent', NULL, '75-85', '65-75', 'Desert adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '301070a9-a213-5e50-af24-1c43ff39315b', 'GOAT', 'AWASSI', 'Awassi', 'عواسي', TRUE,
  'Middle East', 'Dairy', 'Brown', '250-350',
  'High', 'Good', 'Good', 'Good',
  'Gentle', '70-80', '50-60',
  'Very Good', NULL, '80-90', '70-80', 'Milk production'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '4c05be87-0a2a-5077-887c-b5ab99b89f36', 'GOAT', 'BALADI', 'Baladi', 'بلدي', TRUE,
  'Middle East', 'Dual Purpose', 'Brown/Black', '0',
  'Excellent', 'High', 'Excellent', 'Good',
  'Docile', '60-70', '45-55',
  'Excellent', NULL, '70-80', '65-75', 'Hardiness and adaptability'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '3de79f52-484e-570a-acac-e0dc1ac68aad', 'GOAT', 'BARBARI', 'Barbari', 'البربري', TRUE,
  'Pakistan/India', 'Dual Purpose', 'White', '200-300',
  'High', 'Good', 'Good', 'Good',
  'Gentle', '58-68', '38-48',
  'Very Good', NULL, '70-80', '65-75', 'Compact size'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '64a639f6-0656-5cc1-923b-138db2b96996', 'GOAT', 'BARGOD', 'Bargod', 'بارغود', TRUE,
  'India', 'Dual Purpose', 'Black/Brown', '200-300',
  'High', 'Good', 'Good', 'Good',
  'Docile', '70-80', '50-60',
  'Very Good', NULL, '75-85', '70-80', 'Dual-purpose traits'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '1e0a5a86-ffc2-5a10-8baa-612bd2204b73', 'GOAT', 'BARRI', 'Barri', 'برّي', TRUE,
  'Middle East', 'Meat', 'Brown/Black', '150-200',
  'Excellent', 'High', 'Excellent', 'Good',
  'Alert', '58-68', '38-48',
  'Excellent', NULL, '70-80', '65-75', 'Meat quality'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'f3ae4912-2f06-55bc-aafb-a96b107118b4', 'GOAT', 'BATINAH', 'Batinah', 'الباطنة', TRUE,
  'Oman', 'Dual Purpose', 'Brown/Black', '180-280',
  'Excellent', 'High', 'Good', 'Good',
  'Calm', '65-75', '45-55',
  'Excellent', NULL, '75-85', '65-75', 'Local adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'f55f55c1-3dec-59fd-9bdb-4c9322ea4add', 'GOAT', 'BISHI', 'Bishi', 'بيشي', TRUE,
  'Saudi Arabia', 'Dual Purpose', 'Various', '180-280',
  'Excellent', 'High', 'Good', 'Good',
  'Active', '60-70', '40-50',
  'Excellent', NULL, '70-80', '65-75', 'Desert adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '3b50bef8-5462-5dad-9427-b8e939bd61a6', 'GOAT', 'BLACK_BEDOUIN', 'Black Bedouin', 'بدوي أسود', TRUE,
  'Middle East', 'Dual Purpose', 'Black', '200-300',
  'Excellent', 'High', 'Good', 'Good',
  'Active', '63-73', '43-53',
  'Excellent', NULL, '75-85', '65-75', 'Desert hardiness'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '20cde696-7ad7-52a1-8425-5fe0fb8bc0cc', 'GOAT', 'BOER', 'Boer', 'البور', TRUE,
  'South Africa', 'Meat', 'White/Red', '150-250',
  'Good', 'Good', 'Good', 'Excellent',
  'Docile', '100-120', '70-90',
  'Good', NULL, '85-95', '75-85', 'Meat production'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'f82e1927-0662-538b-af9b-893682e985bd', 'GOAT', 'BOER_CROSS', 'Boer Cross', 'بوير كروس', TRUE,
  'South Africa', 'Meat', 'White/Red', '150-250',
  'Good', 'Good', 'Good', 'Excellent',
  'Docile', '90-100', '65-75',
  'Good', NULL, '85-95', '75-85', 'Growth rate'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '76e0a557-3de4-533b-83ec-47d2c9beabc0', 'GOAT', 'DHOFARI_AL_SALALI', 'Dhofari/Al-Salali', 'ظفاري/الصلالي', TRUE,
  'Oman', 'Dual Purpose', 'Various', '180-280',
  'Excellent', 'High', 'Good', 'Good',
  'Calm', '60-70', '40-50',
  'Excellent', NULL, '70-80', '65-75', 'Heat tolerance'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '1a647f98-2d73-55e0-94ae-b2950a987849', 'GOAT', 'HALABI', 'Halabi', 'حلبي', TRUE,
  'Syria', 'Dairy', 'Various', '250-350',
  'High', 'Good', 'Good', 'Good',
  'Gentle', '65-75', '45-55',
  'Very Good', NULL, '75-85', '70-80', 'Milk quality'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'fb795e20-9b55-5b87-9c45-35e992c02a6a', 'GOAT', 'HEJAZI', 'Hejazi', 'حجازي', TRUE,
  'Saudi Arabia', 'Dual Purpose', 'Various', '180-280',
  'Excellent', 'High', 'Good', 'Good',
  'Docile', '60-70', '40-50',
  'Excellent', NULL, '70-80', '65-75', 'Desert adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '730294d2-cfc9-5213-a245-986630569b66', 'GOAT', 'IRAQI_MERIZ', 'Iraqi/Meriz', 'عراقي/ميريز', TRUE,
  'Iraq', 'Dual Purpose', 'Various', '180-280',
  'Excellent', 'High', 'Good', 'Good',
  'Gentle', '63-73', '43-53',
  'Excellent', NULL, '70-80', '65-75', 'Local adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'd38d8920-7851-5e61-9ca2-9d3d90ef3ab1', 'GOAT', 'JABALI', 'Jabali', 'جبلي', TRUE,
  'Oman', 'Meat', 'Various', '120-180',
  'Excellent', 'High', 'Excellent', 'Good',
  'Active', '55-65', '35-45',
  'Excellent', NULL, '65-75', '60-70', 'Mountain adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '98b6ccfd-4c12-50a9-a6bf-ed2afe3ac067', 'GOAT', 'JAZEERI', 'Jazeeri', 'جزيري', TRUE,
  'Middle East', 'Dual Purpose', 'Various', '200-300',
  'Excellent', 'High', 'Good', 'Good',
  'Alert', '65-75', '45-55',
  'Excellent', NULL, '75-85', '65-75', 'Local adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '7e277cd1-6696-59fa-91a1-c74871368913', 'GOAT', 'JORDANIAN_MOUNTAIN', 'Jordanian Mountain', 'جبلي أردني', TRUE,
  'Jordan', 'Dual Purpose', 'Various', '180-280',
  'Excellent', 'High', 'Good', 'Good',
  'Alert', '60-70', '40-50',
  'Excellent', NULL, '70-80', '65-75', 'Mountain adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'abb4f56e-5afb-5516-9be7-4bafde252e7b', 'GOAT', 'KALAHARI_RED', 'Kalahari Red', 'كالاهاري الأحمر', TRUE,
  'South Africa', 'Meat', 'Red', '150-250',
  'High', 'Good', 'Excellent', 'Good',
  'Alert', '79-89', '59-69',
  'Good', NULL, '80-90', '70-80', 'Meat production'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '6c8441e3-8353-5cbc-bda8-abe1cf126b9f', 'GOAT', 'KASHMIRI', 'Kashmiri', 'كشميري', TRUE,
  'Kashmir', 'Dual Purpose', 'Various', '200-300',
  'Good', 'Good', 'Good', 'Good',
  'Gentle', '65-75', '45-55',
  'Good', NULL, '75-85', '65-75', 'Wool/Hair quality'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '72235326-ba16-5d50-9b04-152fabb28dde', 'GOAT', 'MURCIANA', 'Murciana', 'مرسيانا', TRUE,
  'Spain', 'Dairy', 'Black', '400-600',
  'Moderate', 'Good', 'Good', 'Good',
  'Gentle', '70-80', '50-60',
  'Good', NULL, '75-85', '70-80', 'Milk quality'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '392709ad-a3e8-58cc-8363-58176d67016c', 'GOAT', 'NAJDI', 'Najdi', 'نجدي', TRUE,
  'Saudi Arabia', 'Dual Purpose', 'Black', '200-300',
  'Excellent', 'High', 'Good', 'Good',
  'Docile', '70-80', '50-60',
  'Excellent', NULL, '80-90', '70-80', 'Desert adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'e0475257-9311-564c-965d-7b2846e450ad', 'GOAT', 'NUBIAN', 'Nubian', 'نوبي', TRUE,
  'Sudan/Egypt', 'Dairy', 'Various', '400-600',
  'High', 'Good', 'Good', 'Good',
  'Friendly', '80-90', '60-70',
  'Good', NULL, '85-95', '75-85', 'High butterfat milk'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '1ec3834b-410e-5fb1-882d-29960a94a208', 'GOAT', 'OMANI', 'Omani', 'عماني', TRUE,
  'Oman', 'Meat/Milk', 'Brown/Black', '160-260',
  'Excellent', 'High', 'Good', 'Good',
  'Calm', '60-70', '40-50',
  'Excellent', NULL, '70-80', '65-75', 'Heat tolerance'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'd3920c8c-ac9a-5d50-8925-dcbc1159b544', 'GOAT', 'PAKISTANI', 'Pakistani', 'باكستاني', TRUE,
  'Pakistan', 'Dual Purpose', 'Various', '200-300',
  'High', 'Good', 'Good', 'Good',
  'Docile', '65-75', '45-55',
  'Very Good', NULL, '75-85', '65-75', 'Adaptability'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '65b27a0f-25ce-5639-947d-a46b022558d6', 'GOAT', 'PYGMY', 'Pygmy', 'قزم', TRUE,
  'West Africa', 'Meat', 'Various', '100-150',
  'High', 'High', 'Excellent', 'Good',
  'Friendly', '35-45', '25-35',
  'Good', NULL, '50-60', '45-55', 'Small size'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'e90a898f-ad91-50dd-b57e-aca43ef8b454', 'GOAT', 'RAHBI', 'Rahbi', 'رحبي', TRUE,
  'Oman', 'Dual Purpose', 'Brown/Black', '170-270',
  'Excellent', 'High', 'Good', 'Good',
  'Calm', '58-68', '38-48',
  'Excellent', NULL, '70-80', '65-75', 'Heat tolerance'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '7c974592-70d4-57d0-908e-34d6e91e0abc', 'GOAT', 'SAANEN', 'Saanen', 'سانين', TRUE,
  'Switzerland', 'Dairy', 'White', '600-1000',
  'Poor', 'Moderate', 'Good', 'Excellent',
  'Gentle', '80-90', '60-70',
  'Poor', NULL, '85-95', '75-85', 'Highest milk yield'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '3d455427-5906-5d7c-8bd6-178e2d3e038a', 'GOAT', 'SHAMI_DAMASCUS', 'Shami/Damascus', 'شامي/دمشقي', TRUE,
  'Syria', 'Dairy', 'Red/Brown', '350-500',
  'High', 'Good', 'Good', 'Good',
  'Gentle', '75-85', '55-65',
  'Very Good', NULL, '80-90', '70-80', 'Milk production'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '93a7c3ae-843d-5c40-bc3f-6b1f970f9f3b', 'GOAT', 'SINDHI', 'Sindhi', 'السندي', TRUE,
  'Pakistan', 'Dual Purpose', 'Black/Brown', '200-300',
  'Excellent', 'High', 'Good', 'Good',
  'Docile', '65-75', '45-55',
  'Excellent', NULL, '75-85', '65-75', 'Heat tolerance'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '41b7f219-4c51-52f0-ab9b-0a0894a3fbe8', 'GOAT', 'SOMALI', 'Somali', 'صومالي', TRUE,
  'Somalia', 'Meat', 'Black', '150-200',
  'Excellent', 'High', 'Good', 'Good',
  'Alert', '55-65', '35-45',
  'Excellent', NULL, '70-80', '65-75', 'Heat tolerance'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'cb1d891f-72fd-50f3-ba51-c2d2bfd34146', 'GOAT', 'SUDANI', 'Sudani', 'سوداني', TRUE,
  'Sudan', 'Dual Purpose', 'Various', '180-280',
  'Excellent', 'High', 'Good', 'Good',
  'Alert', '60-70', '40-50',
  'Excellent', NULL, '70-80', '65-75', 'Heat tolerance'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'e403f797-2705-5e2b-b11f-617183852db9', 'GOAT', 'YEMNI', 'Yemni', 'يمني', TRUE,
  'Yemen', 'Dual Purpose', 'Various', '180-280',
  'Excellent', 'High', 'Good', 'Good',
  'Alert', '58-68', '38-48',
  'Excellent', NULL, '70-80', '65-75', 'Local adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '876ba15c-10a7-5019-a864-a683a88dbbd9', 'GOAT', 'ZARAIBI', 'Zaraibi', 'زراييبي', TRUE,
  'Egypt', 'Dairy', 'White/Brown', '300-400',
  'High', 'Good', 'Good', 'Excellent',
  'Alert', '65-75', '45-55',
  'Very Good', NULL, '75-85', '70-80', 'Milk production'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '4d48e422-6b0a-5fb0-892b-94dae754a979', 'SHEEP', 'AFGAN_ARABI', 'Afgan Arabi', 'أفغاني عربي', TRUE,
  'Afghanistan', 'Meat', 'White/Grey', '70-110',
  'High', 'High', 'Good', 'Good',
  'Alert', '78-88', '59-69',
  'Very Good', '10-12', '72-82', '62-72', 'Fat-tail and meat quality'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '95c5fefa-d870-5ed2-9050-da12a08a734c', 'SHEEP', 'ARABI', 'Arabi', 'عربي', TRUE,
  'Middle East', 'Meat', 'White/Brown', '60-100',
  'Excellent', 'High', 'Good', 'Good',
  'Docile', '72-82', '55-65',
  'Excellent', '8-10', '68-78', '60-70', 'General hardiness'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'f47c2fda-59ad-57e1-a0b9-d4a0f586a589', 'SHEEP', 'ASSAF', 'Assaf', 'عَسّاف', TRUE,
  'Israel', 'Dairy', 'White', '250-450',
  'High', 'Good', 'Good', 'Excellent',
  'Gentle', '90-100', '70-80',
  'Good', '8-10', '80-90', '70-80', 'Highest dairy sheep, Awassi-Friesian cross'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'e4752f8f-936c-5d2b-a739-532fe84803a4', 'SHEEP', 'AWASSI', 'Awassi', 'عواسي', TRUE,
  'Saudi Arabia', 'Meat', 'White with brown head', '100-160',
  'Excellent', 'High', 'Good', 'Good',
  'Docile', '82-92', '62-72',
  'Excellent', '10-12', '72-82', '65-75', 'Premium meat, show breed in Gulf'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '1a0b29dd-e002-5ccc-8f84-73be730588ce', 'SHEEP', 'BALADI', 'Baladi', 'بلدي', TRUE,
  'Middle East', 'Meat', 'White/Brown', '60-100',
  'Excellent', 'High', 'Excellent', 'Good',
  'Docile', '70-80', '55-65',
  'Excellent', '8-10', '65-75', '60-70', 'Hardiness and local adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '69912658-c165-5a6e-8d2c-202b43322c5a', 'SHEEP', 'BALUCHI', 'Baluchi', 'بالوشي', TRUE,
  'Pakistan/Iran', 'Meat/Wool', 'White', '60-100',
  'High', 'High', 'Good', 'Good',
  'Alert', '76-86', '58-68',
  'Very Good', '10-12', '72-82', '62-72', 'Carpet wool and fat-tail'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '5917cd1a-e437-5930-ad1e-81839b0956ec', 'SHEEP', 'BARBARI', 'Barbari', 'بربري', TRUE,
  'India/Pakistan', 'Meat', 'White with brown spots', '50-80',
  'High', 'Good', 'Excellent', 'Good',
  'Gentle', '65-75', '50-60',
  'Very Good', '8-10', '65-75', '55-65', 'Compact size and prolificacy'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '470bd589-da30-5979-a09d-608ff754e1c4', 'SHEEP', 'BARBARIN', 'Barbarin', 'بربرين', TRUE,
  'Tunisia/North Africa', 'Meat', 'White with brown head', '80-130',
  'Excellent', 'High', 'Good', 'Good',
  'Alert', '80-90', '60-70',
  'Excellent', '10-12', '72-82', '62-72', 'Fat-tail and North African adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'c577261d-3391-5c24-a7a2-2e814e480fa5', 'SHEEP', 'BARKI', 'Barki', 'بركي', TRUE,
  'Egypt/Libya', 'Dual Purpose', 'White/Light Brown', '80-130',
  'Excellent', 'High', 'Good', 'Good',
  'Alert', '75-85', '55-68',
  'Excellent', '10-12', '70-80', '60-70', 'Desert adaptation and carpet wool'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '6652d07b-c614-50a8-9c93-9643e9cc96fe', 'SHEEP', 'CHIOS', 'Chios', 'شيوس', TRUE,
  'Greece', 'Dairy', 'White with black spots', '200-300',
  'High', 'Good', 'Good', 'Good',
  'Gentle', '85-95', '65-75',
  'Good', '10-12', '75-85', '65-75', 'Prolificacy and milk production'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'c45362d2-6568-569c-9384-548ad758e90f', 'SHEEP', 'CYPRIOT', 'Cypriot', 'سيبريوت', TRUE,
  'Cyprus', 'Dairy', 'White/Light Brown', '200-350',
  'High', 'Good', 'Good', 'Good',
  'Gentle', '80-90', '60-70',
  'Good', '10-12', '72-82', '65-75', 'Milk production in Mediterranean climate'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'a1d2bdb3-2552-51ef-804c-99b2bdc76b9e', 'SHEEP', 'DORBOR', 'Dorbor', 'دوربور', TRUE,
  'Middle East cross', 'Meat', 'White/Brown', '60-100',
  'High', 'Good', 'Good', 'Excellent',
  'Docile', '83-93', '63-73',
  'Good', '8-10', '75-85', '65-75', 'Dorper cross, growth rate'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '66a8c156-16ae-5930-9732-898b785444eb', 'SHEEP', 'DORPER', 'Dorper', 'دوربر', TRUE,
  'South Africa', 'Meat', 'White with black head', '60-100',
  'High', 'Good', 'Excellent', 'Excellent',
  'Docile', '90-100', '70-80',
  'Good', '8-10', '78-88', '68-78', 'Rapid growth and hair shedding'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '18354782-c6fb-5206-92f5-a3bc7f94af18', 'SHEEP', 'GROMARK', 'Gromark', 'غرومارك', TRUE,
  'Australia', 'Dual Purpose', 'White', '100-150',
  'Good', 'Good', 'Good', 'Excellent',
  'Gentle', '90-100', '68-78',
  'Good', '8-10', '78-88', '68-78', 'Growth rate and lean meat'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '215c63ff-99cb-5a9a-a391-9b55ee02581e', 'SHEEP', 'HARRI', 'Harri', 'حرّي', TRUE,
  'Saudi Arabia', 'Meat', 'Black/Dark Brown', '60-100',
  'Excellent', 'High', 'Good', 'Good',
  'Active', '72-82', '54-64',
  'Excellent', '8-10', '68-78', '60-70', 'Desert hardiness and meat quality'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '34a92362-ae07-5622-ae57-bab98529f034', 'SHEEP', 'IVESI', 'Ivesi', 'إيفيزي', TRUE,
  'Turkey', 'Dairy', 'White', '150-250',
  'High', 'Good', 'Good', 'Good',
  'Gentle', '80-90', '60-70',
  'Good', '10-12', '72-82', '65-75', 'Milk quality and fat-tail'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '87fcabea-0604-52bb-a6cc-ef92eea99f89', 'SHEEP', 'KARADI', 'Karadi', 'كردي', TRUE,
  'Iraq/Kurdistan', 'Dual Purpose', 'Brown/Black', '100-180',
  'High', 'High', 'Good', 'Good',
  'Alert', '75-85', '55-65',
  'Excellent', '10-12', '70-80', '60-70', 'Mountain adaptation and fat-tail'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '9519c9cd-f4cf-57a3-8ee1-d72b9ef68b86', 'SHEEP', 'KASHMIRI', 'Kashmiri', 'كشميري', TRUE,
  'Kashmir', 'Wool/Meat', 'White/Grey', '50-80',
  'Moderate', 'Good', 'Good', 'Good',
  'Gentle', '72-82', '54-64',
  'Good', '10-12', '68-78', '60-70', 'Fine wool quality'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '6e0db5b8-5d92-5573-a3be-7af6c520f6af', 'SHEEP', 'MARWARI', 'Marwari', NULL, TRUE,
  'India', 'Meat/Wool', 'White/Light Brown', '40-70',
  'High', 'Good', 'Good', 'Good',
  'Alert', '65-75', '45-55',
  'Very Good', '8-10', '65-75', '58-68', 'Arid climate adaptation and carpet wool'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'e2c5fb35-33dc-5af6-8b15-2b7f0d15551c', 'SHEEP', 'NAIMI_AWASSI', 'Naimi/Awassi', 'نعيمي /عواسي', TRUE,
  'Saudi Arabia', 'Meat', 'White with brown head', '100-160',
  'Excellent', 'High', 'Good', 'Good',
  'Docile', '82-92', '62-72',
  'Excellent', '10-12', '72-82', '65-75', 'Premium meat, show breed in Gulf'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '70412541-86d3-5e50-b8f5-8146955578ac', 'SHEEP', 'NAJDI', 'Najdi', 'نجدي', TRUE,
  'Saudi Arabia', 'Meat', 'Black/Brown', '80-120',
  'Excellent', 'High', 'Good', 'Good',
  'Active', '85-95', '65-75',
  'Excellent', '10-12', '75-85', '65-75', 'Desert adaptation and meat quality'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'd4a72c06-e177-5b89-b2de-bcdefd5531e5', 'SHEEP', 'OMANI', 'Omani', 'عماني', TRUE,
  'Oman', 'Meat', 'White/Brown', '60-100',
  'Excellent', 'High', 'Good', 'Good',
  'Calm', '73-83', '56-66',
  'Excellent', '8-10', '68-78', '60-70', 'Heat tolerance and desert adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'f04f98f8-b102-53c0-9f1e-91ef20996cae', 'SHEEP', 'RAHMANI', 'Rahmani', 'رحماني', TRUE,
  'Egypt', 'Meat', 'Brown/Red', '80-130',
  'High', 'Good', 'Good', 'Good',
  'Docile', '80-90', '60-71',
  'Very Good', '8-10', '72-80', '62-72', 'Meat quality and Egyptian adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'e6d6b780-046e-5801-8734-281e7a12e18b', 'SHEEP', 'SA_MUTTON_MERINO', 'SA Mutton Merino', 'ميرينو', TRUE,
  'South Africa', 'Dual Purpose', 'White', '80-120',
  'Good', 'Good', 'Good', 'Good',
  'Gentle', '88-98', '68-78',
  'Good', '10-12', '75-85', '65-75', 'Fine wool and meat quality'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '26cd4cc1-358e-5eeb-a2d5-1c49fc926c1b', 'SHEEP', 'SAWAKINI_SUAKNI', 'Sawakini/Suakni', 'سواكيني', TRUE,
  'Sudan/Saudi Arabia', 'Meat', 'Brown/Red', '70-120',
  'Excellent', 'High', 'Good', 'Good',
  'Alert', '75-85', '58-68',
  'Excellent', '8-10', '70-80', '62-72', 'Heat tolerance and adaptability'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'f87c66e1-f0f9-576e-b664-c251b2738b3c', 'SHEEP', 'SHAMI', 'Shami', 'شامي', TRUE,
  'Syria/Lebanon', 'Dual Purpose', 'Brown/Red', '120-200',
  'Excellent', 'High', 'Good', 'Good',
  'Gentle', '80-90', '60-70',
  'Very Good', '10-12', '72-82', '65-75', 'Adaptation to arid conditions'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'e63f1453-3868-5c84-9120-5c5ee593a793', 'SHEEP', 'SUDANI', 'Sudani', 'سوداني', TRUE,
  'Sudan', 'Meat', 'Brown/Red', '60-100',
  'Excellent', 'High', 'Good', 'Good',
  'Alert', '75-85', '58-68',
  'Excellent', '8-10', '70-80', '62-72', 'Heat tolerance and hardiness'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  'aa752abd-cdd8-5f5a-beb1-1e4f5223c7f6', 'SHEEP', 'SYBARIS', 'Sybaris', 'سيباريس', TRUE,
  'Middle East', 'Meat', 'White/Brown', '80-130',
  'High', 'Good', 'Good', 'Good',
  'Docile', '80-90', '60-70',
  'Very Good', '8-10', '72-82', '65-75', 'Meat quality'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '43131390-bb92-5663-b354-f176ff10c6e4', 'SHEEP', 'SYRIAN_MOUNTAIN', 'Syrian Mountain', 'جبلي سوري', TRUE,
  'Syria', 'Meat', 'White/Brown', '60-100',
  'High', 'High', 'Good', 'Good',
  'Active', '70-78', '52-62',
  'Excellent', '8-10', '65-75', '58-68', 'Mountain terrain adaptation'
);
INSERT INTO breeds (
  id, species, code, name_en, name_ar, is_active,
  origin, primary_purpose, color, milk_production_kg_year,
  heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
  temperament, adult_male_weight_kg, adult_female_weight_kg,
  adaptability, longevity_years, height_male_cm, height_female_cm, known_for
) VALUES (
  '44e2755d-450a-59ae-9d18-9668dcb24da9', 'SHEEP', 'WAZIRI', 'Waziri', 'وزيري', TRUE,
  'Pakistan/Afghanistan', 'Meat', 'White/Brown', '50-80',
  'High', 'High', 'Good', 'Good',
  'Active', '72-82', '54-64',
  'Very Good', '8-10', '68-78', '60-70', 'Rugged terrain adaptation'
);
