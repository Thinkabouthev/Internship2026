*&---------------------------------------------------------------------*
*& Report ZTEST_TEST_04
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_TEST_04.
INCLUDE ztest_test_01_scr.
INCLUDE ztest_test_04_top.

CLASS lcl_events DEFINITION.
  PUBLIC SECTION.

    METHODS on_double_click
      FOR EVENT double_click OF cl_salv_events_table
      IMPORTING row column.
    METHODS on_user_command
      FOR EVENT added_function OF cl_salv_events
      IMPORTING e_salv_function.

ENDCLASS.

CLASS lcl_events IMPLEMENTATION.
  METHOD on_double_click.

    DATA: lt_bdc TYPE TABLE OF bdcdata,
          ls_bdc TYPE bdcdata,
          lt_messtab TYPE TABLE OF bdcmsgcoll.
    REFRESH lt_bdc.
* BREAK-POINT.
    READ TABLE gt_result INDEX row INTO DATA(ls_result).
    DATA lv_actvt TYPE c LENGTH 2.

    CASE sy-tcode.
      WHEN 'MM03'.
        lv_actvt = '03'.
      WHEN 'MM01'.
        lv_actvt = '02'.
    ENDCASE.

    AUTHORITY-CHECK OBJECT 'ZMTART'
      ID 'ACTVT' FIELD lv_actvt
      ID 'ZMTART' FIELD ls_result-mtart.

    IF ls_result-mtart <> 'ABF'.
      MESSAGE 'Only material type ABF is allowed' TYPE 'E'.
      RETURN.
    ENDIF.
*  BREAK-POINT.
    IF ls_result-mtart <> 'ABF'.
      MESSAGE |Access denied for material type { ls_result-mtart }|
        TYPE 'E'.
      RETURN.
    ENDIF.
    AUTHORITY-CHECK OBJECT 'ZMTART'
    ID 'ACTVT' FIELD '03'
    ID 'ZMTART' FIELD ls_result-mtart.
    MESSAGE |SUBRC={ sy-subrc } MTART={ ls_result-mtart }| TYPE 'I'.

    IF sy-subrc <> 0.
      MESSAGE 'No authorization for this material type' TYPE 'E'.
      RETURN.
    ENDIF.

    SET PARAMETER ID 'MXX' FIELD 'K'.   "Sprung in Grunddaten/Klass.
    SET PARAMETER ID 'MAT' FIELD ls_result-matnr.
    CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.



  ENDMETHOD.
  METHOD on_user_command.
    DATA:
          lt_fields    TYPE TABLE OF sval,
          lv_new_matnr TYPE mara-matnr,
          lv_maktx     TYPE makt-maktx,
          ls_field     TYPE sval,
          lo_sel       TYPE REF TO cl_salv_selections,
          lt_rows      TYPE salv_t_row,
          lv_row       TYPE salv_de_row,
          ls_result    TYPE ty_result.
    CASE e_salv_function.
      WHEN 'COPY_BAPI'.

        lo_sel = go_alv->get_selections( ).
        lt_rows = lo_sel->get_selected_rows( ).

        READ TABLE lt_rows INDEX 1 INTO lv_row.
        IF sy-subrc <> 0.
          MESSAGE 'Select a material first' TYPE 'I'.
          RETURN.

        ENDIF.

  READ TABLE gt_result INDEX lv_row INTO ls_result.
  AUTHORITY-CHECK OBJECT 'ZMTART'
  ID 'ACTVT' FIELD '02'
  ID 'ZMTART' FIELD ls_result-mtart.

  IF sy-subrc <> 0.
    MESSAGE 'No authorization for this material type' TYPE 'E'.
    RETURN.
  ENDIF.

        APPEND VALUE #(
        tabname   = 'MARA'
        fieldname = 'MATNR'
        ) TO lt_fields.

        APPEND VALUE #(
        tabname   = 'MAKT'
        fieldname = 'MAKTX'
        ) TO lt_fields.

        CALL FUNCTION 'POPUP_GET_VALUES'
          EXPORTING
            popup_title = 'Create Material'
          TABLES
            fields      = lt_fields.

      READ TABLE lt_fields INDEX 1 INTO ls_field.
      IF sy-subrc = 0.
        lv_new_matnr = ls_field-value.
      ENDIF.

      READ TABLE lt_fields INDEX 2 INTO ls_field.
      IF sy-subrc = 0.
        lv_maktx = ls_field-value.
      ENDIF.

      PERFORM create_material_bapi
        USING ls_result-matnr
              ls_result-mtart
              ls_result-matkl
              lv_new_matnr
              lv_maktx.

      WHEN 'COPY_BDC'.

      lo_sel = go_alv->get_selections( ).
      lt_rows = lo_sel->get_selected_rows( ).

      READ TABLE lt_rows INDEX 1 INTO lv_row.
      IF sy-subrc <> 0.
        MESSAGE 'Select a material first' TYPE 'I'.
        RETURN.
      ENDIF.

      READ TABLE gt_result INDEX lv_row INTO ls_result.
      AUTHORITY-CHECK OBJECT 'ZMTART'
      ID 'ACTVT' FIELD '02'
      ID 'ZMTART' FIELD ls_result-mtart.

      IF sy-subrc <> 0.
        MESSAGE 'No authorization for this material type' TYPE 'E'.
      ENDIF.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

        APPEND VALUE #(
        tabname   = 'MARA'
        fieldname = 'MATNR'
        ) TO lt_fields.

        APPEND VALUE #(
        tabname   = 'MAKT'
        fieldname = 'MAKTX'
        ) TO lt_fields.

        CALL FUNCTION 'POPUP_GET_VALUES'
          EXPORTING
            popup_title = 'Create Material'
          TABLES
            fields      = lt_fields.
        READ TABLE lt_fields INDEX 1 INTO ls_field.
        IF sy-subrc = 0.
          lv_new_matnr = ls_field-value.
        ENDIF.

        READ TABLE lt_fields INDEX 2 INTO ls_field.
        IF sy-subrc = 0.
          lv_maktx = ls_field-value.
        ENDIF.
        PERFORM create_material_bdc
          USING ls_result-matnr
             lv_new_matnr
             lv_maktx.


    ENDCASE.

  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

