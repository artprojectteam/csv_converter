###
Babelコンパイル
###
Config = require '../config'
Plugins = require '../plugins'
Func = require '../func'

# 入力・出力先
dir =
  in: "#{Config.dir.ws}/#{Config.dir.common}/babel"
  out: "#{Config.dir.common}/#{Config.dir.js}"

# Babelifyで利用するファイル名
concat_file = Config.conf.babelify

# 対象リスト
files =
  default: [
    "#{dir.in}/*.js"
    "!#{dir.in}/_*.js"
    "!#{dir.in}/_assets/**"
    "!#{dir.in}/#{concat_file}"
  ]
  babelify: concat_file
  watch: ["#{dir.in}/**"]

# タスク名
task =
  default: 'babel'
  concat: 'babelify'
  watch: 'babelify:watch'




#=======================#
module.exports =
  task: task
  files: files


# タスク実行
g = Plugins.gulp
$ = Plugins.$


# Default Task
g.task task.default, [], ->
  Func.started task.default
  flg = true

  # 実行モードによって出力先を変更する
  switch Func.getEnv()
    when Config.mode._p
      dest = "#{Config.dest.pro}/#{dir.out}"
      option = getBabelOption()
      mode_pro = true
    else
      dest = "#{Config.dest.dev}/#{dir.out}"
      option = getBabelOption()
      mode_pro = false

  return g.src files.default
  .pipe $.cached 'babel'
  .pipe $.plumber
    errorHandler: (err)->
      flg = false
      Func.notifier err, task.default
#@.emit 'end'
  .pipe $.babel option
  .pipe $.if mode_pro, $.stripDebug()
  .pipe g.dest dest
  .on 'end', ->
    if flg == true
      Func.completed task.default



# browserifyを利用して１枚にするタスク
g.task task.concat, [], ->
  watch = if Config.args['watch'] then true else false

  # エントリーポイントが空の場合は処理しない。
  if Config.conf.babelify == ""
    return @

  Func.started task.concat
  flg = true
  ops = {}

  # 実行モードによって出力先を変更する
  switch Func.getEnv()
    when Config.mode._p
      dest = "#{Config.dest.pro}/#{dir.out}"
      option = getBabelOption()
      mode_pro = true
      ops.debug = false
    else
      dest = "#{Config.dest.dev}/#{dir.out}"
      option = getBabelOption()
      mode_pro = false
      ops.debug = true

  # 出力先フルパス
  file = "#{dir.in}/#{concat_file}"

  if watch == true
    ops.cache = {}
    ops.packageCache = {}
    ops.fullPaths = false
    bundler = Plugins.watchify Plugins.browserify file, ops
  else
    bundler = Plugins.browserify file, ops


  bundle = ->
    _d = new Date()
    h = _d.getHours()
    m = _d.getMinutes()
    s = _d.getSeconds()
    console.log "#{Config.echoColor.yellow}[#{h}:#{m}:#{s}] #{files.babelify} Compile Start#{Config.echoColor._reset}"

    return bundler
    .transform Plugins.babelify, option
    .require "./#{file}", {expose: 'Assets'}
    .bundle()
    .pipe Plugins.vSourceStream files.babelify
    .pipe Plugins.vBuffer()
    .pipe $.if mode_pro, $.stripDebug()
    .on "error", (err) ->
      flg = false
      console.log err
      Func.notifier err, task.concat
      @.emit 'end'
    .pipe g.dest dest
    .on 'end', ->
      if flg == true
        Func.completed task.concat


  bundler
  .on 'update', bundle
  .on 'log', (msg)->
    flg = true


  return bundle()



# Babel オプション
getBabelOption = ->
  return {
    presets: [
      'es2015-without-strict'
      'stage-1'
    ]
    compact: false
    plugins: [
      ['transform-es2015-classes', {loose: true}]
    ]
  }










