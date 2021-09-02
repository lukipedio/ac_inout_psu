library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library math_library;
    use math_library.multiplier_pkg.all;

package division_pkg is
--------------------------------------------------
    type division_record is record
        division_process_counter : natural range 0 to 3;
        x: int18;
        number_to_be_reciprocated : int18;
    end record;

    constant init_division : division_record := (3, 0, 0);
------------------------------------------------------------------------
    procedure create_division (
        signal hw_multiplier : inout multiplier_record;
        signal division : inout division_record);

------------------------------------------------------------------------
    function get_initial_value_for_division ( divisor : natural)
        return natural;

------------------------------------------------------------------------
    procedure request_division (
        signal division : out division_record;
        number_to_be_reciprocated : int18);

------------------------------------------------------------------------
    function division_is_ready ( division_multiplier : multiplier_record; division : division_record)
        return boolean;

------------------------------------------------------------------------
    function remove_leading_zeros ( number : int18)
        return int18;

end package division_pkg;


package body division_pkg is

------------------------------------------------------------------------
    function remove_leading_zeros
    (
        number : int18
    )
    return int18
    is
        variable uint_17 : unsigned(16 downto 0);

    begin
        uint_17 := to_unsigned(abs(number),17);

        if to_integer(uint_17(15 downto 15- 15)) = 0 then
            return number * 2**(16-(    15- 15));
        end if;

        if to_integer(uint_17(15 downto 15- 14)) = 0 then
            return number * 2**(16-(    15- 14));
        end if;

        if to_integer(uint_17(15 downto 15- 13)) = 0 then
            return number * 2**(16-(    15- 13));
        end if;

        if to_integer(uint_17(15 downto 15- 12)) = 0 then
            return number * 2**(16-(    15- 12));
        end if;

        if to_integer(uint_17(15 downto 15- 11)) = 0 then
            return number * 2**(16-(    15- 11));
        end if;

        if to_integer(uint_17(15 downto 15- 10)) = 0 then
            return number * 2**(16-(    15- 10));
        end if;

        if to_integer(uint_17(15 downto 15- 9)) = 0 then
            return number * 2**(16-(    15- 9));
        end if;

        if to_integer(uint_17(15 downto 15- 8)) = 0 then
            return number * 2**(16-(    15- 8));
        end if;

        if to_integer(uint_17(15 downto 15- 7)) = 0 then
            return number * 2**(16-(    15- 7));
        end if;

        if to_integer(uint_17(15 downto 15- 6)) = 0 then
            return number * 2**(16-(    15- 6));
        end if; 

        if to_integer(uint_17(15 downto 15- 5)) = 0 then
            return number * 2**(16-(    15- 5));
        end if;

        if to_integer(uint_17(15 downto 15- 4)) = 0 then
            return number * 2**(16-(    15- 4));
        end if;

        if to_integer(uint_17(15 downto 15- 3)) = 0 then
            return number * 2**(16-(    15- 3));
        end if; 

        if to_integer(uint_17(15 downto 15- 2)) = 0 then
            return number * 2**(16-(    15- 2));
        end if;

        if to_integer(uint_17(15 downto 15- 1)) = 0 then
            return number * 2**(16-(    15- 1));
        end if;

        if to_integer(uint_17(15 downto 15- 0)) = 0 then
            return number * 2**(16-(    15- 0));
        end if;

        return number;
        
    end remove_leading_zeros; 

