###
Jadeコンパイル
###
Config = require '../config'
Plugins = require '../plugins'
Func = require '../func'

ext = '.+(pug|jade)'
taskName = 'jade'

dir =
  in:
    default: "#{Config.dir.ws}/jade"
  out: ""

# 対象リスト
target = dir.in.default + Config.wildcard
targetPHP = dir.in.php + Config.wildcard

files =
  default: [
    "#{target}/*#{ext}"
    "!#{target}/_*#{ext}"
    "!#{target}/_assets/**"
  ]
  config: [
    "data/*.yml"
    "!data/_*.yml"
  ]
  watch:
    default: [
      "#{dir.in.default}/**"
      "data/*.yml"
      "!data/_*.yml"
    ]


# タスクリスト
task =
  default: taskName
  config: "#{taskName}:config"


#=======================#
module.exports =
  task: task
  files: files
  dir: dir


# タスク実行
g = Plugins.gulp
$ = Plugins.$
locals = {}


# Default Task
g.task task.default, [task.config], ->
  Func.started task.default
  flg = true
  env = Func.getEnv()

  # 実行モードによって出力先を変える
  switch env
    when Config.mode._p
      dest = Config.dest.pro
      pretty = !Config.conf.minify
    else
      dest = Config.dest.dev
      pretty = !Config.conf.minify


  return g.src target
  .pipe $.plumber(
    errorHandler: (err)->
      flg = false
      Func.notifier err, task.default
  )
  .pipe $.pugLint()
  .pipe $.data ->
    return locals
  .pipe $.jade(
    pretty: pretty
    cache: true
  )
  .pipe g.dest dest
  .on 'end', ->
    if flg == true
      Func.completed task.default


# コンパイルしないyamlファイルの読み込み
g.task task.config, ->
# 変数リセット
  locals.length = 0
  locals = {}

  locals.MODE_ENV = Func.getEnv()
  locals.CMN = Config.conf

  return g.src files.config
  .pipe Plugins.vYmlData()
  .pipe Plugins.deepExtendStream(locals)


