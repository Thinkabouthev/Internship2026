*&---------------------------------------------------------------------*
*& Report ZTEST_TEST_02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_TEST_02.
INCLUDE ztest_test_02_top.
START-OF-SELECTION.

SELECT mtart,
       mtbez
  from t134t
  into table @data(lt_t134t)
  UP to 30 rows
  WHERE spras = 'E'.
 WRITE: lines( lt_t134t ).

LOOP AT lt_t134t INTO DATA(ls_t134t).

  IF ls_t134t-mtbez IS INITIAL.
    WRITE: / ls_t134t-mtart, 'Description missing'.
  ELSE.
    WRITE: / ls_t134t-mtart,
             ls_t134t-mtbez.
  ENDIF.

ENDLOOP.
