library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity regfile is
port( din	: in std_logic_vector(31 downto 0);
      reset_r	: in std_logic;
      clk_r	: in std_logic;
      write	: in std_logic;
      read_a	: in std_logic_vector(4 downto 0);
      read_b	: in std_logic_vector(4 downto 0);
      write_address : in std_logic_vector(4 downto 0);
      out_a	: out std_logic_vector(31 downto 0);
      out_b	: out std_logic_vector(31 downto 0));
end regfile;

architecture reg_arch of regfile is

type Registers is array(0 to 31) of std_logic_vector(31 downto 0);
signal Reg: Registers;

begin
out_a <= Reg(conv_integer(read_a));
out_b <= Reg(conv_integer(read_b));

process(din, reset_r, clk_r, write, write_address)
begin
	if (reset_r = '1') then
		for i in Reg'range loop
			Reg(i) <= (others=> '0');
		end loop;

	elsif( rising_edge(clk_r) ) then
		if ( write = '1' ) then
			Reg(conv_integer(write_address)) <= din;
		end if;
	end if;
end process;
end reg_arch;
