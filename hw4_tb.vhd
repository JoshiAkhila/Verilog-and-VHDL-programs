// Designed by AKHILA JOSHI

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Math_Real.all;
use IEEE.Numeric_Std.all;
use IEEE.Std_Logic_Textio.all;
use STD.textio.all;
use STD.env.all;

entity hw4_tb is end hw4_tb;

architecture tb of hw4_tb is
	-- These are here for your reference and as an example.
	-- I will not test your submissions with any other values
	-- of MATRIX_SIZE and DATA_WIDTH.
	constant MATRIX_SIZE : integer := 5;
	constant DATA_WIDTH : integer := 32;
	constant NUM_RANDOM_TESTS : integer := 5;

	-- Individual components of x and y
	subtype data_value is signed(DATA_WIDTH-1 downto 0);
	type data_value_vector is array(integer range MATRIX_SIZE-1 downto 0) of data_value;
	signal x_vals, y_vals, x_inputs: data_value_vector;

	shared variable error_count : integer := 0;  -- Count of errors across all tests
	signal prev_done : std_logic := '0';  -- Previous values for DUT signals
	signal prev_start : std_logic := '0';
	signal prev_ready : std_logic := '0';

	-- DUT input and output
	signal x, y : signed(MATRIX_SIZE*DATA_WIDTH-1 downto 0);
	signal clk : std_logic := '0';
	signal start : std_logic := '0';
	signal reset : std_logic := '1';
	signal done, ready : std_logic;

	-- DUT
	component hw4 is
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
	procedure verify_results (signal x_vals, y_vals : in data_value_vector; variable error_count : inout integer) is
		subtype double_data_value is signed(2*DATA_WIDTH-1 downto 0);
		variable expected : double_data_value;
		variable display : line;
	begin
		for r in MATRIX_SIZE-1 downto 0 loop
			-- Compute the analytical expected value
			expected := (others => '0');
			for c in MATRIX_SIZE-1 downto 0 loop
				expected := expected + to_signed((-1)**(r+c)*(r+1)*(c+1),DATA_WIDTH) * x_vals(c);
			end loop;

			if( y_vals(r) /= expected(DATA_WIDTH-1 downto 0) ) then
				error_count := error_count + 1;
				write(display, "[T=" & time'image(now) & "] Incorrect result for y(" & integer'image(r) & "). Expected ");
				write(display, std_logic_vector(expected(DATA_WIDTH-1 downto 0)));
				write(display, " and got ");
				write(display, std_logic_vector(y_vals(r)));
				write(display, ".");
				writeline(output, display);
			end if;
		end loop;
		return;
	end procedure;

	-- Trigger start signal and wait for results to complete
	procedure run_test(signal clk, done, ready: in std_logic; signal start: inout std_logic) is
	begin
		start <= '1';
		wait until falling_edge(clk);
		start <= '0';
		if( done /= '1') then
			wait until (done = '1');
		end if;
		if( ready /= '1' ) then
			wait until (ready = '1');
		end if;
		wait until falling_edge(clk);
	end procedure;

	--------------------------------
	-- Start of testbench body
	--------------------------------
