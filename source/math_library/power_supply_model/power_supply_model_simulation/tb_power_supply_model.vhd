LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.state_variable_pkg.all;
    use math_library.pi_controller_pkg.all;
    use math_library.lcr_filter_model_pkg.all;


entity tb_power_supply_model is
end;

architecture sim of tb_power_supply_model is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 50;

    signal simulation_counter : natural := 0;

    signal input_voltage : int18 := 0;
    signal grid_voltage : int18 := 0;

    signal load_current : int18 := 0;
    signal grid_inductor_current : state_variable_record := init_state_variable_gain(5000);

    signal dc_link_voltage : state_variable_record := init_state_variable_gain(5000);

    type inverter_stages is (main_grid_filter  ,
                            grid_emi_filter_1  ,
                            grid_emi_filter_2  ,
                            output_main_filter ,
                            output_emi_filter );
    type grid_inverter_lc_filters is array (inverter_stages range inverter_stages'left to inverter_stages'right) of lcr_model_record; 
    signal grid_lc_filter : grid_inverter_lc_filters := (init_lcr_model_integrator_gains(2000 , 30000)   ,
                                                         init_lcr_model_integrator_gains(2000 , 30000)   ,
                                                         init_lcr_model_integrator_gains(2000 , 30000)   ,
                                                         init_lcr_model_integrator_gains(2000 , 30000)   ,
                                                         init_lcr_model_integrator_gains(2000 , 30000));

    type multipliers is (main_grid_filter            ,
                            grid_emi_filter_1        ,
                            grid_emi_filter_2        ,
                            output_main_filter       ,
                            grid_inductor_multiplier ,
                            output_emi_filter );
    type lc_filter_multiplier_array is array (multipliers range multipliers'left to multipliers'right) of multiplier_record; 
    signal lc_filter_multipliers : lc_filter_multiplier_array := (multiplier_init_values ,
                                                                multiplier_init_values   ,
                                                                multiplier_init_values   ,
                                                                multiplier_init_values   ,
                                                                multiplier_init_values   ,
                                                                multiplier_init_values);

    signal grid_inverter_state_counter : natural range 0 to 7;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        simulation_running <= true;
        wait for simtime_in_clocks*clock_per;
        simulation_running <= false;
        wait;
    end process simtime;	

------------------------------------------------------------------------
    sim_clock_gen : process
    begin
        simulator_clock <= '0';
        rstn <= '0';
        simulator_clock <= '0';
        wait for clock_half_per;
        while simulation_running loop
            wait for clock_half_per;
                rstn <= '1';
                simulator_clock <= not simulator_clock;
            end loop;
        wait;
    end process;
------------------------------------------------------------------------

    clocked_reset_generator : process(simulator_clock, rstn)
        impure function "*" ( left, right : int18)
        return int18
        is
        begin
            sequential_multiply(lc_filter_multipliers(grid_inductor_multiplier), left, right);
            return get_multiplier_result(lc_filter_multipliers(grid_inductor_multiplier), 15);
        end "*";
    begin
        if rising_edge(simulator_clock) then
            create_multiplier(lc_filter_multipliers(main_grid_filter)); 
            create_multiplier(lc_filter_multipliers(grid_emi_filter_1)); 
            create_multiplier(lc_filter_multipliers(grid_emi_filter_2)); 
            create_multiplier(lc_filter_multipliers(grid_inductor_multiplier)); 

            create_multiplier(lc_filter_multipliers(output_main_filter)); 
            create_multiplier(lc_filter_multipliers(output_emi_filter)); 

            --- grid inverter model
            create_lcr_filter(grid_lc_filter(main_grid_filter   ) , lc_filter_multipliers(main_grid_filter    ) , input_voltage                                         - grid_lc_filter(main_grid_filter).capacitor_voltage  , grid_lc_filter(main_grid_filter).inductor_current   - grid_lc_filter(grid_emi_filter_1).inductor_current);
            create_lcr_filter(grid_lc_filter(grid_emi_filter_1  ) , lc_filter_multipliers(grid_emi_filter_1   ) , grid_lc_filter(output_main_filter).capacitor_voltage  - grid_lc_filter(grid_emi_filter_1).capacitor_voltage , grid_lc_filter(grid_emi_filter_1).inductor_current  - grid_lc_filter(grid_emi_filter_2).inductor_current);
            create_lcr_filter(grid_lc_filter(grid_emi_filter_2  ) , lc_filter_multipliers(grid_emi_filter_2   ) , grid_lc_filter(grid_emi_filter_1  ).capacitor_voltage - grid_lc_filter(grid_emi_filter_2).capacitor_voltage , grid_lc_filter(grid_emi_filter_2 ).inductor_current - grid_inductor_current);

            create_state_variable(grid_inductor_current, lc_filter_multipliers(grid_inductor_multiplier), grid_lc_filter(grid_emi_filter_2).capacitor_voltage - grid_voltage);

            --- output inverter model
            create_lcr_filter(grid_lc_filter(output_main_filter ) , lc_filter_multipliers(output_main_filter  ) , grid_lc_filter(output_main_filter ).capacitor_voltage - grid_lc_filter(output_emi_filter ).capacitor_voltage , grid_lc_filter(main_grid_filter).inductor_current  - grid_lc_filter(output_emi_filter).inductor_current);
            create_lcr_filter(grid_lc_filter(output_emi_filter  ) , lc_filter_multipliers(output_emi_filter   ) , grid_lc_filter(output_emi_filter  ).capacitor_voltage - grid_voltage                                         , grid_lc_filter(output_emi_filter).inductor_current - load_current);
            ------------------------------------------------------------------------
            CASE grid_inverter_state_counter is
                WHEN 0 =>
                    input_voltage <= 500 * 16384;
                    increment_counter_when_ready(lc_filter_multipliers(grid_inductor_multiplier), grid_inverter_state_counter);
                WHEN 1 =>
                    input_voltage <= 500 * 16384;
                    increment_counter_when_ready(lc_filter_multipliers(grid_inductor_multiplier), grid_inverter_state_counter);
                WHEN 2 =>
                    calculate(grid_inductor_current);
                    calculate_lcr_filter(grid_lc_filter(main_grid_filter));
                    calculate_lcr_filter(grid_lc_filter(grid_emi_filter_1));
                    calculate_lcr_filter(grid_lc_filter(grid_emi_filter_2)); 
                    grid_inverter_state_counter <= grid_inverter_state_counter + 1;
                WHEN others => -- wait for restart
            end CASE;
    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------

end sim;