SELECT matnr,
       mtart,
       matkl
  FROM mara
  INTO TABLE @gt_result
  WHERE matnr IN @s_matnr
    AND mtart = @p_mtart.

DATA lo_events TYPE REF TO cl_salv_events_table.
DATA lo_handler TYPE REF TO lcl_events.

DATA lo_columns TYPE REF TO cl_salv_columns_table.
DATA lo_column  TYPE REF TO cl_salv_column.

cl_salv_table=>factory(
  IMPORTING
    r_salv_table = go_alv
  CHANGING
    t_table      = gt_result ).
  DATA lo_selections TYPE REF TO cl_salv_selections.

  lo_selections = go_alv->get_selections( ).

  lo_selections->set_selection_mode(
    if_salv_c_selection_mode=>single ).


lo_columns = go_alv->get_columns( ).

TRY.
    lo_column ?= lo_columns->get_column( 'MATNR' ).

    lo_column->set_short_text( 'Mat. No.' ).
    lo_column->set_medium_text( 'Material No.' ).
    lo_column->set_long_text( 'Material Number' ).

  CATCH cx_salv_not_found.
ENDTRY.

CREATE OBJECT lo_handler.
lo_events = go_alv->get_event( ).

SET HANDLER lo_handler->on_double_click
  for lo_events.
SET HANDLER lo_handler->on_user_command
  FOR lo_events.
go_alv->set_screen_status(
  report        = sy-repid
  pfstatus      = 'ZSTATUS'
  set_functions = go_alv->c_functions_all ).
go_alv->display( ).

