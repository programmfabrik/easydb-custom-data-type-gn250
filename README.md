# easydb-custom-data-type-gn250

This is a plugin for [easyDB 5](http://5.easydb.de/) with Custom Data Type `CustomDataTypeGN250` for references to entities of the [Bundesamt für Kartographie](http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=20&gdz_user_id=0).

The Plugins uses <http://ws.gbv.de/suggest/gn250/> for the autocomplete-suggestions and the mapbox-API for displaying the result in a map.

## configuration

As defined in `CustomDataTypeGN250.config.yml` this datatype can be configured:

### Schema options

* which "mapquest-API-key" to use

### Mask options

* whether additional informationen is loaded if the mouse hovers a suggestion in the search result

## sources

The source code of this plugin is managed in a git repository at <https://github.com/programmfabrik/easydb-custom-data-type-gn250>. Please use [the issue tracker](https://github.com/programmfabrik/easydb-custom-data-type-gn250/issues) for bug reports and feature requests!

