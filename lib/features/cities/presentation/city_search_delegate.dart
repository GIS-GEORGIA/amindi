import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../data/georgian_cities.dart';
import '../domain/georgian_city.dart';

/// Search over the bundled Georgian city list. Matches the Georgian name, the
/// Latin name and the region, so typing in either script works.
class CitySearchDelegate extends SearchDelegate<GeorgianCity?> {
  CitySearchDelegate(this.locale) : super(searchFieldLabel: 'cities.search'.tr());

  final String locale;

  List<GeorgianCity> _matches() {
    final q = query.trim().toLowerCase();
    final list = [...georgianCities]
      ..sort((a, b) => a.name.compareTo(b.name));
    if (q.isEmpty) return list;
    return list
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.nameEn.toLowerCase().contains(q) ||
            c.region.toLowerCase().contains(q))
        .toList();
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _list(context);

  @override
  Widget buildSuggestions(BuildContext context) => _list(context);

  Widget _list(BuildContext context) {
    final matches = _matches();
    if (matches.isEmpty) {
      return Center(child: Text('cities.no_results'.tr()));
    }
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, i) {
        final city = matches[i];
        return ListTile(
          leading: const Icon(Icons.location_city_outlined),
          title: Text(locale == 'en' ? city.nameEn : city.name),
          subtitle: Text(city.region),
          onTap: () => close(context, city),
        );
      },
    );
  }
}
