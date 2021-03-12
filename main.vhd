----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:32:11 10/17/2019 
-- Design Name: 
-- Module Name:    lab10 - Behavioral 
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
use ieee.numeric_std.all;

--package pkg is
--  type Memory_return_type is array (0 to 255) of std_logic_vector (11 downto 0);
--end package;

--package body pkg is
--end package body;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library work;    
--use work.pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lab10 is
	port(tx_start : in std_logic;
	      add_key : in std_logic;
		  reset : in std_logic;
		  rx_in : in std_logic;
		  clk : in std_logic;
		  key : in std_logic_vector(11 downto 0);
		  mode : in std_logic;
		  decrypt_memory_mode : in std_logic;
		  decrypt_memory_mode_LED : out std_logic;
		  show_key_button : in std_logic;
		  show_key : out std_logic_vector(11 downto 0);
		  shuffle : in std_logic_vector(1 downto 0);
		  shuffle_out : out std_logic_vector(1 downto 0);
		  tx_out : out std_logic;
		  seg : out std_logic_vector(0 to 6);
		  key_reset : in std_logic;
		  an : out std_logic_vector(3 downto 0)
--		  rx_data : out std_logic_vector(7 downto 0);
--		  tx_data : out std_logic_vector(7 downto 0)
		  );
end lab10;

architecture Behavioral of lab10 is
	signal tx_data_temp : std_logic_vector(7 downto 0) := "00000000";
	signal rx_data_temp : std_logic_vector(7 downto 0) := "00000000";
	signal freq_9600_16 : std_logic_vector(31 downto 0) := "00000000000000000000000101000101";
	signal freq_9600 : std_logic_vector(31 downto 0) := "00000000000000000001010001011000";
	signal freq_1hz : std_logic_vector(31 downto 0) := "00000010111110101111000010000000";
	signal freq_9600_16_clk : std_logic;                     
	signal freq_9600_clk : std_logic;
	signal freq_1hz_clk : std_logic;
	signal tx_start_temp : std_logic;
	signal reset_temp : std_logic;
	signal rx_full : std_logic;
	signal ld_tx : std_logic;
	signal tx_empty : std_logic;
	signal wen : std_logic;
	signal memory_index : integer;
--	signal xor_index : integer;
	signal number_of_keys : integer := 0;
	signal key_wen : std_logic;
	signal wr_vect : std_logic_vector(7 downto 0);
	
	signal wr_addr : std_logic_vector(7 downto 0);
	signal rd_addr : std_logic_vector(7 downto 0);
	
	signal index_key : std_logic_vector(11 downto 0);
	signal encrypt_index_key : std_logic_vector(11 downto 0);
	signal decrypt_index_key : std_logic_vector(11 downto 0);
	
	signal not_decrypt_memory_mode : std_logic;
	
	signal number_of_keys_decrypt : integer := 0;
    signal key_wen_decrypt  : std_logic;
    signal wr_vect_decrypt  : std_logic_vector(7 downto 0);
    
    signal encrypt_show_key : std_logic_vector(11 downto 0);
    signal decrypt_show_key : std_logic_vector(11 downto 0);
--	type Memory_type is array (0 to 255) of std_logic_vector (11 downto 0);
--    signal key_memory_array : Memory_return_type;
begin
    decrypt_memory_mode_LED <= decrypt_memory_mode;
    shuffle_out <= shuffle;
    an<="0111";
    with mode select
        seg <= "0110000" when '0',
                   "1000010" when others;
    with decrypt_memory_mode select
        show_key <= encrypt_show_key when '0',
                    decrypt_show_key when others;
    with decrypt_memory_mode select
        index_key <= encrypt_index_key when '0',
                    decrypt_index_key when others;                                               
	clk_9600_16 : entity work.freq_divider(Behavioral)
		port map(clk, freq_9600_16, freq_9600_16_clk);
	clk_9600 : entity work.freq_divider(Behavioral)
		port map(clk, freq_9600, freq_9600_clk);
    clk_1hz : entity work.freq_divider(Behavioral)
        port map(clk, freq_1hz, freq_1hz_clk);		

	debounce_reset : entity work.debouncer(Behavioral)
		port map(freq_9600_clk, reset, reset_temp);
	debounce_tx_start: entity work.debouncer(Behavioral)
		port map(freq_9600_clk, tx_start, tx_start_temp);
		
	receiver_register : entity work.receiver(Behavioral)
		port map(freq_9600_16_clk, rx_in, rx_data_temp, reset_temp, rx_full);
		
	transmitter_register : entity work.transmitter(Behavioral)
		port map(reset_temp, freq_9600_clk, ld_tx, mode, shuffle, memory_index, tx_data_temp, index_key, tx_out, tx_empty);
		
	memory_register : entity work.memory(Behavioral)
		port map(freq_9600_clk, wen, wr_addr, rx_data_temp, freq_9600_clk, ld_tx, rd_addr, tx_data_temp, memory_index);
		
	timing_circuit_module : entity work.timing_circuit(Behavioral)
		port map(reset_temp, freq_9600_clk, tx_start_temp, rx_full, tx_empty, ld_tx, rd_addr, wr_addr, wen);
		
	not_decrypt_memory_mode<=not decrypt_memory_mode;	
	key_timing_module : entity work.key_timing(Behavioral)
        port map(not_decrypt_memory_mode, key_reset, freq_9600_clk, add_key, number_of_keys, key_wen);
          
    wr_vect <= std_logic_vector(to_unsigned(number_of_keys,8));
    key_memory_register : entity work.key_memory(Behavioral)
        port map(not_decrypt_memory_mode, freq_9600_clk, freq_1hz_clk, key_wen, wr_vect, key, show_key_button, encrypt_show_key, memory_index, encrypt_index_key);
		
	decrypt_key_timing_module : entity work.key_timing(Behavioral)
        port map(decrypt_memory_mode, key_reset, freq_9600_clk, add_key, number_of_keys_decrypt, key_wen_decrypt);
        
    wr_vect_decrypt <= std_logic_vector(to_unsigned(number_of_keys_decrypt,8));
    decrypt_key_memory_register : entity work.key_memory(Behavioral)
        port map(decrypt_memory_mode, freq_9600_clk, freq_1hz_clk, key_wen_decrypt, wr_vect_decrypt, key, show_key_button, decrypt_show_key, memory_index, decrypt_index_key);
--	rx_data <= rx_data_temp;
--	tx_data <= tx_data_temp;

end Behavioral;

