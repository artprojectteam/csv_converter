###
各タスク説明文
###
Config = require '../config'
Plugins = require '../plugins'
Func = require '../func'

# 入力・出力先
dir =
  in: "#{Config.conf.dir.ws}/#{Config.conf.dir.common}/stylus"
  out: "#{Config.conf.dir.common}/#{Config.conf.dir.css}"

# 対象リスト
styl = dir.in + Config.wildcard
files =
  default: ["#{styl}/*.styl", "!#{styl}/_*.styl"]
  watch: ["#{styl}/*.styl"]

# タスク名
task =
  default: 'stylus'


#=======================#
module.exports =
  task: task
  files: files
  dir: dir

# タスク実行
g = Plugins.gulp
$ = Plugins.$


# Default Task
g.task task.default, [], ->
  Func.started task.default
  flg = true

  # 実行モードによって設定を変更
  switch Func.getEnv()
    when Config.mode._p
      dest = "#{Config.dest.pro}/#{dir.out}"
      plz = funcPlz !!Config.conf.minify
    else
      dest = "#{Config.dest.dev}/#{dir.out}"
      plz = funcPlz false

  return g.src files.default
  .pipe $.plumber
    errorHandler: (err)->
      flg = false
      Func.notifier err, task.default
      @.emit 'end'
  .pipe $.stylus
    'include css': true
  .pipe $.bless
    force: true
  .pipe $.pleeease plz
  .pipe g.dest dest
  .on 'error', (e)->
    console.log e
  .on 'end', ->
    if flg == true
      Func.completed task.default





# pleeeaseの設定
funcPlz = (bool)->
  return {
    autoprefixer:
      browsers: ["last 3 version", "> 1%", "ie 9", "ios 7", "Android 2.3"]    # ベンダプレフィックス
    rem: true
    opacity: false
    pseudoElements: false
    mqpacker: true
    minifier: bool
  }