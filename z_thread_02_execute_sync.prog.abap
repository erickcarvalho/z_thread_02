*&---------------------------------------------------------------------*
*&  Include  z_thread_02_execute_sync
*&---------------------------------------------------------------------*

CLASS processor_sync DEFINITION .

  PUBLIC SECTION .

    INTERFACES callback .

    ALIASES:

    on_command FOR callback~on_command ,
    on_command_error FOR callback~on_command_error ,
    on_command_success FOR callback~on_command_success .

ENDCLASS .

CLASS processor_sync IMPLEMENTATION.

  METHOD on_command .
    WAIT UP TO 2 SECONDS .
  ENDMETHOD .


  METHOD on_command_error .
  ENDMETHOD .

  METHOD on_command_success .
  ENDMETHOD .

ENDCLASS.