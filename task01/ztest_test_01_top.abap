**&---------------------------------------------------------------------*
**&  Include           ZTEST_TEST_01_TOP
**&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include ZTEST_TEST_01_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.

TYPES: BEGIN OF ty_result,
         matnr TYPE mara-matnr,
         mtart TYPE mara-mtart,
       END OF ty_result.

DATA:
  gt_result   TYPE TABLE OF ty_result,
  gt_fieldcat TYPE slis_t_fieldcat_alv,
  gs_fieldcat TYPE slis_fieldcat_alv.
