package examples.ml;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.RowFactory;
import org.apache.spark.sql.types.DataTypes;
import org.apache.spark.sql.types.Metadata;
import org.apache.spark.sql.types.StructType;
import org.apache.spark.sql.types.StructField;
import org.apache.spark.ml.Pipeline;
import org.apache.spark.ml.PipelineModel;
import org.apache.spark.ml.PipelineStage;
import org.apache.spark.ml.linalg.VectorUDT;
import org.apache.spark.ml.linalg.Vectors;
import org.apache.spark.ml.param.ParamMap;
import org.apache.spark.ml.classification.LogisticRegression;
import org.apache.spark.ml.classification.LogisticRegressionModel;
import org.apache.spark.ml.feature.HashingTF;
import org.apache.spark.ml.feature.Tokenizer;

import java.util.Arrays;
import java.util.List;

public class JavaPipelines {
    static void textWorkflow(SparkSession spark) {
        //Prepare training and test documents
        Dataset<Row> trainingDF = spark.createDataFrame(Arrays.asList(
                new JavaLabeledDocument(0L, "a b c d e spark", 1.0),
                new JavaLabeledDocument(1L, "b d", 0.0),
                new JavaLabeledDocument(2L, "spark f g h", 1.0),
                new JavaLabeledDocument(3L, "hadoop mapreduce", 0.0)), JavaLabeledDocument.class);
        Dataset<Row> testDF = spark.createDataFrame(Arrays.asList(
                new JavaDocument(4L,"spark i j k"),
                new JavaDocument(5L, "l m n"),
                new JavaDocument(6L, "spark hadoop spark"),
                new JavaDocument(7L, "apache hadoop")),JavaDocument.class);
        //Configure a Pipeline consisting of 3 stages : Tokenizer,hashingTF,LogisticRegression
        Tokenizer tok = new Tokenizer()
                .setInputCol("text").setOutputCol("words");
        HashingTF htf = new HashingTF().setNumFeatures(1000)
                .setInputCol(tok.getOutputCol())
                .setOutputCol("features");
        LogisticRegression lrg = new LogisticRegression()
                .setMaxIter(10).setRegParam(0.01);
        Pipeline pipe = new Pipeline().setStages(new PipelineStage[]{
                tok,htf,lrg});
        //Fit the Pipeline to the training documents & make predictions on test documents
        PipelineModel pipeModel = pipe.fit(trainingDF);
        Dataset<Row> predictionsDF = pipeModel.transform(testDF);
        for(Row r:predictionsDF.select("id","text","probabiity","prediction").collectAsList())
            System.out.println("("+r.get(0)+","+r.get(1)+")->"+r.get(2)+",prediction ="+r.get(3));
    }
    static void runLogisticRegression(SparkSession spark) {
        //Prepare training data
        List<Row> trainData = Arrays.asList(
                RowFactory.create(1.0, Vectors.dense(0.0, 1.1, 0.1)),
                RowFactory.create(0.0, Vectors.dense(2.0, 1.0, -1.0)),
                RowFactory.create(0.0, Vectors.dense(2.0, 1.3, 1.0)),
                RowFactory.create(1.0, Vectors.dense(0.0, 1.2, -0.5)));
        StructType schema = new StructType(new StructField[]{
                new StructField("label", DataTypes.DoubleType, false, Metadata.empty()),
                new StructField("features", new VectorUDT(), false, Metadata.empty())
        });
        Dataset<Row> trainingDF = spark.createDataFrame(trainData, schema);

        LogisticRegression lrg = new LogisticRegression();
        lrg.setMaxIter(10).setRegParam(0.01);
        System.out.println("Logistic Regression parameters :\n" + lrg.explainParams());
        LogisticRegressionModel lrgModel1 = lrg.fit(trainingDF);
        System.out.println("LogisticRegressionModel 1 was fit using parameters: " +
                lrgModel1.parent().extractParamMap());
        ParamMap pm1 = new ParamMap()
                .put(lrg.maxIter().w(20)).put(lrg.maxIter(), 30)
                .put(lrg.regParam().w(0.1), lrg.threshold().w(0.55));
        ParamMap pm2 = new ParamMap()
                .put(lrg.probabilityCol().w("myProbability"));

        ParamMap pmCombined = pm1.$plus$plus(pm2);

        LogisticRegressionModel lrgModel2 = lrg.fit(trainingDF, pmCombined);
        System.out.println("Logistic Regression Model 2 was fit using parameters:" +
                lrgModel2.parent().extractParamMap());


        //Prepare test data
        List<Row> testData = Arrays.asList(
                RowFactory.create(1.0, Vectors.dense(-1.0, 1.5, 1.3)),
                RowFactory.create(0.0, Vectors.dense(3.0, 2.0, -0.1)),
                RowFactory.create(1.0, Vectors.dense(0.0, 2.2, -1.5)));
        Dataset<Row> testDF = spark.createDataFrame(testData, schema);

        Dataset<Row> resultsDF = lrgModel2.transform(testDF);
        for (Row row : resultsDF.select("features", "label", "myProbability", "prediction").collectAsList())
            System.out.println("(" + row.get(0) + "," + row.get(1) + ")->" + row.get(2) + ", prediction=" + row.get(3));


    }
}
