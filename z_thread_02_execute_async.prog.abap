*&---------------------------------------------------------------------*
*&  Include  z_thread_02_execute_async
*&---------------------------------------------------------------------*

CLASS processor_async DEFINITION .

  PUBLIC SECTION .

    INTERFACES callback .

    ALIASES:
         on_command FOR callback~on_command ,
         on_command_error FOR callback~on_command_error ,
         on_command_success FOR callback~on_command_success .

    METHODS:
      constructor
        IMPORTING
          group_name    TYPE rzllitab-classname OPTIONAL
          max_wait_time TYPE i DEFAULT 15,

      handle_return
        IMPORTING
          VALUE(p_task) TYPE c .

  PROTECTED SECTION .

    METHODS:
      assign_command_to_task
        RETURNING
          VALUE(r_task) TYPE char10 ,

      wait_for_avlble_task_exception
        RETURNING
          VALUE(r_task) TYPE char10 .


  PRIVATE SECTION .

    DATA: mt_task_controller   TYPE ty_t_task_controller,
          mt_result_controller TYPE ty_t_result_control.

    DATA:
      m_max_work_processes    TYPE i,
      m_free_work_processes   TYPE i,
      m_active_work_processes TYPE i,
      m_taskid_counter        TYPE n LENGTH 6,

      m_groupname             TYPE rzllitab-classname,
      m_max_wait_time         TYPE i.

    METHODS:

      prepare_available_tasks
        IMPORTING
          group_name    TYPE rzllitab-classname
          max_wait_time TYPE i DEFAULT 15,

      run_command_in_task
        IMPORTING
          i_task TYPE any OPTIONAL ,

      insert_result_control
        IMPORTING
          i_task            TYPE c
          io_result_command TYPE REF TO callback ,

      wait_tasks.

ENDCLASS .



CLASS processor_async IMPLEMENTATION.


  METHOD constructor.

    CALL FUNCTION 'SPBT_INITIALIZE'
      EXPORTING
        group_name                     = group_name
      IMPORTING
        max_pbt_wps                    = m_max_work_processes
        free_pbt_wps                   = m_free_work_processes
      EXCEPTIONS
        invalid_group_name             = 1
        internal_error                 = 2
        pbt_env_already_initialized    = 3
        currently_no_resources_avail   = 4
        no_pbt_resources_found         = 5
        cant_init_different_pbt_groups = 6
        OTHERS                         = 7.

    CASE sy-subrc.
      WHEN 3. "Already Initialized

        CALL FUNCTION 'SPBT_GET_CURR_RESOURCE_INFO'
          IMPORTING
            free_pbt_wps                = m_free_work_processes
          EXCEPTIONS
            internal_error              = 1
            pbt_env_not_initialized_yet = 2.

        IF sy-subrc = 0.
          m_max_work_processes = m_free_work_processes.
        ELSE .
*        Raise a Exception - FATAL
        ENDIF.

    ENDCASE.

    prepare_available_tasks(
      EXPORTING
        group_name    = group_name
        max_wait_time = 15
    ).

  ENDMETHOD.





  METHOD prepare_available_tasks.

    DATA: lw_control LIKE LINE OF mt_task_controller.

    m_groupname = group_name.
    m_max_wait_time = max_wait_time.

    DO  m_free_work_processes TIMES.

      ADD 1 TO m_taskid_counter.
      CONCATENATE c_task_prefix m_taskid_counter INTO lw_control-taskid.

      APPEND lw_control TO mt_task_controller.
    ENDDO.

  ENDMETHOD.







  METHOD assign_command_to_task.

    FIELD-SYMBOLS: <lw_task_controller> LIKE LINE OF mt_task_controller.

    DATA: l_available_wp_now TYPE i.

    CALL FUNCTION 'SPBT_GET_CURR_RESOURCE_INFO'
      IMPORTING
        free_pbt_wps                = l_available_wp_now
      EXCEPTIONS
        internal_error              = 1
        pbt_env_not_initialized_yet = 2.

    IF l_available_wp_now <= 0 OR sy-subrc NE 0.
