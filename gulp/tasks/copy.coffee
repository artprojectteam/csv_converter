###
File Copy
###
Config = require '../config'
Plugins = require '../plugins'
Func = require '../func'

# 対象拡張子
extList =
  ht: '.ht*'
  json: '*.json'
  txt: '*.txt'
  xml: '*.xml'
  csv: '*.csv'
  font: '*.+(ttf|otf|eot|woff*)'
  movie: '*.+(mp4|webm)'
  audio: '*.+(mp3|wav)'
  js: '*.js'
  php: '*.php'


files = []
ws = "#{Config.ws_dir + Config.wildcard}/"

for key of extList
  target = ws + extList[key]
  ignore = "!#{ws}_#{extList[key]}"

  files.push target
  files.push ignore


# 固定除外
files.push "!#{Config.ws_dir}/#{Config.dir.common}/babel/**"


# 画像リストの生成
extIMG = "*.+(jpg|jpeg|png|gif|svg|ico)"
listImg = ["#{ws + extIMG}", "!#{ws}_#{extIMG}"]


# タスク名
task =
  default: 'copy'
  image: 'image'


#=======================#
module.exports =
  files: files
  task: task
  extList: extList
  extImgList: listImg
  extIMG: extIMG



# タスク実行
g = Plugins.gulp
$ = Plugins.$



# Files Copy
g.task task.default, ->
  Func.started task.default

  if !Config.args['production']
    dest = Config.dest.dev
  else
    dest = Config.dest.pro

  return g.src files
  .pipe $.changed dest
  .pipe g.dest "#{dest}/"
  .on 'end', ->
    Func.completed task.default


# Images Copy
g.task task.image, ->
  Func.started task.image
  flg = true

  dest = if !Config.args['production'] then Config.dest.dev else Config.dest.pro

  return g.src listImg
  .pipe $.plumber(
    errorHandler: (err)->
      flg = false
      Func.notifier err, task
  )
  .pipe $.changed dest
  .pipe $.imagemin([
    Plugins.gifscale()
    Plugins.pngquant()
    Plugins.jpegReCompress
      max: 90
    Plugins.svgo
      plugins: [
        removeViewBox: false
      ]

  ])
  .pipe g.dest "#{dest}/"
  .on 'end', ->
    Func.completed task.image





