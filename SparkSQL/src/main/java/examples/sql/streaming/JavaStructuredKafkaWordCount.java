package examples.sql.streaming;
import org.apache.spark.sql.Encoders;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.streaming.StreamingQueryException;
import org.apache.spark.sql.streaming.StreamingQuery;
import org.apache.spark.api.java.function.FlatMapFunction;

import java.util.Arrays;

/***********************************************************************************
 * Consuming messages from >=1 topics in Kafka & performing a word count
 * Usage:JavaStructuredKafkaWordCount \
 *      <bootstrap-servers> <subscribe_type> <topics>
 * <bootstrap-servers>:A comma separated list of host:port [bootstrap.servers]
 * <subscribe_type>:One of the following :
 *      <subscribe>:A comma separated list of topics
 *      <subscribePattern>:A java regex string to subscribe to topics
 *      <assign>:Specify TopicPartitions to consume, Json string of the form :
 *          {"topicA":[0,1],"topicB":[2,4]}
 *<topics>:List of topics ,depends on the type of subscription
 * To run the code:
 * $ ./bin/run-example examples.sql.streaming.JavaStructuredKafkaWordCount \
 *      host1:port1, host2:port2 subscribe topic1,topic2
 *
 ************************************************************************************/
public class JavaStructuredKafkaWordCount {
    public static void runWordCount(SparkSession spark) throws java.util.concurrent.TimeoutException{
        Dataset<String> linesDs = spark.readStream().format("kafka")
                .option("bootstrap.servers")
                .option("sbscribe")
                .load().selectExpr("CAST(value AS STRING)")
                .as(Encoders.STRING());
        Dataset<Row> wordCountsDF = linesDs.flatMap((FlatMapFunction<String, String>)
                val->Arrays.asList(val.split(" ")).iterator(),Encoders.STRING())
                .groupBy("value").count();
        StreamingQuery query = wordCountsDF.writeStream()
                .outputMode("complete").format("console")
                .start();
        try{
            query.awaitTermination();
        }
        catch (StreamingQueryException ex){ex.printStackTrace();}
    }
}