*    zcx_async_cmd_listener=>no_tasks_available.
    ENDIF.

    READ TABLE me->mt_task_controller
        ASSIGNING <lw_task_controller>
        WITH KEY busy = ''.

    IF sy-subrc EQ 0.
      <lw_task_controller>-command = me.
      <lw_task_controller>-busy = 'X'.
      r_task = <lw_task_controller>-taskid.
    ELSE.
*  zcx_async_cmd_listener=>no_tasks_available.
    ENDIF.

  ENDMETHOD.






  METHOD wait_for_avlble_task_exception.

    DO m_max_wait_time TIMES.
      TRY .
          r_task = assign_command_to_task( ).
          EXIT.
        CATCH cx_root.
      ENDTRY.
      WAIT UP TO 1 SECONDS.
    ENDDO.

    IF r_task IS  INITIAL.
*   zcx_async_cmd_listener=>timeout_waiting_for_task.
    ENDIF.

  ENDMETHOD.





  METHOD run_command_in_task.

    DATA: l_command_in  TYPE xstring.

    CALL TRANSFORMATION id
    SOURCE command = me
    RESULT XML l_command_in.

    CALL FUNCTION 'Z_ASYNC_COMMAND'
      STARTING NEW TASK i_task
      DESTINATION IN GROUP m_groupname
      CALLING me->handle_return ON END OF TASK
      EXPORTING
        i_command_xstring     = l_command_in
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        resource_failure      = 3
        error_messages        = 4
        OTHERS                = 5.

    IF sy-subrc EQ 0.
      ADD 1 TO m_active_work_processes.
    ELSE .
*      RAISE EXCEPTION TYPE zcx_async_cmd_listener.
    ENDIF.

  ENDMETHOD.




  METHOD handle_return .

    DATA: l_command_out       TYPE xstring,
          l_exception_out     TYPE xstring,
          lo_result_command   TYPE REF TO callback,
          lo_result_exception TYPE REF TO cx_root.

    RECEIVE RESULTS FROM FUNCTION 'Z_ASYNC_COMMAND'
        IMPORTING
            e_command_object   = l_command_out
            e_exception_object = l_exception_out.

* if l_exception_out is not initial
* call method handle_return_error

    insert_result_control(
      EXPORTING
        i_task            = p_task
        io_result_command = lo_result_command
    ).

    SUBTRACT 1 FROM m_active_work_processes.

  ENDMETHOD .




  METHOD insert_result_control.

    FIELD-SYMBOLS: <lw_task_controller>   LIKE LINE OF mt_task_controller,
                   <lw_result_controller> LIKE LINE OF mt_result_controller.

    READ TABLE mt_task_controller
           ASSIGNING <lw_task_controller>
           WITH KEY taskid = i_task.


    READ TABLE mt_result_controller
        ASSIGNING <lw_result_controller>
        WITH KEY source_command = <lw_task_controller>-command.

    IF sy-subrc EQ 0.
      <lw_result_controller>-result_command = io_result_command.
    ELSE.
      APPEND INITIAL LINE TO mt_result_controller ASSIGNING <lw_result_controller>.
      <lw_result_controller>-source_command = <lw_task_controller>-command.
      <lw_result_controller>-result_command = io_result_command.
    ENDIF.

  ENDMETHOD.



  METHOD wait_tasks.
    WAIT UNTIL m_active_work_processes <= 0.
  ENDMETHOD.




  METHOD on_command.

    DATA: l_task TYPE char10.

    TRY .
        l_task = assign_command_to_task( ).
      CATCH cx_root."cx_async_cmd_listener. -> No Tasks Available
        l_task = wait_for_avlble_task_exception( ).
    ENDTRY.

    run_command_in_task(
        i_task = l_task ).

  ENDMETHOD.


  METHOD on_command_error.
  ENDMETHOD.


  METHOD on_command_success .
    wait_tasks( ).
  ENDMETHOD .

ENDCLASS.