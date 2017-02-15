*&---------------------------------------------------------------------*
*&  Include  z_dec
*&---------------------------------------------------------------------*

TYPES: BEGIN OF  ty_w_task_controller,
         taskid  TYPE char10,
         command TYPE REF TO callback,
         busy    TYPE char1,
       END OF ty_w_task_controller .
TYPES: ty_t_task_controller TYPE STANDARD TABLE OF ty_w_task_controller WITH KEY taskid .


TYPES: BEGIN OF ty_w_result_control,
         source_command TYPE REF TO callback,
         result_command TYPE REF TO callback,
       END OF ty_w_result_control .
TYPES: ty_t_result_control TYPE STANDARD TABLE OF ty_w_result_control WITH KEY source_command .


CONSTANTS c_task_prefix TYPE  rzlli_apcl VALUE 'BAR8'.