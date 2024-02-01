package examples.ml;
import org.apache.ivy.ant.IvyArtifactProperty;
import org.apache.spark.internal.config.R;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.ml.Pipeline;
import org.apache.spark.ml.PipelineModel;
import org.apache.spark.ml.PipelineStage;
import org.apache.spark.ml.feature.*;
import org.apache.spark.ml.evaluation.BinaryClassificationEvaluator;
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator;
import org.apache.spark.ml.classification.BinaryLogisticRegressionTrainingSummary;
import org.apache.spark.ml.classification.LogisticRegression;
import org.apache.spark.ml.classification.LogisticRegressionModel;

import org.apache.spark.ml.classification.DecisionTreeClassifier;
import org.apache.spark.ml.classification.DecisionTreeClassificationModel;
import org.apache.spark.ml.classification.RandomForestClassificationModel;
import org.apache.spark.ml.classification.RandomForestClassifier;

import org.apache.spark.ml.classification.GBTClassifier;
import org.apache.spark.ml.classification.GBTClassificationModel;

import org.apache.spark.ml.classification.MultilayerPerceptronClassificationModel;
import org.apache.spark.ml.classification.MultilayerPerceptronClassifier;

import org.apache.spark.ml.classification.LinearSVC;
import org.apache.spark.ml.classification.LinearSVCModel;

import org.apache.spark.ml.classification.OneVsRest;
import org.apache.spark.ml.classification.OneVsRestModel;

import org.apache.spark.ml.classification.NaiveBayes;
import org.apache.spark.ml.classification.NaiveBayesModel;

import org.apache.spark.ml.classification.FMClassificationModel;
import org.apache.spark.ml.classification.FMClassifier;
import org.apache.spark.sql.catalyst.encoders.RowEncoder;
import org.jetbrains.annotations.Nullable;

import javax.print.attribute.DocAttributeSet;
import java.lang.instrument.UnmodifiableModuleException;

/************************************************************************************************
 *1.Logistic Regression: A method to predict a categorical response,is a special case of the
 * Generalized Linear Models that predicts the probability of the outcomes
 *It can be used to predict a binary outcome or a multiclass outcome
 *
 *2.Decision Tree classifier:This along with its ensembles  are popular methods that are used
 * both in classification and regression problems.
 * It is useful as it captures non-linearities and interactions between features.
 *
 *  Param name    Type    Default
 *  labelCol      Double  "label"
 *  featuresCol   Vector  "features"
 *  predictionCol Double  "prediction"
 *  rawPrediction Vector  "rawPrediction"
 *      Col
 *  probabilityCol Vector "probability"
 *  varianceCol    Double
 *
 * There are 2 major tree ensembles :[Random Forests,Gradient-Boosted-Trees]
 * 3.Random Forests :Are ensembles of Decision Trees;They combine many DTs in order to reduce the
 * risk of overfitting.
 *
 * 4.Gradient-Boosted Trees (GBTs):Are ensembles of DTs,that iteratively train DTs in order
 *  to minimize a loss function
 *  Input Columns                  Output Columns
 *  labelCol ("label")             predictionCol ("prediction")
 *  featuresCol ("features")
 *************************************************************************************************/
