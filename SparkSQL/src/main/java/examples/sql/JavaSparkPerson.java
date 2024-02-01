package examples.sql;
import org.apache.spark.sql.*;
import org.apache.spark.sql.types.StructType;
import org.apache.spark.sql.types.StructField;
import org.apache.spark.sql.types.DataTypes;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.api.java.function.MapFunction;

import java.io.Serializable;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.apache.spark.sql.functions.col;

public class JavaSparkPerson {
    public static class Person implements Serializable{
        private String name;
        private long age;

        public String getName() {
            return name;
        }

        public long getAge() {
            return age;
        }

        public void setName(String name) {
            this.name = name;
        }

        public void setAge(long age) {
            this.age = age;
        }
    }
    static void runPersonDataFrames(SparkSession spark) throws AnalysisException{
        String path = "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/people.json";
        Dataset<Row> df = spark.read().json(path);
        df.show();
        df.printSchema();// [age:long,name:string]
        //selections
        df.select("name").show();df.select(col("name"),col("age").plus(1))
                .show();
        df.filter(col("age").gt(21)).show();
        df.groupBy("age").count()//RelationalGroupedDataset
                .show();
        df.createOrReplaceGlobalTempView("people");
        spark.sql("SELECT * FROM global_temp.people");
        spark.newSession().sql("SELECT * FROM global_temp.people");
    }
    static void runPersonDatasets(SparkSession spark){
        String path = "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/people.json";
        //Create an instance of a Bean class (Person)
        Person person = new Person();
        person.setAge(32);person.setName("Andy");
        Encoder<Person> persEnc = Encoders.bean(Person.class);

        Dataset<Person> personDS = spark.createDataset(Collections.singletonList(person),
                persEnc);
        personDS.show();
        //Converting a DataFrame into a Dataset:Provide a mapping
        Dataset<Person> peopleDS= spark.read().json(path)
                .as(persEnc);
        peopleDS.show();

        Encoder<Long> longEnc = Encoders.LONG();
        Dataset<Long> longDS = spark.createDataset(Arrays.asList(1L,2L,3L),longEnc);
        Dataset<Long> transformedDS = longDS.map((MapFunction<Long, Long>)
                val->val+1L,longEnc);
        transformedDS.collect();//returns an array [2,3,4]
    }
    static void runInferPersonSchema(SparkSession spark){
        String path = "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/people.json";
        JavaRDD<Person> personJavaRDD = spark.read().textFile(path).javaRDD()
                .map(line->{
                    String [] parts = line.split(",");
                    Person pers = new Person();
                    pers.setName(parts[0]);
                    pers.setAge(Integer.parseInt(parts[1]));
                    return pers;
                });

    }
    static void runProgrammaticPersonSchema(SparkSession spark){
        String path = "/home/vangelis/Desktop/SQL/SparkSQL/src/main/resources/people.json";
        JavaRDD<String> personRDD = spark.sparkContext()
                .textFile(path,1).toJavaRDD();


    }
}
