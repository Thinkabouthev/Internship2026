*&---------------------------------------------------------------------*
*&  Include           ZTEST_TEST_04_TOP
*&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&  Include           ZTEST_TEST_01_TOP
**&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include ZTEST_TEST_01_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_result,
         matnr TYPE mara-matnr,
         mtart TYPE mara-mtart,
         matkl TYPE mara-matkl,
       END OF ty_result.

DATA:
  gt_result   TYPE TABLE OF ty_result,
  gv_matnr TYPE mara-matnr,
  gv_mtart TYPE mara-mtart,
  gv_matkl TYPE mara-matkl,
  go_alv TYPE REF TO cl_salv_table.
