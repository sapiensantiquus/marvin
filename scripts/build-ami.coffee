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
aws = require('aws-sdk')




start_instance = (res,robot) ->
  s3_path = res.match[1]
  role = res.match[2]
  playbook = res.match[3]
  inventory = res.match[4]
  ami_id = res.match[5]
  subnet_id = res.match[6]
  key_name = res.match[7]

  res.reply("Attempting to run instances with image_id: #{ami_id}")
  params = {
    ImageId: ami_id,
    MaxCount: 1,
    MinCount: 1,
    InstanceType: 't2.small',
    KeyName: key_name,
    NetworkInterfaces: [
      {
        DeviceIndex: 0,
        SubnetId: subnet_id,
        AssociatePublicIpAddress: true
      }
    ]
  }
  ec2 = new aws.EC2(region: 'us-west-2')
  request = ec2.runInstances(params)
  request.on('complete', (response) ->
    res.reply("Requested runInstances via the API...")
  ).on('success', (response) ->
    instance_id = response.data.Instances[0].InstanceId
    res.reply("Successfully created a new instance: #{instance_id}")
    host_ip = response.data.Instances[0].PublicIpAddress
    res.reply("Attempting to call MexicanSpaceArmada to run playbook #{playbook}")
    message = JSON.stringify {
      s3_path: s3_path
      role: role
      playbook: playbook
      inventory: inventory
      extra_vars: "target=#{host_ip}"
    }
    robot.emit "send-sns", res, message
  ).on('error', (response) ->
    res.reply("Error: #{response}")
  )
  request.send()

module.exports = (robot) ->
  robot.respond /build-ami s3_path:(.*) role:(.*) playbook:(.*) inventory:(.*) ami_id:(.*) subnet_id:(.*) key_name:(.*) ansible_ssh_key:(.*)/i, (res) ->
    start_instance(res,robot)

  robot.respond /publish-ami instance_id:(.*) name:(.*)/i, (res) ->
    ec2 = new aws.EC2(region: 'us-west-2')
    instance_id = res.match[1]
    name = res.match[2]
    params = {
      InstanceId: instance_id,
      Name: name
    }
    request = ec2.createImage(params)
    request.on('complete', (response) ->
      res.reply("Requesting new image creation...")
    ).on('success', (response) ->
      res.reply("New AMI: #{name} started publishing...")
    ).on('error', (response) ->
      res.reply("Error: #{response}")
    )
    request.send()
