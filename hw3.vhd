-- Designed by AKHILA JOSHI



library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use ieee.std_logic_unsigned.all;

entity hw3 is
	generic (DATA_WIDTH : integer :=32; MATRIX_SIZE: integer :=5);
	port (
		x: in signed(MATRIX_SIZE*DATA_WIDTH-1 downto 0);
		y: out signed(MATRIX_SIZE*DATA_WIDTH-1 downto 0)
		);
end hw3;

architecture behavioral of hw3 is
	component multiplier is
		generic(DATA_WIDTH : integer :=32);
		port(
			a, b : in signed(DATA_WIDTH-1 downto 0);
			p : out signed(2*DATA_WIDTH-1 downto 0)
		);
	end component;

	subtype data_value is signed(DATA_WIDTH-1 downto 0);
	subtype double_data_value is signed(2*DATA_WIDTH-1 downto 0);
	
	type data_vector is array(integer range MATRIX_SIZE-1 downto 0) of data_value;
	type double_data_vector is array(integer range MATRIX_SIZE-1 downto 0) of double_data_value;
	type con is array(integer range 0 to 4,integer range 0 to 4) of data_value;
	type con1 is array(integer range 0 to 4,integer range 0 to 4) of double_data_value;
	
	signal x_val : data_vector; -- x_val(MATRIX_SIZE-1) down to x_val(0) are the DATA_WIDTH-bit values
	signal y_val : double_data_vector; 
	signal A_val : con ;
	signal A_val1 : con1;

begin

packing_loop:
	for i in MATRIX_SIZE-1 downto 0 generate
	
		x_val(i) <= x((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH);
		y((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH) <= y_val(i)(DATA_WIDTH-1 downto 0); 
		
looping1:for n in MATRIX_SIZE-1 downto 0 generate
	A_val(i,n) <= to_signed(((((-1)**(i+n))*(i+1)*(n+1))),32);
	mul0: multiplier generic map(DATA_WIDTH => DATA_WIDTH) port map(
	a=> A_val(i,n),
	b=> x_val(n),
	p=>A_val1(i,n));
	end generate;
	end generate;
	
	y_val(0)<=((A_val1(0,0))+(A_val1(0,1))+(A_val1(0,2))+(A_val1(0,3))+(A_val1(0,4)));
   y_val(1)<=((A_val1(1,0))+(A_val1(1,1))+(A_val1(1,2))+(A_val1(1,3))+(A_val1(1,4)));
	y_val(2)<=((A_val1(2,0))+(A_val1(2,1))+(A_val1(2,2))+(A_val1(2,3))+(A_val1(2,4)));
	y_val(3)<=((A_val1(3,0))+(A_val1(3,1))+(A_val1(3,2))+(A_val1(3,3))+(A_val1(3,4)));
	y_val(4)<=((A_val1(4,0))+(A_val1(4,1))+(A_val1(4,2))+(A_val1(4,3))+(A_val1(4,4)));
end behavioral;


