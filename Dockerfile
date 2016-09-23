FROM alpine:3.4
RUN apk update &&\
    apk upgrade &&\
    apk add git nodejs py-pip openssl libc-dev python-dev gcc &&\
    npm install -g yo generator-hubot &&\
    adduser -u 497 -h /marvin -D hubot hubot &&\
    pip install awscli credstash
USER hubot
WORKDIR /marvin
RUN yo hubot --owner="marvin" --name="marvin" --description="the paranoid android" --adapter slack --defaults
RUN npm install --save https://github.com/mGageTechOps/hubot-s3-brain/tarball/master &&\
    npm install hubot-jenkins-enhanced --save &&\
    npm install shelljs --save &&\
    npm install hubot-alias --save &&\
    npm install hubot-marvin --save
ADD external-scripts.json .
ADD send-sns.coffee ./scripts/send-sns.coffee
CMD HUBOT_SLACK_TOKEN=$(credstash -r ${CREDSTASH_REGION} get -n ${CREDSTASH_REF_SLACKTOKEN}) \
    bin/hubot --adapter slack
