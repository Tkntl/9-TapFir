LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.Fir9_pkg.all;

entity Fir9 is

    generic (
        nbits   :   integer := 16;
        FirL    :   integer := 9
        );

    port (
        Mclk    :   in std_logic;
        Sclk    :   in std_logic;
        n_rst   :   in std_logic;
        D       :   in signed((nbits-1) downto 0);
        Q       :   out signed((nbits-1) downto 0)
        );

end Fir9;

architecture rtl of Fir9 is

    type fifo is array (0 to FirL-1) of signed(nbits -1 downto 0);
    signal infifo: fifo := (others => (others => '0'));
    signal FirOut	: signed(nbits - 1 downto 0) := (others => '0');
begin
    
FifoIn: process(Sclk)
    begin
    
    if falling_edge(Sclk) then
        infifo <= D & infifo(0 to FirL - 2);
        end if;
    end process FifoIn;

Fir: process(Mclk)

	 type coeff_array is array (0 to FirL-1) of integer;
	 Constant Coeff : coeff_array := (1024,3111,5148,6628,7168,6628,5148,3108,1024);
	 
	 type fsm_flow is (IDLE,CONV,FINISH); 
	 variable fir_fsm : fsm_flow := IDLE;
	 
	 variable fir_calc		: signed(nbits - 1 downto 0):=(others => '0');
	 variable En 			: std_ulogic := '0';
	 
	begin
		
    if rising_edge(Mclk) then
		Case fir_fsm is
			WHEN IDLE =>
				if Sclk = '1' And En = '0' then
					En := '1';
					fir_fsm := CONV;
				elsif Sclk = '0' then
					En := '0';
				end if;
			WHEN CONV =>
				FOR I in 0 to FirL-1 loop
					fir_calc := fir_calc + FirMult(infifo(I), to_signed(Coeff(I),nbits));
					end loop;
					fir_fsm := FINISH;
			WHEN FINISH =>
				FirOut <= fir_calc;
				fir_calc := (others => '0');
				fir_fsm := IDLE;
				WHEN OTHERS => NULL;
		END CASE;
	end if;
end process Fir;					
    
FifoOut: process(Sclk)
    begin
    
    if rising_edge(Sclk) then
        Q <= FirOut;
		end if;
end process;
end rtl;
 
