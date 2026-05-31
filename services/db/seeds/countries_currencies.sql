-- Reference countries and currencies (unchanged by breed extract)

INSERT INTO countries (iso_code, name_en, name_ar) VALUES
  ('SA', 'Saudi Arabia', 'المملكة العربية السعودية'),
  ('AE', 'United Arab Emirates', 'الإمارات العربية المتحدة'),
  ('QA', 'Qatar', 'قطر'),
  ('KW', 'Kuwait', 'الكويت'),
  ('BH', 'Bahrain', 'البحرين'),
  ('OM', 'Oman', 'عُمان'),
  ('JO', 'Jordan', 'الأردن'),
  ('EG', 'Egypt', 'مصر')
ON CONFLICT (iso_code) DO NOTHING;

INSERT INTO currencies (iso_code, name_en, symbol) VALUES
  ('SAR', 'Saudi Riyal', 'ر.س'),
  ('AED', 'UAE Dirham', 'د.إ'),
  ('QAR', 'Qatari Riyal', 'ر.ق'),
  ('KWD', 'Kuwaiti Dinar', 'د.ك'),
  ('BHD', 'Bahraini Dinar', 'د.ب'),
  ('OMR', 'Omani Rial', 'ر.ع'),
  ('JOD', 'Jordanian Dinar', 'د.أ'),
  ('EGP', 'Egyptian Pound', 'ج.م'),
  ('USD', 'US Dollar', '$')
ON CONFLICT (iso_code) DO NOTHING;
