#Required backbone classes
BaseView = require '../lib/base_view'
ResultCollectionView = require '../views/result_collection_view'
ResultsGlobalControlsView = require '../views/results_global_controls_view'
MetaInfosModel = require './../models/meta_infos_model'
ResultsMetaInfosView = require '../views/results_meta_infos_view'

#Define SearchView class
module.exports = class SearchView extends BaseView

    el: '#results-list'
    template: require('./templates/search')
    hasDoctype : false
    events :
        'click #btn-scroll-up' : 'hideThis'

    hideThis : (event) ->
        jqObj = $(event.currentTarget)
        jqObj.hide()


    initialize : (options) ->
        @options = options
        @hasDoctype = @options.doctypes and @options.doctypes.length > 0
        @bindSearch()

        if @hasDoctype

            #Prepare meta-informations
            metaInfosModel = new MetaInfosModel()
            $('#results-meta-infos').empty()
            metaInfosModel.fetch
                data: $.param
                    doctype : @options.doctypes[0]
                success : (col, data) =>
                    if data and data.name and (data.application or data.metadoctype)

                        #Add the container Meta Infos
                        resultsMetaInfosView = new ResultsMetaInfosView()
                        resultsMetaInfosView.render(data)
                        @options['hasMetaInfos'] = true
                        @options['displayName'] = data.displayName

                    #Add the top bar Global Controls
                    @resultsGlobalControlsView = new ResultsGlobalControlsView(@options)

            #Add the results
            @resultCollectionView = new ResultCollectionView(@options)

            #scroll event trigger next page (infinite scroll)
            if @options.range?
                $(window).bind 'scroll', (e, isTriggered) =>
                    docHeight = $(document).height()
                    if !@resultCollectionView.isLoading and !@resultCollectionView.noMoreItems
                        if $(window).scrollTop() + $(window).height() is docHeight
                            @loadMore(isTriggered)
                    if $(window).scrollTop() > 0
                        $('#btn-scroll-up').show()
                    else
                        $('#btn-scroll-up').hide()

    afterRender : ->
        if @hasDoctype
            @resultCollectionView.render()

            #resize event trigger 1 or + pages (infinite scroll)
            $(window).bind 'resize', =>
                @resultCollectionView.loopFirstScroll()
            @bindSearch()


    loadMore : (isTriggered)->
        @resultCollectionView.loadNextPage isTriggered


    bindSearch: ->
        searchElt = $('#launch-search')
        searchField = $('#search-field')
        searchElt.unbind 'click'
        searchField.unbind 'keypress'
        searchElt.click =>
            @resultCollectionView.search(searchField.val())
        searchField.attr 'placeholder', t 'search-placeholder'
        searchField.keypress (event) =>
            if event.which is 13
                event.preventDefault()
                searchElt.click()
