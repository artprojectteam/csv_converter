###
Plugins
###
module.exports =
  gulp: require 'gulp'
  $: require('gulp-load-plugins')()
  spawn: require('child_process').spawn
  rimraf: require 'rimraf'
  del: require 'del'
  _: require 'lodash'
  runSequence: require 'run-sequence'
  pngquant: require 'imagemin-pngquant'
  jpegReCompress: require 'imagemin-jpeg-recompress'
  svgo: require 'imagemin-svgo'
  gifscale: require 'imagemin-gifsicle'
  vBuffer: require 'vinyl-buffer'
  vYmlData: require 'vinyl-yaml-data'
  vSourceStream: require 'vinyl-source-stream'
  deepExtendStream: require 'deep-extend-stream'
  browserify: require 'browserify'
  babelify: require 'babelify'
  debowerify: require 'debowerify'
  watchify: require 'watchify'







