Session::getCustomDataTypes = ->
  @getDefaults().server.custom_data_types or {}

class CustomDataTypeGN250 extends CustomDataType

  # custom style to head
  CUI.ready =>
    style = DOM.element("style")
    style.innerHTML = ".gn250Popover { min-width:600px !important; } .gn250Input .cui-button-visual, .gn250Select .cui-button-visual { width: 100%; } .gn250Select > div { width: 100%; }"
    document.head.appendChild(style)
    console.log("CSS appended");

  #######################################################################
  # return name of plugin
  getCustomDataTypeName: ->
    "custom:base.custom-data-type-gn250.gn250"

  #######################################################################
  # return name (l10n) of plugin
  getCustomDataTypeNameLocalized: ->
    $$("custom.data.type.gn250.name")

  #######################################################################
  # handle editorinput
  renderEditorInput: (data, top_level_data, opts) ->
    # console.error @, data, top_level_data, opts, @name(), @fullName()
    if not data[@name()]
      cdata = {
            conceptName : ''
            conceptURI : ''
        }
      data[@name()] = cdata
      conceptURI = ''
      conceptName = ''
    else
      cdata = data[@name()]
      conceptName = cdata.conceptName
      conceptURI = cdata.conceptURI

    @__renderEditorInputPopover(data, cdata)

  #######################################################################
  # buttons, which open and close popover
  __renderEditorInputPopover: (data, cdata) ->

    @__layout = new HorizontalLayout
      left:
        content:
            new Buttonbar(
              buttons: [
                  new Button
                      text: ""
                      icon: 'edit'
                      group: "groupA"

                      onClick: (ev, btn) =>
                        @showEditPopover(btn, cdata, data)

                  new Button
                      text: ""
                      icon: 'trash'
                      group: "groupA"
                      onClick: (ev, btn) =>
                        # delete data
                        cdata = {
                              conceptName : ''
                              conceptURI : ''
                        }
                        data[@name()] = cdata
                        # trigger form change
                        Events.trigger
                          node: @__layout
                          type: "editor-changed"
                        @__updateGN250Result(cdata)
              ]
            )
      center: {}
      right: {}
    @__updateGN250Result(cdata)
    @__layout

  #######################################################################
  # update result in Masterform
  __updateGN250Result: (cdata) ->
    btn = @__renderButtonByData(cdata)
    @__layout.replace(btn, "right")


  #######################################################################
  # read info from gn250-terminology
  __getInfoForGN250Entry: (uri, tooltip, mapquest_api_key, extendedInfo_xhr) ->

    # extract gn250ID from uri
    gn250ID = uri
    gn250ID = gn250ID.split "/"
    gn250ID = gn250ID.pop()

    # download infos from entityfacts
    if extendedInfo_xhr != undefined

      # abort eventually running request
      extendedInfo_xhr.abort()

    # start new request
    extendedInfo_xhr = new (CUI.XHR)(url: location.protocol + '//uri.gbv.de/terminology/gn250/' + gn250ID + '?format=json')
    extendedInfo_xhr.start()
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
        CUI.debug 'FAIL', extendedInfo_xhr.getXHR(), extendedInfo_xhr.getResponseHeaders()

    return


  #######################################################################
  # handle suggestions-menu
  __updateSuggestionsMenu: (cdata, cdata_form, suggest_Menu, searchsuggest_xhr) ->
    that = @

    gn250_searchterm = cdata_form.getFieldsByName("gn250SearchBar")[0].getValue()
    gn250_countSuggestions = cdata_form.getFieldsByName("gn250SelectCountOfSuggestions")[0].getValue()

    if gn250_searchterm.length == 0
        return

    # run autocomplete-search via xhr
    if searchsuggest_xhr.xhr != undefined
        # abort eventually running request
        searchsuggest_xhr.xhr.abort()
    # start new request
    searchsuggest_xhr = new (CUI.XHR)(url: location.protocol + '//ws.gbv.de/suggest/gn250/?searchterm=' + gn250_searchterm + '&count=' + gn250_countSuggestions)
    searchsuggest_xhr.start().done((data, status, statusText) ->

        CUI.debug 'OK', searchsuggest_xhr.getXHR(), searchsuggest_xhr.getResponseHeaders()

        # init xhr for tooltipcontent
        extendedInfo_xhr = undefined

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
                    that.__getInfoForGN250Entry(data[3][key], tooltip, mapquest_api_key, extendedInfo_xhr)
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
            cdata_form.getFieldsByName("gn250SearchBar")[0].setValue('')
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
    #.fail (data, status, statusText) ->
        #CUI.debug 'FAIL', searchsuggest_xhr.getXHR(), searchsuggest_xhr.getResponseHeaders()


  #######################################################################
  # reset form
  __resetGN250Form: (cdata, cdata_form) ->
    # clear variables
    cdata.conceptName = ''
    cdata.conceptURI = ''

    # reset type-select
    cdata_form.getFieldsByName("gn250SelectFeatureClasses")[0].setValue("DifferentiatedPerson")

    # reset count of suggestions
    cdata_form.getFieldsByName("gn250SelectCountOfSuggestions")[0].setValue(20)

    # reset searchbar
    cdata_form.getFieldsByName("gn250SearchBar")[0].setValue("")

    # reset result name
    cdata_form.getFieldsByName("conceptName")[0].storeValue("").displayValue()

    # reset and hide result-uri-button
    cdata_form.getFieldsByName("conceptURI")[0].__checkbox.setText("")
    cdata_form.getFieldsByName("conceptURI")[0].hide()


  #######################################################################
  # if something in form is in/valid, set this status to masterform
  __setEditorFieldStatus: (cdata, element) ->
    switch @getDataStatus(cdata)
      when "invalid"
        element.addClass("cui-input-invalid")
      else
        element.removeClass("cui-input-invalid")

    Events.trigger
      node: element
      type: "editor-changed"

    @

  #######################################################################
  # show popover and fill it with the form-elements
  showEditPopover: (btn, cdata, data) ->

    # init xhr-object to abort running xhrs
    searchsuggest_xhr = { "xhr" : undefined }

    # set default value for count of suggestions
    cdata.gn250SelectCountOfSuggestions = 20
    cdata_form = new Form
      data: cdata
      fields: @__getEditorFields(cdata)
      onDataChanged: =>
        @__updateGN250Result(cdata)
        @__setEditorFieldStatus(cdata, @__layout)
        @__updateSuggestionsMenu(cdata, cdata_form, suggest_Menu, searchsuggest_xhr)
    .start()

    # init suggestmenu
    suggest_Menu = new Menu
        element : cdata_form.getFieldsByName("gn250SearchBar")[0]
        use_element_width_as_min_width: true

    xpane = new SimplePane
      class: "cui-demo-pane-pane"
      header_left:
        new Label
          text: "Header left shortcut"
      content:
        new Label
          text: "Center content shortcut"
      footer_right:
        new Label
          text: "Footer right shortcut"
    @popover = new Popover
      element: btn
      placement: "wn"
      class: "gn250Popover"
      pane:
        # titel of popovers
        header_left: new LocaLabel(loca_key: "custom.data.type.gn250.edit.modal.title")
        # "save"-button
        footer_right: new Button
            text: "Übernehmen"
            onClick: =>
              # put data to savedata
              data.gn250 = {
                conceptName : cdata.conceptName
                conceptURI : cdata.conceptURI
              }
              # close popup
              @popover.destroy()
        # "reset"-button
        footer_left: new Button
            text: "Zurücksetzen"
            onClick: =>
              @__resetGN250Form(cdata, cdata_form)
              @__updateGN250Result(cdata)
        content: cdata_form
    .show()


  #######################################################################
  # create form
  __getEditorFields: (cdata) ->
    fields = [
      {
        type: Select
        class: "gn250Select"
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
        ]
        name: 'gn250SelectCountOfSuggestions'
      }
      {
        type: Input
        class: "gn250Input"
        undo_and_changed_support: false
        form:
            label: $$("custom.data.type.gn250.modal.form.text.searchbar")
        placeholder: $$("custom.data.type.gn250.modal.form.text.searchbar.placeholder")
        name: "gn250SearchBar"
      }
      {
        form:
          label: "Gewählter Eintrag"
        type: Output
        name: "conceptName"
        data: {conceptName: cdata.conceptName}
      }
      {
        form:
          label: "Verknüpfte URI"
        type: FormButton
        name: "conceptURI"
        icon: new Icon(class: "fa-lightbulb-o")
        text: cdata.conceptURI
        onClick: (evt,button) =>
          window.open cdata.conceptURI, "_blank"
        onRender : (_this) =>
          if cdata.conceptURI == ''
            _this.hide()
      }]

    fields

  #######################################################################
  # renders details-output of record
  renderDetailOutput: (data, top_level_data, opts) ->
    @__renderButtonByData(data[@name()])


  #######################################################################
  # checks the form and returns status
  getDataStatus: (cdata) ->
    if (cdata)
        if cdata.conceptURI and cdata.conceptName
          # check url for valididy
          uriCheck = CUI.parseLocation(cdata.conceptURI)

          # /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(value);

          # uri-check patch!?!? returns always a result

          nameCheck = if cdata.conceptName then cdata.conceptName.trim() else undefined

          if uriCheck and nameCheck
            console.debug "getDataStatus: OK "
            return "ok"

          if cdata.conceptURI.trim() == '' and cdata.conceptName.trim() == ''
            console.debug "getDataStatus: empty"
            return "empty"

          console.debug "getDataStatus returns invalid"
          return "invalid"
        else
          cdata = {
                conceptName : ''
                conceptURI : ''
            }
          console.debug "getDataStatus: empty"
          return "empty"


  #######################################################################
  # renders the "result" in original form (outside popover)
  __renderButtonByData: (cdata) ->
    that = @
    # when status is empty or invalid --> message
    switch @getDataStatus(cdata)
      when "empty"
        return new EmptyLabel(text: $$("custom.data.type.gn250.edit.no_gn250")).DOM
      when "invalid"
        return new EmptyLabel(text: $$("custom.data.type.gn250.edit.no_valid_gn250")).DOM

    # if status is ok
    cdata.conceptURI = CUI.parseLocation(cdata.conceptURI).url

    # if conceptURI .... ... patch abwarten

    # output Button with Name of picked GN250-Entry and URI
    new ButtonHref
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
          console.log gn250ID
          # wenn mapquest-api-key
          # read mapquest-api-key from schema
          if that.getCustomSchemaSettings().mapquest_api_key?.value
              mapquest_api_key = that.getCustomSchemaSettings().mapquest_api_key?.value
          if mapquest_api_key
              htmlContent = '<div style="width:400px; height: 250px; background-color: gray; background-image: url(' + location.protocol  + '//ws.gbv.de/suggest/mapfromgn250id/?id=' + gn250ID + '&zoom=12&width=400&height=250&mapquestapikey=' + mapquest_api_key + '); background-repeat: no-repeat; background-position: center center;"></div>'
              tooltip.DOM.html(htmlContent)
              tooltip._pane.DOM.html(htmlContent)
              tooltip.autoSize()
              htmlContent

      text: cdata.conceptName
    .DOM.html()


  #######################################################################
  # is called, when record is being saved by user
  getSaveData: (data, save_data, opts) ->
    cdata = data[@name()] or data._template?[@name()]
    switch @getDataStatus(cdata)
      when "invalid"
        throw InvalidSaveDataException
      when "empty"
        save_data[@name()] = null
      when "ok"
        save_data[@name()] =
          conceptName: cdata.conceptName.trim()
          conceptURI: cdata.conceptURI.trim()

  #######################################################################
  # zeige die gewählten Optionen im Datenmodell unter dem Button an
  renderCustomDataOptionsInDatamodel: (custom_settings) ->
    if custom_settings.mapquest_api_key?.value
      new Label(text: "Mapquest-API-Key hinterlegt")
    else
      new Label(text: "Kein Mapquest-API-Key hinterlegt")

CustomDataType.register(CustomDataTypeGN250)
