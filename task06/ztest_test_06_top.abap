*&---------------------------------------------------------------------*
*&  Include           ZTEST_TEST_06_TOP
*&---------------------------------------------------------------------*
TABLES zmaterial.

DATA:
      ls_material TYPE zmaterial,
      gt_material TYPE TABLE OF zmaterial,
      go_alv TYPE REF TO cl_salv_table,
      gv_mode TYPE c LENGTH 1,
      gv_locked TYPE abap_bool.
