window.WisP =
  config:
    baseUrl: ""
    per_page: 3
    html :
      categorySelect: $('#category-dropdown')
      main: $('#main')
      popup: $('#popup')
  loadingPosts : false
  currentPost : {}
  currentPosts : []
  currentCollection : {}

  init:()->
    $scrollToTop = $('.scroll-to-top')
    $(window).scroll(()->
      if $(@).scrollTop() + $(window).height() > $(document).height() - 100
        if WisP.loadingPosts is false
          # determine opts
          opts = {}
          WisP.config.html.main.append(WisP.Controller.morePosts(opts))
          WisP.loadingPosts = true
      if $(@).scrollTop() > 100
        $scrollToTop.fadeIn()
      else
        $scrollToTop.fadeOut()
    )

    $scrollToTop.click((e)->
      e.preventDefault()
      $("html, body").animate({ scrollTop: 0 }, 600)
    )
    $('.dropdown-toggle').dropdown()
    WisP.masonry()
    WisP.config.html.main.on('click', '.thermal-item h4 a', (e)->
      e.preventDefault()
      id = $(@).attr('href')
        .substr($(@).attr('href')
        .lastIndexOf('/'))
        .replace('/', '')
      WisP.Controller.showPost(id)
      WisP.config.html.popup.modal('toggle')
    )
    WisP.Router.start()

  masonry : () ->
    $container = $('.thermal-loop')
    gutter = 20
    min_width = 300
    $container.masonry(
      itemSelector : '.thermal-item'
      gutterWidth: gutter
      isAnimated: true
      columnWidth: ( cWidth ) ->
        boxNum = (cWidth/min_width | 0)
        box_width = (((cWidth - (boxNum-1)*gutter)/boxNum) | 0)
        if cWidth < min_width then box_width = cWidth
        $('.thermal-item').width(box_width)
        return box_width
      )

  getMediaByID : (id, images) ->
    q = _.where(images, {id: id})
    if q.length > 0
      if not q[0].altText
        q[0].altText = ""
      if q[0].sizes and q[0].sizes.length > 0
        if q[0].sizes[0].url
          return q[0]
    false

  getPostByID: (id)->
    _.where(WisP.currentPosts, {id: id})


###
Is this date "new" within the last day

@module Date
@method isNew
@return Boolean
###
Date.prototype.isNew = ()->
  d = new Date(this)
  now = new Date()
  if (now.getTime() - d.getTime()) <= 86400000 then return true
  false

###
Format date object like "x minutes ago, y days ago, etc"

@module Date
@method timeAgo
###
Date.prototype.timeAgo = ()->
  date = new Date(this)
  diff = (((new Date()).getTime() - date.getTime()) / 1000)
  day_diff = Math.floor(diff / 86400)
  if isNaN(day_diff) or day_diff < 0 then return
  tAgo = (date.getMonth()+1) + ' ' + date.getDate() + ', ' + date.getFullYear()
  if day_diff is 0
    if diff < 60 then tAgo = 'just now'
    else if diff < 120 then tAgo = '1 minute ago'
    else if diff < 3600 then tAgo = Math.floor( diff / 60 ) + " minutes ago"
    else if diff < 7200 then tAgo = '1 hour ago'
    else if diff < 86400 then tAgo = Math.floor( diff / 3600 ) + " hours ago"
  else
    if day_diff is 1 then tAgo = 'Yesterday'
    else if day_diff < 7 then tAgo = "#{day_diff} days ago"
    else if day_diff < 31 then tAgo = Math.ceil( day_diff / 7 ) + " weeks ago"

  return tAgo
