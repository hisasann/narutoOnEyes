$ = require 'jquery'
_ = require 'lodash'

(() ->
  $ ->
    images = $ '#images'
    imageUrl = $ '#imageUrl'
    loading = $ '#loading'

    naruto = '/images/naruto.png'

    # 目の位置が少しずれるので微調整（かなり適当な数値）
    adjustmentPosition = (obj) ->
      return {
        x: obj.x - 30
        y: obj.y - 20
      }

    _hash = location.hash
    setInterval(() ->
      if _hash is location.hash
        return

      images.html ''

      _hash = location.hash
      hashchangeEventHandler()
    , 300)

    hashchangeEventHandler = () ->
      if !_hash
        return

      loading.html 'loading...'
      url = _hash.substring 1

      $('<img>')
        .addClass('target-image')
        .attr('src', url)
        .appendTo images

      $.ajax(
        type: 'GET'
        url: ['/detect?','image=' , url].join('')
        dataType: 'json'
      )
      .done((data) ->
        _(data.face_detection).forEach((detection) ->
          eyeLeft = adjustmentPosition detection.eye_left
          eyeRight = adjustmentPosition detection.eye_right
          console.log 'eyeLeft: ', eyeLeft
          console.log 'eyeRight: ', eyeRight

          $('<img>')
            .addClass('naruto-image')
            .attr('src', naruto)
            .css(
                top: eyeLeft.y
                left: eyeLeft.x
              )
            .appendTo images

          $('<img>')
            .addClass('naruto-image')
            .attr('src', naruto)
            .css(
                top: eyeRight.y
                left: eyeRight.x
              )
            .appendTo images
        )

        loading.html ''
      )
    hashchangeEventHandler()

    $('#detectButton').on 'click', (e) ->
      location.hash = '#' + imageUrl.val()
)()