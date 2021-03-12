----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:32:25 09/19/2019 
-- Design Name: 
-- Module Name:    receiver - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



--given_clk is 16*baud_rate
entity receiver is
	port(given_clk : in std_logic;
		  rx_in : in std_logic;
		  rx_out : out std_logic_vector(7 downto 0);
		  reset : in std_logic;
		  rx_full : out std_logic
		 );
end receiver;


--idle refers to an ideal state where it is waiting for start bit
--start refers to the state where the receiver thinks it has received start bit and is waiting for 8 continuous 0 to determine whether the given signal is really start_bit or noise.
--si refers to the state when the receiver is reading bits given by the transmitter

architecture Behavioral of receiver is
	signal count : integer := 0;
	signal i : integer := 0;
--	signal old_bit : std_logic := '1';
	signal rx_reg : std_logic_vector(7 downto 0) := "00000000";
	type state_type is (idle,start,si);
	signal state : state_type;
begin
	process(given_clk, reset)
	begin
	    if(reset = '1') then
            state <= idle;
        else
		if (rising_edge(given_clk)) then
			--rx_full <= '1';
			case state is
				when idle =>
--					strt <= '0';
--					if(rx_in = '0' and (rx_in = not old_bit)) then
					if(rx_in = '0') then
						count <= 0;
						state <= start;
					end if;
				when start =>
					count <= count + 1;
					if(rx_in = '1') then
						state <= idle;
					else
						if (count < 6) then
							state <= start;
						else
							i <= 0;
							count <= 0;
							state <= si;
							rx_full <= '0';
						end if;
					end if;						
				
				when si =>
					count <= count + 1;
					if (count>=15) then
						count <= 0;
						--if(i=2) then
							--strt <= '0';
						--end if;
						if(i<8) then
							rx_reg <= rx_in & rx_reg(7 downto 1);
						end if;
						i <= i + 1;
						if (i=8) then
							rx_out <= rx_reg;
							rx_full <= '1';
							count <= 0;
							state <= idle;
						end if;
					end if;
				end case;
		end if;
--		old_bit <= rx_in;
        end if;
	end process;
	
--	process(state)
--	begin
--		if(state = idle) then
--			rx_out <= rx_reg;
--		end if;
--	end process;
--	with reset select
--	state <= idle when '1',
--				state when others;

end Behavioral;

