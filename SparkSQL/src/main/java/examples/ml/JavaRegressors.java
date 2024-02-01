package examples.ml;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.RowFactory;
import org.apache.spark.sql.types.DataTypes;
import org.apache.spark.sql.types.Metadata;
import org.apache.spark.sql.types.StructType;
import org.apache.spark.sql.types.StructField;
import org.apache.spark.ml.linalg.Vectors;
import org.apache.spark.ml.linalg.VectorUDT;
import org.apache.spark.ml.Pipeline;
import org.apache.spark.ml.PipelineModel;
import org.apache.spark.ml.PipelineStage;

import org.apache.spark.ml.regression.LinearRegression;
import org.apache.spark.ml.regression.LinearRegressionModel;
import org.apache.spark.ml.regression.LinearRegressionTrainingSummary;
import org.apache.spark.ml.regression.GeneralizedLinearRegression;
import org.apache.spark.ml.regression.GeneralizedLinearRegressionModel;
import org.apache.spark.ml.regression.GeneralizedLinearRegressionTrainingSummary;
import org.apache.spark.ml.regression.DecisionTreeRegressor;
import org.apache.spark.ml.regression.DecisionTreeRegressionModel;
import org.apache.spark.ml.regression.RandomForestRegressionModel;
import org.apache.spark.ml.regression.RandomForestRegressor;
import org.apache.spark.ml.regression.GBTRegressor;
import org.apache.spark.ml.regression.GBTRegressionModel;
import org.apache.spark.ml.regression.AFTSurvivalRegression;
import org.apache.spark.ml.regression.AFTSurvivalRegressionModel;
import org.apache.spark.ml.regression.FMRegressionModel;
import org.apache.spark.ml.regression.FMRegressor;
import org.apache.spark.ml.regression.IsotonicRegression;
import org.apache.spark.ml.regression.IsotonicRegressionModel;

import org.apache.spark.ml.feature.VectorIndexerModel;
import org.apache.spark.ml.feature.VectorIndexer;
import org.apache.spark.ml.feature.MinMaxScaler;
import org.apache.spark.ml.feature.MinMaxScalerModel;

import org.apache.spark.ml.evaluation.RegressionEvaluator;

import javax.xml.crypto.Data;
import java.util.List;
import java.util.Arrays;

