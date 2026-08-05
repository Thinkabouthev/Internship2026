*&---------------------------------------------------------------------*
*& Report ZTEST_TEST_05
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_TEST_05.
INCLUDE ztest_test_05_top.

DATA: lo_alv TYPE REF TO cl_salv_table,
      ls_color TYPE lvc_s_scol.

select mara~matnr,
       mara~mtart,
       t134t~mtbez
  from mara
  LEFT JOIN t134t
    ON mara~mtart = t134t~mtart
  AND t134t~spras = 'E'
  INTO CORRESPONDING FIELDS OF TABLE @gt_result.
*  INTO table @data(lt_result).
*  UP TO 20 rows.

LOOP AT gt_result ASSIGNING FIELD-SYMBOL(<fs>).

  CLEAR ls_color.

  CASE <fs>-mtart.

    WHEN 'HALB'.
      ls_color-fname = 'MATNR'.
      ls_color-color-col = 1.

    WHEN 'HIBE'.
      ls_color-fname = 'MATNR'.
      ls_color-color-col = 2.

    WHEN 'ROH'.
      ls_color-fname = 'MATNR'.
      ls_color-color-col = 3.
    WHEN 'FERT'.
      ls_color-color-col = 4.

    WHEN 'HALB'.
      ls_color-color-col = 5.

    WHEN 'ROH'.
      ls_color-color-col = 6.

    WHEN 'ERSA'.
      ls_color-color-col = 8.
    WHEN OTHERS.
      CONTINUE.

  ENDCASE.

  ls_color-color-int = 1.

  APPEND ls_color TO <fs>-color.

ENDLOOP.

**LOOP AT gt_result ASSIGNING FIELD-SYMBOL(<fs>).
**  IF <fs>-mtbez = 'HALB'.
***      <fs>-mtbez = 'Doesnt have description'.
**    ls_color-fname = 'MTBEZ'.
**    ls_color-color-col = 6.
**    ls_color-color-int = 1.
**    APPEND ls_color TO <fs>-color.
**
**  ENDIF.
**ENDLOOP.

cl_salv_table=>factory(
  IMPORTING r_salv_table = lo_alv
  CHANGING  t_table      = gt_result ).

DATA lo_columns TYPE REF TO cl_salv_columns_table.

lo_columns = lo_alv->get_columns( ).

lo_columns->set_color_column( 'COLOR' ).
lo_alv->display( ).


*****LOOP at lt_result into data(lt_result).
*****  write: / ls_result-matnr,
*****           ls_result-mtart,
*****           ls_result-mtbez.
*****ENDLOOP.