public class JavaClassifiers {
    static void runBinomialLR(SparkSession spark){
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_libsvm_data.txt");
        LogisticRegressionModel lrModel = new LogisticRegression()
                .setMaxIter(10).setRegParam(0.3)
                .setElasticNetParam(0.8).fit(df);
        System.out.println("Coefficients: "+
                lrModel.coefficients()+" Intercept: "+lrModel.intercept());
        //Let's use the Multinomial family for binary classification
        LogisticRegression lr = new LogisticRegression()
                .setElasticNetParam(0.8).setRegParam(0.3).setMaxIter(10)
                .setFamily("multinomial");
        LogisticRegressionModel lrModel2  = lr.fit(df);
        System.out.println("Multinomial coefficients: "+lrModel2.coefficientMatrix()+
                " Intercept : "+lrModel2.interceptVector());


    }
    static void runMultinomialLR(SparkSession spark){
           }
    static void runDTClassifier(SparkSession spark){
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_libsvm_data.txt");
        /***********************************************************************************
         * 1.Index labels adding metadata to the label column :StringIndexer
         *  Fit on the whole df to include all labels in index
         * 2.Identify categorical features and index them :VectorIndexer
         *  Fit on the df
         * 3.Split data into training and testing data sets
         * 4.Train a DecisionTreeClassifier model
         * 5.Convert indexed labels back to original labels :IndexToString
         * 6.Create a Pipeline consisting of StringIndexer,VectorIndexer,IndexToString,
         *  and DecisionTreeClassifier
         * 7.Train the model ->PipelineModel using training data
         * 8.Transform the PipelineModel ,making predictions on the test data
         * 9.Evaluate the predictions :MulticlassClassificationEvaluator ,and compute
         * the test accuracy (error)
         *
         *************************************************************************************/
        StringIndexerModel labelIndxModel = new StringIndexer()
                .setInputCol("label").setOutputCol("indexedLabel")
                .fit(df);
        VectorIndexerModel featureIdxModel = new VectorIndexer()
                .setInputCol("features").setOutputCol("indexedFeatures")
                .fit(df);
        Dataset<Row> [] splitDF = df.randomSplit(new double[]{0.7,0.3});
        Dataset<Row> trainingDF = splitDF[0];
        Dataset<Row> testDF = splitDF[1];
        DecisionTreeClassifier dt = new DecisionTreeClassifier()
                .setLabelCol("indexedLabel").setFeaturesCol("indexedFeatures");
        IndexToString lblConverter =new IndexToString()
                .setInputCol("prediction").setOutputCol("predictedLabel")
                .setLabels(labelIndxModel.labelsArray()[0]);
        Pipeline pipeline = new Pipeline()
                .setStages(new PipelineStage[]{labelIndxModel,featureIdxModel,lblConverter,dt});
        PipelineModel model = pipeline.fit(trainingDF);
        Dataset<Row> predictionsDF = model.transform(testDF);
        predictionsDF.select("predictedLabel","label","features").show(5);
        MulticlassClassificationEvaluator ev = new MulticlassClassificationEvaluator()
                .setLabelCol("indexedlabel").setPredictionCol("prediction")
                .setMetricName("accuracy");
        double accuracy = ev.evaluate(predictionsDF);
        System.out.println("Test Error :"+(1-accuracy));
        DecisionTreeClassificationModel dtModel = (DecisionTreeClassificationModel)
                model.stages()[2];
        System.out.println("Learned Classification tree model :\n"+dtModel.toDebugString());
           }

