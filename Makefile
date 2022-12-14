PLUGIN_NAME = custom-data-type-gn250
PLUGIN_PATH = easydb-custom-data-type-gn250

L10N_FILES = easydb-library/src/commons.l10n.csv \
    l10n/$(PLUGIN_NAME).csv

INSTALL_FILES = \
    $(WEB)/l10n/cultures.json \
    $(WEB)/l10n/de-DE.json \
    $(WEB)/l10n/en-US.json \
    $(JS) \
    $(CSS) \
    manifest.yml

COFFEE_FILES = easydb-library/src/commons.coffee \
    src/webfrontend/CustomDataTypeGN250.coffee

CSS_FILES = src/webfrontend/css/main.css

all: build

include easydb-library/tools/base-plugins.make

$(CSS): $(CSS_FILES)
	cat $(CSS_FILES) > $(CSS)

build: code buildinfojson

code: $(JS) $(L10N)

clean: clean-base
