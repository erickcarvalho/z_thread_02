*&---------------------------------------------------------------------*
*&  Include  z_thread_02_invokers
*&---------------------------------------------------------------------*

CLASS invoker DEFINITION .

  PUBLIC SECTION .

    METHODS:

      constructor
        IMPORTING
          new_command TYPE REF TO if_command ,

      dispatch ,

      on_error .

  PRIVATE SECTION .

    DATA the_command TYPE REF TO if_command .

ENDCLASS .

CLASS invoker IMPLEMENTATION.

  METHOD constructor.
    me->the_command = new_command .
  ENDMETHOD.


  METHOD dispatch.
    me->the_command->execute( ).
  ENDMETHOD.

  METHOD on_error.
    me->the_command->rollback( ).
  ENDMETHOD.

ENDCLASS.