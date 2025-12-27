class Department {
  final String name;
  final String url;

  const Department({required this.name, required this.url});
}

class Departments {
  static const List<Department> all = [
    Department(
      name: 'Anestezi',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/anestezi/akademik-kadro',
    ),
    Department(
      name: 'Antrenörlük Eğitimi',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/spor-bilimleri-fakultesi/antrenorluk-egitimi/akademik-kadro',
    ),
    Department(
      name: 'Aşçılık',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/ascilik/akademik-kadro',
    ),
    Department(
      name: 'Bankacılık ve Sigortacılık',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/bankacilik-ve-sigortacilik/akademik-kadro',
    ),
    Department(
      name: 'Beden Eğitimi ve Spor Bilimleri',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/saglik-bilimleri-enstitusu/beden-egitimi-ve-spor-bilimleri/akademik-kadro',
    ),
    Department(
      name: 'Beden Eğitimi ve Spor Öğretmenliği',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/spor-bilimleri-fakultesi/beden-egitimi-ve-spor-ogretmenligi/akademik-kadro',
    ),
    Department(
      name: 'Beslenme ve Diyetetik',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/saglik-bilimleri-fakultesi/beslenme-ve-diyetetik/akademik-kadro',
    ),
    Department(
      name: 'Bilgisayar Mühendisliği',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/muhendislik-fakultesi/bilgisayar-muhendisligi/akademik-kadro',
    ),
    Department(
      name: 'Bilgisayar Programcılığı',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/bilgisayar-programciligi/akademik-kadro',
    ),
    Department(
      name: 'Bilişim Güvenliği Teknolojisi',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/bilisim-guvenligi-teknolojisi/akademik-kadro',
    ),
    Department(
      name: 'Biyomedikal Cihaz Teknolojisi',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/biyomedikal-cihaz-teknolojisi/akademik-kadro',
    ),
    Department(
      name: 'Çocuk Gelişimi (Fakülte)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/saglik-bilimleri-fakultesi/cocuk-gelisimi/akademik-kadro',
    ),
    Department(
      name: 'Çocuk Gelişimi (MYO)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/cocuk-gelisimi/akademik-kadro',
    ),
    Department(
      name: 'Dış Ticaret',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/dis-ticaret/akademik-kadro',
    ),
    Department(
      name: 'Egzersiz ve Spor Bilimleri',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/spor-bilimleri-fakultesi/egzersiz-ve-spor-bilimleri/akademik-kadro',
    ),
    Department(
      name: 'Elektrik (MYO)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/elektrik/akademik-kadro',
    ),
    Department(
      name: 'Elektrik-Elektronik Mühendisliği',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/muhendislik-fakultesi/elektrik-elektronik-muhendisligi/akademik-kadro',
    ),
    Department(
      name: 'Elektrik-Elektronik Mühendisliği (Enstitü)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fen-bilimleri-enstitusu/elektrik-elektronik-muhendisligi/akademik-kadro',
    ),
    Department(
      name: 'Fizyoterapi ve Rehabilitasyon',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/saglik-bilimleri-fakultesi/fizyoterapi-ve-rehabilitasyon/akademik-kadro',
    ),
    Department(
      name: 'Gastronomi ve Mutfak Sanatları',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/mimarlik-ve-tasarim-fakultesi/gastronomi-ve-mutfak-sanatlari/akademik-kadro',
    ),
    Department(
      name: 'Gastronomi ve Mutfak Sanatları (Enstitü)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/sosyal-bilimler-enstitusu/gastronomi-ve-mutfak-sanatlari/akademik-kadro',
    ),
    Department(
      name: 'Görsel İletişim Tasarımı',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/mimarlik-ve-tasarim-fakultesi/gorsel-iletisim-tasarimi/akademik-kadro',
    ),
    Department(
      name: 'Görsel İletişim Tasarımı (Enstitü)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/sosyal-bilimler-enstitusu/gorsel-iletisim-tasarimi/akademik-kadro',
    ),
    Department(
      name: 'Grafik Tasarımı',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/grafik-tasarimi/akademik-kadro',
    ),
    Department(
      name: 'Hemşirelik',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/saglik-bilimleri-fakultesi/hemsirelik/akademik-kadro',
    ),
    Department(
      name: 'Hukuk Fakültesi',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/hukuk-fakultesi/akademik-kadro',
    ),
    Department(
      name: 'İç Mimarlık ve Çevre Tasarımı',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/mimarlik-ve-tasarim-fakultesi/ic-mimarlik-ve-cevre-tasarimi/akademik-kadro',
    ),
    Department(
      name: 'İç Mimarlık ve Çevre Tasarımı (Enstitü)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fen-bilimleri-enstitusu/ic-mimarlik-ve-cevre-tasarimi/akademik-kadro',
    ),
    Department(
      name: 'İlk ve Acil Yardım',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/ilk-ve-acil-yardim/akademik-kadro',
    ),
    Department(
      name: 'İnşaat Mühendisliği',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/muhendislik-fakultesi/insaat-muhendisligi/akademik-kadro',
    ),
    Department(
      name: 'İnşaat Mühendisliği (Enstitü)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fen-bilimleri-enstitusu/insaat-muhendisligi/akademik-kadro',
    ),
    Department(
      name: 'İş Sağlığı ve Güvenliği (Fakülte)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/saglik-bilimleri-fakultesi/is-sagligi-ve-guvenligi/akademik-kadro',
    ),
    Department(
      name: 'İş Sağlığı ve Güvenliği (MYO)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/is-sagligi-ve-guvenligi/akademik-kadro',
    ),
    Department(
      name: 'İş Sağlığı ve Güvenliği (Tezli YL)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/saglik-bilimleri-enstitusu/is-sagligi-ve-guvenligi-tezli-yl/akademik-kadro',
    ),
    Department(
      name: 'İş Sağlığı ve Güvenliği (Tezsiz YL)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/saglik-bilimleri-enstitusu/is-sagligi-ve-guvenligi-tezsiz-yl/akademik-kadro',
    ),
    Department(
      name: 'İşletme',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/sosyal-bilimler-enstitusu/isletme/akademik-kadro',
    ),
    Department(
      name: 'İşletme Yönetimi',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/sosyal-bilimler-enstitusu/isletme-yonetimi/akademik-kadro',
    ),
    Department(
      name: 'Kamu Hukuku',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/sosyal-bilimler-enstitusu/kamu-hukuku/akademik-kadro',
    ),
    Department(
      name: 'Kamu Hukuku (Tezsiz YL)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/sosyal-bilimler-enstitusu/kamu-hukuku-tezsiz-yl/akademik-kadro',
    ),
    Department(
      name: 'Kaynak Teknolojisi',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/kaynak-teknolojisi/akademik-kadro',
    ),
    Department(
      name: 'Kimya Teknolojisi',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/kimya-teknolojisi/akademik-kadro',
    ),
    Department(
      name: 'Klinik Psikoloji',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/sosyal-bilimler-enstitusu/klinik-psikoloji/akademik-kadro',
    ),
    Department(
      name: 'Makine (MYO)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/makine/akademik-kadro',
    ),
    Department(
      name: 'Makine Mühendisliği',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/muhendislik-fakultesi/makine-muhendisligi/akademik-kadro',
    ),
    Department(
      name: 'Makine Mühendisliği (Tezli YL)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fen-bilimleri-enstitusu/makine-muhendisligi-tezli-yl/akademik-kadro',
    ),
    Department(
      name: 'Medya ve İletişim',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/medya-ve-iletisim/akademik-kadro',
    ),
    Department(
      name: 'Mekatronik (MYO)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/mekatronik/akademik-kadro',
    ),
    Department(
      name: 'Mekatronik Mühendisliği (Enstitü)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fen-bilimleri-enstitusu/mekatronik-muhendisligi/akademik-kadro',
    ),
    Department(
      name: 'Mekatronik Mühendisliği (Türkçe)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/muhendislik-fakultesi/mekatronik-muhendisligi-turkce/akademik-kadro',
    ),
    Department(
      name: 'Metalurji ve Malzeme Mühendisliği',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/muhendislik-fakultesi/metalurji-ve-malzeme-muhendisligi/akademik-kadro',
    ),
    Department(
      name: 'Mimarlık',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/mimarlik-ve-tasarim-fakultesi/mimarlik/akademik-kadro',
    ),
    Department(
      name: 'Mimarlık (Enstitü)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fen-bilimleri-enstitusu/mimarlik/akademik-kadro',
    ),
    Department(
      name: 'Muhasebe ve Vergi Uygulamaları',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/muhasebe-ve-vergi-uygulamalari/akademik-kadro',
    ),
    Department(
      name: 'Mühendislik Yönetimi',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fen-bilimleri-enstitusu/muhendislik-yonetimi/akademik-kadro',
    ),
    Department(
      name: 'Ortak Dersler Bölümü',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/rektorluge-bagli-bolumler/ortak-dersler-bolumu/akademik-kadro',
    ),
    Department(
      name: 'Özel Hukuk',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/sosyal-bilimler-enstitusu/ozel-hukuk/akademik-kadro',
    ),
    Department(
      name: 'Özel Hukuk (Tezsiz YL)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/sosyal-bilimler-enstitusu/ozel-hukuk-tezsiz-yl/akademik-kadro',
    ),
    Department(
      name: 'Psikoloji',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/iktisadi-idari-ve-sosyal-bilimler-fakultesi/psikoloji/akademik-kadro',
    ),
    Department(
      name: 'Rekreasyon',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/spor-bilimleri-fakultesi/rekreasyon/akademik-kadro',
    ),
    Department(
      name: 'Savunma Teknolojileri (Tezli YL)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fen-bilimleri-enstitusu/savunma-teknolojileri-tezli-yl/akademik-kadro',
    ),
    Department(
      name: 'Siyaset Bilimi ve Kamu Yönetimi',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/iktisadi-idari-ve-sosyal-bilimler-fakultesi/siyaset-bilimi-ve-kamu-yonetimi/akademik-kadro',
    ),
    Department(
      name: 'Siyaset Bilimi ve Kamu Yönetimi (Enstitü)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/sosyal-bilimler-enstitusu/siyaset-bilimi-ve-kamu-yonetimi/akademik-kadro',
    ),
    Department(
      name: 'Siyaset Bilimi ve Uluslararası İlişkiler (İngilizce)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/lisansustu-egitim-enstitusu/siyaset-bilimi-ve-uluslararasi-iliskiler-ingilizce/akademik-kadro',
    ),
    Department(
      name: 'Sivil Havacılık Kabin Hizmetleri',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/sivil-havacilik-kabin-hizmetleri/akademik-kadro',
    ),
    Department(
      name: 'Sosyoloji',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/iktisadi-idari-ve-sosyal-bilimler-fakultesi/sosyoloji/akademik-kadro',
    ),
    Department(
      name: 'Spor Yöneticiliği',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/spor-bilimleri-fakultesi/spor-yoneticiligi/akademik-kadro',
    ),
    Department(
      name: 'Su Altı Teknolojisi',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/su-alti-teknolojisi/akademik-kadro',
    ),
    Department(
      name: 'Tahribatsız Muayene',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/tahribatsiz-muayene/akademik-kadro',
    ),
    Department(
      name: 'Tıbbi Dokümantasyon ve Sekreterlik',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/tibbi-dokumantasyon-ve-sekreterlik/akademik-kadro',
    ),
    Department(
      name: 'Tıbbi Görüntüleme Teknikleri',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/gedik-meslek-yuksekokulu/tibbi-goruntuleme-teknikleri/akademik-kadro',
    ),
    Department(
      name: 'Uluslararası İlişkiler',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/iktisadi-idari-ve-sosyal-bilimler-fakultesi/uluslararasi-iliskiler/akademik-kadro',
    ),
    Department(
      name: 'Uluslararası Ticaret (Enstitü)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/sosyal-bilimler-enstitusu/uluslararasi-ticaret-3/akademik-kadro',
    ),
    Department(
      name: 'Uluslararası Ticaret ve Finansman (İngilizce)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/iktisadi-idari-ve-sosyal-bilimler-fakultesi/uluslararasi-ticaret-ve-finansman-ingilizce/akademik-kadro',
    ),
    Department(
      name: 'Yabancı Diller Yüksekokulu',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/yuksekokullar/yabanci-diller-yuksekokulu/akademik-kadro',
    ),
    Department(
      name: 'Yapay Zeka Mühendisliği',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fen-bilimleri-enstitusu/yapay-zeka-muhendisligi/akademik-kadro',
    ),
    Department(
      name: 'Yazılım Mühendisliği (İngilizce)',
      url:
          'https://www.gedik.edu.tr/akademik-birimler/fakulteler/muhendislik-fakultesi/yazilim-muhendisligi-ingilizce/akademik-kadro',
    ),
  ];

  // Default department (Bilgisayar Mühendisliği)
  static Department get defaultDepartment => all.firstWhere(
        (dept) => dept.name == 'Bilgisayar Mühendisliği',
        orElse: () => all.first,
      );
}
