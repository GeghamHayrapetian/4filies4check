import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_chat/data/models/country.dart';
import 'package:snap_chat/data/repositories/country_repository.dart';

import '../../../app_localizations.dart';
import 'country_bloc.dart';
import 'country_event.dart';
import 'country_state.dart';

//typedef CountryValue = Country Function(Country);

class CountryScreen extends StatefulWidget {
  CountryScreen({this.notifier});
  ValueNotifier<Country> notifier;

  @override
  _CountryScreenState createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  CountryBloc _countryBloc;

  @override
  void initState() {
    super.initState();
    _countryBloc = CountryBloc(countryRepository: CountryRepository());
    _countryBloc.add(FetchCountryEvent());
  }

  @override
  void dispose() {
    _countryBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CountryBloc>(
      create: (context) {
        return _countryBloc;
      },
      child: _render(),
    );
  }

  Widget _render() {
    return BlocBuilder<CountryBloc, CountryState>(builder: (context, state) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 40),
          child: Column(
            children: [
              _renderButtonBack(state, context),
              Expanded(child: _fieldOnScreen(state)),
            ],
          ),
        ),
      );
    });
  }

  Widget _fieldOnScreen(CountryState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _renderFilterField(state),
          if (state is CountryLoaded)
            Expanded(child: _builCountryList(state.counties))
          else
            state is SearchedCountries
                ? Expanded(child: _builCountryList(state.searchedCountries))
                : Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: _buildLoading(),
                  )
        ],
      ),
    );
  }

  Widget _renderFilterField(CountryState state) {
    return Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            child: TextField(
              onChanged: (value) {
                _countryBloc.add(SearchCountry(searchingName: value));
              },
              decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('search'),
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)))),
            )));
  }

  Widget _renderButtonBack(CountryState state, BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
            size: 32,
          ),
          onPressed: () =>
              state is EnteredCountry ? Navigator.pop(context) : null),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  String _stringToEmoji(String string) {
    return string.replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0).codeUnitAt(0) + 127397));
  }

  Widget _builCountryList(List<Country> countries) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(
            color: Colors.black,
          ),
          shrinkWrap: true,
          itemCount: countries.length,
          itemBuilder: (ctx, pos) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                widget.notifier.value = countries[pos];
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                child: Stack(
                  children: [
                    Text(
                      "${_stringToEmoji(countries[pos].iso2Cc)}  ${countries[pos].name}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(countries[pos].e164Cc,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          )),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
