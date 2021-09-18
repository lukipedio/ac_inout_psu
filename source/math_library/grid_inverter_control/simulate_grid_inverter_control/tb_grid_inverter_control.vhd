LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.division_pkg.all;
    use math_library.sincos_pkg.all;
    use math_library.pi_controller_pkg.all;
    use math_library.state_variable_pkg.all;
    use math_library.inverter_model_pkg.all;

entity tb_grid_inverter_control is
end;

architecture sim of tb_grid_inverter_control is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 15000;
------------------------------------------------------------------------
    signal simulation_counter : natural := 0;


    --------------------------------------------------
    -- grid voltage
    signal sincos_multiplier : multiplier_record := init_multiplier;
    signal sincos : sincos_record := init_sincos; 
    signal sincos_angle : unsigned(15 downto 0) := (others => '0'); 

    --------------------------------------------------
    -- inverter model
    signal inverter_model : inverter_model_record := init_inverter_state_variable_gains(inductor_integrator_gain => 8e3, ac_capacitor_integrator_gain => 20e3, dc_link_integrator_gain => 5000);
    
    signal grid_inductor_multiplier : multiplier_record := init_multiplier;
    -- inductor = 2^radix*ts/gain = 13uh for grid
    signal grid_inductor : state_variable_record := init_state_variable_gain(5000);

    --------------------------------------------------
    -- controller
    signal multiplier : multiplier_record := init_multiplier; 
    signal current_pi_control : pi_controller_record := init_pi_controller; 
    signal divider_multiplier : multiplier_record := init_multiplier;
    signal divider : division_record := init_division;
    --------------------------------------------------
    signal sine : int18 := 0;
    signal grid_current : int18 := 0;
    signal pi_control_output : int18;
    signal inverter_inductor_current : int18 := 0;

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
            report "grid inverter control simulation finished";
        wait;
    end process;
------------------------------------------------------------------------

    clocked_reset_generator : process(simulator_clock, rstn)
    begin
        if rising_edge(simulator_clock) then
            --------------------------------------------------
            simulation_counter <= simulation_counter + 1;
            --------------------------------------------------
            create_multiplier(sincos_multiplier);
            create_sincos(sincos_multiplier, sincos); 
            --------------------------------------------------
            create_multiplier(grid_inductor_multiplier); 
            create_state_variable(grid_inductor, grid_inductor_multiplier, get_sine(sincos)/2);
            create_inverter_model(inverter_model, 0, 0);
            inverter_model.dc_link_voltage.state <= 25e3;
            inverter_model.inverter_lc_filter.capacitor_voltage.state <= get_sine(sincos)/16;
            --------------------------------------------------
            create_multiplier(multiplier); 
            create_pi_controller(multiplier, current_pi_control, 40e2, 2e2);
            create_multiplier(divider_multiplier);
            create_division(divider_multiplier, divider);
            --------------------------------------------------

            if sincos_is_ready(sincos) or simulation_counter = 0 then
                sincos_angle <= sincos_angle + 300;
                request_sincos(sincos, sincos_angle);
                -- request_state_variable_calculation(grid_inductor);
                request_inverter_calculation(inverter_model, get_pi_control_output(current_pi_control));
                calculate_pi_control(current_pi_control, -get_sine(sincos)/32 - get_inverter_inductor_current(inverter_model));
                request_division(divider, get_inverter_capacitor_voltage(inverter_model), get_dc_link_voltage(inverter_model));

            end if;

        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------
    sine <= sincos.sin;
    grid_current <= grid_inductor.state;
    pi_control_output <= get_pi_control_output(current_pi_control);
    inverter_inductor_current <= get_inverter_inductor_current(inverter_model);

end sim;