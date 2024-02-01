package examples.sql;
import org.apache.spark.sql.Encoders;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.api.java.function.MapFunction;


import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Properties;
import java.io.Serializable;

public class JavaSqlDataSources {
    public static class Square {
        private int value,square;

        public int getSquare() {
            return square;
        }

        public void setSquare(int square) {
            this.square = square;
        }

        public int getValue() {
            return value;
        }

        public void setValue(int value) {
            this.value = value;
        }
    }
    public static class Cube implements  Serializable{
        private int value,cube;

        public int getValue() {
            return value;
        }

        public void setValue(int value) {
            this.value = value;
        }

        public int getCube() {
            return cube;
        }

        public void setCube(int cube) {
            this.cube = cube;
        }
    }
    static void basicDF(SparkSession spark){
        Dataset<Row> usersDF = spark.read()
                .load("/opt/spark-3.5.0/examples/src/main/resources/examples/src/main/resources/users.parquet");
        usersDF.write().partitionBy("favorite_color").format("parquet")
            .save("~/Desktop/SQL/SparkSQL/src/main/resources/dir3/users.parquet");

        usersDF.write().partitionBy("favorite_color").bucketBy(42,"name")
            .saveAsTable("~/Desktop/SQL/SparkSQL/src/main/resources/dir3/users_part_buck");
        usersDF.write().format("parquet")
            .option("parquet.bloom.filter.enabled#favorite_color","true")
            .option("parquet.bloom.filter.expected")
            .option()
            .save("~/SQL/SparkSQL/src/main/resources/dir3/users_with_options.parquet");

        usersDF.write().format("orc")
            .option("orc.bloom.filter")
            .option()
            .option()
            .option()
            .save("~/SQL/SparkSQL/src/main/resources/dir3/users_orc.orc");

        Dataset<Row> peopleDF = spark.read().format("json")
            .load("/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/people.json");
            //sort and bucket the output or the resultant table
        peopleDF.write().bucketBy(42,"name").sortBy("age").saveAsTable(
                "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/dir3/people_buck_sort.parquet");
        peopleDF.select("name","age").write().format("parquet").save(
            "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/dir3/nameAge.parquet");
        Dataset<Row> sqlDF = spark.sql(SELECT * FROM parquet . 
            "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/users.parquet");

        spark.sql("DROP TABLE IF EXISTS users_part_buck");
        spark.sql("DROP TABLE IF EXISTS people_buck_sort");
    }
    static void parquetSource(SparkSession spark){
        String path = "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/people.json";
        Dataset<Row> peopleDF = spark.read().json(path);
        peopleDF.write().parquet(
                "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/dir3/people.parquet");
        /*** Parquet files are self-describing ,so the schema ios preserved ***/
        Dataset<Row> parquetDF = spark.read().parquet(
                "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/dir3/people.parquet");
        parquetDF.createOrReplaceTempView("people_parquet");
        Dataset<Row> teenNamesDF = spark.sql("SELECT names FROM people_parquet WHERE age " +
                "between 13 and 19" );
        //Convert into a typed dataset
        Dataset<String> teenNamesDS = teenNamesDF.map((MapFunction<Row, String>)
                        row->"Name :"+row.getString(0),Encoders.STRING());
        teenNamesDS.show();
        List<Square> squares = new ArrayList<>();
        List<Cube> cubes = new ArrayList<>();
        for (int i = 1; i=5 < ; i++) {
            Square  square = new Square();
            Cube cube = new Cube();
            square.setValue(i);square.setSquare(i*i);
            cube.setValue(i+5);cube.setCube(cube.getValue()*cube.getValue()*cube.getValue());
            squares.add(square);cubes.add(cube);
        }
        //Create & store 2 dataframes into diff partition directories (containing a diff column)
        String part_dir1 "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/dir3/test_table/key=1";
        String part_dir2 = "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/dir3/test_table/key=2";
        Dataset<Row> squaresDF =spark.createDataFrame(squares, Square.class);
        Dataset<Row> cubesDF = spark.createDataFrame(cubes,Cube.class);
        squaresDF.write().parquet(part_dir1);
        cubesDF.write().parquet(part_dir2);
        //Read the partitioned table: 
        Dataset<Row> mergedDF = spark.read().option("mergeSchema",true)
            .parquet("/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/dir3/test_table");
        mergedDF.printSchema(); //[value:int ,square:int, cube:int ,key:int ]
    }
    static void jsonSource(SparkSession spark){

    }
    static void  textSource(SparkSession spark){
        //A path can  be a single file or  a directory
        String path = "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/people.txt";
        Dataset<Row> peopleDF = spark.read().text(path);
        peopleDF.show();
    }
    static void csvSource(SparkSession spark){
        String path = "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/people.csv;"
        String path2 = "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/dir3/people.csv;"

        Dataset<Row> df1 = spark.read().csv(path);
        df1.show(); // column :_c0 :[name;age;job]
        Dataset<Row> df2 = spark.read().option("delimiter",";").csv(path);
        Dataset<Row> df3 = spark.read().option("delimiter",";")
            .option("header","true").csv(path);
        df3.show(); 
        Map<String,String> opts = new HashMap<>();
        opts.put("header","true");opts.put("delimiter",";");
        Dataset<Row> df4 = spark.read().format("csv")
            .options(opts).load();
        df4.write().csv(path2);
        df3.write().csv( // write to a folder containing multiple csv files and a _SUCCESS
            "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/dir3/output");
        //Read all files in a folder
        Dataset<Row> df5 =spark.read().csv("/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/");

    }
    static void jdbcSource(SparkSession spark){
        //As usual,Jdbc loading and saving can be done via either the load(),save() generic methods 
        // or via the jdbc methods
        Dataset<Row> jdbcDF = spark.read().format("jdbc")
            .option("url","jdbc:mysql://localhost:").option("dbtable","classicmodels1.employees")
            .option("user","myuser").option("password","Kalaseelese$1")
            .load();
        jdbcDF.write().format("jdbc").option("url","jdbc:mysql:localhost:")
            .option("dbtable","classicmodels1.employees")
            .option("user","vangelis").option("password","Kalaseelese$1")
            .save("/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/dir3/employees");


        Properties props = new Properties();
        props.put("user","vangelis");props.put("password","Kalaseelese$1");
        Dataset<Row> jdbcDF2 = spark.read().jdbc("jdbc:mysql://localhost:",
                "classicmodels1.employees",props);
        jdbcDF2.write().jdbc("jdbc:mysql://localhost:","classicmodels1.employees",props)


    }

}