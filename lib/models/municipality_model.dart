

import 'package:equatable/equatable.dart';

class Municipality extends Equatable{
  final String name;
  //alle andre parametre som nullable.

  const Municipality({
    required this.name,
  });

  @override
  List<Object?> get props => [name];



  static List<Municipality> municipalities = [
    Municipality(name:'Sønderborg'),
    Municipality(name:'København'),
    Municipality(name:'Århus'),
    Municipality(name:'Aalborg'),
    Municipality(name:'Odense'),
    Municipality(name:'Vejle'),
    Municipality(name:'Esbjerg'),
    Municipality(name:'Frederiksberg'),
    Municipality(name:'Randers'),
    Municipality(name:'Viborg'),
    Municipality(name:'Silkeborg'),
    Municipality(name:'Kolding'),
    Municipality(name:'Horsens'),
    Municipality(name:'Herning'),
    Municipality(name:'Roskilde'),
    Municipality(name:'Næstved'),
    Municipality(name:'Slagelse'),
    Municipality(name:'Gentofte'),
    Municipality(name:'Holbæk'),
    Municipality(name:'Gladsaxe'),
    Municipality(name:'Hjørring'),
    Municipality(name:'Skanderborg'),
    Municipality(name:'Helsingør'),
    Municipality(name:'Køge'),
    Municipality(name:'Guldborgsund'),
    Municipality(name:'Frederikshavn'),
    Municipality(name:'Holstebro'),
    Municipality(name:'Svendborg'),
    Municipality(name:'Aabenraa'),
    Municipality(name:'Rudersdal'),
    Municipality(name:'Lyngby-Taastrup'),
    Municipality(name:'Faaborg-Midtfyn'),
    Municipality(name:'Hillerød'),
    Municipality(name:'Fredericia'),
    Municipality(name:'Greve'),
    Municipality(name:'Varde'),
    Municipality(name:'Ballerup'),
    Municipality(name:'Kalundborg'),
    Municipality(name:'Favrskov'),
    Municipality(name:'Hedensted'),
    Municipality(name:'Frederikssund'),
    Municipality(name:'Skive'),
    Municipality(name:'Vordingborg'),
    Municipality(name:'Egedal'),
    Municipality(name:'Syddjurs'),
    Municipality(name:'Thisted'),
    Municipality(name:'Vejen'),
    Municipality(name:'Tårnby'),
    Municipality(name:'Mariagerfjord'),
    Municipality(name:'Ikast-Brande'),
    Municipality(name:'Rødovre'),
    Municipality(name:'Furesø'),
    Municipality(name:'Fredensborg'),
    Municipality(name:'Gribskov'),
    Municipality(name:'Assens'),
    Municipality(name:'Lolland'),
    Municipality(name:'Bornholm'),
    Municipality(name:'Middelfart'),
    Municipality(name:'Jammerbugt'),
    Municipality(name:'Tønder'),
    Municipality(name:'Norddjurs'),
    Municipality(name:'Faxe'),
    Municipality(name:'Vesthimmerland'),
    Municipality(name:'Brønderslev-Dronninglund'),
    Municipality(name:'Brøndby'),
    Municipality(name:'Ringsted'),
    Municipality(name:'Odsherred'),
    Municipality(name:'Nyborg'),
    Municipality(name:'Halsnæs'),
    Municipality(name:'Rebild'),
    Municipality(name:'Sorø'),
    Municipality(name:'Nordfyns'),
    Municipality(name:'Herlev'),
    Municipality(name:'Lejre'),
    Municipality(name:'Albertslund'),
    Municipality(name:'Billund'),
    Municipality(name:'Allerød'),
    Municipality(name:'Hørsholm'),
    Municipality(name:'Kerteminde'),
    Municipality(name:'Solrød'),
    Municipality(name:'Odder'),
    Municipality(name:'Ishøj'),
    Municipality(name:'Stevns'),
    Municipality(name:'Glostrup'),
    Municipality(name:'Struer'),
    Municipality(name:'Morsø'),
    Municipality(name:'Lemvig'),
    Municipality(name:'Vallensbæk'),
    Municipality(name:'Dragør'),
    Municipality(name:'Langeland'),
    Municipality(name:'Ærø'),
    Municipality(name:'Samsø'),
    Municipality(name:'Fanø'),
    Municipality(name:'Læsø'),
    Municipality(name:'Ringkøbing-Skjern'),
    Municipality(name:'Haderslev'),
    Municipality(name:'Høje-Taastrup'),
  ];
  List<Municipality> get getList => municipalities;


}