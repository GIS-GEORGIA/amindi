import '../domain/georgian_city.dart';

/// Curated list of Georgian cities and towns with coordinates, covering every
/// region. Used by city search; the forecast itself comes from the app's own
/// sources (Open-Meteo + YR) for the selected coordinates.
const List<GeorgianCity> georgianCities = [
  // თბილისი და ქვემო ქართლი
  GeorgianCity(name: 'თბილისი', nameEn: 'Tbilisi', region: 'თბილისი', lat: 41.7151, lon: 44.8271),
  GeorgianCity(name: 'რუსთავი', nameEn: 'Rustavi', region: 'ქვემო ქართლი', lat: 41.5495, lon: 44.9931),
  GeorgianCity(name: 'მარნეული', nameEn: 'Marneuli', region: 'ქვემო ქართლი', lat: 41.4776, lon: 44.8093),
  GeorgianCity(name: 'ბოლნისი', nameEn: 'Bolnisi', region: 'ქვემო ქართლი', lat: 41.4489, lon: 44.5386),
  GeorgianCity(name: 'გარდაბანი', nameEn: 'Gardabani', region: 'ქვემო ქართლი', lat: 41.4569, lon: 45.0906),
  GeorgianCity(name: 'დმანისი', nameEn: 'Dmanisi', region: 'ქვემო ქართლი', lat: 41.3269, lon: 44.2069),
  GeorgianCity(name: 'თეთრიწყარო', nameEn: 'Tetritsqaro', region: 'ქვემო ქართლი', lat: 41.5453, lon: 44.4661),
  GeorgianCity(name: 'წალკა', nameEn: 'Tsalka', region: 'ქვემო ქართლი', lat: 41.5947, lon: 44.0872),

  // მცხეთა-მთიანეთი
  GeorgianCity(name: 'მცხეთა', nameEn: 'Mtskheta', region: 'მცხეთა-მთიანეთი', lat: 41.8458, lon: 44.7207),
  GeorgianCity(name: 'დუშეთი', nameEn: 'Dusheti', region: 'მცხეთა-მთიანეთი', lat: 42.0847, lon: 44.7003),
  GeorgianCity(name: 'სტეფანწმინდა', nameEn: 'Stepantsminda', region: 'მცხეთა-მთიანეთი', lat: 42.6561, lon: 44.6417),
  GeorgianCity(name: 'გუდაური', nameEn: 'Gudauri', region: 'მცხეთა-მთიანეთი', lat: 42.4708, lon: 44.4806),

  // შიდა ქართლი
  GeorgianCity(name: 'გორი', nameEn: 'Gori', region: 'შიდა ქართლი', lat: 41.9847, lon: 44.1086),
  GeorgianCity(name: 'ხაშური', nameEn: 'Khashuri', region: 'შიდა ქართლი', lat: 41.9930, lon: 43.5993),
  GeorgianCity(name: 'კასპი', nameEn: 'Kaspi', region: 'შიდა ქართლი', lat: 41.9214, lon: 44.4270),
  GeorgianCity(name: 'ქარელი', nameEn: 'Kareli', region: 'შიდა ქართლი', lat: 42.0186, lon: 43.8969),

  // კახეთი
  GeorgianCity(name: 'თელავი', nameEn: 'Telavi', region: 'კახეთი', lat: 41.9192, lon: 45.4731),
  GeorgianCity(name: 'გურჯაანი', nameEn: 'Gurjaani', region: 'კახეთი', lat: 41.7431, lon: 45.7994),
  GeorgianCity(name: 'ყვარელი', nameEn: 'Kvareli', region: 'კახეთი', lat: 41.9497, lon: 45.8130),
  GeorgianCity(name: 'საგარეჯო', nameEn: 'Sagarejo', region: 'კახეთი', lat: 41.7331, lon: 45.3319),
  GeorgianCity(name: 'სიღნაღი', nameEn: 'Sighnaghi', region: 'კახეთი', lat: 41.6175, lon: 45.9214),
  GeorgianCity(name: 'ლაგოდეხი', nameEn: 'Lagodekhi', region: 'კახეთი', lat: 41.8236, lon: 46.2758),
  GeorgianCity(name: 'ახმეტა', nameEn: 'Akhmeta', region: 'კახეთი', lat: 42.0322, lon: 45.2078),
  GeorgianCity(name: 'დედოფლისწყარო', nameEn: 'Dedoplistsqaro', region: 'კახეთი', lat: 41.4667, lon: 46.1064),

  // სამცხე-ჯავახეთი
  GeorgianCity(name: 'ახალციხე', nameEn: 'Akhaltsikhe', region: 'სამცხე-ჯავახეთი', lat: 41.6392, lon: 42.9826),
  GeorgianCity(name: 'ბორჯომი', nameEn: 'Borjomi', region: 'სამცხე-ჯავახეთი', lat: 41.8395, lon: 43.3839),
  GeorgianCity(name: 'ბაკურიანი', nameEn: 'Bakuriani', region: 'სამცხე-ჯავახეთი', lat: 41.7492, lon: 43.5322),
  GeorgianCity(name: 'ახალქალაქი', nameEn: 'Akhalkalaki', region: 'სამცხე-ჯავახეთი', lat: 41.4058, lon: 43.4869),
  GeorgianCity(name: 'ნინოწმინდა', nameEn: 'Ninotsminda', region: 'სამცხე-ჯავახეთი', lat: 41.2650, lon: 43.5920),
  GeorgianCity(name: 'ადიგენი', nameEn: 'Adigeni', region: 'სამცხე-ჯავახეთი', lat: 41.6906, lon: 42.7000),

  // იმერეთი
  GeorgianCity(name: 'ქუთაისი', nameEn: 'Kutaisi', region: 'იმერეთი', lat: 42.2679, lon: 42.7180),
  GeorgianCity(name: 'ზესტაფონი', nameEn: 'Zestaponi', region: 'იმერეთი', lat: 42.1103, lon: 43.0378),
  GeorgianCity(name: 'სამტრედია', nameEn: 'Samtredia', region: 'იმერეთი', lat: 42.1553, lon: 42.3350),
  GeorgianCity(name: 'ჭიათურა', nameEn: 'Chiatura', region: 'იმერეთი', lat: 42.2905, lon: 43.2839),
  GeorgianCity(name: 'საჩხერე', nameEn: 'Sachkhere', region: 'იმერეთი', lat: 42.3436, lon: 43.4064),
  GeorgianCity(name: 'ტყიბული', nameEn: 'Tkibuli', region: 'იმერეთი', lat: 42.3506, lon: 42.9967),
  GeorgianCity(name: 'ვანი', nameEn: 'Vani', region: 'იმერეთი', lat: 42.0836, lon: 42.5222),
  GeorgianCity(name: 'ხონი', nameEn: 'Khoni', region: 'იმერეთი', lat: 42.3197, lon: 42.4247),

  // სამეგრელო-ზემო სვანეთი
  GeorgianCity(name: 'ზუგდიდი', nameEn: 'Zugdidi', region: 'სამეგრელო-ზემო სვანეთი', lat: 42.5088, lon: 41.8709),
  GeorgianCity(name: 'ფოთი', nameEn: 'Poti', region: 'სამეგრელო-ზემო სვანეთი', lat: 42.1461, lon: 41.6714),
  GeorgianCity(name: 'სენაკი', nameEn: 'Senaki', region: 'სამეგრელო-ზემო სვანეთი', lat: 42.2706, lon: 42.0656),
  GeorgianCity(name: 'ზჩხოროწყუ', nameEn: 'Chkhorotsqu', region: 'სამეგრელო-ზემო სვანეთი', lat: 42.5211, lon: 42.1131),
  GeorgianCity(name: 'მარტვილი', nameEn: 'Martvili', region: 'სამეგრელო-ზემო სვანეთი', lat: 42.3819, lon: 42.3789),
  GeorgianCity(name: 'აბაშა', nameEn: 'Abasha', region: 'სამეგრელო-ზემო სვანეთი', lat: 42.2044, lon: 42.2131),
  GeorgianCity(name: 'ხობი', nameEn: 'Khobi', region: 'სამეგრელო-ზემო სვანეთი', lat: 42.3131, lon: 41.9006),
  GeorgianCity(name: 'ანაკლია', nameEn: 'Anaklia', region: 'სამეგრელო-ზემო სვანეთი', lat: 42.3869, lon: 41.5628),
  GeorgianCity(name: 'მესტია', nameEn: 'Mestia', region: 'სამეგრელო-ზემო სვანეთი', lat: 43.0458, lon: 42.7300),

  // გურია
  GeorgianCity(name: 'ოზურგეთი', nameEn: 'Ozurgeti', region: 'გურია', lat: 41.9247, lon: 42.0089),
  GeorgianCity(name: 'ლანჩხუთი', nameEn: 'Lanchkhuti', region: 'გურია', lat: 42.0900, lon: 42.0331),
  GeorgianCity(name: 'ჩოხატაური', nameEn: 'Chokhatauri', region: 'გურია', lat: 41.9986, lon: 42.2367),

  // აჭარა
  GeorgianCity(name: 'ბათუმი', nameEn: 'Batumi', region: 'აჭარა', lat: 41.6459, lon: 41.6386),
  GeorgianCity(name: 'ქობულეთი', nameEn: 'Kobuleti', region: 'აჭარა', lat: 41.8214, lon: 41.7772),
  GeorgianCity(name: 'ხულო', nameEn: 'Khulo', region: 'აჭარა', lat: 41.6461, lon: 42.3103),
  GeorgianCity(name: 'ქედა', nameEn: 'Keda', region: 'აჭარა', lat: 41.6033, lon: 41.9439),
  GeorgianCity(name: 'შუახევი', nameEn: 'Shuakhevi', region: 'აჭარა', lat: 41.6300, lon: 42.1900),

  // რაჭა-ლეჩხუმი
  GeorgianCity(name: 'ამბროლაური', nameEn: 'Ambrolauri', region: 'რაჭა-ლეჩხუმი', lat: 42.5216, lon: 43.1503),
  GeorgianCity(name: 'ონი', nameEn: 'Oni', region: 'რაჭა-ლეჩხუმი', lat: 42.5794, lon: 43.4419),
  GeorgianCity(name: 'ცაგერი', nameEn: 'Tsageri', region: 'რაჭა-ლეჩხუმი', lat: 42.6469, lon: 42.7644),
  GeorgianCity(name: 'ლენტეხი', nameEn: 'Lentekhi', region: 'რაჭა-ლეჩხუმი', lat: 42.7894, lon: 42.7252),

  // meteo.gov.ge-ის დამატებითი დასახლებები — კურორტები, საკურორტო ცენტრები
  // და ოკუპირებული ტერიტორიების ადმინისტრაციული ცენტრები.
  GeorgianCity(name: 'აბასთუმანი', nameEn: 'Abastumani', region: 'სამცხე-ჯავახეთი', lat: 41.7536, lon: 42.8319),
  GeorgianCity(name: 'საირმე', nameEn: 'Sairme', region: 'იმერეთი', lat: 41.9060, lon: 42.7440),
  GeorgianCity(name: 'წყალტუბო', nameEn: 'Tsqaltubo', region: 'იმერეთი', lat: 42.3233, lon: 42.6016),
  GeorgianCity(name: 'ბახმარო', nameEn: 'Bakhmaro', region: 'გურია', lat: 41.8513, lon: 42.3245),
  GeorgianCity(name: 'თიანეთი', nameEn: 'Tianeti', region: 'მცხეთა-მთიანეთი', lat: 42.1098, lon: 44.9682),
  GeorgianCity(name: 'ფასანაური', nameEn: 'Pasanauri', region: 'მცხეთა-მთიანეთი', lat: 42.3489, lon: 44.6905),
  GeorgianCity(name: 'ცხინვალი', nameEn: 'Tskhinvali', region: 'შიდა ქართლი', lat: 42.2257, lon: 43.9700),
  GeorgianCity(name: 'სოხუმი', nameEn: 'Sokhumi', region: 'აფხაზეთი', lat: 43.0031, lon: 41.0197),
];
