###
Original Function
###
Config = require './config'
Noti = require('node-notifier').NotificationCenter
echoColor = Config.echoColor

module.exports =
  notifier: (err, tasks)->
    console.log "#{echoColor.red + err.message + echoColor._reset}"
    notifer = new Noti()
    notifer.notify(
      message: err.message
      title: tasks + ' --Task Error'
      sound: 'Glass'
    )
  getEnv: ->
    if Config.args['production']
      return Config.mode._p
    else
      return Config.env
  messages: (mes, color = echoColor.yellow)->
    @.logs mes, color
  started: (task, mes = '')->
    @.logs echoColor.green, "'#{task}' start... #{mes}"
  completed: (task, mes = '')->
    @logs echoColor.blue, "--'#{task}' completed !! #{mes}"
  logs: (color, mes)->
    console.log color + mes + echoColor._reset







