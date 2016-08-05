###
Gulp Setting
###
config = require('../package.json').config

dest =
  dev: "build_#{config.mode._d}"
  pro: "build_#{config.mode._p}"


module.exports =
  conf: config
  dest: dest
  dir: config.dir
  mode: config.mode
  env: config.mode._d   # 実行モード
  wildcard: '/**'
  ws_dir: config.dir.ws
  echoColor:
    _reset: "\u001b[0m"
    black: "\u001b[30m"
    white: "\u001b[37m"
    red: "\u001b[31m"
    green: "\u001b[32m"
    yellow: "\u001b[33m"
    blue: "\u001b[34m"
  args: require('minimist')(process.argv.slice(2))












