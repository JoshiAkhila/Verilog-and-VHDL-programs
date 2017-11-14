-- Designed by AKHILA JOSHI


library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Math_Real.all;
use IEEE.Numeric_Std.all;
use IEEE.Std_Logic_Textio.all;
library STD;
use STD.textio.all;
use STD.env.all;

entity hw5_tb is end hw5_tb;

architecture tb of hw5_tb is
	-- These are here for your reference and as an example.
	-- I will not test your submissions with any other values
	-- of MATRIX_SIZE and DATA_WIDTH.
	constant MATRIX_SIZE : integer := 5;
	constant DATA_WIDTH : integer := 32;
	constant TIMING_START_TEST : integer := 10;

	-- New types
	subtype data_value is signed(DATA_WIDTH-1 downto 0);
	type data_value_vector is array(integer range MATRIX_SIZE-1 downto 0) of data_value;
	subtype io_value is signed(MATRIX_SIZE*DATA_WIDTH-1 downto 0);

	-- DUT input and output
	signal x, y : io_value := (others => '0');
	signal clk : std_logic := '0';
	signal start : std_logic := '0';
	signal reset : std_logic := '1';
	signal done, ready : std_logic;

	-- Testbench counters and state
	shared variable error_count : integer := 0;  -- Count of errors across all tests
	signal prev_done : std_logic := '0';  -- Previous values for DUT signals
	signal prev_start : std_logic := '0';
	signal prev_ready : std_logic := '0';
	signal measure_timing : std_logic := '0';
	signal first_measurement : std_logic := '1';
	signal measurement_count : integer := 0;
	signal sum_clock_counts : integer := 0;
	signal clock_count : integer := 0;
	signal num_start, num_done : integer := 0;

	-- Stimulus and result values
	file stimulus_file : text open read_mode is "stimulus.dat";
	file results_file : text open read_mode is "results.dat";

	-- DUT
	component hw5 is
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
	
	-- Trigger start signal to capture inputs
	procedure start_test(signal clk : in std_logic; signal start : inout std_logic) is
	begin
		start <= '1';
		wait until falling_edge(clk);
		start <= '0';
	end procedure;

	-- Wait for next available input opportunity
	procedure end_test(signal clk,ready : in std_logic) is
	begin
		if( ready /= '1' ) then
			wait until (ready = '1');
		end if;
		wait until falling_edge(clk);
	end procedure;

	procedure run_test(signal clk,ready : in std_logic; signal start : inout std_logic) is
	begin
		start_test(clk, start);
		end_test(clk, ready);
	end procedure;

	-- Verify the matrix multiplication results against the analytical result
	procedure verify_results (variable result_num : in integer; signal y : in io_value; variable expected : in io_value; variable error_count : inout integer) is
		variable display : line;
	begin
		if( y /= expected ) then
			error_count := error_count + 1;
			write(display, "[T=" & time'image(now) & "] ERROR: Incorrect result for test " & integer'image(result_num) & "." & LF & HT & "Expected:");
			write(display, std_logic_vector(expected));
			write(display, LF & HT & "Received:");
			write(display, std_logic_vector(y));
			write(display, ".");
			writeline(output, display);
		end if;
		return;
	end procedure;

