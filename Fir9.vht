LIBRARY ieee;                                               
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Fir9_tb IS
    generic (
        nbits   :   integer := 16
        );
end Fir9_tb;

architecture Fir9_arch OF Fir9_tb IS

    signal D        : signed(nbits - 1 downto 0) := (others => '0');
    signal Mclk     : std_logic := '0';
    signal n_rst    : std_logic := '1';
    signal Q        : signed(nbits - 1 downto 0);
    signal Sclk     : std_logic := '0';

    constant stime	: time := 100 ns;
    constant mtime  : time := 10 ns;

component Fir9
	PORT (
	D      : in signed(nbits - 1 downto 0);
	Mclk   : in std_logic;
	n_rst  : in std_logic;
	Q      : out signed(nbits - 1 downto 0);
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
	
	file stim_file: text open read_mode is "stim_in.txt";
	variable current_line: line;
	variable input: integer;
	 
	begin                                                         
        
        while not endfile(stim_file) loop
            readline(stim_file,current_line);
            read(current_line, input);
            D <= (to_signed(input,nbits));
            wait until rising_edge(Sclk);
        end loop;
        
        file_close(stim_file);
        D <= (others => '0');
    wait;
end process Signal_gen;

Capture_Out : process
    file capture: text open write_mode is "output.txt";
    variable current_line : line;
    variable output: integer;
begin
    output := (to_integer(Q));
    write(current_line,output);
    writeline(capture,current_line);
    wait until falling_edge(Sclk);

end process Capture_Out;
end Fir9_arch;
