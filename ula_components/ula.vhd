library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_package.all;

entity ula is
    port (
        A:                  in std_logic_vector(31 downto 0);
        B:                  in std_logic_vector(31 downto 0);
        ula_op:             in ULA_OPERATION;
		  shift_amount:		 in std_logic_vector(4 downto 0);
        ula_out:            out std_logic_vector(31 downto 0);
        zero:               out std_logic;
        overflow:           out std_logic
    );
end entity;

architecture ula_architeture of ula is
    signal resultado32 : std_logic_vector(31 downto 0);
    signal tmp : std_logic_vector(31 downto 0);
    signal overflow_temp : std_logic_vector(31 downto 0);
begin
    ula_out <= resultado32; 
    tmp <= std_logic_vector(signed(A) - signed(B));
    init: process (A, B, ULA_OP, resultado32, tmp, overflow_temp, shift_amount)
    begin
        overflow <= '0';
        if (resultado32 = X"00000000") then zero <= '1'; else zero <= '0'; end if;
        
        case ULA_OP is
            when ADD    => resultado32 <= std_logic_vector(unsigned(A) + unsigned(B)); overflow <= (A(31) xnor B(31)) and (A(31) xor resultado32(31));
            when ADDU   => resultado32 <= std_logic_vector(unsigned(A) + unsigned(B));
            when SUB    => resultado32 <= tmp; overflow <=  (B(31) and resultado32(31));
            when SUBU   => resultado32 <= tmp;
            when AND_OP => resultado32 <= A and B;
            when OR_OP  =>  resultado32 <= A or B;
            when XOR_OP => resultado32 <= A xor B;
            when NOR_OP => resultado32 <= A nor B;
            when SLT    => resultado32 <= (0 => tmp(31), others => '0');
            when SLTU   =>
					if (unsigned(A) < unsigned(B))
						then resultado32 <= x"00000001";
						else resultado32 <= x"00000000";
					end if;
            when SLL_OP => resultado32 <= std_logic_vector(unsigned(B) sll to_integer(unsigned(shift_amount)));   
            when SRL_OP => resultado32 <= std_logic_vector(unsigned(B) srl to_integer(unsigned(shift_amount)));
            when RTL    => resultado32 <= std_logic_vector(unsigned(B) rol to_integer(unsigned(A)));
            when RTR    => resultado32 <= std_logic_vector(unsigned(B) ror to_integer(unsigned(A)));
            when SRA_OP => resultado32 <= to_stdlogicvector(to_bitvector(B) sra to_integer(unsigned(shift_amount)));
            when LUI    => resultado32 <= std_logic_vector(unsigned(B) sll 16);
            when others => resultado32 <= (others => '0');
        end case;           
    end process;

end architecture; 
