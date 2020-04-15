library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Fir9_pkg is

    function FirMult(op_l, op_r:signed) return signed;
end;

package body Fir9_pkg is
    function FirMult(op_l, op_r:signed) return signed is
    
    variable product : signed(op_l'left + op_r'left + 1 downto 0);

    begin
        product := op_l * op_r;
        return product(op_l'left + op_r'left downto op_r'left);
    end;
end;
