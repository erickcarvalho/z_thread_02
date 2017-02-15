*&---------------------------------------------------------------------*
*&  Include  z_thread_02_interfaces
*&---------------------------------------------------------------------*


INTERFACE if_command .

  METHODS:

    execute ,
    rollback .

ENDINTERFACE .


INTERFACE callback .

  METHODS:

    on_command,

    on_command_error ,

    on_command_success .

ENDINTERFACE .