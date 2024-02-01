package examples.sql.streaming;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Encoders;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.streaming.StreamingQuery;
import org.apache.spark.sql.streaming.StreamingQueryException;
import org.apache.spark.api.java.function.FlatMapFunction;

import javax.xml.crypto.Data;
import java.util.Arrays;

/***********************************************************************************
 * Usage: JavaStructuredNetworkWordCount <host><port>
 * The host,port describe the TCP server connection
 * Run the Netcat server on a local machine & then run the code:
 * $nc -lk 9999
 * $ ./bin/run-example examples.sql.streaming.JavaStructuredNetworkWordCount 9999
 * 1 create a DataFrame representing the stream of input lines from the connection
 * to host:port
 * 2.Split the lines into words ->Dataset<String>
 * 3.Generate running word counts to the console [outputMode:complete]
 *
 */
public class JavaStructuredNetworkWordCount {
    public static void runWordCount(SparkSession spark)throws
                            java.util.concurrent.TimeoutException,StreamingQueryException{
        Dataset<Row> linesDF = spark.readStream().format("socket")
                .option("host",).option("port",port)
                .load();
        Dataset<String> wordsDS = linesDF.as(Encoders.STRING())
                .flatMap(val-> Arrays.asList(val.split(" ")).iterator(),Encoders.STRING());
        Dataset<Row> wordCountsDF = wordsDS.groupBy("value").count();
        StreamingQuery query = wordCountsDF.writeStream()
                .outputMode("complete").format("console")
                .start();
        query.awaitTermination();
    }

}