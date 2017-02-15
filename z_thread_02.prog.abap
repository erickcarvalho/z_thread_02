*&---------------------------------------------------------------------*
*& Report  z_thread_02
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT z_thread_02.

INCLUDE z_thread_02_interfaces .
INCLUDE z_dec .
INCLUDE z_thread_02_classes .

START-OF-SELECTION .

  DATA new_callback TYPE REF TO callback .

  TRY.
      new_callback = factory=>get_callback( type_of = 'ASYNC' ) .
    CATCH cx_root.
      new_callback = factory=>get_callback( type_of = 'SYNC'  ) .
  ENDTRY.
*
  DATA(on_command) = NEW commander( new_callback = new_callback ) .

  DATA(on_invoker01) = NEW invoker( new_command = on_command ) .
  DATA(on_invoker02) = NEW invoker( new_command = on_command ) .
  DATA(on_invoker03) = NEW invoker( new_command = on_command ) .
  DATA(on_invoker04) = NEW invoker( new_command = on_command ) .
  DATA(on_invoker05) = NEW invoker( new_command = on_command ) .
  DATA(on_invoker06) = NEW invoker( new_command = on_command ) .
  DATA(on_invoker07) = NEW invoker( new_command = on_command ) .
  DATA(on_invoker08) = NEW invoker( new_command = on_command ) .
  DATA(on_invoker09) = NEW invoker( new_command = on_command ) .
  DATA(on_invoker10) = NEW invoker( new_command = on_command ) .

  on_invoker01->dispatch( ).
  on_invoker02->dispatch( ).
  on_invoker03->dispatch( ).
  on_invoker04->dispatch( ).
  on_invoker05->dispatch( ).
  on_invoker06->dispatch( ).
  on_invoker07->dispatch( ).
  on_invoker08->dispatch( ).
  on_invoker09->dispatch( ).
  on_invoker10->dispatch( ).

*
  new_callback->on_command_success( ).