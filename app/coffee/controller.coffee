WisP.Controller =

  showPosts: (category, paged)->
    opts =
      category : null
      paged : 1
    if category? then opts.category = category
    if paged? then opts.paged = paged
    WisP.config.html.main.append(@morePosts(opts))

  morePosts: (opts)->
    WisP.currentPosts.push()
    WisP.currentCollection = new WisP.Posts([], opts)
    postsView = new WisP.PostArchiveView(collection : WisP.currentCollection)
    WisP.currentCollection.fetch(success: () ->
      WisP.loadingPosts = false
    )
    postsView.listenTo(WisP.currentCollection, 'add', postsView.renderOne)
    postsView.el

  showPost: (id)->
    WisP.currentPost = new WisP.Post(id: id)
    postView = new WisP.PostView(model:WisP.currentPost)
    WisP.currentPost.fetch()
    postView.listenTo(WisP.currentPost, 'change', postView.render)
    WisP.config.html.popup.html(postView.el)