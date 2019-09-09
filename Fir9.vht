LIBRARY ieee;                                               
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;                                

entity Fir9_tb IS
end Fir9_tb;

architecture Fir9_arch OF Fir9_tb IS

    signal D        : signed(15 downto 0) := (others => '0');
    signal Mclk     : std_logic := '0';
    signal n_rst    : std_logic := '1';
    signal Q        : signed(15 downto 0);
    signal Sclk     : std_logic := '0';

    constant stime	: time := 100 ns;
    constant mtime  : time := 10 ns;

component Fir9
	PORT (
	D      : in signed(15 downto 0);
	Mclk   : in std_logic;
	n_rst  : in std_logic;
	Q      : out signed(15 downto 0);
	Sclk   : in std_logic
	);
end component;

begin
	uut1 : Fir9 port map (
       
        D      => D,
        Mclk   => Mclk,
        n_rst  => n_rst,
        Q      => Q,
        Sclk   => Sclk
        );
                                          
Mclock : process
    begin
        Mclk <= not Mclk; wait for mtime;
end process Mclock; 

Sclock : process
    begin
        Sclk <= not Sclk; wait for stime;
end process Sclock; 

Signal_gen : process                                              

	-- TO DO implement signal generator
	type input_array is array (0 to 11) of integer;
	Constant in_D  : input_array := (0,12629,22134,26163,15408,3286,-9650,-20199,-25750,-24931,-17945,-6519);
    variable D_tmp : signed(15 downto 0);
	 
	begin                                                         
        for X in 0 to 10 loop
			for I in 0 to 11 loop
				wait for stime;
				D_tmp := (to_signed(in_D(I),16));
				D <= D_tmp;
				wait for stime;
			end loop;
		end loop;
        
    wait;
end process Signal_gen;   
    -- TO DO Write output to csv file                                     
end Fir9_arch;
