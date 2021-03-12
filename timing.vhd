----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:58:29 10/17/2019 
-- Design Name: 
-- Module Name:    timing_circuit - Behavioral 
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

entity timing_circuit is
  port(
  reset : in std_logic;
  clk : in std_logic; --9600Hz clock
  tx_start : in std_logic;
  rx_full : in std_logic;
  tx_empty : in std_logic;
  ld_tx : out std_logic;
  rd_addr : out std_logic_vector(7 downto 0);
  wr_addr : out std_logic_vector(7 downto 0);
  wen : out std_logic --write enable signal
  );
end timing_circuit;

architecture Behavioral of timing_circuit is
  type state_type is(s1,s2,s3,s4,s5,s6,s7,s8);
  -- s1 is the state acheived when reset is set to 1
  -- s2 while transmitter hasn't started and receiver is full. Basically, an idle state
  -- s3 receives the data from receiver until receiver is full
  -- s4 when receiver becomes full. It then writes it to memory. Then moves to s2
  -- s5 when transmitter starts receiving data. Sets read location to the base point of memory
  -- s6 when we have started reading file. We send data from memory to transmitter and append read address. Occurs whenever we read a new bit
  -- s7 while transmitter has some data left to transmit. In this state, data is transmitted by transmitter
  -- s8 when the whole file has been read. Waits until transmitter becomes off(tx_start==0)
  signal state : state_type;
  signal wr_addr_int : integer := 0;
  signal rd_addr_int : integer := 0;
  begin
    process(clk,reset)
    begin
		--wen <= '0';
		--ld_tx <= '0';
      if(reset='1') then
        state <= s1;
		  wr_addr_int <= 0;
      elsif(rising_edge(clk)) then
        case state is
          when s1 =>
          state <= s2;
			 wen <= '0';
          when s2 =>
          if(tx_start = '1') then
            if wr_addr_int=0 then
                state<=s8;
            else
                state <= s5;
                    rd_addr_int <= 0;
            end if;
          else
                if(rx_full = '0') then
                  state <= s3;
                end if;
             
          end if;
          when s3 =>
          if(rx_full = '1') then
            state <= s4;
				wr_addr_int <= wr_addr_int+1;
				wen <= '1';
          end if;
          when s4 =>
          wen <= '0';
          state <= s2;
          when s5 =>
          ld_tx <= '1';
			 rd_addr_int <= rd_addr_int+1;
          state <= s6;
          when s6 =>
          ld_tx <= '0';
          state <= s7;
          when s7 =>
          if(tx_empty = '1') then
            if(rd_addr_int=wr_addr_int) then
              state <= s8;
            else
				  ld_tx <= '1';
              state <= s6;
				  rd_addr_int <= rd_addr_int+1;
            end if;
          end if;
          when s8 =>
          if(tx_start = '0') then
            state <= s2;
				wen <= '0';
          end if;
        end case;
      end if;
    end process;
	 wr_addr <= std_logic_vector(to_unsigned(wr_addr_int, 8));
	 rd_addr <= std_logic_vector(to_unsigned(rd_addr_int, 8));
  end Behavioral;