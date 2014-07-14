'use strict'

gulp = require 'gulp'
$ = require('gulp-load-plugins')()

browserify = require 'browserify'
watchify = require 'watchify'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
colors = require 'colors'

# リリースの場合 gulp watch --release
isRelease = $.util.env.release

#gulp.task 'setWatch', ->
#  global.isWatching = true

# JavaScript Task
javascriptFiles = [
  {
    input      : ['./src/javascripts/main.coffee']
    output     : 'main.js'
    extensions : ['.coffee']
    destination: './public/javascripts/'
  }
]

createBundle = (options) ->
  bundleMethod = if global.isWatching then watchify else browserify
  bundler = bundleMethod
    entries   : options.input
    extensions: options.extensions

  rebundle = ->
    startTime = new Date().getTime()
    bundler.bundle
      debug: true
    .on 'error', ->
      console.log arguments
    .pipe(source(options.output))
    .pipe buffer()
    .pipe $.if isRelease, $.uglify({preserveComments: 'some'})    # リリース時は圧縮する
    .pipe $.size(gulp) # jsのファイルサイズ
    .pipe gulp.dest(options.destination)
    .on 'end', ->
      time = (new Date().getTime() - startTime) / 1000
      console.log "#{options.output.cyan} was browserified: #{(time + 's').magenta}"

  if global.isWatching
    bundler.on 'update', rebundle

  rebundle()

createBundles = (bundles) ->
  bundles.forEach (bundle) ->
    createBundle
      input      : bundle.input
      output     : bundle.output
      extensions : bundle.extensions
      destination: bundle.destination

gulp.task 'browserify', ->
  createBundles javascriptFiles


  # browserify使わない場合
#  gulp.src './src/javascripts/*.coffee'
#    .pipe $.plumber()   # エラーが置きても中断させない
#    .pipe $.coffeelint
#      max_line_length:
#        value: 120
#    .pipe $.coffeelint.reporter()
#    .pipe $.coffee({bare: false}).on 'error', (err) ->
#      console.log err
#    .pipe $.if isRelease, $.uglify()    # リリース時は圧縮する
#    .pipe gulp.dest 'app/javascripts/'
#    .pipe $.size() # jsのファイルサイズ


# CSS Task
# sassのcompileとautoprefixer、minify用のcsso
#gulp.task 'sass', ->
#  gulp.src ['./src/stylesheets/style.scss', './src/stylesheets/development.scss']
#    .pipe $.sass
#      errLogToConsole: true
#    .pipe $.autoprefixer 'last 1 version', '> 1%', 'ie 8'
#    .pipe $.if isRelease, $.csso()    # リリース時は圧縮する
#    .pipe $.concat 'all.css'
#    .pipe gulp.dest 'app/stylesheets/'
#    .pipe $.size() #cssのファイルサイズ

# Compass Task
gulp.task 'compass', ->
  gulp.src ['./src/stylesheets/style.scss']
    .pipe $.plumber()   # エラーが置きても中断させない
    .pipe $.compass
      config_file: 'config.rb'
      css: 'src/stylesheets'
      sass: 'src/stylesheets'

gulp.task 'concat', ->
  gulp.src ['./src/stylesheets/style.css']
    .pipe $.concat 'all.css'
    .pipe $.if isRelease, $.csso()    # リリース時は圧縮する
    .pipe gulp.dest 'public/stylesheets/'
    .pipe $.size() #cssのファイルサイズ


# Watch
gulp.task 'watch', ->
  global.isWatching = true

  gulp.watch([
    'app/*.html',
    'app/stylesheets/*.css'
    'app/javascripts/*.js'
  ]).on 'change', (file)->
    server.changed file.path

  gulp.watch './src/javascripts/*.coffee', ['browserify']
  gulp.watch './src/stylesheets/*.scss', ['compass']
  gulp.watch './src/stylesheets/*.css', ['concat']
