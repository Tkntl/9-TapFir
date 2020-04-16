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
        rst_n   :   in std_logic;
        D       :   in signed((nbits-1) downto 0);
        Q       :   out signed((nbits-1) downto 0)
        );

end Fir9;

architecture rtl of Fir9 is

    type fifo is array (0 to FirL-1) of signed(nbits -1 downto 0);
    signal infifo: fifo;
    signal fifoFull     : std_logic;
    signal FirOut	: signed(nbits - 1 downto 0);
begin
    
  FifoIn: process(Sclk)

    variable fifoCntr : integer range 0 to FirL;
    
    begin
    if rst_n = '0' then
        fifoFull <= '0';
        fifoCntr := 0;
        
    elsif falling_edge(Sclk) then
        infifo <= D & infifo(0 to FirL - 2);
        if fifoCntr = FirL - 1 then
            fifoFull <= '1';
        else
            fifoCntr := fifoCntr + 1;
        end if;
    end if;                     
end process FifoIn;

Fir: process(Mclk)

	 type coeff_array is array (0 to FirL-1) of integer;
	 Constant Coeff : coeff_array := (1024,3111,5148,6628,7168,6628,5148,3108,1024);
	 
	 type fsm_flow is (IDLE,CONV,FINISH); 
	 variable fir_fsm : fsm_flow;
	 
	 variable fir_calc		: signed(nbits - 1 downto 0);
	 variable En 			: std_ulogic;
	 
	begin
    if rst_n = '0' then
        En := '0';
        fir_calc := (others => '0');
        firOut <= (others => '0');
        fir_fsm := IDLE;
    elsif rising_edge(Mclk) then
		Case fir_fsm is
			WHEN IDLE =>
				if Sclk = '1' and En = '0' and fifoFull = '1' then
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
    if rst_n = '0' then
        Q <= (others => '0');
    elsif rising_edge(Sclk) then
        Q <= FirOut;
    end if;
end process;
end rtl;