------------------------------------------------------------------------
    function get_initial_value_for_division
    (
        divisor : natural
    )
    return natural

    is
    --------------------------------------------------
        function get_lut_index
        (
            number : natural
        )
        return natural
        is

            variable u_number : unsigned(16 downto 0);
            variable lut_index : natural;
        begin 
            u_number  := to_unsigned(number, 17);
            lut_index := to_integer(u_number(14 downto 10)); 
            return lut_index; 
        end get_lut_index;
    -------------------------------------------------- 
        type divisor_lut_array is array (integer range 0 to 31) of int18;
        constant divisor_lut : divisor_lut_array := (
          0  => 2**16+2**15+2**14+2**13+2**12+2**11 , 1  => 2**16+2**15+2**14+2**13+2**12 , 2  => 2**16+2**15+2**14+2**13 , 3  => 2**16+2**15+2**14+2**12 , 4  => 2**16+2**15+2**14+2**11 , 5  => 2**16+2**15+2**14       , 6  => 2**16+2**15+2**13+2**12 , 7  => 2**16+2**15+2**13  ,
          8  => 2**16+2**15+2**13                   , 9  => 2**16+2**15+2**12             , 10 => 2**16+2**15             , 11 => 2**16+2**15             , 12 => 2**16+2**14+2**13+2**12 , 13 => 2**16+2**14+2**13+2**11 , 14 => 2**16+2**14+2**13       , 15 => 2**16+2**14+2**13  ,
          16 => 2**16+2**14+2**12                   , 17 => 2**16+2**14+2**11             , 18 => 2**16+2**14+2**11       , 19 => 2**16+2**14             , 20 => 2**16+2**14             , 21 => 2**16+2**13 +2**12      , 22 => 2**16+2**13 +2**12      , 23 => 2**16+2**13 +2**12 ,
          24 => 2**16+2**13                         , 25 => 2**16+2**13                   , 26 => 2**16+2**13             , 27 => 2**16+2**12             , 28 => 2**16+2**12             , 29 => 2**16+2**11             , 30 => 2**16+2**10             , 31 => 2**16);
    begin
        return divisor_lut(get_lut_index(divisor));
    end get_initial_value_for_division;
--------------------------------------------------
------------------------------------------------------------------------
    procedure create_division
    (
        signal hw_multiplier : inout multiplier_record;
        signal division : inout division_record
    ) is
    --------------------------------------------------
        function invert_bits
        (
            number : natural
        )
        return natural
        is
            variable number_in_std_logic : std_logic_vector(16 downto 0);
        begin
            number_in_std_logic := not std_logic_vector(to_unsigned(number,17));
            return to_integer(unsigned(number_in_std_logic));
        end invert_bits;
    --------------------------------------------------
        alias division_process_counter is division.division_process_counter;
        alias x is division.x;
        alias number_to_be_reciprocated is division.number_to_be_reciprocated; 
        variable xa : int18;
    --------------------------------------------------
    begin
        
        CASE division_process_counter is
            WHEN 0 =>
                multiply(hw_multiplier, number_to_be_reciprocated, x);
                division_process_counter <= division_process_counter + 1;
            WHEN 1 =>
                if multiplier_is_ready(hw_multiplier) then
                    xa := get_multiplier_result(hw_multiplier, 16);
                    multiply(hw_multiplier, x, invert_bits(xa));
                end if;
                increment_counter_when_ready(hw_multiplier,division_process_counter);
            WHEN 2 =>
                if multiplier_is_ready(hw_multiplier) then
                    x <= get_multiplier_result(hw_multiplier, 16);
                end if;
                increment_counter_when_ready(hw_multiplier,division_process_counter);
            WHEN others => -- wait for start
        end CASE;
    end create_division;

------------------------------------------------------------------------
    procedure request_division
    (
        signal division : out division_record;
        number_to_be_reciprocated : int18
    ) is
    begin
        division.division_process_counter <= 0;
        division.x <= get_initial_value_for_division(number_to_be_reciprocated);
        division.number_to_be_reciprocated <= number_to_be_reciprocated;
    end request_division;

------------------------------------------------------------------------
    function division_is_ready
    (
        division_multiplier : multiplier_record;
        division : division_record
    )
    return boolean
    is
    begin
        if division.division_process_counter = 2 then
            return multiplier_is_ready(division_multiplier);
        else
            return false;
        end if;
        
    end division_is_ready;

------------------------------------------------------------------------ 
end package body division_pkg;