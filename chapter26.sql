DECLARE
    subrefs subject_refs_t;
BEGIN
    SELECT REF(s)
    BULK COLLECT INTO subrefs
    FROM subjects s
    WHERE name IN ('Oracle', 'PL/SQL', 'Relational databases');

    INSERT INTO catalog_items
    VALUES (
        NEW book_t(
            10007,
            'Oracle PL/SQL Programming',
            'Sept 1997',
            subrefs,
            '1-56592-335-9',
            987
        )
    );
END;

-- ------------------------------------------------
ALTER TYPE catalog_item_t
ADD MEMBER PROCEDURE remove
CASCADE;

TYPE BODY catalog_item_t
AS
    ...
    MEMBER PROCEDURE remove
    IS
    BEGIN
        DELETE catalog_items
        WHERE id = SELF.id;

        SELF := NULL;
    END;
END;
-----------------------------------------------


/* File on web: printany.fun */
1  FUNCTION printany (adata IN ANYDATA)
2  RETURN VARCHAR2
3  AS
4      aType       ANYTYPE;
5      retval      VARCHAR2(32767);
6      result_code PLS_INTEGER;
7  BEGIN
8      CASE adata.GetType(aType)
9          WHEN DBMS_TYPES.TYPECODE_NUMBER THEN
10             RETURN 'NUMBER: ' || TO_CHAR(adata.AccessNumber);
11
12         WHEN DBMS_TYPES.TYPECODE_VARCHAR2 THEN
13             RETURN 'VARCHAR2: ' || adata.AccessVarchar2;
14
15         WHEN DBMS_TYPES.TYPECODE_CHAR THEN
16             RETURN 'CHAR: ' || RTRIM(adata.AccessChar);
17
18         WHEN DBMS_TYPES.TYPECODE_DATE THEN
19             RETURN 'DATE: ' ||
20                    TO_CHAR(adata.AccessDate, 'YYYY-MM-DD hh24:mi:ss');
21
22         WHEN DBMS_TYPES.TYPECODE_OBJECT THEN
23             EXECUTE IMMEDIATE
24                 'DECLARE ' ||
25                 ' myobj ' || adata.GetTypeName || '; ' ||
26                 ' myad anydata := :ad; ' ||
27                 'BEGIN ' ||
28                 ' :res := myad.GetObject(myobj); ' ||
29                 ' :ret := myobj.print(); ' ||
30                 'END;'
31             USING IN adata, OUT result_code, OUT retval;
32
33             retval := adata.GetTypeName || ': ' || retval;
34
35         WHEN DBMS_TYPES.TYPECODE_REF THEN
36             EXECUTE IMMEDIATE
37                 'DECLARE ' ||
38                 ' myref ' || adata.GetTypeName || '; ' ||
39                 ' myobj ' || SUBSTR(adata.GetTypeName,
40                     INSTR(adata.GetTypeName, ' ')) || '; ' ||
41                 ' myad anydata := :ad; ' ||
42                 'BEGIN ' ||
43                 ' :res := myad.GetREF(myref); ' ||
44                 ' UTL_REF.SELECT_OBJECT(myref, myobj);' ||
45                 ' :ret := myobj.print(); ' ||
46                 'END;'
47             USING IN adata, OUT result_code, OUT retval;
48
49             retval := adata.GetTypeName || ': ' || retval;
50
51         ELSE
52             retval := '<data of type ' || adata.GetTypeName || '>';
53     END CASE;
54
55     RETURN retval;
56
57 EXCEPTION
58     WHEN OTHERS THEN
59         IF INSTR(SQLERRM, 'component ''PRINT'' must be declared') > 0
60         THEN
61             RETURN adata.GetTypeName || ': <no print() function>';
62         ELSE
63             RETURN 'Error: ' || SQLERRM;
64         END IF;
65 END;




------------------------------------------------------

1  MEMBER PROCEDURE save
2  IS
3  BEGIN
4      UPDATE catalog_items c
5      SET c = SELF
6      WHERE id = SELF.id;
7      IF SQL%ROWCOUNT = 0
8      THEN
9          INSERT INTO catalog_items VALUES (SELF);
10     END IF;
11 END;
12
13 STATIC FUNCTION cursor_for_query (
14     typename IN VARCHAR2 DEFAULT NULL,
15     title    IN VARCHAR2 DEFAULT NULL,
16     att1     IN VARCHAR2 DEFAULT NULL,
17     val1     IN VARCHAR2 DEFAULT NULL
18 )
19 RETURN SYS_REFCURSOR
20 IS
21     l_sqlstr VARCHAR2(1024);
22     l_refcur SYS_REFCURSOR;
23 BEGIN
24     l_sqlstr := 'SELECT VALUE(c) FROM catalog_items c WHERE 1=1 ';
25     IF title IS NOT NULL
26     THEN
27         l_sqlstr := l_sqlstr || 'AND title = :t ';
28     END IF;
29
30     IF typename IS NOT NULL
31     THEN
32         IF att1 IS NOT NULL
33         THEN
34             l_sqlstr := l_sqlstr
35                         || 'AND TREAT(SELF AS '
36                         || typename || ').' || att1 || ' ';
37             IF val1 IS NULL
38             THEN
39                 l_sqlstr := l_sqlstr || 'IS NULL ';
40             ELSE
41                 l_sqlstr := l_sqlstr || '=:v1 ';
42             END IF;
43         END IF;
44         l_sqlstr := l_sqlstr || 'AND VALUE(c) IS OF (' || typename || ') ';
45     END IF;
46
47     l_sqlstr := 'BEGIN OPEN :lcur FOR ' || l_sqlstr || '; END;';
48
49     IF title IS NULL AND att1 IS NULL
50     THEN
51         EXECUTE IMMEDIATE l_sqlstr USING IN OUT l_refcur;
52     ELSIF title IS NOT NULL AND att1 IS NULL
53     THEN
54         EXECUTE IMMEDIATE l_sqlstr USING IN OUT l_refcur, IN title;
55     ELSIF title IS NOT NULL AND att1 IS NOT NULL
56     THEN
57         EXECUTE IMMEDIATE l_sqlstr
58             USING IN OUT l_refcur, IN title, IN att1;
59     END IF;
60
61     RETURN l_refcur;
62 END;











------------------------------------
TRIGGER catalog_hist_upd_trg
AFTER UPDATE ON catalog_items
FOR EACH ROW
BEGIN
    INSERT INTO catalog_history (
        id,
        action,
        action_time,
        old_item,
        new_item
    )
    VALUES (
        catalog_history_seq.NEXTVAL,
        'U',
        SYSTIMESTAMP,
        :OLD.OBJECT_VALUE,
        :NEW.OBJECT_VALUE
    );
END;

