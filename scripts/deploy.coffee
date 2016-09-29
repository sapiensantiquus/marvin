# Description:
#   send an sns message
#
# Configuration:
#   SNS_TOPIC_ARN=some-topic-arn
#   CREDSTASH_REGION=us-west-2
#
# Commands:
#   hubot deploy s3_path:<s3://example-bucket/example-path.tgz> role:<role_arn> playbook:<playbook.yml> inventory:<inventory> extra_vars:<moar vars>
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
  robot.respond /deploy s3_path:(.*) role:(.*) playbook:(.*) inventory:(.*) extra_vars:(.*)/i, (res) ->
    message = JSON.stringify {
      s3_path: res.match[1]
      role: res.match[2]
      playbook: res.match[3]
      inventory: res.match[4]
      extra_vars: res.match[5]
    }
    topic="#{process.env.SNS_TOPIC_ARN}"
    send_sns(robot, topic, message, res)
