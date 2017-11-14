-- Designed by AKHILA JOSHI

library IEEE;
use IEEE.Numeric_Std.all;

entity multiplier is
	generic(DATA_WIDTH : integer :=32);
	port(
		a, b : in signed(DATA_WIDTH-1 downto 0);
		p : out signed(2*DATA_WIDTH-1 downto 0)
	);
end multiplier;

architecture behavioral of multiplier is
begin
	p <= a * b;
end behavioral;
