*&---------------------------------------------------------------------*
*&  Include  z_thread_02_factory
*&---------------------------------------------------------------------*

CLASS factory DEFINITION .

  PUBLIC SECTION .

    CLASS-METHODS:
      get_callback
        IMPORTING
                  type_of           TYPE string
        RETURNING VALUE(r_callback) TYPE REF TO callback .

ENDCLASS .

CLASS factory IMPLEMENTATION.

  METHOD get_callback.

    r_callback = SWITCH #( type_of
                            WHEN 'SYNC' THEN NEW processor_sync( )
                            WHEN 'ASYNC' THEN NEW processor_async( )
                             ).
  ENDMETHOD.

ENDCLASS.