FORM create_material_bapi
  USING iv_old_matnr TYPE mara-matnr
        iv_mtart     TYPE mara-mtart
        iv_matkl     TYPE mara-matkl
        iv_new_matnr TYPE mara-matnr
        iv_maktx     TYPE makt-maktx.

  DATA:
    ls_head        TYPE bapimathead,
    ls_client_old  TYPE bapi_mara_ga,
    ls_client_new  TYPE bapi_mara,
    ls_clientx     TYPE bapi_marax,
    lt_desc        TYPE TABLE OF bapi_makt,
    ls_desc        TYPE bapi_makt,
    lt_return      TYPE TABLE OF bapiret2.


  CALL FUNCTION 'BAPI_MATERIAL_GET_ALL'
    EXPORTING
      material   = iv_old_matnr
    IMPORTING
      clientdata = ls_client_old.



  ls_head-material   = iv_new_matnr.
  ls_head-matl_type = iv_mtart.
  ls_head-ind_sector = 'M'.

  MOVE-CORRESPONDING ls_client_old TO ls_client_new.

  ls_clientx-base_uom = 'X'.
  IF iv_matkl IS NOT INITIAL.
    ls_client_new-matl_group = iv_matkl.
  ELSE.
    ls_client_new-matl_group = '001'.
  ENDIF.

  ls_clientx-matl_group = 'X'.

  ls_desc-langu = sy-langu.
  ls_desc-matl_desc = iv_maktx.
  APPEND ls_desc TO lt_desc.

  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'

    EXPORTING
      headdata            = ls_head
      clientdata          = ls_client_new
      clientdatax         = ls_clientx
    TABLES
      materialdescription = lt_desc
      returnmessages      = lt_return.
    READ TABLE lt_return INTO DATA(ls_return)
      WITH KEY type = 'E'.

        IF sy-subrc = 0.
          MESSAGE ls_return-message TYPE 'I'.
          RETURN.
        ENDIF.
*BREAK-POINT.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  SET PARAMETER ID 'MAT' FIELD iv_new_matnr.
  SET PARAMETER ID 'MXX' FIELD 'K'.

  CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

ENDFORM.

FORM create_material_bdc
  USING iv_old_matnr TYPE mara-matnr
        iv_new_matnr TYPE mara-matnr
        iv_maktx     TYPE makt-maktx.

  DATA:
    lt_bdc TYPE TABLE OF bdcdata,
    ls_bdc TYPE bdcdata,
    lt_msg TYPE TABLE OF bdcmsgcoll.

* Screen 0060
  CLEAR ls_bdc.
  ls_bdc-program  = 'SAPLMGMM'.
  ls_bdc-dynpro   = '0060'.
  ls_bdc-dynbegin = 'X'.
  APPEND ls_bdc TO lt_bdc.

  CLEAR ls_bdc.
  ls_bdc-fnam = 'RMMG1-MATNR'.
  ls_bdc-fval = iv_new_matnr.
  APPEND ls_bdc TO lt_bdc.

  CLEAR ls_bdc.
  ls_bdc-fnam = 'RMMG1-MBRSH'.
  ls_bdc-fval = 'M'.
  APPEND ls_bdc TO lt_bdc.

  CLEAR ls_bdc.
  ls_bdc-fnam = 'RMMG1-MTART'.
  ls_bdc-fval = 'ZMDG'.
  APPEND ls_bdc TO lt_bdc.

  CLEAR ls_bdc.
  ls_bdc-fnam = 'RMMG1_REF-MATNR'.
  ls_bdc-fval = iv_old_matnr.
  APPEND ls_bdc TO lt_bdc.

  CLEAR ls_bdc.
  ls_bdc-fnam = 'BDC_OKCODE'.
  ls_bdc-fval = '=ENTR'.
  APPEND ls_bdc TO lt_bdc.

* Screen 0070
  CLEAR ls_bdc.
  ls_bdc-program  = 'SAPLMGMM'.
  ls_bdc-dynpro   = '0070'.
  ls_bdc-dynbegin = 'X'.
  APPEND ls_bdc TO lt_bdc.

  CLEAR ls_bdc.
  ls_bdc-fnam = 'MSICHTAUSW-KZSEL(01)'.
  ls_bdc-fval = 'X'.
  APPEND ls_bdc TO lt_bdc.

  CLEAR ls_bdc.
  ls_bdc-fnam = 'BDC_OKCODE'.
  ls_bdc-fval = '=ENTR'.
  APPEND ls_bdc TO lt_bdc.

