library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity alu is
port(		
	x,y	    : in std_logic_vector(31 downto 0);  -- two input operands
	add_sub_alu     : in std_logic;			 -- 0 = add , 1 = sub
	logic_func_alu  : in std_logic_vector(1 downto 0);   -- 00 = AND, 01 = OR , 10 = XOR , 11 = NOR
	func_alu	    : in std_logic_vector(1 downto 0);   -- 00 = lui, 01 = setless , 10 = arith , 11 = logic
	output	    : out std_logic_vector(31 downto 0);
	overflow_alu    : out std_logic;
	zero_alu	    : out std_logic);
end alu;

architecture alu_arch of alu is
signal temp, logic_unit: std_logic_vector(31 downto 0);	 --temp holds the result of add_sub
signal MSD : std_logic_vector(2 downto 0); 		 --MSD = Most significant digit

begin
process(x, y, func_alu, logic_func_alu, add_sub_alu, temp, logic_unit, MSD)
begin	

MSD <= x(x'high) & y(y'high) & temp(temp'high);		 --MSD got from both inputs MSD and their addsub result

case add_sub_alu is
	when '0' => temp <= x + y;			 
		if ((MSD = "001") OR (MSD = "110")) then
			overflow_alu <= '1';
		else
			overflow_alu <= '0';
		end if;
	when '1' => temp <= x - y;
		if ((MSD = "100") OR (MSD = "011")) then
			overflow_alu <= '1';
		else
			overflow_alu <= '0';
		end if;
	when others =>
end case;


if  (temp = (temp'range => '0')) then --Check the result of add_sub if its zero or not
	zero_alu <= '1';
else
	zero_alu <= '0';
end if;


case logic_func_alu is
	when "00" => logic_unit <= x and y;
	when "01" => logic_unit <= x or y;
	when "10" => logic_unit <= x xor y;
	when "11" => logic_unit <= x nor y;
	when others =>
end case;


case func_alu is
	when "00" => output <= y;
	when "01" => output <= "0000000000000000000000000000000" & temp(31);
	when "10" => output <= temp;
	when "11" => output <= logic_unit;
	when others =>
	end case;
end process;
end alu_arch;
