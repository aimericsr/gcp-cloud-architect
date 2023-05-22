gcloud pubsub topics create myTopic
gcloud pubsub topics list
gcloud pubsub topics delete Test1s

gcloud  pubsub subscriptions create --topic myTopic mySubscription
gcloud pubsub topics list-subscriptions myTopic
gcloud pubsub subscriptions delete Test1

gcloud pubsub topics publish myTopic --message "Hello"

gcloud pubsub subscriptions pull mySubscription --auto-ack

gcloud pubsub subscriptions pull mySubscription --auto-ack --limit=3