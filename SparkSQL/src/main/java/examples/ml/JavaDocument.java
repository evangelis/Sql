package examples.ml;

import java.io.Serializable;
@SuppressWarnings("serial")
public class JavaDocument implements Serializable{
    private long id ;
    private String text ;
    public JavaDocument(long id,String text){
        this.id= id;
        this.text = text;
    }

    public long getId() {
        return id;
    }

    public String getText() {
        return text;
    }
}
