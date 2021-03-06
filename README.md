> This Plugin / Repo is being maintained by a community of developers.
There is no warranty given or bug fixing guarantee; especially not by
Programmfabrik GmbH. Please use the github issue tracking to report bugs
and self organize bug fixing. Feel free to directly contact the committing
developers.

# easydb-custom-data-type-gn250

This is a plugin for [easyDB 5](http://5.easydb.de/) with Custom Data Type `CustomDataTypeGN250` for references to entities of the gn250-Set of [Bundesamt für Kartographie](http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=20&gdz_user_id=0).

The Plugins uses <http://ws.gbv.de/suggest/gn250/> for the autocomplete-suggestions and the mapbox-API for displaying the result in a map.

## configuration

As defined in `CustomDataTypeGN250.config.yml` this datatype can be configured:

### Schema options

* which "mapbox-token" to use

### Mask options

* none

## saved data
* conceptName
    * Preferred label of the linked record
* conceptURI
    * URI to linked record
* _fulltext
    * easydb-fulltext
* _standard
    * easydb-standard

## sources

The source code of this plugin is managed in a git repository at <https://github.com/programmfabrik/easydb-custom-data-type-gn250>. Please use [the issue tracker](https://github.com/programmfabrik/easydb-custom-data-type-gn250/issues) for bug reports and feature requests!
