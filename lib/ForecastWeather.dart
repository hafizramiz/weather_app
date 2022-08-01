import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

String sehirBilgisiForecast = '';

class ForecastWeather extends StatefulWidget {
  String secilenSehirBilgisi = "";

  ForecastWeather({required this.secilenSehirBilgisi}) {
    sehirBilgisiForecast = this.secilenSehirBilgisi;
  }

  @override
  State<ForecastWeather> createState() => _ForecastWeatherState();
}

class _ForecastWeatherState extends State<ForecastWeather> {
  var dataForecastDays;
  bool controlVar = true;
  String description = "";
  List listeGunler = [
    "Pazartesi",
    "Salı",
    "Çarşamba",
    "Perşembe",
    "Cuma",
    "Cumartesi",
    "Pazar"
  ];

  // Data cekmek icin method
  Future getForecastData() async {
    bool controlVariable = true;
    final responseForecast = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?&q=$sehirBilgisiForecast&lang=tr&units=metric&appid=f7431eb947fce4e7c83104f1fffed92f"));
    if (responseForecast.statusCode == 200) {
      dataForecastDays = jsonDecode(responseForecast.body);
      setState(() {
        controlVar = false;
      });
    } else {
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
                  children: [Text("Lutfen gecerli bir sehir ismi girin")],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      int count = 0;
                      Navigator.popUntil(context, (route) {
                        return count++ == 2;
                      });
                    },
                    child: Text("OK"))
              ],
            );
          });
      print("Forecast hata kodu: ${responseForecast.statusCode}");
    }
  }

  initState() {
    super.initState();
    getForecastData();
  }

  @override
  Widget build(BuildContext context) {
    return controlVar == true
        ? Center(child: SpinKitFadingFour(size: 120,
        itemBuilder: (_,int a){
          return DecoratedBox(
              decoration: BoxDecoration(color: a.isEven?Colors.white:Colors.black38));
        }))
        : Scaffold(
            backgroundColor: Colors.blueGrey,
            body: ListView.separated(
              itemCount: dataForecastDays["list"].length,
              itemBuilder: (_, int x) {
                return Divider(height: 10);
              },
              separatorBuilder: (_, int x) {
                description =
                    dataForecastDays["list"][x]["weather"][0]["description"];
                //Containerler ekrana sigmiyor.Responsive hale getirmeliyim.
                //FractionallSizedBox ile yapmayi deniycem
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    image: DecorationImage(
                        opacity: 150.0,
                        image: AssetImage(
                          "assets/${dataForecastDays["list"][x]["weather"][0]["icon"]}.jpg",
                        ),
                        fit: BoxFit.cover),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Container(width: 100,
                                child: Text(
                                    "${description[0].toUpperCase() + description.substring(1, description.length)}",
                                    style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold)),
                              ),
                              Text(
                                "${sehirBilgisiForecast[0].toUpperCase() + sehirBilgisiForecast.substring(1, sehirBilgisiForecast.length)}",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              Text("Saat ${(DateTime.parse(dataForecastDays["list"][x]["dt_txt"])).hour} : ${(DateTime.parse(dataForecastDays["list"][x]["dt_txt"])).minute}0"),
                              Text(
                                  "${listeGunler[(DateTime.parse(dataForecastDays["list"][x]["dt_txt"])).weekday - 1]}"),
                            ],
                          ),
                          Column(
                            children: [
                              Image.network(
                                  "http://openweathermap.org/img/wn/${dataForecastDays["list"][x]["weather"][0]["icon"]}@2x.png"),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Sıcaklık: ${dataForecastDays["list"][x]["main"]["temp"]} ° C",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  "Hissedilen: ${dataForecastDays["list"][x]["main"]["feels_like"]} ° C"),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  height: MediaQuery.of(context).size.height * 0.13,
                  width: MediaQuery.of(context).size.width * 0.3,
                );
              },
              scrollDirection: Axis.vertical,
            ),
          );
  }
}
