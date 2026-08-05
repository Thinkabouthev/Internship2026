*&---------------------------------------------------------------------*
*& Report ZTEST_TEST_03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_TEST_03.
*Include ZTEST_TEST_01_SCR.
select mara~matnr,
       mara~mtart,
       t134t~mtbez
  from mara
  INNER JOIN t134t
    ON mara~mtart = t134t~mtart
  AND t134t~spras = 'E'
  INTO table @data(lt_result).
*  UP TO 20 rows.

DATA lo_alv TYPE REF TO cl_salv_table.

cl_salv_table=>factory(
  IMPORTING r_salv_table = lo_alv
  CHANGING  t_table      = lt_result ).

lo_alv->display( ).

*LOOP at lt_result into data(ls_result).
*    write: / ls_result-matnr,
*             ls_result-mtart,
*             ls_result-mtbez.
*ENDLOOP.
