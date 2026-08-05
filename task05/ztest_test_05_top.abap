*&---------------------------------------------------------------------*
*&  Include           ZTEST_TEST_05_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.

TYPES: BEGIN OF ty_result,
         matnr TYPE mara-matnr,
         mtart TYPE mara-mtart,
         mtbez TYPE t134t-mtbez,
         color TYPE lvc_t_scol,
       END OF ty_result.

DATA:
  gt_result   TYPE TABLE OF ty_result.
