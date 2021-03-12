

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:56:38 10/17/2019 
-- Design Name: 
-- Module Name:    memory - Behavioral 
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

--package pkg is
--  type Memory_return_type is array (0 to 255) of std_logic_vector (11 downto 0);
--end package;

--package body pkg is
--end package body;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
--use work.pkg.all;

entity key_memory is
  PORT (
    enable : IN STD_LOGIC;
    clka : IN STD_LOGIC;
    clkhz : IN STD_LOGIC;
    wea : IN STD_LOGIC; --wen from timing circuit
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0); --Written to memory at addra
    show_key_button : IN STD_LOGIC;
    show_key : OUT std_logic_vector(11 downto 0);
    
--    clkb : IN STD_LOGIC;
--    enb : IN STD_LOGIC; --Should be ld_tx by logical deduction
    memory_index : IN integer;
    doutb : OUT STD_LOGIC_VECTOR(11 DOWNTO 0) --Returned on reading file
--    index : OUT Memory_type (0 to 255)
  );
end key_memory;

architecture Behavioral of key_memory is

	type Memory_type is array (0 to 255) of std_logic_vector (11 downto 0);
	signal Memory_array : Memory_type;
	signal address : unsigned (7 downto 0);
	signal number_of_keys : integer;
	signal i : integer := 255;
begin
    doutb <= Memory_array(memory_index mod number_of_keys);
    number_of_keys <= to_integer(unsigned(addra));
--	process (clkb)
--	begin
--    if rising_edge(clkb) then    
--        if (enb = '1') then
--            address <= unsigned(addrb);    
--        end if;
--    end if;
--    end process;
    
--	doutb <= Memory_array (to_integer(address));
	process (clka)
	begin
		if rising_edge(clka) then	
			if (wea = '1') then
				Memory_array (to_integer(unsigned(addra))) <= dina (11 downto 0);	
			end if;
		end if;
	end process;
	
	process(clkhz, show_key_button)
	begin
	   if enable='1' then
	   if show_key_button='1' then
	       i<=0;
	   elsif (rising_edge(clkhz)) then
	       if i=0 then
	           show_key<="111111111111";
               i<=i+1;
	       elsif i<=number_of_keys then
	           i<=i+1;
	           show_key<=memory_array(i);
	       elsif i=number_of_keys+1 then
               show_key<="111111111111";
               i<=256;
	       else
	           show_key<="000000000000";    	      
	       end if;
	   end if;	       
	   end if;
	end process;
	
end Behavioral;
