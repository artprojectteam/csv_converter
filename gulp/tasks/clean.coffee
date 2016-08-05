###
出力先ディレクトリ削除
###
Config = require '../config'
Plugins = require '../plugins'
Func = require '../func'

# タスク名
task =
  default: 'clean'
  image: 'clean:image'
  copy: 'clean:copy'


#=======================#
module.exports =
  task: task

# タスク実行
g = Plugins.gulp
$ = Plugins.$


# 別タスク読み込み
T_copy = require './copy'


# 出力先を削除(引数がない場合は実行モードの出力先)
g.task task.default, (callback)->
  switch true
    when Config.args['all']
      dest = [
        "#{Config.dest.pro + Config.wildcard}/*"
        "#{Config.dest.dev + Config.wildcard}/*"
      ]
    when Config.args['production']
      dest = [
        "#{Config.dest.pro + Config.wildcard}/*"
      ]
    else
      dest = [
        "#{Config.dest.dev + Config.wildcard}/*"
      ]

  return Plugins.del dest, callback


# 画像のみ削除
extIMG = "#{Config.wildcard}/#{T_copy.extIMG}"
g.task task.image, (callback)->
  switch true
    when Config.args['all']
      dest = [
        Config.dest.pro + extIMG
        Config.dest.dev + extIMG
      ]
    when Config.args['production']
      dest = [
        Config.dest.pro + extIMG
      ]
    else
      dest = [
        Config.dest.dev + extIMG
      ]

  return Plugins.del dest, callback









