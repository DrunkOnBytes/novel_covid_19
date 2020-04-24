import 'package:flutter/material.dart';
import 'package:novel_covid_19/controllers/covid_api.dart';
import 'package:novel_covid_19/custom_widgets/theme_switch.dart';
import 'package:novel_covid_19/custom_widgets/virus_loader.dart';
import 'package:novel_covid_19/models/country_model.dart';
import 'country_detail.dart';

class CountryListPage extends StatefulWidget {
  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  bool _isLoading = false;
  CovidApi api = CovidApi();
  var items = List<Country>();
  var _focusNode = FocusNode();
  List<Country> _countries = List<Country>();
  var _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  void filterSearchResults(String query) {
    List<Country> dummySearchList = List<Country>();
    dummySearchList.addAll(_countries);
    if (query.isNotEmpty) {
      List<Country> dummyListData = List<Country>();
      dummySearchList.forEach((item) {
        if (item.country.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(_countries);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Countries',
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        leading: Icon(
          Icons.public,
          color: Theme.of(context).accentColor,
        ),
        actions: <Widget>[
          ThemeSwitch(),
        ],
      ),
      body: _isLoading
          ? VirusLoader()
          : _countries == null
              ? buildErrorMessage()
              : Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        child: TextFormField(
                          focusNode: _focusNode,
                          controller: _controller,
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.search,
                                color: Theme.of(context).accentColor,
                              ),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).accentColor)),
                              labelText: 'Search',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).accentColor),
                              hintText: 'Enter country name'),
                          onChanged: filterSearchResults,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          var country = items[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Card(
                              elevation: 4.0,
                              child: ListTile(
                                onTap: () {
                                  _controller.clear();
                                  filterSearchResults('');
                                  _focusNode.unfocus();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CountryDetailPage(
                                          countryName: country.country),
                                    ),
                                  );
                                },
                                title: Text(country.country),
                                subtitle:
                                    Text('Cases: ' + country.cases.toString()),
                                trailing: Icon(Icons.arrow_right),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Center buildErrorMessage() {
    return Center(
      child: Text(
        'Unable to fetch data',
        style: Theme.of(context).textTheme.title.copyWith(color: Colors.grey),
      ),
    );
  }

  void _fetchCountries() async {
    try {
      setState(() => _isLoading = true);
      var countries = await api.getAllCountriesInfo();
      setState(() {
        _countries = countries;
        items.addAll(_countries);
      });
    } catch (ex) {
      setState(() => _countries = null);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