begin
	-- Instantiate the DUT
	uut: hw4 generic map(MATRIX_SIZE=>MATRIX_SIZE, DATA_WIDTH=>DATA_WIDTH) port map (x=>x, y=>y, clk=>clk, start=>start, ready=>ready, done=>done, reset=>reset);

	--------------------------------
	-- Start of input generation block
	--------------------------------
	process
		-- Random number generator state
		variable seed1, seed2 : positive;
	begin
		set_all_x(x_vals, (others => '1'));

		-- Reset DUT
		for i in 1 to 4 loop
			wait until falling_edge(clk);
		end loop;
		reset <= '0';

		-- Setup first test
		set_all_x(x_vals, (others => '0'));
		if ( ready /= '1' ) then
			wait until (ready = '1');
		end if;
		set_all_x(x_vals, (others => '1'));
		wait until falling_edge(clk);

		-- Check A*0 = 0
		set_all_x(x_vals, (others => '0'));
		write(output, "[T=" & time'image(now) & "] Running A*0 = 0 tests." & LF);
		run_test(clk, done, ready, start);

		-- Verify each matrix entry
		for i in MATRIX_SIZE-1 downto 0 loop
			set_all_x(x_vals, (others => '0'));
			x_vals(i) <= to_signed(1,DATA_WIDTH);
			write(output, "[T=" & time'image(now) & "] Running matrix coefficient y(" & integer'image(i) & ") tests." & LF);
			run_test(clk, done, ready, start);
		end loop;

		-- Check that the system can remain idle between operations
		for i in 1 to 4 loop
			wait until falling_edge(clk);
		end loop;

		-- Check vector of all 1's
		set_all_x(x_vals, to_signed(1,DATA_WIDTH));
		write(output, "[T=" & time'image(now) & "] Running all-1 input tests." & LF);
		run_test(clk, done, ready, start);

		-- Check random inputs
		for i in 1 to NUM_RANDOM_TESTS loop
			set_random_x(x_vals, seed1, seed2);
			write(output, "[T=" & time'image(now) & "] Running random input test " & integer'image(i) & "." & LF);
			run_test(clk, done, ready, start);
		end loop;

		-- Check that the input values can change mid-operation
		set_random_x(x_vals, seed1, seed2);
		write(output, "[T=" & time'image(now) & "] Running changing input test." & LF);
		start <= '1';
		wait until falling_edge(clk);
		start <= '0';
		for i in 1 to 3 loop
			wait until falling_edge(clk);
		end loop;
		set_all_x(x_vals, (others => '0'));
		if( done /= '1') then
			wait until (done = '1');
		end if;
		if( ready /= '1' ) then
			wait until (ready = '1');
		end if;
		wait until falling_edge(clk);

		for i in 1 to 5 loop
			wait until falling_edge(clk);
		end loop;
		finish(0);
	end process;

	--------------------------------
	-- Output verification block
	--------------------------------
	process (clk) is begin
		if( rising_edge(clk) ) then
			if( start = '1' ) then
				x_inputs <= x_vals;
			end if;
		end if;
	end process;
	process is begin
		if( done /= '1' ) then
			wait until (done = '1');
		end if;
		wait until falling_edge(clk);
		verify_results(x_inputs, y_vals, error_count);
		wait until (done = '0');
	end process;

	--------------------------------
	-- Check that done signal is high for only one cycle
	--------------------------------
	process (clk) is begin
		if (falling_edge(clk)) then
			if( done = '1' and prev_done = '1' ) then
				error_count := error_count + 1;
				write(output, "[T=" & time'image(now) & "] done signal held asserted for multiple clock cycles." & LF);
			end if;
			prev_done <= done;
		end if;
	end process;

	--------------------------------
	-- Check that ready goes low one cycle after start is asserted
	--------------------------------
	process (clk) is begin
		if( rising_edge(clk) ) then
			prev_start <= start;
		end if;
	end process;
	process (clk) is begin
		if( falling_edge(clk) ) then
			if( prev_start = '1' and ready = '1' ) then
				error_count := error_count + 1;
				write(output, "[T=" & time'image(now) & "] ready signal held asserted after start asserted." & LF);
			end if;
			prev_ready <= ready;
		end if;
	end process;

	--------------------------------
	-- Check that ready goes low only after start is asserted
	--------------------------------
	process (clk) is begin
		if( falling_edge(clk) ) then
			if( prev_ready = '1' and ready = '0' and prev_start = '0' ) then
				error_count := error_count + 1;
				write(output, "[T=" & time'image(now) & "] ready signal deasserted without start being asserted." & LF);
			end if;
		end if;
	end process;

	-- Generate the clock
	clk <= not clk after 5 ns;

	-- Associate x to x_vals and y to y_vals
	packing_loop:
	for i in MATRIX_SIZE-1 downto 0 generate
		x((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH) <= x_vals(i);
		y_vals(i) <= y((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH);
	end generate;

end tb;
