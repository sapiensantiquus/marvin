# Description:
#   send an sns message
#
# Configuration:
#   SNS_TOPIC_ARN=some-topic-arn
#   CREDSTASH_REGION=us-west-2
#
# Commands:
#   hubot send-sns [topic-arn] <message>
shell = require('shelljs')
send_sns = (robot, topic, message, res) ->
  script = "aws --region #{process.env.CREDSTASH_REGION} sns publish --topic-arn #{topic} --message '#{message}'"
  shell.exec script, {async:true}, (code, output) ->
    if code != 0
      res.reply "Something went wrong -- I handled this situation by not handling it...¯\\_(ツ)_/¯"
    else
      if robot.adapterName == "slack"
        res.send {
          as_user: true
          attachments: [
            color: "good"
            fields: [
              { title: "message", value: "#{message}", short: false }
              { title: "topic", value: "#{topic}", short: false }
              { title: "output", value: "#{output}", short: true }
            ]
          ]
        }
      else
        res.reply "Success, message:#{message} topic:#{topic} output:#{output}"

module.exports = (robot) ->
  robot.respond /send-sns( .*)? (.*)/i, (res) ->
    topic=res.match[1]
    unless topic?
      topic="#{process.env.SNS_TOPIC_ARN}"
    topic=topic.replace("/^\s+|\s+$/g", "")
    message=res.match[2].replace("/^\s+|\s+$/g", "")
    send_sns(robot, topic, message, res)
