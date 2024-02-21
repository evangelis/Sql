package jdbc.mysql.books;
import java.sql.*;


public class Books {
    /********************************************************************
     * A book table already exists in a ebookshop database
     * consisting of the following columns:
     * [id(int),title(varchar),author(varchar),price(float),qty(int)
     *******************************************************************/
    public static void queryAll(){
        var query="SELECT title,author,price,qty FROM books";
        try(var conn = MySQLConnection.createConnection();
            var stmt = conn.createStatement();
            var rs = stmt.executeQuery(query)) {
            System.out.println("The SQL statement is :"+ query);
            int rowCount = 0;
            while(rs.next()){
                var title = rs.getString("title");
                var author =rs.getString(2) ;
                var price = rs.getDouble("price");
                var qty = rs.getInt("qty");
                System.out.println(title +"\t"+ author +"\t" +price +"\t" + qty);
                ++rowCount;
            }
            System.out.printf("Total number of records : %d",rowCount);
        }
        catch (SQLException ex){
            ex.printStackTrace();
        }
    }
    public static void updateBooks(){
        var strUpd = "UPDATE books SET price = price*1.07, qty=qty+1 WHERE id =1";
        var query = "SELECT * FROM books WHERE id = 1";
        try(var conn = MySQLConnection.createConnection();
            var stmt = conn.createStatement()){
            System.out.println("The SQL statement is :"+strUpd);
            int rowCount = stmt.executeUpdate(strUpd);
            System.out.printf("%s records affected\n",rowCount);
            System.out.printf("The SQL statement is :%s%n",query);
            var rs = stmt.executeQuery(query);
            while(rs.next()){
                var id = rs.getInt(1);
                var author = rs.getString("author");
                var title = rs.getString("title");
                var price =rs.getDouble("price");
                var qty = rs.getInt("qty");
                System.out.println(id +"\t"+author +"\t" +title +
                        "\t"+price + "\t"+ qty);
            }
        }
        catch (SQLException ex){ex.printStackTrace();}
    }
    public static void insertRows() throws  SQLException{
        var deleteStr = "DELETE FROM books WHERE id >=3000 AND i< 4000";
        var insertStr = "INSERT INTO books (id,title,author,price,qty) VALUE" +
                "(3001,'Gone Fishing','Kumar',20.11 ,110)";
        var multiInsertRows = "INSERT INTO books (id,title,author,price,qty) VALUES" +
                "(3002,'Gone Fishing II','Kumar',20.11 ,50)" +
                "(3003, 'Gone Fishing III', 'Kumar', 33.33, 33)";
        var partialInsert = "INSERT INTO books(id,title,author) VALUES " +
                "(3004, 'Fishing 101', 'Kumar')";
        var query ="SELECT * FROM books";
        try(var conn = MySQLConnection.createConnection();
            var stmt = conn.createStatement();
            var rs = stmt.executeQuery(query)){
            while(rs.next()){
                System.out.println(rs.getInt(1)+"\t" +rs.getString("author") +"\t" +
                       rs.getString("title")+ "\t" +rs.getDouble("price") +"\t"
                        +rs.getInt("qty"));
            }
            System.out.println("The SQL statement is :"+deleteStr);
            int rowCount = stmt.executeUpdate(deleteStr);
            System.out.printf("%d records deleted\n",rowCount);

            System.out.println("The SQL statement is :"+insertStr);
            rowCount= stmt.executeUpdate(insertStr);
            System.out.printf("%d rows inserted\n",rowCount);

            System.out.println("The SQL statement is :"+multiInsertRows);
            rowCount = stmt.executeUpdate(multiInsertRows);
            System.out.printf("%d rows inserted\n",rowCount);

            System.out.println("The SQL statement is :"+partialInsert);
            rowCount=stmt.executeUpdate(partialInsert);
            System.out.printf("%d rows inserted\n",rowCount);

            System.out.println("The SQL statement is :"+query);
            while(rs.next()){
                System.out.println(rs.getInt(1)+"\t" +rs.getString("author") +"\t" +
                        rs.getString("title")+ "\t" +rs.getDouble("price") +"\t"
                        +rs.getInt("qty"));
            }


        }
        catch (SQLException ex){ex.printStackTrace();}

    }

}