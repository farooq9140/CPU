library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity d_cache is
port(	input	 : in std_logic_vector(31 downto 0);
	reset_d	 : in std_logic;
      	clock_d	 : in std_logic;
	add	 : in std_logic_vector(4 downto 0);
      data_write_d : in std_logic;
      	output	 : out std_logic_vector(31 downto 0));
end d_cache;

architecture d_cache_arch of d_cache is

-- declare internal signals
type Locations is array(0 to 31) of std_logic_vector(31 downto 0);
signal L: Locations;

begin
	output <= L(conv_integer(add));

	process(input, reset_d, clock_d, data_write_d, add)
	begin
		if (reset_d = '1') then
			for i in L'range loop
				L(i) <= (others => '0');
			end loop;

		elsif( rising_edge(clock_d) ) then
			if ( data_write_d = '1' ) then
				L(conv_integer(add)) <= input;
			end if;
		end if;
	end process;
end d_cache_arch;

