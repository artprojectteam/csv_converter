###
起動タスク
###
Config = require '../config'
Plugins = require '../plugins'
Func = require '../func'


# タスクファイル読み込み
T_copy = require './copy'
T_html = require './pug_jade'
T_css = require './stylus'
T_js = require './babel'


# タスク実行
g = Plugins.gulp
$ = Plugins.$


# Default Command
g.task 'default', ->
  process = undefined

  restart = ()->
    if process
      process.kill()

    process = Plugins.spawn 'gulp', ['start'], stdio:'inherit'

  g.watch 'gulp/**', restart
  restart()


g.task 'start', ->
  $.watch T_copy.files, ->
    g.start T_copy.task.default

  $.watch T_copy.extImgList, ->
    g.start T_copy.task.image

  $.watch T_html.files.watch.default, ->
    g.start T_html.task.default

  $.watch T_css.files.watch, ->
    g.start T_css.task.default

  $.watch T_js.files.default, ->
    g.start T_js.task.default




