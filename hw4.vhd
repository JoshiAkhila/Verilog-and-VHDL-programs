
-- Akhila Joshi
-- HW 4
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
entity hw4 is
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
end hw4;

architecture behavioral of hw4 is
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
	signal x_val1 : data_vector;
	signal y_val : double_data_vector;
	signal A_val : con ;
	signal A_val1 : con1;
	signal rd: std_logic;
	signal dn ,nx: std_logic;
	signal st:integer range 0 to 1:=0;
	signal inter_mat1,inter_matf:double_data_value:=(others=>'0');
	signal x_1:data_value:=(others =>'0');
	signal const_mat:data_value:=(others =>'0');
	signal i1,j1:integer;
	


------- MAIN--------
begin
	packing_loop:
	for i in MATRIX_SIZE-1 downto 0 generate
		x_val(i) <= x((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH);
		y((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH) <= y_val(i)(DATA_WIDTH-1 downto 0);
		packingloop1:
		for j in 0 to MATRIX_SIZE-1 generate
		A_val(i,j)<=to_signed(((-1)**(i+j)*(i+1)*(j+1)),32);
		end generate;
		end generate;


			m: multiplier generic map(DATA_WIDTH=>DATA_WIDTH) port map(a=>x_1, b=>const_mat, p=>inter_mat1);
	
--	end generate;
--	if( i=0 and c = 0 ) generate
--		dn<='1';
----		end generate;
----	end generate;
done<=dn;
	ready<=rd;
	inter_matf<=inter_mat1;
	------------PROCESS---------------
processxval:process (clk)
variable rowcnt,colcnt,i,j:integer range 0 to 5:=0;
variable row,colm:integer range 0 to 5  :=0;
variable temp :double_data_value :=(others=>'0');
variable x1:std_logic:='0';
variable temp_sum: double_data_value;
variable count:integer :=0;
variable yrw: integer range 0 to 4:=4;
variable gof: integer range 0 to 1 :=0;
--variable inter_mat1:con1;

begin
if( rising_edge(clk) ) then

--ready<=rd;
	if2:
	if (reset ='1')then
			rd<='1' ;
			dn<='0';
			--end if;
	elsif ( dn='1')then
				dn<='0';
				rd<='1';
				st<=0;
	elsif(start='1' and dn='0')then
			if( rd = '1' ) then
				rd<='0';
				x1:='1';
				dn<='0';
				for z in 4 downto 0 loop
					x_val1(z)<=x_val(z);
				end loop;
			
			--end if; 
			end if;
			end if;
	if (x1='1') then
				--dn<='0';
			if (i < 5 and j < 5) then
				x_1<= x_val1(j);
				const_mat<=A_val(i,j);
				i1<=i;
				j1<=j;
				st<=1;	
					nx<='1';				
				j:=j+1;
				end if;
			if (j=5) then 
				i:=i+1;
				j:=0;
				count:=1;
				end if;
			if (i=5) then
				i:=0;
				j:=0;
				gof:=1;
				x1:='1';
				end if;
				
				end if;
	if(nx='1')then
				--st<=0;
		temp:=temp+inter_mat1;
			colm:=colm+1;
					if (colm=5)then
					y_val(yrw)<=temp;
						yrw:=yrw-1;
						colm:=0;
						row:=row+1;
				temp:=(others=>'0');
	          --end if;
					elsif (row=5) then
							dn<='1';
							x1:='0';
							--rd<='1';
							row:=0;
							yrw:=4;
							gof:=0;
							nx<='0';
						colm:=0;
						st<=0;
						temp:=(others=>'0');
							end if;
			
	end if;
end if;

end process;
end behavioral;

