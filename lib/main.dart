import 'package:flutter/material.dart';
import 'package:havadurumu/searchpage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(
    MaterialApp(
      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

List<Widget> listeForecastWeather = [];
String sehirbilgisiCityName = "";

class _HomePageState extends State<HomePage> {
  // Alert Dialog fonksiyonu
  dynamic alertDialogFonksiyonu() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (
          BuildContext,
        ) {
          return AlertDialog(
            title: Text("Http Hatasi:"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [Text("Lutfen gecerli bir şehir ismi girin")],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"))
            ],
          );
        });
  }

  //Global degisken olusturdum.
  List listeGunler = [
    "Pazartesi",
    "Salı",
    "Çarşamba",
    "Perşembe",
    "Cuma",
    "Cumartesi",
    "Pazar"
  ];
  List listeAylar = [
    "Ocak",
    "Şubat",
    "Mart",
    "Nisan",
    "Mayıs",
    "Haziran",
    "Temmuz",
    "Ağustos",
    "Eylül",
    "Ekim",
    "Kasım",
    "Aralık"
  ];

  // Current weather Variables
  String sehirbilgisiCurrentWeather = "";
  String ulkebilgisiCurrentWeather = "";
  String iconbilgisiCurrentWeather = "";
  String descriptionbilgisiCurrentWeather = "";
  double sicaklikbilgisiCurrentWeather = 0;
  double hissedilenSicaklikBilgisiCurrentWeather = 0;
  double longbilgisi = 0;
  double latbilgisi = 0;
  String secilenSehir = '';

  var dataForecastWeather;
  var zamanParsedForecastWeather;
  var dataCurrentWeather;
  var description;
  bool controlVariable=true;

  void asyncMethod() async {
    await getCurrentLocationFromDevice();
    if(controlVariable==true){
      await getForecastWeather();
      getCurrentWeather();
    }
  }

  initState() {
    super.initState();
    asyncMethod();
  }

  int intFonk(){
    int counter=0;
    for (int i = 0; i <= dataForecastWeather["list"].length; i++){
      zamanParsedForecastWeather =DateTime.parse(dataForecastWeather["list"][i]["dt_txt"]);
     if (zamanParsedForecastWeather.hour != 0){
       counter++;
     }else{
       break;
     }
    }
    return counter;
  }

  Widget listViewMethodu() {
    return Center(
      child: Container(
          height: 200,
          child: ListView.builder(shrinkWrap: true,
              itemCount: intFonk(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, int i) {
                description=dataForecastWeather["list"][i]["weather"][0]["description"];
                return Card(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${description[0].toUpperCase() + description.substring(1, description.length)}",style: TextStyle(color: Colors.white)),
                      Text(style: TextStyle(color: Colors.white),
                          "Saat: ${(DateTime.parse(dataForecastWeather["list"][i]["dt_txt"])).hour}:${(DateTime.parse(dataForecastWeather["list"][i]["dt_txt"])).minute}0"),
                      Text("${dataForecastWeather["list"][i]["main"]["temp"]}",style: TextStyle(color: Colors.white)),
                      Image.network(
                          "https://openweathermap.org/img/wn/${dataForecastWeather["list"][i]["weather"][0]["icon"]}@2x.png"),
                      Text(
                        "${listeGunler[(DateTime.parse(dataForecastWeather["list"][i]["dt_txt"])).weekday - 1]}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  color: Colors.black38,
                );
              })),
    );
  }

  //Bu fonksiyon ile kullanici cihazindan lokasyon bilgisini cektim.
  Future<void> getCurrentLocationFromDevice() async {
    try {
      Position pozisyon = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        longbilgisi = pozisyon.longitude;
        latbilgisi = pozisyon.latitude;
      });
      print(longbilgisi);
      print(latbilgisi);
    } catch (error) {
      print("$error");
      controlVariable=false;
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (
              BuildContext,
              ) {
            return AlertDialog(
              title: Text("Hata!"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [Text("Kullanıcı, cihazın konumuna erişim izinlerini reddetti.")],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Kapat"))
              ],
            );
          });
    }
  }
  // Bu fonksiyon ile  cihazin lat long bilgisine gore ya da kullanicinin girdigi sehire gore mevcut hava durumunu cekiyorum.
  Future<void> getCurrentWeather() async {
    if (secilenSehir.isNotEmpty) {
      final responseCityName = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?&units=metric&q=$secilenSehir&lang=tr&appid=f7431eb947fce4e7c83104f1fffed92f"));
      if (responseCityName.statusCode == 200) {
        dataCurrentWeather = jsonDecode(responseCityName.body);
        setState(() {
          sehirbilgisiCurrentWeather = dataCurrentWeather["name"];
          ulkebilgisiCurrentWeather = dataCurrentWeather["sys"]["country"];
          sicaklikbilgisiCurrentWeather = dataCurrentWeather["main"]["temp"];
          hissedilenSicaklikBilgisiCurrentWeather =
              dataCurrentWeather["main"]["feels_like"];
          iconbilgisiCurrentWeather = dataCurrentWeather["weather"][0]["icon"];
          descriptionbilgisiCurrentWeather =
              dataCurrentWeather["weather"][0]["description"];
        });
      } else {
        alertDialogFonksiyonu();
      }
    } else {
      final responseLatLong = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?&units=metric&lat=$latbilgisi&lon=$longbilgisi&lang=tr&appid=f7431eb947fce4e7c83104f1fffed92f"));
      if (responseLatLong.statusCode == 200) {
        dataCurrentWeather = jsonDecode(responseLatLong.body);
        setState(() {
          sehirbilgisiCurrentWeather = dataCurrentWeather["name"];
          ulkebilgisiCurrentWeather = dataCurrentWeather["sys"]["country"];
          sicaklikbilgisiCurrentWeather = dataCurrentWeather["main"]["temp"];
          hissedilenSicaklikBilgisiCurrentWeather =
              dataCurrentWeather["main"]["feels_like"];
          iconbilgisiCurrentWeather = dataCurrentWeather["weather"][0]["icon"];
          descriptionbilgisiCurrentWeather =
              dataCurrentWeather["weather"][0]["description"];
        });
      } else {
        alertDialogFonksiyonu();
      }
    }
  }

  //------------------------------------------------------------------------

  //Bu Fonksiyon ile ileriye donuk hava durumu verisini cekiyorum
  Future<void> getForecastWeather() async {
    if (secilenSehir.isNotEmpty) {
      final responseForecastCityName = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?&q=$secilenSehir&units=metric&lang=tr&appid=f7431eb947fce4e7c83104f1fffed92f"));
      if (responseForecastCityName.statusCode == 200) {
        dataForecastWeather = jsonDecode(responseForecastCityName.body);
        listViewMethodu();
      } else {
        alertDialogFonksiyonu();
      }
    }
    //Secilen sehir bos ise burasi calisacak
    else {
      print("getForecastWeather calisiyor.");
      final responseForecastLatLong = await http.get(
        Uri.parse(
            "https://api.openweathermap.org/data/2.5/forecast?&lat=$latbilgisi&lon=$longbilgisi&units=metric&lang=tr&appid=f7431eb947fce4e7c83104f1fffed92f"),
      );
      if (responseForecastLatLong.statusCode == 200) {
        dataForecastWeather = jsonDecode(responseForecastLatLong.body);
       listViewMethodu();
        print("for fonksiyonu calisiyor");
      } else {
        alertDialogFonksiyonu();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return sehirbilgisiCurrentWeather.isEmpty
        ? Center(child: SpinKitFadingCircle(size: 120,
        itemBuilder: (_,int a){
          return DecoratedBox(
              decoration: BoxDecoration(color: a.isEven?Colors.red:Colors.blue));
    }))
        :Scaffold(
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/$iconbilgisiCurrentWeather.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "${(descriptionbilgisiCurrentWeather[0].toUpperCase() + descriptionbilgisiCurrentWeather.substring(1, descriptionbilgisiCurrentWeather.length))}",
                      style: TextStyle(fontSize: 30),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          "https://openweathermap.org/img/wn/$iconbilgisiCurrentWeather@2x.png",
                        ),
                        Text(
                          "$sicaklikbilgisiCurrentWeather °",
                          style: TextStyle(
                              fontSize: 60,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    offset: Offset(2, 2),
                                    color: Colors.black,
                                    blurRadius: 1),
                              ]),
                        ),
                      ],
                    ),
                    Text("Hissedilen:$hissedilenSicaklikBilgisiCurrentWeather"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "$ulkebilgisiCurrentWeather, $sehirbilgisiCurrentWeather ",
                          style: TextStyle(fontSize: 30, color: Colors.black),
                        ),
                        IconButton(
                          iconSize: 30,
                          onPressed: () async {
                            final sehirismiSearchPageDenGelen =
                                await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPage(),
                              ),
                            );
                            setState(() {
                              // Tiklaninca Listeyi sifirlama yapiyorum burada
                              listeForecastWeather = [];
                              secilenSehir = sehirismiSearchPageDenGelen;
                            });
                            await getForecastWeather();
                            getCurrentWeather();
                          },
                          icon: Icon(Icons.search),
                        ),
                      ],
                    ),
                    Text(
                      "${listeGunler[DateTime.now().weekday - 1]}, ${listeAylar[DateTime.now().month - 1]} ${DateTime.now().day}",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    listViewMethodu(),
                  ]),
            ),
          );
  }
}

