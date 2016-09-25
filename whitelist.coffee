
module.exports = (robot) ->
  robot.receiveMiddleware (context, next, done) ->
    room = context.response.message.room
    next() if "#{process.env.HUBOT_WHITELIST}".indexOf(room) isnt "-1"
    done()
