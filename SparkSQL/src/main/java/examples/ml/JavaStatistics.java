package examples.ml;
import org.apache.spark.sql.*;
import org.apache.spark.sql.types.StructType;
import org.apache.spark.sql.types.StructField;
import org.apache.spark.sql.types.DataTypes;
import org.apache.spark.sql.types.Metadata;
import org.apache.spark.ml.linalg.Vectors;
import org.apache.spark.ml.linalg.VectorUDT;
import org.apache.spark.ml.stat.Correlation;
import org.apache.spark.ml.stat.Summarizer;

import java.util.List;
import java.util.Arrays;

public class JavaStatistics {
    static void runCorrelation(SparkSession spark){
        List<Row> ls =
                RowFactory.create(Vectors.sparse(4,new int[]{0,3}, new double[]{1.0,-2.0})),
                RowFactory.create(Vectors.dense(4.0,5.0,0.0,3.0)),
                RowFactory.create(Vectors.dense(6.0,7.0,0.0,8.0)),
                RowFactory.create(Vectors.sparse(4,new int[] {0,3}, new double[] {9.0,1.0}));
        StructType schema = new StructType(new StructField[]{
                new StructField()
        });
        Dataset<Row> df = spark.createDataFrame(ls,schema);
        Row r1 = Correlation.corr(df,"features").head();
        System.out.println("Pearson Correlation matrix :\n"+ r1.get(0).toString());
        Row r2 = Correlation.corr(df,"features","spearman").head();
        System.out.println("Spearman Correlation matrix : \n" + r2.get(0).toString());

    }
    static void runSummarizer(SparkSession spark){
        /*** Available column-wise metrics are :min,max,sum,variance,std,count, number or non-zeros
        ***/
        List<Row> ls = Arrays.asList(
                RowFactory.create(Vectors.dense(2.0,3.0,5.0),1.0),
                RowFactory.create(Vectors.dense(4/0,6.0,7.0),2.0));
        StructType schema = new StructType(new StructField[]{
                new StructField("features", new VectorUDT(),false,Metadata.empty()),
                new StructField("weight",DataTypes.DoubleType,false,Metadata.empty())
        });
        Dataset<Row> df =spark.createDataFrame(ls,schema);
        System.out.println();
        Row r2 =df.select(Summarizer.mean(new Column("features")),
                Summarizer.variance(new Column("features"))).head();
        System.out.println();
    }
    static void runChiSquareTest(SparkSession spark){
        List<Row> data = Arrays.asList(
                RowFactory.create(0.0,Vectors.dense(0.5,10.0)),
                RowFactory.create(0.0,Vectors.dense(1.5,20.0)),
                RowFactory.create(1.0,Vectors.dense(1.5,30.0)),
                RowFactory.create(0.0,Vectors.dense(3.5,30.0)),
                RowFactory.create(0.0,Vectors.dense(3.5,40.0)),
                RowFactory.create(1.0,Vectors.dense(3.5,40.0)));
        StructType schema = new StructType(new StructField[]{
                new StructField("label",DataTypes.DoubleType(),false,Metadata.empty()),
                new StructField("features",new VectorUDT(),false,Metadata.empty())
        });
        Dataset<Row> df = spark.createDataFrame(data,schema);
        System.out.println("pvalues :");
        System.out.println("degreesOfFreedom :");
        System.out.println("statistics ");
    }
}