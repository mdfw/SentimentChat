# SentimentChat
A demonstration project using PubNub and AWS Comprehend for a chat system running on MacOS/Objective-C.

![Image of Chat screen](readme_assets/chat_screen.png)

Each chat is sent on one channel ("Channel-helpchat") which, in addition to sending to all subscribers, is set to be parsed by `AWS Comprehend`. `Comprehend` sends sentiment information back on a separate channel ("Channel-sentiment"). In this demo, everyone sees each message sentiment but since it is on a separate channel, it could be subscribed only by admins to monitor the health of the chat.


## To build something similar

You will need to install the PubNub SDK for Cocoa (I used Carthage) from https://www.pubnub.com/docs/ios-objective-c/pubnub-objective-c-sdk

You'll need an AWS account. Then install the AWS Comprehend block into your PubNub environment here: https://www.pubnub.com/docs/blocks-catalog/amazon-comprehend (Click "Try it Now")

I set up the PubNubb <-> Comprehend adaptor like so:

![Image of PubNub's comprehend screen](readme_assets/pubnub_aws_comprehend_settings.png)

"Channel-helpchat" the the channel I want the AWS function to listen on for chats to analyze. 


Add your AWS secrets to the secrets vault:

![Image of PubNub's secret's vault screen](readme_assets/pubnub_secrets_screen.png)
The keys to have are `AWS_access_key` and `AWS_secret_key`. You can get them from the AWS AMI panel.

I modified the javascript for the provided AWS Comprehend function like so:
```
                    return xhr.fetch('https://' + sentimentOpts.host, sentimentHttp_options)
                        .then(function (response) {
                            console.log(payload.text);
                            var sentiment = JSON.parse(response.body)
                                var sentimentMessage = {
                                    "sentiment": sentiment,
                                    "sender":"1510099933557",
                                    "event":"sentimentAnalysis", 
                                    "originalUUID": payload.uuid
                                }
                                pubnub.publish({ message: sentimentMessage, channel: "Channel-sentiment" });
                            console.log(sentiment);
                            return request.ok();
                        }).catch(function (error) {
                            console.log(error);
                            return request.ok();
                        });
```

The main change was to send back sentiment on every parse instead of just on negative sentiment (as is the default). Also, sending back the UUID from the original message payload allows us to connect the message to the sentiment when the sentiment is sent back on the "Channel-sentiment" channel.

The rest of the work is done in THCHelpChat.m - check that file for more info.