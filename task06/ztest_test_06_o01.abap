*&---------------------------------------------------------------------*
*&  Include           ZTEST_TEST_06_O01
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'STATUS_0100'.
  CASE sy-tcode.
    WHEN 'ZMM01'.
      gv_mode = 'C'.

    WHEN 'ZMM02'.
      gv_mode = 'M'.

    WHEN 'ZMM03'.
      gv_mode = 'D'.

  ENDCASE.

  IF gv_mode = 'D'.
    LOOP AT SCREEN.
      IF screen-group1 = 'DAT'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF zmaterial-matnr IS INITIAL
    AND sy-tcode = 'ZMM01'.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZMATNR'
      IMPORTING
        number      = zmaterial-matnr.

  ENDIF.

ENDMODULE.