* Screen 4004
  CLEAR ls_bdc.
  ls_bdc-program  = 'SAPLMGMM'.
  ls_bdc-dynpro   = '4004'.
  ls_bdc-dynbegin = 'X'.
  APPEND ls_bdc TO lt_bdc.

  CLEAR ls_bdc.
  ls_bdc-fnam = 'MAKT-MAKTX'.
  ls_bdc-fval = iv_maktx.
  APPEND ls_bdc TO lt_bdc.

  CLEAR ls_bdc.
  ls_bdc-fnam = 'BDC_OKCODE'.
  ls_bdc-fval = '=BU'.
  APPEND ls_bdc TO lt_bdc.

  CALL TRANSACTION 'MM01'
    USING lt_bdc
    MODE 'E'
    MESSAGES INTO lt_msg.

   IF sy-subrc = 0.
     SET PARAMETER ID 'MAT' FIELD iv_new_matnr.
     SET PARAMETER ID 'MXX' FIELD 'K'.
     CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
   ELSE.
    READ TABLE lt_msg INTO DATA(ls_msg) WITH KEY msgtyp = 'E'.
    IF sy-subrc <> 0.
      READ TABLE lt_msg INTO ls_msg INDEX 1.
    ENDIF.

    IF sy-subrc = 0.
      MESSAGE ID ls_msg-msgid TYPE 'I' NUMBER ls_msg-msgnr DISPLAY LIKE 'E'
              WITH ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.
** Screen 0060
*   CLEAR ls_bdc.
*   ls_bdc-program  = 'SAPLMGMM'.
*   ls_bdc-dynpro   = '0060'.
*   ls_bdc-dynbegin = 'X'.
*   APPEND ls_bdc TO lt_bdc.
*
*   CLEAR ls_bdc.
*   ls_bdc-fnam = 'RMMG1-MATNR'.
*   ls_bdc-fval = ls_result-matnr.
*   APPEND ls_bdc TO lt_bdc.
*
*   CLEAR ls_bdc.
*   ls_bdc-fnam = 'BDC_CURSOR'.
*   ls_bdc-fval = 'RMMG1-MATNR'.
*   APPEND ls_bdc TO lt_bdc.
*
*   CLEAR ls_bdc.
*   ls_bdc-fnam = 'BDC_OKCODE'.
*   ls_bdc-fval = '=AUSW'.
*   APPEND ls_bdc TO lt_bdc.
*
** Screen 0070
*   CLEAR ls_bdc.
*   ls_bdc-program  = 'SAPLMGMM'.
*   ls_bdc-dynpro   = '0070'.
*   ls_bdc-dynbegin = 'X'.
*   APPEND ls_bdc TO lt_bdc.
*
*   CLEAR ls_bdc.
*   ls_bdc-fnam = 'BDC_CURSOR'.
*   ls_bdc-fval = 'MSICHTAUSW-DYTXT(01)'.
*   APPEND ls_bdc TO lt_bdc.
*
*   CLEAR ls_bdc.
*   ls_bdc-fnam = 'MSICHTAUSW-KZSEL(01)'.
*   ls_bdc-fval = 'X'.
*   APPEND ls_bdc TO lt_bdc.
*
*   CLEAR ls_bdc.
*   ls_bdc-fnam = 'BDC_OKCODE'.
*   ls_bdc-fval = '=ENTR'.
*   APPEND ls_bdc TO lt_bdc.
**   LOOP AT lt_bdc INTO ls_bdc.
**     WRITE: / ls_bdc-fnam, ls_bdc-fval.
**   ENDLOOP.
*
*    CALL TRANSACTION 'MM03'
*      USING lt_bdc
*      MODE 'E'
*      MESSAGES INTO lt_messtab.
