class CustomDataTypeGN250 extends CustomDataTypeWithCommons

  #######################################################################
  # bugfix, may be removed after next update (1.3.2017)
  getL10NPrefix: ->
    "custom.data.type.gn250"


  #######################################################################
  # return name of plugin
  getCustomDataTypeName: ->
    "custom:base.custom-data-type-gn250.gn250"


  #######################################################################
  # return name (l10n) of plugin
  getCustomDataTypeNameLocalized: ->
    $$("custom.data.type.gn250.name")


  #######################################################################
  # read info from gn250-terminology
  __getAdditionalTooltipInfo: (uri, tooltip, mapquest_api_key, extendedInfo_xhr) ->

    # extract gn250ID from uri
    gn250ID = uri
    gn250ID = gn250ID.split "/"
    gn250ID = gn250ID.pop()

    # download infos from entityfacts
    if extendedInfo_xhr.xhr != undefined
      # abort eventually running request
      extendedInfo_xhr.xhr.abort()

    # start new request
    extendedInfo_xhr.xhr = new (CUI.XHR)(url: location.protocol + '//uri.gbv.de/terminology/gn250/' + gn250ID + '?format=json')
    extendedInfo_xhr.xhr.start()
    .done((data, status, statusText) ->
      htmlContent = '<span style="font-weight: bold">Informationen über den Eintrag</span>'
      if mapquest_api_key
          url = location.protocol  + '//ws.gbv.de/suggest/mapfromgn250id/?id=' + gn250ID + '&zoom=12&width=400&height=250&mapquestapikey=' + mapquest_api_key;
          htmlContent += '<div style="width:400px; height: 250px; background-image: url(' + url + '); background-repeat: no-repeat; background-position: center center;"></div>'
      htmlContent += '<table style="border-spacing: 10px; border-collapse: separate;">'

      if data.NNID
        if typeof data.NNID != 'object'
            htmlContent += '<tr><td>NNID:</td><td>' + data.NNID + '</td></tr>'

      if data.OBA
        if typeof data.OBA != 'object'
            htmlContent += '<tr><td>OBA:</td><td>' + data.OBA + '</td></tr>'

      if data.OBA_WERT
        if typeof data.OBA_WERT != 'object'
            htmlContent += '<tr><td>OBA_WERT:</td><td>' + data.OBA_WERT + '</td></tr>'

      if data.NAME
        if typeof data.NAME != 'object'
            htmlContent += '<tr><td>Name:</td><td>' + data.NAME + '</td></tr>'

      if data.E
        if typeof data.NAME2 != 'object'
            htmlContent += '<tr><td>Name2:</td><td>' + data.NAME2 + '</td></tr>'

      if data.GEMEINDE
        if typeof data.GEMEINDE != 'object'
            htmlContent += '<tr><td>Gemeinde:</td><td>' + data.GEMEINDE + '</td></tr>'

      if data.VERWGEM
        if typeof data.VERWGEM != 'object'
            htmlContent += '<tr><td>Verwaltungsgemeinde:</td><td>' + data.VERWGEM + '</td></tr>'

      if data.KREIS
        if typeof data.KREIS != 'object'
            htmlContent += '<tr><td>Kreis:</td><td>' + data.KREIS + '</td></tr>'

      if data.REGBEZIRK
        if typeof data.REGBEZIRK != 'object'
            htmlContent += '<tr><td>Reg.Bezirk:</td><td>' + data.REGBEZIRK + '</td></tr>'

      if data.BUNDESLAND
        if typeof data.BUNDESLAND != 'object'
            htmlContent += '<tr><td>Bundesland:</td><td>' + data.BUNDESLAND + '</td></tr>'

      if data.SOURCE
        if typeof data.SOURCE != 'object'
            htmlContent += '<tr><td>Quelle:</td><td>' + data.SOURCE + '</td></tr>'

      #tooltip.getPane().replace(htmlContent, "center")
      tooltip.DOM.html(htmlContent);
      tooltip.autoSize()
    )
    .fail (data, status, statusText) ->
        console.debug 'FAIL', extendedInfo_xhr.xhr.getXHR(), extendedInfo_xhr.xhr.getResponseHeaders()

    return


  #######################################################################
  # handle suggestions-menu
  __updateSuggestionsMenu: (cdata, cdata_form, suggest_Menu, searchsuggest_xhr) ->
    that = @

    delayMillisseconds = 200

    setTimeout ( ->

        gn250_searchterm = cdata_form.getFieldsByName("searchbarInput")[0].getValue()
        gn250_countSuggestions = cdata_form.getFieldsByName("countOfSuggestions")[0].getValue()

        if gn250_searchterm.length == 0
            return

        # run autocomplete-search via xhr
        if searchsuggest_xhr.xhr != undefined
            # abort eventually running request
            searchsuggest_xhr.xhr.abort()
        # start new request
        searchsuggest_xhr.xhr = new (CUI.XHR)(url: location.protocol + '//ws.gbv.de/suggest/gn250/?searchterm=' + gn250_searchterm + '&count=' + gn250_countSuggestions)
        searchsuggest_xhr.xhr.start().done((data, status, statusText) ->

            console.debug 'OK', searchsuggest_xhr.xhr.getXHR(), searchsuggest_xhr.xhr.getResponseHeaders()

            # init xhr for tooltipcontent
            extendedInfo_xhr = { "xhr" : undefined }

            # create new menu with suggestions
            menu_items = []
            # the actual Featureclass
            for suggestion, key in data[1]
              do(key) ->
                # the actual Featureclass...
                aktType = data[2][key]
                lastType = ''
                if key > 0
                  lastType = data[2][key-1]
                if aktType != lastType
                  item =
                    divider: true
                  menu_items.push item
                  item =
                    label: aktType
                  menu_items.push item
                  item =
                    divider: true
                  menu_items.push item
                item =
                  text: suggestion
                  value: data[3][key]
                  tooltip:
                    markdown: true
                    placement: "e"
                    content: (tooltip) ->
                      # if enabled in mask-config
                      if that.getCustomMaskSettings().show_infopopup?.value
                        mapquest_api_key = ''
                        if that.getCustomSchemaSettings().mapquest_api_key?.value
                            mapquest_api_key = that.getCustomSchemaSettings().mapquest_api_key?.value
                        that.__getAdditionalTooltipInfo(data[3][key], tooltip, mapquest_api_key, extendedInfo_xhr)
                        new Label(icon: "spinner", text: "lade Informationen")
                menu_items.push item

            # set new items to menu
            itemList =
              onClick: (ev2, btn) ->
                # lock in save data
                cdata.conceptURI = btn.getOpt("value")
                cdata.conceptName = btn.getText()
                # lock in form
                cdata_form.getFieldsByName("conceptName")[0].storeValue(cdata.conceptName).displayValue()
                # nach eadb5-Update durch "setText" ersetzen und "__checkbox" rausnehmen
                cdata_form.getFieldsByName("conceptURI")[0].__checkbox.setText(cdata.conceptURI)
                cdata_form.getFieldsByName("conceptURI")[0].show()

                # clear searchbar
                cdata_form.getFieldsByName("searchbarInput")[0].setValue('')
              items: menu_items

            # if no hits set "empty" message to menu
            if itemList.items.length == 0
              itemList =
                items: [
                  text: "kein Treffer"
                  value: undefined
                ]

            suggest_Menu.setItemList(itemList)

            suggest_Menu.show()

        )
    ), delayMillisseconds


  #######################################################################
  # create form
  __getEditorFields: (cdata) ->
    fields = [
      {
        type: CUI.Select
        class: "commonPlugin_Select"
        undo_and_changed_support: false
        form:
            label: $$('custom.data.type.gn250.modal.form.text.count')
        options: [
          (
              value: 10
              text: '10 Vorschläge'
          )
          (
              value: 20
              text: '20 Vorschläge'
          )
          (
              value: 50
              text: '50 Vorschläge'
          )
          (
              value: 100
              text: '100 Vorschläge'
          )
          (
              value: 500
              text: '500 Vorschläge'
          )
        ]
        name: 'countOfSuggestions'
      }
      {
        type: CUI.Input
        class: "commonPlugin_Input"
        undo_and_changed_support: false
        form:
            label: $$("custom.data.type.gn250.modal.form.text.searchbar")
        placeholder: $$("custom.data.type.gn250.modal.form.text.searchbar.placeholder")
        name: "searchbarInput"
      }
      {
        form:
          label: "Gewählter Eintrag"
        type: CUI.Output
        name: "conceptName"
        data: {conceptName: cdata.conceptName}
      }
      {
        form:
          label: "Verknüpfte URI"
        type: CUI.FormButton
        name: "conceptURI"
        icon: new CUI.Icon(class: "fa-lightbulb-o")
        text: cdata.conceptURI
        onClick: (evt,button) =>
          window.open cdata.conceptURI, "_blank"
        onRender : (_this) =>
          if cdata.conceptURI == ''
            _this.hide()
      }]

    fields


  #######################################################################
  # renders the "result" in original form (outside popover)
  __renderButtonByData: (cdata) ->

    that = @

    # when status is empty or invalid --> message

    switch @getDataStatus(cdata)
      when "empty"
        return new CUI.EmptyLabel(text: $$("custom.data.type.gn250.edit.no_gn250")).DOM
      when "invalid"
        return new CUI.EmptyLabel(text: $$("custom.data.type.gn250.edit.no_valid_gn250")).DOM

    # if status is ok
    cdata.conceptURI = CUI.parseLocation(cdata.conceptURI).url

    # if conceptURI .... ... patch abwarten
    mapquest_api_key = @getCustomSchemaSettings().mapquest_api_key?.value
    # output Button with Name of picked GN250-Entry and URI
    new CUI.ButtonHref
      appearance: "link"
      href: cdata.conceptURI
      target: "_blank"
      tooltip:
        markdown: true
        placement: 'n'
        content: (tooltip) ->
          uri = cdata.conceptURI
          gn250ID = uri.split('/')
          gn250ID = gn250ID.pop()
          # wenn mapquest-api-key, dann
          # read mapquest-api-key from schema
          if that.getCustomSchemaSettings().mapquest_api_key?.value
              mapquest_api_key = that.getCustomSchemaSettings().mapquest_api_key?.value
          if mapquest_api_key
              htmlContent = '<div style="width:400px; height: 250px; background-color: gray; background-image: url(' + location.protocol  + '//ws.gbv.de/suggest/mapfromgn250id/?id=' + gn250ID + '&zoom=12&width=400&height=250&mapquestapikey=' + mapquest_api_key + '); background-repeat: no-repeat; background-position: center center;"></div>'
              tooltip.DOM.innerHTML = htmlContent
              tooltip.autoSize()
              htmlContent

      text: cdata.conceptName
    .DOM


  #######################################################################
  # zeige die gewählten Optionen im Datenmodell unter dem Button an
  getCustomDataOptionsInDatamodelInfo: (custom_settings) ->
    tags = []

    if custom_settings.mapquest_api_key?.value
      tags.push "✓ Mapquest-API-Key"
    else
      tags.push "✘ Mapquest-API-Key"

    tags


CustomDataType.register(CustomDataTypeGN250)
