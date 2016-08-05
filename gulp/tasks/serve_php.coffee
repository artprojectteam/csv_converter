###
ローカルサーバ立ちあげ
###
Config = require '../config'
Plugins = require '../plugins'
$bs = require 'browser-sync'

# タスクリスト
task =
  php: 'serve:php'

# タスク実行
g = Plugins.gulp
$ = Plugins.$


# PHPサーバ起動
g.task task.php, ->
  dir = if !Config.args['production'] then Config.dest.dev else Config.dest.pro

  $.connectPhp.server
    port: 9090
    base: dir
    #bin: ''
    #ini: ''
  , ->
    $bs.init
      proxy: 'localhost:9090'
      port: 3005
      ui:
        port: 3006


  g.watch "#{dir}/**", ->
    $bs.reload()



