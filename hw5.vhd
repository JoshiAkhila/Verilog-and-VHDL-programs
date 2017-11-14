
---- Designed by AKHILA JOSHI
-- HW 5
-- EECE 643
-- Spring 2016

library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Math_Real.all;
use IEEE.Numeric_Std.all;

--------------------------------------
-- Do not modify the module interface.
--
-- You may ignore the parameters if needed. Your submissions will not be
-- tested with values different from the defaults provided.
--
-- You may use the packing/upacking code provided or create your own
-- equivalent code.
--
-- Inputs:
-- x     - The vector of input values arranged {xM,...,x4,x3,x2,x1,x0}. These
--         may not remain stable during the computation (i.e., x may change
--         between the start and finish signals).
-- clk   - Input clock. Use the rising edge in your design.
-- start - Active high control signal that indicates the values provided on
--         x should be accepted for processing. The value of x should be saved
--         on the clock cycle in which both high and ready are asserted. start
--         should be ignored if ready is deasserted.
-- reset - Active high synchronous signal that causes sytem to be reset.
--
-- Outputs:
-- y     - The vector of output values arranged {yM,...,y4,y3,y2,y1,y0}. They
--         may take on any value while done is deasserted, but must have the
--         correct result whenever done is asserted.
-- ready - Active high control signal indicating the module is ready to accept
--         a new input. Ready should remain asserted whenever the module is
--         capable of accepting new input and should remain deasserted during
--         any period in which the module cannot accept new input. ready must
--         become active for at least one cycle between computations.
-- done  - Active high control signal indicating the computation is complete
--         and the result, y, is valid. done should remain asserted for only
--         one cycle.
--------------------------------------
entity hw5 is
	generic (DATA_WIDTH : integer :=32; MATRIX_SIZE : integer :=5);
	port (
		x     : in signed(MATRIX_SIZE*DATA_WIDTH-1 downto 0);
		clk   : in std_logic;
		start : in std_logic;
		reset : in std_logic;
		y     : out signed(MATRIX_SIZE*DATA_WIDTH-1 downto 0);
		ready : out std_logic;
		done  : out std_logic
	);
end hw5;

architecture behavioral of hw5 is
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
	type con is array(integer range 4 downto 0,integer range 0 to 4) of data_value;
	type con1 is array(integer range 4 downto 0,integer range 4 downto 0) of double_data_value;
	
	signal x_val : data_vector; -- x_val(MATRIX_SIZE-1) down to x_val(0) are the DATA_WIDTH-bit values
	signal x_val1 : data_vector;
	signal y_val : double_data_vector;
	signal A_val : con ;
	signal rd: std_logic:='0';
	signal dn, hdn, nx,nx1: std_logic:='0';
	signal inter_matr0,inter_matr1,inter_matr2,inter_matr3,inter_matr4:double_data_value:=(others=>'0');
	signal x_0,x_1,x_2,x_3,x_4:data_value:=(others =>'0');
	signal const_mat_0,const_mat_1,const_mat_2,const_mat_3,const_mat_4:data_value:=(others =>'0');
	signal x1:std_logic:='0';
	signal yrw: integer :=0;
	
	------- MAIN--------
   begin
   packing_loop:
	for i in MATRIX_SIZE-1 downto 0 generate
		x_val(i) <= x((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH);
		y((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH) <= y_val(i)(DATA_WIDTH-1 downto 0);
		packingloop1:
		for j in MATRIX_SIZE-1 downto 0 generate
		A_val(i,j)<=to_signed((((-1)**(i+j))*(i+1)*(j+1)),32);
		end generate;
		end generate;

	 	m: multiplier generic map(DATA_WIDTH=>DATA_WIDTH) port map(a=>x_0, b=>const_mat_0, p=>inter_matr0);
		m1: multiplier generic map(DATA_WIDTH=>DATA_WIDTH) port map(a=>x_1, b=>const_mat_1, p=>inter_matr1);
		m2: multiplier generic map(DATA_WIDTH=>DATA_WIDTH) port map(a=>x_2, b=>const_mat_2, p=>inter_matr2);
		m3: multiplier generic map(DATA_WIDTH=>DATA_WIDTH) port map(a=>x_3, b=>const_mat_3, p=>inter_matr3);
		m4: multiplier generic map(DATA_WIDTH=>DATA_WIDTH) port map(a=>x_4, b=>const_mat_4, p=>inter_matr4);
	  
	  done<=dn;
	  ready<=rd;
	------------PROCESS---------------
processxval:process (clk)
variable i,j:integer:=0;
variable row,colm:integer :=0;
variable temp :double_data_value :=(others=>'0');

begin
if( rising_edge(clk) ) then
	if2:
	if (reset ='1')then
			rd<='1' ;
			dn<='0';			
	elsif ( dn='1')then
				dn<='0';
				rd<='1';
	elsif(start='1' and dn='0')then
			if( rd = '1' ) then
				rd<='0';				
				dn<='0';

	x_0<=x_val(0);
	x_1<=x_val(1);
	x_2<=x_val(2);
	x_3<=x_val(3);
	x_4<=x_val(4);
	x1<='1';
			end if;
			end if;
			 
if (x1='1') then
if(i=0)then 
const_mat_0<=A_val(i,0);
	const_mat_1<=A_val(i,1);
	const_mat_2<=A_val(i,2);
	const_mat_3<=A_val(i,3);
	const_mat_4<=A_val(i,4);
	yrw<=0;
elsif (i=1)then 
	const_mat_0<=A_val(i,0);
	const_mat_1<=A_val(i,1);
	const_mat_2<=A_val(i,2);
	const_mat_3<=A_val(i,3);
	const_mat_4<=A_val(i,4);
	yrw<=1;
	elsif( i=2) then 
	const_mat_0<=A_val(i,0);
	const_mat_1<=A_val(i,1);
	const_mat_2<=A_val(i,2);
	const_mat_3<=A_val(i,3);
	const_mat_4<=A_val(i,4);
	yrw<=2;
	elsif(i=3) then 
	const_mat_0<=A_val(i,0);
	const_mat_1<=A_val(i,1);
	const_mat_2<=A_val(i,2);
	const_mat_3<=A_val(i,3);
	const_mat_4<=A_val(i,4);
	yrw<=3;
elsif(i=4) then 
const_mat_0<=A_val(i,0);
	const_mat_1<=A_val(i,1);
	const_mat_2<=A_val(i,2);
	const_mat_3<=A_val(i,3);
	const_mat_4<=A_val(i,4);
	yrw<=4;
end if; 
i:=i+1;

if (yrw=0) then 
y_val(0)<=inter_matr0+inter_matr1+inter_matr2+inter_matr3+inter_matr4;
end if;
if (yrw=1) then 
y_val(1)<=inter_matr0+inter_matr1+inter_matr2+inter_matr3+inter_matr4;
end if;
if (yrw=2) then 
y_val(2)<=inter_matr0+inter_matr1+inter_matr2+inter_matr3+inter_matr4;
end if;
if (yrw=3) then 
y_val(3)<=inter_matr0+inter_matr1+inter_matr2+inter_matr3+inter_matr4;
end if;
if (yrw=4) then 
y_val(4)<=inter_matr0+inter_matr1+inter_matr2+inter_matr3+inter_matr4;
	i:=0;
	dn<='1';
	x1<='0';
	yrw<=0;

end if; 
end if; 
end if;
 			
end process;
end behavioral;
