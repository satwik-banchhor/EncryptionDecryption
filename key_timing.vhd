----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.11.2019 12:58:18
-- Design Name: 
-- Module Name: key_timing - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity key_timing is
    Port (
        enable : IN std_logic;
        reset : IN std_logic;
        key_clk : IN std_logic;
        add_key : IN std_logic;
        number_of_keys : OUT integer;
        wen : OUT std_logic
        );
end key_timing;

architecture Behavioral of key_timing is
    type state_type is (idle, write, pressed);
    signal state : state_type := idle;
    signal internal_numkeys : integer := 0;    
begin
    number_of_keys <= internal_numkeys;
    
    process(key_clk)
    begin
        if enable='1' then
            if reset = '1' then
                internal_numkeys<=0;
            end if;
            if (rising_edge(key_clk)) then
                case state is
                    when idle=>
                        if add_key='1' then
                            state<=write;
                            wen<='1';
                            internal_numkeys<= internal_numkeys + 1;
                        end if;
                    when write=>
                        state<=pressed;
                        wen<='0';
                    when pressed=>
                        if add_key='0' then
                            state<=idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
