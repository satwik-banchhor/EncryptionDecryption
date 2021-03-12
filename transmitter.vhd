----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:55:09 10/10/2019 
-- Design Name: 
-- Module Name:    transmitter - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--entity transmitter is
--end transmitter;

--architecture Behavioral of transmitter is

--begin


--end Behavioral;

entity transmitter is
  port(
  reset : in std_logic;
  tx_clk : in std_logic;
  ld_tx : in std_logic;
  mode : in std_logic;
  shuffle :in std_logic_vector(1 downto 0);
  xor_index : in integer;
  tx_data : in std_logic_vector(7 downto 0);
  key : in std_logic_vector(11 downto 0);
  tx_out : out std_logic;
  tx_empty : out std_logic
  );
end transmitter;

architecture Behavioral of transmitter is
  type state_type is(idle,start,s0,s1,s2,s3,s4,s5,s6,s7);
  signal state : state_type;
  signal modified_tx_data : std_logic_vector(7 downto 0);
  signal xor_key : std_logic_vector(7 downto 0);
  signal shuffle_data : std_logic_vector(7 downto 0);
  begin
    --Modification 
    --Making xor_key
    xor_key(0)<=key((xor_index) mod 12);
    xor_key(1)<=key((xor_index+1) mod 12);
    xor_key(2)<=key((xor_index+2) mod 12);
    xor_key(3)<=key((xor_index+3) mod 12);
    xor_key(4)<=key((xor_index+4) mod 12);
    xor_key(5)<=key((xor_index+5) mod 12);
    xor_key(6)<=key((xor_index+6) mod 12);
    xor_key(7)<=key((xor_index+7) mod 12);    

    
    
    --Making shuffle_data    
    process(tx_data, shuffle_data, modified_tx_data, mode, shuffle, key)
    begin
        case mode is
            when '0'=>
            --Encrypt mode
                case shuffle is
                    when "00"=>
                        shuffle_data(0)<=tx_data(0);
                        shuffle_data(1)<=tx_data(2);
                        shuffle_data(2)<=tx_data(4);
                        shuffle_data(3)<=tx_data(6);
                        shuffle_data(4)<=tx_data(1);
                        shuffle_data(5)<=tx_data(3);
                        shuffle_data(6)<=tx_data(5);
                        shuffle_data(7)<=tx_data(7);
                    when "01"=>
                        shuffle_data(0)<=tx_data(4);
                        shuffle_data(1)<=tx_data(5);
                        shuffle_data(2)<=tx_data(6);
                        shuffle_data(3)<=tx_data(7);
                        shuffle_data(4)<=tx_data(0);
                        shuffle_data(5)<=tx_data(1);
                        shuffle_data(6)<=tx_data(2);
                        shuffle_data(7)<=tx_data(3);                    
                    when "10"=>
                        shuffle_data(0)<=tx_data(7);
                        shuffle_data(1)<=tx_data(6);
                        shuffle_data(2)<=tx_data(5);
                        shuffle_data(3)<=tx_data(4);
                        shuffle_data(4)<=tx_data(3);
                        shuffle_data(5)<=tx_data(2);
                        shuffle_data(6)<=tx_data(1);
                        shuffle_data(7)<=tx_data(0);                    
                    when "11"=>
                        shuffle_data(0)<=tx_data(2);
                        shuffle_data(1)<=tx_data(3);
                        shuffle_data(2)<=tx_data(4);
                        shuffle_data(3)<=tx_data(5);
                        shuffle_data(4)<=tx_data(6);
                        shuffle_data(5)<=tx_data(7);
                        shuffle_data(6)<=tx_data(0);
                        shuffle_data(7)<=tx_data(1);
                end case;
                modified_tx_data <= shuffle_data xor xor_key;
                
            when '1'=>
                --Decrypt mode
                shuffle_data <= tx_data xor xor_key;
                case shuffle is
                    when "00"=>
                        modified_tx_data(0)<=shuffle_data(0);
                        modified_tx_data(1)<=shuffle_data(4);
                        modified_tx_data(2)<=shuffle_data(1);
                        modified_tx_data(3)<=shuffle_data(5);
                        modified_tx_data(4)<=shuffle_data(2);
                        modified_tx_data(5)<=shuffle_data(6);
                        modified_tx_data(6)<=shuffle_data(3);
                        modified_tx_data(7)<=shuffle_data(7);
                        
                    when "01"=>
                        modified_tx_data(0)<=shuffle_data(4);
                        modified_tx_data(1)<=shuffle_data(5);
                        modified_tx_data(2)<=shuffle_data(6);
                        modified_tx_data(3)<=shuffle_data(7);
                        modified_tx_data(4)<=shuffle_data(0);
                        modified_tx_data(5)<=shuffle_data(1);
                        modified_tx_data(6)<=shuffle_data(2);
                        modified_tx_data(7)<=shuffle_data(3);                    
                    when "10"=>
                        modified_tx_data(0)<=shuffle_data(7);
                        modified_tx_data(1)<=shuffle_data(6);
                        modified_tx_data(2)<=shuffle_data(5);
                        modified_tx_data(3)<=shuffle_data(4);
                        modified_tx_data(4)<=shuffle_data(3);
                        modified_tx_data(5)<=shuffle_data(2);
                        modified_tx_data(6)<=shuffle_data(1);
                        modified_tx_data(7)<=shuffle_data(0);                  
                    when "11"=>
                        modified_tx_data(0)<=shuffle_data(6);
                        modified_tx_data(1)<=shuffle_data(7);
                        modified_tx_data(2)<=shuffle_data(0);
                        modified_tx_data(3)<=shuffle_data(1);
                        modified_tx_data(4)<=shuffle_data(2);
                        modified_tx_data(5)<=shuffle_data(3);
                        modified_tx_data(6)<=shuffle_data(4);
                        modified_tx_data(7)<=shuffle_data(5);
                end case;
        end case;
    end process;
    
    
    process(tx_clk, reset)
    begin
		if(reset='1') then
			state <= idle;
      elsif(rising_edge(tx_clk)) then
        case state is
          when idle =>
          if(ld_tx='1') then
            state <= start;
				tx_empty <= '0';
				tx_out <= '0';
          else
            state <= idle;
				tx_out <= '1';
          end if;
          when start =>
				tx_out <= modified_tx_data(0);
          state <= s0;
          when s0 =>
          state <= s1;
				tx_out <= modified_tx_data(1);
          when s1 =>
          state <= s2;
				tx_out <= modified_tx_data(2);
          when s2 =>
          state <= s3;
				tx_out <= modified_tx_data(3);
          when s3 =>
          state <= s4;
				tx_out <= modified_tx_data(4);
          when s4 =>
          state <= s5;
				tx_out <= modified_tx_data(5);
          when s5 =>
          state <= s6;
				tx_out <= modified_tx_data(6);
          when s6 =>
          state <= s7;
				tx_out <= modified_tx_data(7);
          when s7 =>
          state <= idle;
				tx_out <= '1';
			 tx_empty <= '1';
        end case;
      end if;
    end process;
end architecture Behavioral;