    static void runRandomForestClassifier(SparkSession spark){
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_libsvm_data.txt");
        StringIndexerModel labelIdxModel = new StringIndexer()
                .setInputCol("label").setOutputCol("indexedLabel")
                .fit(df);
        VectorIndexerModel featureIdxModel = new VectorIndexer()
                .setInputCol("features").setOutputCol("indexedFeatures")
                .fit(df);
        Dataset<Row> [] splitDF = df.randomSplit(new double[]{0.7,0.3});
        Dataset<Row> trainingDF =splitDF[0];
        Dataset<Row> testDF = splitDF[1];
        RandomForestClassifier rfc = new RandomForestClassifier()
                .setLabelCol("indexedLabel").setFeaturesCol("indexedFeature");
        IndexToString labelConverter = new IndexToString()
                .setInputCol("prediction").setOutputCol("predictedLabel")
                .setLabels(labelIdxModel.labelsArray()[0]);

        Pipeline pipeline = new Pipeline().setStages(new PipelineStage[]{
                labelIdxModel,featureIdxModel,rfc,labelConverter});
        PipelineModel model = pipeline.fit(trainingDF);

        Dataset<Row>  predictionsDF = model.transform(testDF);
        predictionsDF.select("predictedLabel","label","features").show(5);

        MulticlassClassificationEvaluator ev = new MulticlassClassificationEvaluator()
                .setLabelCol("indexedLabel").setPredictionCol("prediction")
                .setMetricName("accuracy");
        double accuracy = ev.evaluate(predictionsDF);
        System.out.println("Test Error :"+(1-accuracy));
        RandomForestClassificationModel rfcModel = (RandomForestClassificationModel)
            model.stages()[2];
        System.out.println("Learned classification forest model :"+rfcModel);

    }
    static void runGBT(SparkSession spark){
        /**********************************************************************
         * GBTs are ensembles of decision trees ,which iteratively train DTs
         *in order to minimize a loss function
         ***********************************************************************/
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_libsvm_data.txt");
        //Index labels
        StringIndexerModel labelIdx = new StringIndexer()
                .setInputCol("label").setOutputCol("indexedLabel").fit(df);
        //Identify categorical features and index them
        VectorIndexerModel featuresIdx = new VectorIndexer()
                .setInputCol("features").setOutputCol("indexedFeatures")
                .setMaxCategories(4)
                .fit(df);
        //Split the data into training & test data sets & train a GBT classifier
        Dataset<Row> []splits = df.randomSplit(new double[]{0.7,0.3});
        Dataset<Row> trainingDF = splits[0];
        Dataset<Row> testDF = splits[1];

        GBTClassifier gbt = new GBTClassifier()
                .setFeaturesCol("indexedFeatures").setLabelCol("indexedLabel")
                .setMaxIter(10);

        //Convert indexed labels back to the original labels
        IndexToString labelConverter = new IndexToString()
                .setInputCol("indexedLabel").setOutputCol("predictedLabel")
                .setLabels(labelIdx.labelsArray()[0]);
        //Chain indexers and GBT classifier in a Pipeline & train the estimator
        Pipeline pipeline = new Pipeline().setStages(new PipelineStage[]{
                labelIdx,featuresIdx,gbt,labelConverter});
        PipelineModel model = pipeline.fit(trainingDF);
        //Make predictions
        Dataset<Row> predictionsDF = model.transform(testDF);
        predictionsDF.select("predictedLabel","label","features").show(5);
        //Select  (prediction,true label) and compute test error
        MulticlassClassificationEvaluator ev  =new MulticlassClassificationEvaluator()
                .setLabelCol("indexedLabel").setPredictionCol("prediction")
                .setMetricName("accuracy");
        double accuracy =ev.evaluate(predictionsDF);
        System.out.println("Test error :"+(1.0-accuracy));


    }
    static void runNaiveBayes(SparkSession spark){
        /*********************************************************************************************************
         * Naive Bayes Classifiers: A family of probabilistic, multiclass classifiers that use
         * Bayes' theorem with strong (naive) independence assumptions between every pair of features.
         *The ml library supports : Multinomial, Complement, Bernoulli and Gaussian Naive Bayes which are
         * mostly used for document classification.
         *   Thus, each observation is a document and each feature represents a term.
         *   The feature's value is the frequency of the term (in Multinomial or Complement types) or
         *      1 or 0 in bernoulli type of Naive Bayes, indicating whether the term was found in the document
         *   Feature values must be non-negative.
         * The model type is chosen using a parameter: "multinomial","gaussian","bernoulli","complement"
         *
         **********************************************************************************************************/
        //Load the dataset ,split the data into train and test & create the NaiveBayes estimator
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_libsvm_data.txt");
        Dataset<Row> splits[] = df.randomSplit(new double[]{0.7,0.30});
        Dataset<Row> trainingDF = splits[0];
        Dataset<Row> testDf = splits[1];

        NaiveBayes nb = new NaiveBayes();
        //Fit the training data using NaiveBayes classifier ,make predictions  & evaluate them
        NaiveBayesModel nbModel = nb.fit(trainingDF);
        Dataset<Row> predictionsDF =nbModel.transform(testDf);
        predictionsDF.show(5);

        MulticlassClassificationEvaluator ev = new MulticlassClassificationEvaluator()
                .setMetricName("accuracy").setLabelCol("label")
                .setPredictionCol("prediction");
        double accuracy = ev.evaluate(predictionsDF);
        System.out.println("Test Error = "+(1-accuracy));
    }

