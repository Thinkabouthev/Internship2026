*&---------------------------------------------------------------------*
*& Report ZTEST_TEST_06
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest_test_06.

INCLUDE ztest_test_06_top.
INCLUDE ztest_test_06_o01.
INCLUDE ztest_test_06_user_command_i01.

START-OF-SELECTION.

  CALL SCREEN 0100.

FORM show_table.

  SELECT *
    FROM zmaterial
    INTO TABLE gt_material.

  cl_salv_table=>factory(
    IMPORTING
      r_salv_table = go_alv
    CHANGING
      t_table      = gt_material ).

  go_alv->display( ).

ENDFORM.

FORM lock_material.

  CALL FUNCTION 'ENQUEUE_EZMATERIAL'
    EXPORTING
      matnr = zmaterial-matnr
    EXCEPTIONS
      foreign_lock = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    MESSAGE 'Material is locked by another user'
      TYPE 'E'.
  ENDIF.

ENDFORM.
