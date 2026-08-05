*&---------------------------------------------------------------------*
*& Report ZPTB00_TASK1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPTB00_TASK1.
*task1
data sum type i.
do 10 times.
  if sy-index MOD 2 <> 0.
    sum = sum + sy-index.
  else.
    continue.
  endif.
enddo.
write sum.
*task2
do 20 times.
 if sy-index MOD 7 = 0.
   write / sy-index.
   exit.
 endif.
enddo.

*task3
do 15 times.
 if sy-index MOD 2 = 0.
   write: / sy-index, 'even'.
 else.
   write: / sy-index, 'odd'.
endif.
 if sy-index MOD 3 = 0.
   write 'Multiple of 3'.
endif.
enddo.


*task4
do 100 times.
DATA(result) = COND string(
  when sy-index MOD 3 = 0
    AND sy-index MOD 5 = 0
      then 'FizzBuzz'
  when sy-index MOD 3 = 0
    then 'fizz'
  when sy-index MOD 5 = 0
    then 'buzz'
  else |{ sy-index }|
).
write / result.
enddo.

*task5
data lv_i type i.
data lv_j type i.
do 10 times.
  lv_i = sy-index.
  do 10 times.
    lv_j = sy-index.

enddo.
enddo.

*task6
data text type string value 'level'.
data rev type string.
data len type i.
data pos type i.
len = strlen( text ).
do len times.
  pos = len - sy-index.
  concatenate rev text+pos(1)
    into rev.
enddo.
if text = rev.
  write: / 'palindrome'.
else.
  write: / 'not palinfdrome'.
endif.