    static void runOneVsRest(SparkSession spark){
        /*************************************************************************************************
         * OneVsRest or One-Vs-All is an ML reduction algorithm for performing multiclass classification
         * given a base classifier that can perform binary classification efficiently.
         * For the base classifier, OnevsRest takes instances of the classifier and creates a binary
         * classification problem for each of the k classes.
         * The classifier for class i is trained to predict whether the label is i or not,sistinguishing
         * class i from all other classes.
         *We use the Iris dataset ,parse it as a DataFrame and perform a multiclass classification using
         * OneVsRest while for the base classifier we use LogisticRegression
         *
         ***************************************************************************************************/
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_multiclass_classification_data.txt");
        Dataset<Row> parts[] = df.randomSplit(new double[]{0.70,0.30});
        Dataset<Row> trainingDF = parts[0];
        Dataset<Row> testDF = parts[1];
        //Configure the main classifier :LogisticRegression ,the OneVsRest estimator & train the estimator
        LogisticRegression lr = new LogisticRegression()
                .setMaxIter(10).setFitIntercept(true)
                .setTol(1E-6);
        OneVsRest ovr = new OneVsRest()
                .setClassifier(lr);
        OneVsRestModel ovrModel = ovr.fit(trainingDF);
        //Make predictions using the test data & evaluate them
        Dataset<Row> predictionsDF = ovrModel.transform(testDF);

        MulticlassClassificationEvaluator ev = new MulticlassClassificationEvaluator()
                .setMetricName("accuracy");
        double accuracy = ev.evaluate(predictionsDF);
        System.out.println("Test Error = "+(1-accuracy));

    }
    static void runMultilayerPerceptron(SparkSession spark){
        /*****************************************************************************************************
         * Multilayer Perceptron Classifier (MLPC): It is based on the feed-forward artificial neural network
         * MLPC consists of multiple layers of nodes,each being connected to the next layer in the network.
         * Nodes in the input layer represent the input data.
         * All other nodes map inputs to outputs by a linear combination of the inputs with the node's weights
         * w and bias b and apply an activation function.
         *              y(x) = fk(...f2(w2^Tf1(w1^Tx +b1)+b2)...)+bk)
         *Nodes in intermediate layers use a sigmoid (logistic ) function of the form:
         *
         *Nodes in the output use a softmax function :
         *
         * We specify 4 node layers for the input (features)
         *   2 intermediate layers of sizes 5 and 4
         *   output layers of size 3 (ie 3 classes)
         ******************************************************************************************************/
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_multiclass_classification_data.txt");
        Dataset<Row> parts[] = df.randomSplit(new double[]{0.7,0.30});
        Dataset<Row> trainingDF = parts[0];
        Dataset<Row> testDF = parts[1];
        //Specify the layers for the neural network
        int[] layers = new int[]{4,5,4,3};
        MultilayerPerceptronClassifier mlpc = new MultilayerPerceptronClassifier()
                .setLayers(layers).setSeed(1234L).setMaxIter(1000)
                .setBlockSize(128);

        MultilayerPerceptronClassificationModel mlcpModel = mlpc.fit(trainingDF);
        Dataset<Row> resultsDF = mlcpModel.transform(testDF);
        Dataset<Row> predictionLabelsDF = resultsDF.select("prediction","label");
        MulticlassClassificationEvaluator ev = new MulticlassClassificationEvaluator()
                .setMetricName("accuracy");
        System.out.println("Test set Error = "+(1-ev.evaluate(predictionLabelsDF)));


    }
    static void runLinearSVM(SparkSession spark){

    }
        static void runFactorizationMachine(SparkSession spark){
        /********************************************************************************************
         *Factorization Machines (FM) are able to estimate interactions between features even
         * when dealing with sparse data.
         * Spark ml library supports FM for binary classification problems and for regression
         * problems.
         *  Formula :\hat{y} = w_0 + \sum\limits^n_{i=1} w_i x_i +
         *   \sum\limits^n_{i=1} \sum\limits^n_{j=i+1} \langle v_i, v_j \rangle x_i x_j
         ********************************************************************************************/
        Dataset<Row> df = spark.read().format("libsvm")
                .load("data/mllib/sample_libsvm_data.txt");

        //Index
        StringIndexerModel labelIdx = new StringIndexer()
                .setInputCol("label").setOutputCol("indexedLabel")
                .fit(df);
        //Scale features:
        MinMaxScalerModel featureScaler = new MinMaxScaler()
                .setInputCol("features").setOutputCol("scaledFeatures")
                .fit(df);
        //Split the data
        Dataset<Row> parts[] = df.randomSplit(new double[]{0.70,0.30});
        Dataset<Row> trainingDF = parts[0];
        Dataset<Row> testDF = parts[1];

        // Create a FM estimator
        FMClassifier fmc = new FMClassifier()
                .setFeaturesCol("scaledFeatures")
                .setLabelCol("indexedLabel")
                .setStepSize(0.001);
        //Convert indexed labels back to the original labels
        IndexToString labelConverter = new IndexToString()
                .setInputCol("prediction").setOutputCol("predictedLabel")
                .setLabels(labelIdx.labelsArray()[0]);
        //Create a pipeline, train the model
        PipelineModel pipelineModel = new Pipeline().setStages(new PipelineStage[]
                {labelIdx,featureScaler,fmc,labelConverter}).fit(trainingDF);
        //Make predictions
        Dataset<Row> predictionsDF = pipelineModel.transform(testDF);

        //Evaluate the learned model (predictionsDF)
        MulticlassClassificationEvaluator ev = new MulticlassClassificationEvaluator()
                .setMetricName("accuracy")
                .setLabelCol("indexedlabel").setPredictionCol("prediction");
        var accuracy = ev.evaluate(predictionsDF);
        System.out.println("Test Error = "+ (1-accuracy));

        FMClassificationModel fmcModel = (FMClassificationModel) pipelineModel.stages()[2];
        System.out.println("Factors :"+ fmcModel.factors());
        System.out.println("Linear : "+fmcModel.linear());
        System.out.println("Intercept :"+ fmcModel.intercept());

    }
}
