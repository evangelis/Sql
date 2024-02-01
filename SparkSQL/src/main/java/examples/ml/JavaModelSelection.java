package examples.ml;
import org.antlr.runtime.UnwantedTokenException;
import org.apache.spark.ml.tuning.*;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.ml.Pipeline;
import org.apache.spark.ml.PipelineStage;
import org.apache.spark.ml.param.ParamMap;
import org.apache.spark.ml.evaluation.BinaryClassificationEvaluator;
import org.apache.spark.ml.evaluation.RegressionEvaluator;
import org.apache.spark.ml.regression.LinearRegression;
import org.apache.spark.ml.classification.LogisticRegression;
import org.apache.spark.ml.feature.Tokenizer;
import org.apache.spark.ml.feature.HashingTF;

import java.util.Arrays;

public class JavaModelSelection {
    static void runCrossValidator(SparkSession spark){
        /*******************************************************************************
         * // Configure an ML pipeline, which consists of three stages:
         * tokenizer, hashingTF, and lr.
         * Use a ParamGridBuilder to build a grid of 6 parameters to search over:
         * 3 values for HashingTF.numFeatures and 2 values for lr.regParam.
         *CrossValidator requires an Estimator,a set of estimator ParamMaps and
         * an Evaluator
         * We use k=2 folds ,producing 2X(3X2)=12 Models being trained and evaluated
         *******************************************************************************/
        //Prepare a labeled training documents and unlabeled test documents
        Dataset<Row> trainingDF = spark.createDataFrame(Arrays.asList(
                        new JavaLabeledDocument(0L,"a b c d e spark",1.0),
                        new JavaLabeledDocument(1L,"b d",0.0),
                        new JavaLabeledDocument(2L,"spark f g h", 1.0),
                        new JavaLabeledDocument(3L, "hadoop mapreduce", 0.0),
                        new JavaLabeledDocument(4L, "b spark who", 1.0),
                        new JavaLabeledDocument(5L, "g d a y", 0.0),
                        new JavaLabeledDocument(6L, "spark fly", 1.0),
                        new JavaLabeledDocument(7L, "was mapreduce", 0.0),
                        new JavaLabeledDocument(8L, "e spark program", 1.0),
                        new JavaLabeledDocument(9L, "a e c l", 0.0),
                        new JavaLabeledDocument(10L, "spark compile", 1.0),
                        new JavaLabeledDocument(11L, "hadoop software", 0.0)
                ), JavaLabeledDocument.class);

        Dataset<Row> testDF = spark.createDataFrame(Arrays.asList(
                new JavaDocument(4L,"spark i j k"),
                new JavaDocument(5L,"l m n"),
                new JavaDocument(6L,"mapreduce spark"),
                new JavaDocument(7L,"apache hadoop")), JavaDocument.class);
        //Configure the ML Pipeline
        Tokenizer tok = new Tokenizer().setInputCol("text").setOutputCol("words");
        HashingTF htf = new HashingTF().setInputCol(tok.getOutputCol())
                .setOutputCol("features");
        LogisticRegression logisticRegression = new LogisticRegression();
        Pipeline pipeline = new Pipeline().setStages(
                new PipelineStage[]{tok,htf,logisticRegression});
        ParamMap[] paramMap = new ParamGridBuilder()
                .addGrid(htf.numFeatures(),new int[] {10,100,1000})
                .addGrid(logisticRegression.regParam(),new double[]{0.1,0.01})
                .build();
        BinaryClassificationEvaluator ev = new BinaryClassificationEvaluator();
        //The Pipeline is an Estimator to be wrapped into a CrossValidator instance
        CrossValidator cv = new CrossValidator()
                .setEstimator(pipeline)
                .setEvaluator(ev)
                .setEstimatorParamMaps(paramMap)
                .setNumFolds(2) //use >=3 in practice
                .setParallelism(2);
        CrossValidatorModel cvModel = cv.fit(trainingDF);

        //Make predictions on test documents
        Dataset<Row> predictionsDF  = cvModel.transform(testDF);
        for(Row row:predictionsDF.select("id","text","probability","prediction")
            .collectAsList())
            System.out.println("("+row.get(0)+","+row.get(1)+")->"+row.get(2)+",prediction :"+row.get(3));
    }
    static void runTrainValidationSplit(SparkSession spark){
        //Prepare training and test data
        Dataset<Row> dataset = spark.read().format("libsvm").load(
                "data/mllib/sample_linear_regression_data.txt");
        Dataset<Row>[] splits = dataset.randomSplit(new double[]{0.9,0.1},12345);
        Dataset<Row> trainingDF = splits[0];
        Dataset<Row> testDF  =splits[1];
        /***************************************************************************************
         * Run a LinearRegression estimator on the data using a ParamMap ,and ParamGridBuilder
         * to construct a grid of (2 for regParam, 3 for elasticNetParam ) parameters for
         * TrainValidationSplit to search over and choose the best set of parameters
         *
         **************************************************************************************/
        LinearRegression lr = new LinearRegression();
        ParamMap[] pm = new ParamGridBuilder()
                .addGrid(lr.regParam(),new double[] {0.1,0.01})
                .addGrid(lr.fitIntercept())
                .addGrid(lr.elasticNetParam(),new double[]{0.0,0.5,1.0})
                .build();
        TrainValidationSplit tvs = new TrainValidationSplit()
                .setEstimator(lr).setEstimatorParamMaps(pm)
                .setEvaluator(new RegressionEvaluator())
                .setTrainRatio(0.75)
                .setParallelism(2); //Evaluate up to 2 parameter settings in parallel
        TrainValidationSplitModel tvsModel  =tvs.fit(trainingDF);
        Dataset<Row> resDF = tvsModel.transform(testDF);
        resDF.select("features","prediction","label").show();




    }
}