begin
	-- Instantiate the DUT
	uut: hw5 generic map(MATRIX_SIZE=>MATRIX_SIZE, DATA_WIDTH=>DATA_WIDTH) port map (x=>x, y=>y, clk=>clk, start=>start, ready=>ready, done=>done, reset=>reset);

	--------------------------------
	-- Setup and stimulus generation block
	--------------------------------
	process
		-- Random number generator state
		variable seed1, seed2 : positive;
		variable data_line : line;
		variable data_value : std_logic_vector(MATRIX_SIZE*DATA_WIDTH-1 downto 0);
		variable stim_num : integer := 1; -- Track which input test
	begin
		-- Reset DUT
		for i in 1 to 4 loop
			wait until falling_edge(clk);
		end loop;
		reset <= '0';

		-- Setup first test
		end_test(clk, ready);

		-- Proceed through stimulus cases until all are processed
		while not endfile(stimulus_file) loop
			readline(stimulus_file, data_line);
			-- Skip comment lines
			while ( data_line(1) = '/' ) loop
				readline(stimulus_file, data_line);
			end loop;

			hread(data_line, data_value);
			x <= signed(data_value);
			write(output, "[T=" & time'image(now) & "] INFO: Running test number " & integer'image(stim_num) & "." & LF);

			-- Check that the input values can change mid-operation
			if( stim_num = 7 ) then
				write(output, "[T=" & time'image(now) & "] INFO: Input changing mid-operation test started." & LF);
				start_test(clk, start);
				wait until falling_edge(clk);
				x <= not x;
				end_test(clk, ready);
			else
				run_test(clk, ready, start);
			end if;

			-- Check that the system can remain idle between operations
			if( stim_num = 5 ) then
				write(output, "[T=" & time'image(now) & "] INFO: System held idle for several clock cycles test started." & LF);
				for i in 1 to 6 loop
					wait until falling_edge(clk);
				end loop;
			end if;
			stim_num := stim_num + 1;
		end loop;
	end process;

	--------------------------------
	-- Output verification block
	--------------------------------
	process
		variable result_line : line;
		variable expected : io_value;
		variable data_value : std_logic_vector(MATRIX_SIZE*DATA_WIDTH-1 downto 0);
		variable result_num : integer := 1; -- Track which verification test
	begin
		-- Wait for reset to complete
		if( reset /= '0' ) then
			wait until (reset = '0');
		end if;

		-- Proceed through test cases and check module outputs
		while not endfile(results_file) loop
			if( done /= '1' ) then
				wait until (done = '1');
			end if;
			wait until falling_edge(clk);
			readline(results_file, result_line);
			-- Skip comment lines
			while (result_line(1) = '/' ) loop
				readline(results_file, result_line);
			end loop;

			hread(result_line, data_value);
			expected := signed(data_value);
			verify_results(result_num, y, expected, error_count);
			if( done /= '0' ) then
				wait until (done = '0');
			end if;
			result_num := result_num + 1;
			
			-- Start timing measurements on the indicated test
			if( result_num >= TIMING_START_TEST ) then
				measure_timing <= '1';
			end if;
		end loop;

		for i in 1 to 30 loop
			wait until falling_edge(clk);
		end loop;

		-- Check that the number of requests match the number of results
		if( num_done /= num_start ) then
			write(output, "[T=" & time'image(now) & "] ERROR: A different number of operations was started than completed. " & integer'image(num_start) & " operations started and " & integer'image(num_done) & " completed." & LF);
			error_count := error_count + 1;
		end if;

		-- Final summary messages
		write(output, "[T=" & time'image(now) & "] SUMMARY: Simulation finished with " & integer'image(error_count) & " total errors." & LF);
		write(output, "SUMMARY: Average clock cycles per operation equals " & real'image(real(sum_clock_counts) / real(measurement_count)) & "." & LF);
		finish(0);
	end process;

	--------------------------------
	-- Timing measurement block
	--------------------------------
	process(clk) is begin
		if( falling_edge(clk) ) then
			if( (measure_timing = '1') and (done = '1') ) then
				if( first_measurement = '1' ) then
					first_measurement <= '0';
				else
					measurement_count <= measurement_count + 1;
					sum_clock_counts <= sum_clock_counts + clock_count + 1;
				end if;
				clock_count <= 0;
			else
				clock_count <= clock_count + 1;
			end if;
		end if;
	end process;

	--------------------------------
	-- Check that done signal is high for only one cycle
	--------------------------------
	process (clk) is begin
		if (falling_edge(clk)) then
			if( done = '1' and prev_done = '1' ) then
				error_count := error_count + 1;
				write(output, "[T=" & time'image(now) & "] ERROR: done signal held asserted for multiple clock cycles." & LF);
			end if;
		end if;
	end process;

	--------------------------------
	-- Check that ready goes low one cycle after start is asserted
	--------------------------------
	process (clk) is begin
		if( falling_edge(clk) ) then
			if( prev_start = '1' and ready = '1' ) then
				error_count := error_count + 1;
				write(output, "[T=" & time'image(now) & "] ERROR: ready signal held asserted after start asserted." & LF);
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
				write(output, "[T=" & time'image(now) & "] ERROR: ready signal deasserted without start being asserted." & LF);
			end if;
		end if;
	end process;

	--------------------------------
	-- Keep track of how many start and done signals have occured
	--------------------------------
	process (clk) is begin
		if( rising_edge(clk) ) then
			prev_start <= start;
			if( (start = '1') and (prev_start = '0') ) then
				num_start <= num_start + 1;
			end if;
		elsif( falling_edge(clk) ) then
			prev_done <= done;
			if( (done = '1') and (prev_done = '0') ) then
				num_done <= num_done + 1;
			end if;
		end if;
	end process;

	-- Generate the clock
	clk <= not clk after 5 ns;

end tb;
