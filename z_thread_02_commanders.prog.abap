*&---------------------------------------------------------------------*
*&  Include  z_thread_02_commanders
*&---------------------------------------------------------------------*

CLASS commander DEFINITION .

  PUBLIC SECTION .

    INTERFACES if_command .

    ALIASES:

    execute FOR if_command~execute ,
    rollback FOR if_command~rollback .

    METHODS:

      constructor
        IMPORTING
          new_callback TYPE REF TO callback .

  PRIVATE SECTION .

    DATA the_callback TYPE REF TO callback .

ENDCLASS .

CLASS commander IMPLEMENTATION.

  METHOD constructor.
    me->the_callback = new_callback .
  ENDMETHOD.



  METHOD execute .
    me->the_callback->on_command( ).
  ENDMETHOD .



  METHOD rollback .
  ENDMETHOD .

ENDCLASS.