-- Designed by AKHILA JOSHI

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Math_Real.all;
use IEEE.Numeric_Std.all;
use IEEE.Std_Logic_Textio.all;
use STD.textio.all;
use STD.env.all;

entity hw3_tb is end hw3_tb;

architecture tb of hw3_tb is
	-- These are here for your reference and as an example.
	-- I will not test your submissions with any other values
	-- of MATRIX_SIZE and DATA_WIDTH.
	constant MATRIX_SIZE : integer := 5;
	constant DATA_WIDTH : integer := 32;
	constant NUM_RANDOM_TESTS : integer := 5;

	-- Individual components of x and y
	subtype data_value is signed(DATA_WIDTH-1 downto 0);
	type data_value_vector is array(integer range MATRIX_SIZE-1 downto 0) of data_value;
	signal x_vals, y_vals: data_value_vector;

	-- Count of errors for each test case
	signal error_count : integer;

	-- DUT input and output
	signal x, y : signed(MATRIX_SIZE*DATA_WIDTH-1 downto 0);

	-- DUT
	component hw3 is
		generic (DATA_WIDTH : integer :=32; MATRIX_SIZE : integer :=5);
		port (
			x: in signed(MATRIX_SIZE*DATA_WIDTH-1 downto 0);
			y: out signed(MATRIX_SIZE*DATA_WIDTH-1 downto 0)
		);
	end component;

	-------------------------
	-- Procedures
	-------------------------
	
	-- Set all x_vals to the given value val
	procedure set_all_x( signal x_vals: out data_value_vector; constant val: in data_value ) is
	begin
		for i in MATRIX_SIZE-1 downto 0 loop
			x_vals(i) <= val;
		end loop;
	end procedure;

	-- Set all x_vals to a random value
	procedure set_random_x( signal x_vals: out data_value_vector; variable seed1, seed2: inout positive ) is
		variable rand : real;
	begin
		for i in MATRIX_SIZE-1 downto 0 loop
			uniform(seed1, seed2, rand);
			-- Note that the random numbers are limited to integer'length bits due to required integer cast
			x_vals(i) <= to_signed(integer(rand * (real(2) ** real(DATA_WIDTH) - 1.0)), DATA_WIDTH);
		end loop;
	end procedure;

	-- Verify the matrix multiplication results against the analytical result
	procedure verify_results (signal x_vals, y_vals : in data_value_vector; signal error_count : inout integer) is
		subtype double_data_value is signed(2*DATA_WIDTH-1 downto 0);
		variable expected : double_data_value;
		variable display : line;
	begin
		wait for 5 ns;
		for r in MATRIX_SIZE-1 downto 0 loop
		
			-- Compute the analytical expected value
			expected := (others => '0');
			for c in MATRIX_SIZE-1 downto 0 loop
				expected := expected + to_signed((-1)**(r+c)*(r+1)*(c+1),DATA_WIDTH) * x_vals(c);
			end loop;

			if( y_vals(r) /= expected(DATA_WIDTH-1 downto 0) ) then
				error_count <= error_count + 1;
				write(display, "[T=" & time'image(now) & "] Incorrect result for y(" & integer'image(r) & "). Expected ");
				write(display, std_logic_vector(expected));
				write(display, " and got ");
				write(display, std_logic_vector(y_vals(r)));
				write(display, ".");
				writeline(output, display);
			end if;
			wait for 5 ns;
		end loop;
		return;
	end procedure;

	--------------------------------
	-- Start of testbench body
	--------------------------------
begin
	-- Instantiate the DUT
	uut: hw3 generic map(MATRIX_SIZE=>MATRIX_SIZE, DATA_WIDTH=>DATA_WIDTH) port map (x=>x, y=>y);

	-- Input stimulus and output checking steps
	process
		-- Random number generator state
		variable seed1, seed2 : positive;
	begin
		-- Check A*0 = 0
		error_count <= 0;
		set_all_x(x_vals, (others => '0'));
		verify_results(x_vals, y_vals, error_count);
		write(output,"[T=" & time'image(now) & "] " & integer'image(error_count) & " total errors checking A*0 != 0." & LF);

		-- Verify each matrix entry
		error_count <= 0;
		for i in MATRIX_SIZE-1 downto 0 loop
			set_all_x(x_vals, (others => '0'));
			x_vals(i) <= to_signed(1,DATA_WIDTH);
			verify_results(x_vals, y_vals, error_count);
		end loop;
		write(output,"[T=" & time'image(now) & "] " & integer'image(error_count) & " total errors checking matrix coefficients." & LF);

		-- Check vector of all 1's
		error_count <= 0;
		set_all_x(x_vals, to_signed(1,DATA_WIDTH));
		verify_results(x_vals, y_vals, error_count);
		write(output,"[T=" & time'image(now) & "] " & integer'image(error_count) & " total errors checking all-1 inputs." & LF);

		-- Check random inputs
		for i in NUM_RANDOM_TESTS-1 downto 0 loop
			error_count <= 0;
			set_random_x(x_vals, seed1, seed2);
			verify_results(x_vals, y_vals, error_count);
			write(output,"[T=" & time'image(now) & "] " & integer'image(error_count) & " total errors for random input test " & integer'image(i) & "." & LF);
		end loop;

		wait for 5 ns;
		finish(0);
	end process;

	-- Associate x to x_vals and y to y_vals
	packing_loop:
	for i in MATRIX_SIZE-1 downto 0 generate
		x((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH) <= x_vals(i);
		y_vals(i) <= y((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH);
	end generate;

end tb;
