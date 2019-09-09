library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Fir9_pkg is

    function FirMult(op_l, op_r:signed) return signed;
end;

package body Fir9_pkg is
    function FirMult(op_l, op_r:signed) return signed is
    
    variable tmp : signed(2*op_l'left+1 downto 0);

    begin
        tmp := op_l * op_r;
        return tmp(2*op_l'left downto op_l'left);
    end;
end;
