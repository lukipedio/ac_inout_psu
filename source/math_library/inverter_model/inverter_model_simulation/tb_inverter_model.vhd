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
    use math_library.lcr_filter_model_pkg.all;


entity tb_inverter_model is
end;

architecture sim of tb_inverter_model is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 50;

    signal simulation_counter : natural := 0;

------------------------------------------------------------------------
    -- inverter model signals
    signal duty_ratio : int18;
    signal input_voltage : int18 := 0;
    signal grid_voltage : int18 := 0;

    signal dc_link_current : int18 := 0;
    signal dc_link_load_current : int18 := 0;
    signal load_current : int18 := 0;
    
    signal inverter_multiplier : multiplier_record     := multiplier_init_values;
    signal inductor_current    : lcr_model_record      := init_lcr_model_integrator_gains(5000, 2000);
    signal dc_link_voltage     : state_variable_record := init_state_variable_gain(500);

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
    --------------------------------------------------
        impure function "*" ( left, right : int18)
        return int18
        is
        begin
            sequential_multiply(inverter_multiplier, left, right);
            return get_multiplier_result(inverter_multiplier, 15);
        end "*";
    --------------------------------------------------
    begin
        if rising_edge(simulator_clock) then
            ------------------------------------------------------------------------

            create_multiplier(inverter_multiplier);
            create_state_variable(dc_link_voltage, inverter_multiplier, dc_link_current - dc_link_load_current); 

            CASE grid_inverter_state_counter is
                WHEN 0 =>
                    input_voltage <= dc_link_voltage.state * duty_ratio;
                    increment_counter_when_ready(inverter_multiplier, grid_inverter_state_counter);
                WHEN 1 =>
                    dc_link_current <= inductor_current.inductor_current.state * duty_ratio;
                    increment_counter_when_ready(inverter_multiplier, grid_inverter_state_counter);
                WHEN 2 =>
                    calculate(dc_link_voltage);
                    increment_counter_when_ready(inverter_multiplier, grid_inverter_state_counter);
                WHEN 3 =>
                    calculate_lcr_filter(inductor_current);
                    grid_inverter_state_counter <= grid_inverter_state_counter + 1;
                WHEN others => -- wait for restart
            end CASE;
    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------

end sim;