public class JavaRegressors {
    static void runLinearRegression(SparkSession spark){
        /*********************************************************************
         *
         ********************************************************************/
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_linear_regression_data");

    }
    static void runGLM(SparkSession spark){
        /*********************************************************************
         *
         ********************************************************************/
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_linear_regression_data");


    }
    static void runDecisionTree(SparkSession spark){
        /*********************************************************************
         *
         ********************************************************************/
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_libsvm_data.txt");
        //Detect categorical features and index them
        VectorIndexerModel featuresIndx =new VectorIndexer()
                .setInputCol("features").setOutputCol("indexedFeatures")
                .setMaxCategories(4)//features with > 4 distinct values are treated as continuous
                .fit(df);
        Dataset<Row> [] parts = df.randomSplit(new double[]{0.70,0.30});
        Dataset<Row> trainingDF = parts[0];
        Dataset<Row> testDF = parts[1];
        //Train a  DecisionTree model
        DecisionTreeRegressor dt = new DecisionTreeRegressor()
                .setFeaturesCol("indexedFeatures");
        //Chain indexer and dt into a Pipeline & fit on the   training dataset
        PipelineModel model = new Pipeline().setStages(new PipelineStage[]{featuresIndx,dt})
                .fit(trainingDF);
        //Make predictions and evaluate them
        Dataset<Row> predictionsDF = model.transform(testDF);
        RegressionEvaluator ev = new RegressionEvaluator().setMetricName("rmse")
                .setLabelCol("label").setPredictionCol("prediction");
        double rmse = ev.evaluate(predictionsDF);
        System.out.println("Root Mean Squared Error (RMSE) on test data = "+rmse);
        DecisionTreeRegressionModel dtModel = (DecisionTreeRegressionModel) model.stages()[1];
        System.out.println("Learned Regression Tree Model :\n " +dtModel.toDebugString() );
    }
    static void runRandomForest(SparkSession spark){
        /*********************************************************************
         *
         ********************************************************************/
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_libsvm_data.txt");
        Dataset<Row> splits[] = df.randomSplit(new double[]{0.70,0.30});
        Dataset<Row> trainingDF = splits[0];
        Dataset<Row> testDF = splits[1];
        VectorIndexerModel featuresIndx = new VectorIndexer()
                .setInputCol("features").setOutputCol("indexedFeatures")
                .setMaxCategories(4).fit(df);
        RandomForestRegressor rf = new RandomForestRegressor()
                .setFeaturesCol("indexedFeatures").setLabelCol("label");
        Pipeline pipeline = new Pipeline().setStages(new PipelineStage[]{featuresIndx,rf});
        PipelineModel model = pipeline.fit(trainingDF);
        //Make predictions & evaluate them using a RegressionEvaluator's rmse
        Dataset<Row> predictionsDF = model.transform(testDF);
        RegressionEvaluator ev = new RegressionEvaluator()
                .setPredictionCol("prediction").setLabelCol("label")
                .setMetricName("rmse");
        double rmse = ev.evaluate(predictionsDF);
        System.out.println("Root Mean Squared Error (RMSE) on test data = "+rmse);
        RandomForestRegressionModel rfModel = (RandomForestRegressionModel)
                model.stages()[1];
        System.out.println("Learned Regression Forest Model :\n " +rfModel.toDebugString() );


    }
    static void runGBT(SparkSession spark){
        /*********************************************************************
         *
         ********************************************************************/
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_libsvm_data.txt");
        Dataset<Row> splits[] = df.randomSplit(new double[]{0.70,0.30});
        Dataset<Row> trainingDF = splits[0];
        Dataset<Row> testDF = splits[1];
        //Identify categorical features & index them

        VectorIndexerModel featuresIndexer = new VectorIndexer()
                .setInputCol("features").setOutputCol("indexedFeatures")
                .setMaxCategories(4).fit(df);
        //Train a GBT model
        GBTRegressor gbt = new GBTRegressor().setLabelCol("label")
                        .setFeaturesCol("indexedFeatures")
                                .setMaxIter(10);
        //Create a Pipeline consisting of: featureIndexer and gbt regresssor
        Pipeline pipeline= new Pipeline().setStages(new PipelineStage[]{featuresIndexer,gbt});
        //Train Pipeline Estimator ,fitting the training dataset
        PipelineModel model = pipeline.fit(trainingDF);
        //Make predictions and evaluate them
        Dataset<Row> predictionsDF = model.transform(testDF);
        RegressionEvaluator ev = new RegressionEvaluator()
                .setLabelCol("label").setPredictionCol("prediction")
                .setMetricName("rmse");
        double rmse = ev.evaluate(predictionsDF);
        System.out.println("Root Mean Squared Error (RMSE) on test data = "+rmse);
        GBTRegressionModel gbtModel = (GBTRegressionModel) model.stages()[1];
        System.out.println("Learned Regression GBT model : \n "+ gbtModel.toDebugString());
    }
    static void runFM(SparkSession spark){
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_libsvm_data.txt");
        Dataset<Row> splits[] = df.randomSplit(new double[]{0.70,0.30});
        Dataset<Row> trainingDF = splits[0];
        Dataset<Row> testDF = splits[1];
        //Scale features
    }
    static void runIsotonicRegression(SparkSession spark){
        /*********************************************************************
         *
         ********************************************************************/
        Dataset<Row> dataset = spark.read().format("libsvm")
                .load("data/mllib/sample_isotonic_regression_libsvm_data.txt");
        IsotonicRegression isr = new IsotonicRegression();
        IsotonicRegressionModel irModel = isr.fit(dataset);
        System.out.println("Boundaries in increasing order : "+irModel.boundaries());
        System.out.println("Predictions associated with the boundaries : "+irModel.predictions());

        irModel.transform(dataset);
    }
    static void runSurvivalRegression(SparkSession spark){
        /*********************************************************************
         *
         ********************************************************************/


    }


}





