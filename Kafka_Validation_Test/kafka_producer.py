import os
import time
from datetime import datetime

class KafkaProducer:
    def __init__(self):
        self.TEST_LOG= "test.log"

    def produce_msg(self, topic):
        """
        param: topic
        return:
        """
        #producer return code
        producer_rc = 1
        for i in range(2):
            current_datetime = datetime.now()
            cur_ts = current_datetime.strftime("%m/%d/%Y, %H:%M:%S")
            msg="Ta_Jenkins_K8S_Check_{0}_{1}".format(topic, cur_ts)
            print("producing msg={} into topic={}".format(msg, topic))
            #echo "${msg}" | sudo kubectl exec -i  -n kafka kafka-0 -- /opt/kafka/bin/kafka-console-producer.sh --max-block-ms 5000 --timeout 5000 --topic $topic --broker-list kafka-hs.kafka.svc.cluster.local:9093 &> ${TEST_LOG}
            test_log_out = os.popen("sudo kubectl exec -n kafka kafka-0 -- bash -c \"echo {} | /opt/kafka/bin/kafka-console-producer.sh --max-block-ms 5000 --timeout 5000 --topic {} --broker-list kafka-hs.kafka.svc.cluster.local:9093\"".format(msg, topic, self.TEST_LOG)).read()
            test_log_catted = os.popen("cat %s" %(self.TEST_LOG))
            print("TEST_LOG_IS: ", test_log_catted)

            if "ERROR Error when sending message" in test_log_catted:
                #Failed to produce - just restart the Kafka POD
                print("Got ERROR Error when sending message so retry after 10 sec ..")
                time.sleep(60)
            else:
                #when no error with kafka-console-producer.sh, we are done
                print("Produced msg into Kafka topic"+topic)
                producer_rc=0
        return producer_rc

    def get_kafka_return_code_topics_test(self, topic_list):
        """
        # #produce 5 msgs into Kafka topic stats and event and check for retun val
        param: topic_list: Passes the topic list array to the func
        return: None
        """

        for topic in topic_list:
            print ("producing into topic: " + topic)
            for i in range(5):
                return_val = self.produce_msg(topic)
                if return_val != 0:
                    error_count+=1
                    print ("Error producing into topic: " + topic + "; Error count: " + str(error_count))
        return return_val

def main():
    kafka_producer_obj = KafkaProducer()
    print(kafka_producer_obj.get_kafka_return_code_topics_test(["stats","event"]))

if __name__ == "__main__":
    main()